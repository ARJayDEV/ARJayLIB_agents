/*
   working notes (takistan)
   **************   
   
   works pretty good actually, after some bugs are finally dealt with... :)
   

   working notes (chernarus)
   **************
   
     >>> hardship case: Pusta - Prigorodki (ess. routes with neg. ps)  
         > maxDistMul needs to be higher than 5(!) here to reach it!
         > while we had PI working very fine for almost everything..
         
         >> maybe recalculate maxDistance if first roads have almost
            no section performance?!

     >>> improve conditional lookahead (that's pretty ugly for now and
         not that great (performance/time-saving) either) 
         
     >>> maybe fix/decrease number of waypoints with `no lookahead`..
         lookahead features this already as a nice side-effect, by
         merging small sections into a longer lookahead-section
         
         >> test and finally drive in a convoy by myself, damit! :D


   bug report
   **************
      
   BY roadsConnectedTo UNDETECTED JUNCTIONS/CROSSROADS
   
    - Chernarus 095081 [Guglovo-Dolina, Shakhovka-Gorka]
    - Chernarus 070108 [Chernogorsk-Moglievka]
    - Chernarus 075094 [Moglievka-Guglovo, Moglievka-Novy Sobor]
    - Chernarus 069097 [Moglievka-Vyshnoye]
    - Chernarus 125066 [Nizhnoye-Berezino]
    - Chernarus 098065 [Gorka-Polana]
    - Chernarus 058052 [Grishino-Kabanino]
    - Chernarus 059073 [Stary Sobor]
    - Chernarus 034104 [Polkovo-Drozhino]
    - Chernarus 033107 [Drozhino-Bor]
    - Chernarus 044144 [Drozhino-Balota]
    - Chernarus 123109 [Tulga-Kamyshovo]
    - Chernarus 119114 [Tulga/Msta-Kamyshovo]
    
    case studies:
    
    - "Kleiner Hügel" at 069104 can't be reached/not connected!
      -> 070108 and 069097 not connected! (broken network)
    
    - Chernarus: unconnected roads at Vybor Airport (impossible to reach)
      -> make landstrip "non-roads", connect them maybe invisible or
         implement a command isSameNetwork? [EDIT: fixed with RUBE_isRoadway filter]
      
    - Chernarus 095081 [Guglovo-Dolina, Shakhovka-Gorka]
      -> with a lookahead alogrithm, this "non-recognition" can occur
         in a crossing loop!! [EDIT: this may actually have been a BUG in RUBE_findRoute itself, DOH!]
         
        instead of      we may get a 
        right turn:     crossing loop:
            
           \/              \/
            
            |               |
        <___| . .       <___|__
            .               |  \
            .               |   |      <- lol wtf! :D
                            \___/
                            
                      ... and now send a 8-truck convoy along this
                         route. hahaha
      
     - Chernarus 119114 [Tulga/Msta-Kamyshovo]
       from Tulga to Kamyshovo, easy right?.. Well no, the direct
       route can't be recognized, thus you end up with no route at
       all, or a really heavy detour.. :/
      
      
  --> ROAD NETWORK CHECK/CORRECTION AT BINARIZATION/COMPILATION TIME
    -> new-command: getRoadNetworkId OR (_r1 sameRoadNetwork _r2)
       -> so we can easily check if there is no route anyway.. keep
          such algorithms running if it's not possible to complete
          isn't that much fun. ... ok, maybe the first time, to watch
          him go nuts, haha, but no.. really.
          
          And to make this command lightning fast, I guess the best
          solution would be to analyse and compile a given world
          at binarization or whenever apropriate, so every road-object
          has a network-id, thus the check is easy.
          
       -> btw. such a command would be needed for landmasses too!
       -> plus road networks and sub-islands should be defined in
           CfgWorlds >> islandName >> roadNetworks
           CfgWorlds >> islandName >> islands
          or something similar.

*/
/*
   Author:
    rübe
    
   Description:
    finds a route from A to B, using the road-network of the given
    island, where the given destinations can be either a route-object 
    or a position. Given a position, we search the nearest road to it.
    
    Keep in mind that this algorithm may take several seconds until a 
    route (or the information that no route could be found) may be 
    returned. 
    
    Second, the search for A->B is not equal to B->A and can yield 
    considerably different results.
    
    ___

    Since the road network of the map may be broken (or it may rightly 
    consist of multiple non-connected networks), we have a runtime-cap 
    based on the airline-distance of the demanded route to prematurely
    abort the search. (due to the recursive nature of the algorithm, 
    we would try out all possible routes (really all, incl. going into
    the completely wrong direction!) in the starting road network in
    reach of the maximum distance otherwise, which could take up
    minutes... oO)
    
    -> pass ["debug", true], switch on the map and you can look what
       is going on.
       
       
    Illustration:
                                       ___________. dead end
                                      / 
                                     /         __. dead end
     __[FROM]________(j1)___________/_________/___________________
                       \                       ____/
                        \_(j2)__________(j3)__/
                            \             \
                             \             \______[TO]___(j5)___
               __             \                           /
              /                \_____(j4)________________/
        _____/                         \
             \                          \____. dead end
              \______/                 

                  ^^ second non-connected
              route network can't be easily detected

                               
     - Considering start- and endingpoint junctions too, a _section_
       is defined as the road from junction to junction. (see private
       function _roadSection below)
       
     - The question is which way to go if we meet a junction. To decide
       we consider (see private function _roadRoute below):
       
       - the direction the available start-roads of the sections ahead,
         favorising those with a direction most similar to the optimal
         air-line direction to the target.
         
       - the sections outcome. We can look ahead a section and evaluate
         to possibly prematurely discard the section (taking to first 
         section that is "good enough") or we may even look ahead all 
         available sections and compare their outcome. Since
         the length of a section is arbitrary, we may rate them by the
         simple formula: airline-distance-nearer-to-end per section-
         distance, which will naturally oscillate between -1 and 1.
         (^^ this is the `section performance`)
           
     - Positions for waypoints are only generated at junctions, including
       start and endpoints:  
           
       _from               _j1              _to
           ^                 ^               ^
           | - - - - - - - - | - - - - - - - |
           
           | - - - - - - - | | - - - - - - |    (sections)
                           |-|             |-|  (section connections)
                     
           R R R R R R R R R R R R R R R R R R  (returned route in road-objects)
           ^                 ^               ^
          WP                WP              WP  (returned route in waypoints)
           

              

   Parameter(s):
    _this: parameters (array of array [key (string), value (any)])
    
           - required:
           
             - "start" (position OR road-object)
             - "end" (position OR road-object)
             
             
           - optional:
           
             - "blacklist", (array of road-objects)
               - Beware! Don't pass too many road-objects along, for the larger the
               blacklist, the slower the search. Maybe consider a "safe" middle 
               position and search two routes instead?
             
             - "lookahead", (int from 0 to 2 OR array [int, scalar])
             
               - 0: no lookahead (simple direction-test, though dead-end sections
                    will be discarded like in `discard lookahead`, thus the algorithm
                    goes back to the last junction and tries that one and so on, until
                    we're back to the first junction if still no route was successfull..
                    ... thus, this may take way too long, so a reasonable distance-cap
                    is essential here)
                    
                      -> in conclusion: very fast, prone to detours 
                    
               - 1: conditional lookahead (the first poped section may be 
                    immediately accepted or discarded, based on it's performance.
                    If the performance isn't bad but not that good either, we may
                    check and compare the next route to it. If everything fails, 
                    even already discarded routes are considered - if there's some
                    runtime left.
                    Thus there is no overhead at all in the best case and up to 
                    1/2 - 2/3 in the worst case)
                    
                      -> in conclusion: pretty fast, pretty good
                    
               - 2: strict lookahead (we strictly check all available sections
                    and follow the one with the best performance, theoretically 
                    recieving the best route possible* at the cost of a guaranteed 
                    section-tracing overhead of 1/2 - 2/3, depending on the 
                    junctions nature)
                    
                      * of course this is only true, if the lookahead distance
                        is infinite (though if the lookahead distance is infinit
                        or simply high enough to cover all routes possible, "looking
                        ahead" becomes pointless. hehehe). In short: you eventually
                        won't get the abs. best route there is. :P
                        
                      -> in conclusion: slow*, but finds the very best routes in most
                         cases
                         
                         * not that slow on long main routes. Worst case here is
                           a city like Chernogorsk with lots of small little sections
                           and junctions.
               
               -> you may pass an array where the second number is the minimal 
                  lookahead distance (since sections may be of any length).
                  -> Though you really should not increase the lookahead distance
                     too much, for there is no decision made/filter on the gathered
                     lookahead-sections.  (if there is a junction in the lookahead-
                     section, we will split, follow and rate all possible routes, 
                     thus the lookahead-pool of different routes grows exponentially
                     - okok not really, due to the nature of road networks, but 
                     still... 
                      
               -> default: 1 (or [1, 500])
             
             - "detour", (scalar from 0 to 2 OR array [detourThreshold, probabilityDecimator])
                We compare the two best available sections and take the difference
                of their section performance (from -1 to 1). If this difference is
                below the given detour threshold, we follow the second best route
                first, thus favoring detours. This way you can get pretty good
                alternative routes, and in some cases, you can't get the abs. 
                shortest route without detour.
                
                 - as a roule of thumb, try:
                   - ~0.2 for good alternative routes
                   - ~0.5 for mild detours
                   - and no (or not much) higher
                   
                 -> BEWARE: detour works only with `strict lookahead`!
                 -> you may pass an array, where the second value is a probability
                    divisor (-1 to 1) that gets applied to the starting probability of
                    100% everytime a detour-section has been taken. Thus, by setting
                    this value to 1 (default), the second best rated section is 
                    always taken. With a value of 0, a detour section is taken only
                    once. And with a value of 0.5, the probability halfs everytime 
                    after a detour section has been taken.
                    -> with a probability divisor of 1 you may get really silly routes.
                       Try keep it below 1, so the probability decreases as we're 
                       approaching the destination, thus the detour looks alot more
                       reasonable.
                    -> you may even pass a negative value to alternate! (don't worry,
                       sign and divisior are decoupled). -1 means, the first option
                       to take a detour is taken, the second not, but the third again
                       and so on...
                       
                 >> Franks pro tip #21: slightly randomise the detour-threshold and the
                    probability decimator to find slightly new routes, each time you 
                    start your mission. (of course this only works good for long routes)
                    - give [(random 0.5), (-1 + (random 2))] a try ;)
                 
               -> default: 0 (or [0,1])
              
             - "maxDistance", (scalar)
               - maximum distance at which we abort the search. BEWARE: this is 
                 NOT an absolute value in meters but a MULTIPLICATOR of the air-
                 line distance from "start" to "end".
                 
               -> default: 5 
               
             - "maxRuntime", (scalar)
               - maximum runtime in meter per second (maxruntime * airline-
                 distance = max runtime in seconds) before we abort the search. 
                 This is a base-value that will be  scaled to the selected 
                 lookahead-mode and level of randomness.
                 -> set this value reasonable for it should only catch/abort searches
                    for impossible routes (e.g. if start and end position are on 
                    different non-connected route networks.)
               - default: 0.004 (4 m/s)
               
             - "debug", (boolean)
               watch the algorithm at work:
               - blue marker lines are lookahead sections
               - red  marker lines are "decision" sections, yet they don't have
                 to be part of the final route in case this leads us to nowhere. 
                 If this is the case, another "blue one" get's picked up and thus 
                 "turns red", etc.. (Fred's pro tip #85: try to connect 
                 unconnectable destinations and watch the algorithm go totally 
                 nuts, ttiiihihihi)
               - the "no lookahead"/direction based decision prints the difference
                 of optimal to actual direction (less is better) for each 
                 junction, while lookahead section decisions each have an additional 
                 marker (mid-section), showing the performance of this route (more
                 is better).  
               -> default: false
   
   
   Example 1:
    _route = [
       ["start", _position],
       ["end", _position2]
    ] call RUBE_findRoute;
    
    // plot route (see RUBE_plotRoute)
    _markers = [
      _route,
      [
         ["id", ([] call RUBE_createID)],
         ["color", "ColorBlue"]
      ]
    ] call RUBE_plotRoute;
      
   Example 2:
    // slightly random detour
    _route = [
       ["start", _position],
       ["end", _position2],
       ["lookahead", 2],
       ["detour", [(random 0.5), (-1 + (random 2))]]
    ] call RUBE_findRoute;
    
           
   Returns:
    array [
       0: success (boolean)
       1: route, road objects (array of objects)
       2: route, waypoints (array of positions; usually at every junction)
          - you might wanna drop the first and maybe even the last waypoint,
            depending on what you're up to. You might wanna drop the first
            since some group is already there/starts there. And you might 
            wanna drop the last one (from the last road object to the given
            position - in case that's not a road object too) to ensure that
            some group stays on the road... just draw some markers and you'll
            understand.
       3: distance in m (scalar)
       4: time to calculate the route (scalar)
    ]
*/

private ["_debug", "_startTime", "_start", "_startDestination", "_end", "_endDestination", "_userBlacklist", "_blacklist", "_detourThreshold", "_detourProbability", "_detourDivisor", "_detourSign", "_lookahead", "_lookaheadDist", "_acceptThreshold", "_discardThreshold", "_airlineDist", "_maxDist", "_maxDistMul", "_maxRuntime", "_maxRuntimePerMeter"];

_debug = false;
_startTime = time;

_start = [0,0,0];           // road-object after init
_startDestination = false;  // off-road position/destination after init

_end = [0,0,0];
_endDestination = false;

_userBlacklist = [];
// internal connection blacklist we'll work on
_blacklist = [];

_detourThreshold = 0; // max. section-performance difference thresholds
_detourProbability = 100;
// we need to decouple the sign from the divisor! 
// (or else alternating best/detour route won't work)
_detourDivisor = -1;
_detourSign = 1; 

_lookahead = 2; // mode
_lookaheadDist = 500; // minimal distance of one or multiple sections to lookahead
_acceptThreshold = 0.8; // lookahead thresholds
_discardThreshold = 0.0; 

// since we blacklist any traced section (even discarded onces), we don't really have
// to deal with the halting problem... yet we don't won't to run this script for 
// minutes either... so:
_airlineDist = 0; 
_maxDist = 0;
_maxDistMul = 5;

// runtime cap in seconds per m airline distance
_maxRuntime = 0;
// 4m per second as basis (depending on lookahead method and detour mode)
// this value probably needs to be tweaked (e.g. for mp/servers)
_maxRuntimePerMeter = 0.004; 


// read parameters
{
   switch (_x select 0) do
   {
      case "debug": { _debug = _x select 1; };
      case "start": { _start = _x select 1; };
      case "end": { _end = _x select 1; };
      case "blacklist": { _userBlacklist = _x select 1; }; 
      case "lookahead":    
      { 
         if ((typeName (_x select 1)) == "ARRAY") then
         {
            _lookahead = (_x select 1) select 0;
            _lookaheadDist = (_x select 1) select 1;
         } else {
            _lookahead = _x select 1;
         };
      };
      case "detour": 
      { 
         if ((typeName (_x select 1)) == "ARRAY") then
         {
            _detourThreshold = (_x select 1) select 0;
            _detourDivisor = (_x select 1) select 1; 
         } else {
            _detourThreshold = _x select 1;
         };
      };
      case "maxDistance": { _maxDistMul = _x select 1; };
      case "maxRuntime": { _maxRuntimePerMeter = _x select 1; };
   };
} forEach _this;

if (_detourDivisor < 0) then
{
   _detourDivisor = _detourDivisor * -1;
   _detourSign = -1;
};

private ["_debugSection", "_debugJunctions", "_nearestRoad", "_dirDiff", "_roadDir", "_junctionCost", "_sectionPerformance", "_performanceDiff", "_swapBestSections", "_roadSection", "_lookaheadSections", "_roadRoute"];


// debug markers for sections
_debugSection = {
   private ["_roads", "_final", "_wps", "_text", "_color", "_size", "_m"];
   _roads = _this select 0;
   _final = _this select 1;
   _text = "";
   
   if ((count _this) > 2) then
   {
      _text = format["sp: %1", (_this select 2)];
   };
   
   _wps = [];
   
   if ((typeName _final) == "ARRAY") then
   {
      _wps = [(position (_roads select 0))] + _final;
      if ((count _roads) > 1) then
      {
         _wps = _wps + [(position (_roads select ((count _roads) - 1)))];
      };
      _final = true;
   } else {
      _wps = [
         (position (_roads select 0)),
         (position (_roads select ((count _roads) - 1)))
      ];
   };
   
   _color = "ColorBlue";
   _size = 5;
   
   if (_final) then
   {
      _color = "ColorRed";
      _size = 7;
   };
   if (_text != "") then
   {
      _m = floor ((count _roads) * 0.5);
      [
         ["position", (position (_roads select _m))],
         ["type", "mil_dot"],
         ["color", "ColorBlack"],
         ["text", _text]
      ] call RUBE_mapDrawMarker;
   };
   
   for "_i" from 1 to ((count _wps) - 1) do
   {
      ([
         ["start", (_wps select (_i - 1))],
         ["end", (_wps select _i)],
         ["color", _color],
         ["size", _size]
      ] call RUBE_mapDrawLine)
   };
};

// debug marker for junctions
_debugJunctions = {
   private ["_d", "_t"];
   _d = -1;
   _t = (count _this) - 1;
   {
      [
         ["position", (position (_x select 0))],
         ["direction", (direction (_x select 0)) - 90],
         ["type", "Move"],
         ["size", 0.4],
         ["color", "ColorRed"],
         ["text", format["J%1: %2", (_t - _d), (_x select 1)]]
      ] call RUBE_mapDrawMarker;
      _d = _d + 1;
   } forEach _this;
};



// returns the nearest road to a given position
/*
   position (2d position) OR road (object) 
   => road (object)
*/
_nearestRoad = {
   // this may already be a road object
   if ((typeName _this) == "OBJECT") exitWith
   {
      _this
   };
   
   private ["_pos", "_radius", "_roads"];
   _pos = _this call RUBE_getPosASL;
   _radius = 20;
   _roads = [];
   
   while {(count _roads) == 0} do
   {
      _roads = [
         (_pos nearRoads _radius),
         {
            // runways are not connected to the "real/big" road-network!!
            if (_this call RUBE_WORLD_isRunway) exitWith { false };
            //diag_log format["accepted: %1", _this];
            true
         }
      ] call RUBE_arrayFilter;
      
      _radius = _radius + 20; 
      
      if (_radius > 99999) exitWith 
      {
         _roads = [objNull];
      };
   };
   
   (_roads select 0)
};



// difference between two directions/angles
/*
   [angle1 (scalar), angle2 (scalar)] => angleDiff (scalar)
*/
_dirDiff = {
   private ["_diff"];
   _diff = abs (((_this select 1) % 360) - ((_this select 0) % 360));
   if (_diff > 180) then
   {
      _diff = 360 - _diff;
   };
   _diff
};

// determine which direction a road is used
/*
   [junction (road-object), direction (scalar)] => direction (scalar)
*/
_roadDir = {
   private ["_dir", "_orientation"];
   _dir = direction (_this select 0);
   _orientation = _this select 1;
   
   if (([_dir, _orientation] call _dirDiff) > 90) exitWith
   {
      (_dir - 180)
   };
   
   _dir
}; 


// simple cost based on best/nearest to optimal direction
/*
   [road (road-object prior to junction), junction (road-object), to (road-object)]
   => scalar (the smaller the better)
*/
_junctionCost = {
   private ["_road", "_junction", "_to", "_optimalDir", "_orientation", "_junctionDir"];
   _road = _this select 0;
   _junction = _this select 1;
   _to = _this select 2;
   
   _optimalDir = [_road, _to] call BIS_fnc_dirTo;
   _orientation = [_road, _junction] call BIS_fnc_dirTo;
   _junctionDir = [_junction, _orientation] call _roadDir;
   
   ([_optimalDir, _junctionDir] call _dirDiff)
};



// section performance (advancement in meter per meter section-distance)
/*
   [route (road-objects), distance (scalar), to (road-object)]
   => scalar
      - p  < 0: regression!  
      - p == 0: no advancement
      - p == 1: most effective advancement (1m per 1m)
*/
_sectionPerformance = {
   private ["_route", "_distance", "_to", "_sectionStart", "_sectionEnd", "_d0", "_d1"];
   
   _route = _this select 0;
   _distance = _this select 1;
   _to = _this select 2;
   
   if (_distance == 0) exitWith
   {
      0
   };
   
   _sectionStart = _route select 0;
   _sectionEnd = (_route select ((count _route) - 1));
   
   _d0 = _sectionStart distance _to;
   _d1 = _sectionEnd distance _to;
   
   ((_d0 - _d1) / _distance)
};

// performance difference of the best two rated sections
_performanceDiff = {
   private ["_n"];
   _n = count _this;
   (((_this select (_n - 1)) select 0) - ((_this select (_n - 2)) select 0))
};

// swaps the best sections of an array of rated/sorted sections
_swapBestSections = {
   private ["_n", "_tmp"];
   _n = count _this;
   _tmp = _this select (_n - 2);
   _this set [(_n - 2), (_this select (_n - 1))];
   _this set [(_n - 1), _tmp];
   
   _this
};


// roadSection
// simple (dumb/non-intelligent) recursive road-follower to the next 
// junction or an exit/target destination (road-object) that prematurely  
// truncates the section.
/*
   [from (road-object), to (road-object), ¦ previous (road-object) ¦ section (array), ¦ distance (scalar)] 
   => [roads (array), connections (array), distance (scalar)]
*/
_roadSection = {
   private ["_from", "_to", "_previous", "_section", "_distance", "_connections", "_n"];
   _from = _this select 0;
   _to = _this select 1;
   _previous = [];
   _section = [];
   _distance = 0;
   
   //hintSilent format["BLACKLIST SIZE: %1", (count _blacklist)];

   if ((count _this) > 4) then
   {
      _previous = [(_this select 2)];
      _section = _this select 3;
      _distance = _this select 4;
   } else {
      _blacklist set [(count _blacklist), _from]; //*** blacklist start of a section
   };
   
   // check user blacklist
   if (_from in _userBlacklist) exitWith
   {
      [_section, [], _distance]
   };
   
   if ((count _section) > 0) then
   {
      _distance = _distance + ((_section select ((count _section) - 1)) distance _from);
   };
   
   _section set [(count _section), _from];
   _connections = ((roadsConnectedTo _from) - _blacklist) - _previous;
   _n = count _connections;

   // dead end
   if (_n == 0) exitWith 
   {
      [_section, [], _distance]
   };
   
   // arrived?
   if (_to in _connections) exitWith
   {
      [_section, [_to], _distance]
   };
   
   // only one way to go? keep going..
   if (_n == 1) exitWith
   {
      ([(_connections select 0), _to, _from, _section, _distance] call _roadSection)
   };
   
   // junction -> end of a section
   _blacklist set [(count _blacklist), _from]; //*** blacklist end of a section
   [_section, _connections, _distance]
};



// retrieve all possible sections (and combinations thereof
// in case one section isn't long/representative enough) up 
// to the set lookahead distance.... and measure performance
/*
   [from (road-object), to (road-object),
    ¦ route (road-objects), ¦ waypoints (positions), ¦ distance (scalar)]
   => array of sections [section-performance, route, waypoints, distance]
*/
_lookaheadSections = {
   private ["_from", "_to", "_route", "_waypoints", "_distance", "_next", "_n"];
   _from = _this select 0;
   _to = _this select 1;
   _route = [];
   _waypoints = [];
   _distance = 0;
   
   if ((count _this) > 4) then
   {
      _route = _this select 2;
      _waypoints = _this select 3;
      _distance = _this select 4;
   };
   
   // poll next section
   _next = [_from, _to] call _roadSection;
   _n = count (_next select 1);

   
   // dead-end
   if (_n == 0) exitWith
   {
      []
   };
   
   // register section
   if ((count _route) > 0) then
   {
      // add section connection distance (not included in section distance!) 
      _distance = _distance + (((_route select ((count _route) - 1))) distance _from);
   };

   [_route, (_next select 0)] call RUBE_arrayAppend;
   
   // (this is actually no good idea; we don't need wp's for 
   // every little section there is) TODO: maybe a min. distance? parameter?
   //_waypoints = _waypoints + [(position _from)];
   
   _distance = _distance + (_next select 2);

   // section is long enough/lookahead complete
   // OR even arrived?
   if ((_distance > _lookaheadDist) || (_to in (_next select 1))) exitWith
   {
      private ["_performance"];
      _performance = [_route, _distance, _to] call _sectionPerformance;
      if (_debug) then
      {
         [_route, false, _performance] call _debugSection;
      };
      [
         [
            _performance, 
            _route, 
            _waypoints, 
            _distance
         ]
      ]
   };

   private ["_sections"];
   _sections = [];
   
   // junction/section split
   // >>make sure to copy the arrays!<<
   {
      [
         _sections, 
         ([
            _x, 
            _to, 
            (+ _route),
            (+ _waypoints),
            _distance
         ] call _lookaheadSections)
      ] call RUBE_arrayAppend;
   } forEach (_next select 1);
   
   _sections
};


// roadRoute
// recursive route finder, deciding on junctions which way
// to go...
/*
   [from (road-object), to (road-object), 
    ¦ route (array), ¦ waypoints (array) ¦ distance (scalar) 
   ] 
   => [success (boolean), route (array), waypoints (array), distance (scalar)]
*/
_roadRoute = {
   private ["_from", "_to", "_route", "_waypoints", "_distance"];
   _from = _this select 0;
   _to = _this select 1;
   _route = [];
   _waypoints = [];
   _distance = 0;
   
   if ((count _this) > 4) then
   {
      _route = _this select 2;
      _waypoints = _this select 3;
      _distance = _this select 4;
   };
   
   // arrived? (catch last call or nonsense-request)
   if (_from == _to) exitWith
   {
      [true, _route, _waypoints, _distance]
   };
   
   private ["_section", "_n", "_last", "_performance"];
   
   // _roadSection => [roads (array), connections (array), distance (scalar)]
   _section = [_from, _to] call _roadSection;
   _n = count (_section select 1);

   // dead end -> early exit (or try another junction; see below)
   // or runtime-limit
   if ((_n == 0) || ((time - _startTime) > _maxRuntime)) exitWith
   {
      [false, _route, _waypoints, _distance]
   };
   
   // register section
   if ((count _route) > 0) then
   {
      // add section connection distance (not included in section distance!)
      _distance = _distance + (((_route select ((count _route) - 1))) distance _from);
   };

   [_route, (_section select 0)] call RUBE_arrayAppend;
   _waypoints set [(count _waypoints), (position ((_section select 0) select 0))];
   _distance = _distance + (_section select 2);
   _last = (_section select 0) select ((count (_section select 0)) - 1);
   
   if (_debug && ((_section select 2) != 0)) then
   {
      _performance = [
         (_section select 0),
         (_section select 2), 
         _to
      ] call _sectionPerformance;
      
      [(_section select 0), true, _performance] call _debugSection;
   };
   
   // abort? (max dist)
   if (_distance > _maxDist) exitWith
   {
      [false, _route, _waypoints, _distance]
   };
   
   // last section? (premature exit from _roadSection!) 
   if (_to in (_section select 1)) exitWith
   {
      // last call + register final section connection (waypoint + distance)
      ([
         _to,
         _to,
         _route,
         ([_waypoints, [(position _to)]] call RUBE_arrayAppend),
         (_distance + (_last distance _to)) 
      ] call _roadRoute)
   };

   // we need to make a decision  
   /*                      
                        \
                       /
                      /  
              <---- [?] ----->
                     |
                     |
   */
   private ["_decision", "_junctions", "_j"];
   _decision = [false, _route, _waypoints, _distance];
   
   // sort available junctions if we need to depending 
   // on the decision-method
   _junctions = [];
   _j = 0;
   if (_lookahead in [2]) then
   {
      {
         _junctions set [_j, [_x, 0]];
         _j = _j + 1;
      } forEach (_section select 1);
   } else {
      // reference crossroad object prior to every junction-road-obj
      private ["_crObj"];
      _crObj = ((_section select 0) select ((count (_section select 0)) - 1));
      {
         _junctions set [_j, [_x, ([_crObj, _x, _to] call _junctionCost)]];
         _j = _j + 1;
      } forEach (_section select 1);
      // sort DESC on cost, ready to be poped
      _junctions = [_junctions, {((_this select 1) * -1)}] call RUBE_shellSort;
      
      if (_debug) then
      {
         _junctions call _debugJunctions;
      };
   };
   
   switch (_lookahead) do
   {
      // conditional lookahead (_acceptThreshold, _discardThreshold)
      case 1:
      {
         private ["_bestSection", "_compareSections", "_discardedSections", "_current", "_currentSections", "_las"];
         _bestSection = [];
         _compareSections = [];
         _discardedSections = [];
         while {(count _junctions) > 0} do
         {
            _current = _junctions call BIS_fnc_arrayPop;
            _currentSections = [(_current select 0), _to] call _lookaheadSections;
            _currentSections = [_currentSections, {(_this select 0)}] call RUBE_shellSort;
            
            while {(count _currentSections) > 0} do
            {
               _las = _currentSections call BIS_fnc_arrayPop;
               
               if ((_las select 0) > _acceptThreshold) exitWith
               {
                  _bestSection = _las;
               };
               
               if ((_las select 0) > _discardThreshold) then
               {
                  _compareSections set [(count _compareSections), _las];
               } else {
                  _discardedSections set [(count _discardedSections), _las];
               }; 
            };
            
            if ((count _bestSection) > 0) then
            {
               // section is good enough, don't poll a second one yet
               private ["_bsRoute", "_bsLast"];
               _bsRoute = _bestSection select 1;
               _bsLast = _bsRoute call BIS_fnc_arrayPop;
               
               if (_debug) then
               {
                  [_bsRoute, (_bestSection select 2)] call _debugSection;
               };
               
               _decision = [
                  _bsLast,
                  _to,
                  ([_route, _bsRoute] call RUBE_arrayAppend),
                  ([_waypoints, (_bestSection select 2)] call RUBE_arrayAppend),
                  (_distance + (_bestSection select 3)) 
               ] call _roadRoute;
            } else {
               // section is not good enough, poll another one
               if ((count _compareSections) > 0) then
               {
                  _compareSections = [_compareSections, {(_this select 0)}] call RUBE_shellSort;
                  private ["_compareSection", "_csRoute", "_csLast"];
                  _compareSection = _compareSections call BIS_fnc_arrayPop;
                  _csRoute = _compareSection select 1;
                  _csLast = _csRoute call BIS_fnc_arrayPop;
               
                  if (_debug) then
                  {
                     [_csRoute, (_compareSection select 2)] call _debugSection;
                  };
               
                  _decision = [
                     _csLast,
                     _to,
                     ([_route, _csRoute] call RUBE_arrayAppend),
                     ([_waypoints, (_compareSection select 2)] call RUBE_arrayAppend),
                     (_distance + (_compareSection select 3)) 
                  ] call _roadRoute;
               };
            };
         
            // return the first complete route found
            if (_decision select 0) exitWith {};
         };
         
         if (!(_decision select 0)) then
         {
            _compareSections = [_compareSections, {(_this select 0)}] call RUBE_shellSort;
            while {(count _compareSections) > 0} do
            {
               private ["_compareSection", "_csRoute", "_csLast"];
               _compareSection = _compareSections call BIS_fnc_arrayPop;
               _csRoute = _compareSection select 1;
               _csLast = _csRoute call BIS_fnc_arrayPop;
               
               if (_debug) then
               {
                  [_csRoute, (_compareSection select 2)] call _debugSection;
               };
               
               _decision = [
                  _csLast,
                  _to,
                  ([_route, _csRoute] call RUBE_arrayAppend),
                  ([_waypoints, (_compareSection select 2)] call RUBE_arrayAppend),
                  (_distance + (_compareSection select 3)) 
               ] call _roadRoute;
               
               // return the first complete route found
               if (_decision select 0) exitWith {};
            };
         };
         
         if (!(_decision select 0)) then
         {
            _discardedSections = [_discardedSections, {(_this select 0)}] call RUBE_shellSort;
            while {(count _discardedSections) > 0} do
            {
               private ["_discardedSection", "_dsRoute", "_dsLast"];
               _discardedSection = _discardedSections call BIS_fnc_arrayPop;
               _dsRoute = _discardedSection select 1;
               _dsLast = _dsRoute call BIS_fnc_arrayPop;
               
               if (_debug) then
               {
                  [_dsRoute, (_discardedSection select 2)] call _debugSection;
               };
               
               _decision = [
                  _dsLast,
                  _to,
                  ([_route, _dsRoute] call RUBE_arrayAppend),
                  ([_waypoints, (_discardedSection select 2)] call RUBE_arrayAppend),
                  (_distance + (_discardedSection select 3)) 
               ] call _roadRoute;
               
               // return the first complete route found
               if (_decision select 0) exitWith {};
            };
         };
         
      };
      
      // strict comparing lookahead
      case 2:
      {
         private ["_routes"];
         _routes = [];
         {
            [_routes, ([(_x select 0), _to] call _lookaheadSections)] call RUBE_arrayAppend;
         } forEach _junctions;
         
         // sort ASC on performance, ready to be poped
         _routes = [_routes, {(_this select 0)}] call RUBE_shellSort;
         
         // detour?
         if (_detourThreshold > 0) then
         {
            if ((count _routes) > 1) then
            {
               if ((_routes call _performanceDiff) < _detourThreshold) then
               {
                  if (_detourProbability call RUBE_chance) then
                  {
                     _routes call _swapBestSections;
                  } else {
                     _detourProbability = _detourProbability * _detourSign;
                  };
                  _detourProbability = _detourProbability * _detourDivisor;
               };
            };
         };
         
         while {(count _routes) > 0} do
         {
            private ["_best", "_bestRoute", "_bestLast"];
            _best = _routes call BIS_fnc_arrayPop;
            _bestRoute = _best select 1;
            _bestLast = _bestRoute call BIS_fnc_arrayPop;
            
            if (_debug) then
            {
               [_bestRoute, (_best select 2)] call _debugSection;
            };
            
            // (again, remember to make a copy of _route and _waypoints,
            //  otherwise we end up with a screwed up route, since arrayAppend
            //  modifies the original/passed array(!), thus rejected lookahead
            //  sections would still show up in the route... brrrrr :/ )
            _decision = [
               _bestLast,
               _to,
               ([(+_route), _bestRoute] call RUBE_arrayAppend),
               ([(+_waypoints), (_best select 2)] call RUBE_arrayAppend),
               (_distance + (_best select 3)) 
            ] call _roadRoute;
            
            // return the first complete route found
            if (_decision select 0) exitWith {};
         };
      };
      
      // simple best-direction decision
      default
      {
         while {(count _junctions) > 0} do
         {
            _decision = [
               ((_junctions call BIS_fnc_arrayPop) select 0),
               _to,
               (+_route), // again: copy(!)
               (+_waypoints),
               _distance
            ] call _roadRoute;
            
            // return the first complete route found
            if (_decision select 0) exitWith {};
         };
      };
   };
   
   _decision
};




// make sure we have a start and end road object
// and register any off-road destination
if ((typeName _start) == "ARRAY") then
{
   _startDestination = +_start;
   _start = _start call _nearestRoad;
};

if ((typeName _end) == "ARRAY") then
{
   _endDestination = +_end;
   _end = _end call _nearestRoad;
};

// calculate abortion limits
// ... for distance
_airlineDist = _start distance _end; 
_maxDist = _maxDistMul * _airlineDist;
// ... and runtime (lookahead and detours need more time)
_maxRuntime = _maxRuntimePerMeter * (1 + (_lookahead * 0.6) + (_detourThreshold * 2)) * _airlineDist;


// debug route destination markers
if (_debug) then
{
   {
      if ((typeName (_x select 1)) == "ARRAY") then
      {
         [
            ["position", (_x select 1)],
            ["type", "mil_dot"],
            ["color", "ColorRed"]
         ] call RUBE_mapDrawMarker;
      };
      [
         ["position", (position (_x select 2))],
         ["type", (_x select 3)],
         ["color", "ColorRed"],
         ["text", (_x select 0)]
      ] call RUBE_mapDrawMarker;
   } forEach [
      ["START", _startDestination, _start, "mil_start"],
      ["END", _endDestination, _end, "mil_end"]
   ];
};


private ["_runtime"];
_runtime = {
   private ["_t"];
   _t = (time - _startTime);
   
   // write final debug log
   /*
   if (_debug) then
   {
      diag_log "______________________________________________________";
      diag_log "plotRoute final debug log";
      diag_log "";
      diag_log format["- runtime: %1 (cap: %2; ratio: %3)", _t, _maxRuntime, (_t / _maxRuntime)];
      diag_log format["- distance: %1 ALD (cap: %2)", _airlineDist, _maxDist];
      diag_log "- blacklist:";
      diag_log _blacklist;
   };
   */
   
   // return runtime
   _t
};

// calculate route, append runtime and return
(([_start, _end] call _roadRoute) + [([] call _runtime)])




