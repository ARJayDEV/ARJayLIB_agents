/*
   Author:
    rübe
    
   Description:
    plots a route onto the map returned by RUBE_findRoute
    
   Parameter(s):
    _this select 1: route data structure returned by RUBE_findRoute
    _this select 2: parameters (array of array [key (string), value (any)])
                    (all optional)
                    
                    - "id" (unique string)
                      - used to generate unique markernames. If non is
                        given, we'll get autid's from RUBE_createMarkerID 
                    
                    - "reference" (int)
                      - 0: road objects
                      - 1: pattern/modulo road objects (nice for dots)
                      - 2: adaptive road objects (nice for linked lines)
                      - 3: waypoints
                      -> default = 2
                    
                    - "style" (int)
                      - 0: dotted (icon-markers)
                      - 1: linked lines (rect-markers)
                      -> default = 1
                      
                    - "modulo" (int)
                      - only for pattern/modulo road objects (reference = 1)
                      - every nth road-element that get's respected... in 
                        effect it's much like dot-spacing/margin.
                          
                    - "delta" (scalar)
                      - only for adaptive road objects (reference = 2)
                      - if the relative direction of the road (compared
                        to the previous one) changed more than "delta",
                        the point is respected, otherwise ignored. Also
                        we have a memory of the last accepted point and
                        compare the delta to this one too, to catch 
                        little but gradual changement of the direction.
                        
                        Thus, the lower delta, the closer the marker 
                        follow the route at the cost of lots of markers.
                        
                      -> default = 15 (very nice for linked lines, yet 
                         probably too small (thus tight) for dots)
                      
                    - "color" (string)
                      -> default = "ColorBlue"
                      
                    - "size" (int)
                      - only for linked lines (style = 1)
                      - default = 9;
                    
                    markers: 
                    - "start" (string/icon or empty string)
                    - "end" (string/icon or empty string)
                    - "dot" (string/icon or empty string)
                      - only for dotted routes (style = 0)
                      - you can easily use arrows for all reference-modes
                        support correct route direction.
                        
                      -> default: "mil_start", "mil_end", "mil_dot"
                    
                    - "startLabel" and "endLabel" (string)
                      -> default = empty string
                    
                    - "dotSize" (scalar)
                      - only for dotted routes (style = 0)
                      - affects only route- and not destination-markers
                      -> default = 1
                    
                    - "dotDirOffset" (int)
                      - only for dotted routes (style = 0)
                      - direction-offset, so markers like "Move" can be 
                        used too!
                        -> default = 0

   
   Example 1 (linked lines):
    _route = [...] call RUBE_findRoute;
    if (_route select 0) then
    {
       _routeMarkers = [_route, [
          ["style", 1],     // linked lines
          ["reference", 2], // adaptive ref. points 
          ["delta", 15]     // tight
       ]] call RUBE_plotRoute;
    };
   
   Example 2 (arrows):
    _route = [...] call RUBE_findRoute;
    if (_route select 0) then
    {
       _routeMarkers = [_route, [
         ["style", 0],
         ["reference", 1],
         ["modulo", 13],
         ["dot", "Move"],
         ["dotSize", 0.6],
         ["dotDirOffset", -90]
      ]] call RUBE_plotRoute;
    };
    
   Returns:
    array of markers
*/

private ["_route", "_roads", "_waypoints", "_reference", "_style", "_delta", "_color", "_start", "_startLabel", "_end", "_endLabel", "_dot", "_dotDirOffset", "_createId", "_idBase", "_idCounter", "_modulo", "_size", "_dotSize"];

// [success, route (road objects), waypoints (positions), distance, time]
_route = _this select 0;

if ((count _route) == 0) exitWith { [] };
if (!(_route select 0)) exitWith { [] };

_roads = _route select 1;
_waypoints = _route select 2;

_reference = 2;
_style = 1;

_modulo = 5;
_delta = 15;

_color = "ColorBlue";
_size = 9;

_start = "mil_start";
_startLabel = "";
_end = "mil_end";
_endLabel = "";
_dot = "mil_dot";
_dotSize = 1;
_dotDirOffset = 0;

_createId = { -1 };
_idBase = "";
_idCounter = 0;


{
   switch (_x select 0) do
   {
      case "reference": { _reference = _x select 1; };
      case "style": { _style = _x select 1; };
      case "modulo": { _modulo = _x select 1; };
      case "delta": { _delta = _x select 1; };
      case "color": { _color = _x select 1; };
      case "size": { _size = _x select 1; };
      case "start": { _start = _x select 1; };
      case "startLabel": { _startLabel = _x select 1; };
      case "end": { _end = _x select 1; };
      case "endLabel": { _endLabel = _x select 1; };
      case "dot": { _dot = _x select 1; };
      case "dotSize": { _dotSize = _x select 1; };
      case "dotDirOffset": { _dotDirOffset = _x select 1; };
      case "id": 
      {
         _idBase = _x select 1;
         _createId = {
            private ["_id"];
            _id = format["%1%2", _idBase, _idCounter];
            _idCounter = _idCounter + 1;
            _id
         };
      };
   };
} forEach (_this select 1);

private ["_dirDiff", "_roadDir", "_objToPoint", "_startPos", "_endPos", "_points", "_markers"];

//
_dirDiff = {
   private ["_diff"];
   _diff = (abs ((_this select 1) - (_this select 0))) % 360;
   if (_diff > 180) then
   {
      _diff = 360 - _diff;
   };
   _diff
};

//
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

//
_objToPoint = {
   [(position (_this select 0)), ([(_this select 0), (_this select 1)] call _roadDir)]
};
// overwrite for _dotDirOffset
if ((_style == 0) && (_dotDirOffset != 0)) then
{
   _objToPoint = {
      [(position (_this select 0)), (([(_this select 0), (_this select 1)] call _roadDir) + _dotDirOffset)]
   };
};

_startPos = [];
_endPos = [];
_points = [];
_markers = [];

private ["_d0", "_d1", "_dy"];

// gather marker-route reference points 
switch (_reference) do
{
   // (strict/all) road objects
   case 0:
   {
      for "_i" from 0 to ((count _roads) - 2) do
      {
         _d0 = [(_roads select _i), (_roads select (_i + 1))] call BIS_fnc_dirTo;
         _points = _points + [([(_roads select _i), _d0] call _objToPoint)];
      };
      _points = _points + [([(_roads select ((count _roads) - 1)), _d0] call _objToPoint)];
   };
   // pattern/modulo road objects
   case 1:
   {
      _d0 = [(_roads select 0), (_roads select 1)] call BIS_fnc_dirTo;
      _points = _points + [([(_roads select 0), _d0] call _objToPoint)];
      
      for "_i" from 1 to ((count _roads) - 2) do
      {
         if (((_i + 1) % _modulo) == 0) then
         {
            _d0 = [(_roads select _i), (_roads select (_i + 1))] call BIS_fnc_dirTo;
            _points = _points + [([(_roads select _i), _d0] call _objToPoint)];
         };
      };
      
      _points = _points + [([(_roads select ((count _roads) - 1)), _d0] call _objToPoint)];
   };
   // adaptive road objects
   case 2:
   {
      if ((count _roads) < 4) exitWith
      {
         {
            _points = _points + [(_x call _objToPoint)];
         } forEach _roads;
      };
      
      _d0 = [(_roads select 0), (_roads select 1)] call BIS_fnc_dirTo;
      _dy = _d0;
      _points = _points + [([(_roads select 0), _d0] call _objToPoint)];
      
      for "_i" from 2 to ((count _roads) - 2) do
      {
         _d1 = [(_roads select (_i - 1)), (_roads select _i)] call BIS_fnc_dirTo;
         if ((([_d0, _d1] call _dirDiff) > _delta) ||
             (([_dy, _d1] call _dirDiff) > _delta)) then
         {
            _points = _points + [([(_roads select _i), _d1] call _objToPoint)];
            _dy = _d1;
         };
         _d0 = _d1;
      };
      _points = _points + [([(_roads select ((count _roads) - 1)), _d0] call _objToPoint)];
   };
   // waypoints
   default
   {
      for "_i" from 1 to ((count _waypoints) - 2) do
      {
         _points = _points + [
            [
               (_waypoints select _i), 
               ([(_waypoints select _i), (_waypoints select (_i + 1))] call BIS_fnc_dirTo)
            ]
         ];
      };
   };
};

// plot route markers
switch (_style) do
{
   // dotted
   case 0:
   {
      for "_i" from 1 to ((count _points) - 2) do
      {
         _markers = _markers + [([
            ["id", ([] call _createId)],
            ["position", ((_points select _i) select 0)],
            ["direction", ((_points select _i) select 1)],
            ["type", _dot],
            ["size", _dotSize],
            ["color", _color]
         ] call RUBE_mapDrawMarker)];
      };
   };
   
   // linked lines
   case 1:
   {
      for "_i" from 1 to ((count _points) - 1) do
      {
         _markers = _markers + [([
            ["id", ([] call _createId)],
            ["start", ((_points select (_i - 1)) select 0)],
            ["end", ((_points select _i) select 0)],
            ["color", _color],
            ["size", _size]
         ] call RUBE_mapDrawLine)];
      };
   };
};

// plot destination markers
{
   if ((_x select 0) != "") then
   {
      _markers = _markers + [
         ([
            ["id", ([] call _createId)],
            ["position", ((_x select 1) select 0)],
            ["type", (_x select 0)],
            ["color", _color],
            ["text", (_x select 2)]
         ] call RUBE_mapDrawMarker)
      ];
   };
} forEach [
   [_start, (_points select 0), _startLabel],
   [_end, (_points select ((count _points) - 1)), _endLabel]
];


_markers