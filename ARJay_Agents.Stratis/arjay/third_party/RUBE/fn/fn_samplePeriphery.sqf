/*
   Author:
    rübe
    
   Descriptions:
    samples the terrain around a given position to get an
    idea of the landform/physical features. 
    
    Illustration:
    
                         
                       ^ 
                       x  
               /       |       \
                x      |      x
                 \     |     /
                  \    x    /
                   x   |   x
                    \  |  / 
                     \ | /           
       <-x------x------O------x------x->
                     / |\
                    /  | \
                   x   |  x
                  /    x   \
                 /     |    \
                x      |     x
               \       |      /
                       x
                       \   
                           
    we're sampling N positions on a line cast from the given position
    into all directions using a uniform sector/step. This gives us the 
    opportunity to characterize the terrain around the given position, 
    for the following five outcomes can be distinguished (only three 
    if we sample only one position per direction-ray):
    
     0) flat:           2) ascent:       1) hill: 
     
        O----x----x           x                x
                             /                / \
                            x                /   \
                           /                /     x
                          O                O       
                        
                        
                       -2) descent      -1) pit
                        
                          O               O       
                           \               \     x
                            x               \   /
                             \               \ /
                              x               x
        
        
     - if the last sample on a ray is the highest/lowest, we label
       it as ascent or descent respectively. Otherwise the most extrem
       point (to O) is either a hill or a pit.
       
     - if refine is activated (highly recommended) any points that are
       not considered flat will search for a more extreme position:
       ascent and hills for a higher, descent and pits for a lower resp.
       (thus some rays may end up with more or less the same position!)
       
     - thus if something is considered an ascent or a hill (descent or pit
       respectively) depends on the sample rays spacing (N samples taken 
       on a ray). So it's up to you if you can manage to do something with
       this distinction or just test for greater or smaller than zero...
       
       Position refinement illustration with a 90er sector (4 rays):
       
                          (again most extreme, but all taken samples
                            from here are less extreme than the current
                            origin, thus we stop the refine search)
                         .  /
                         | / 
                     .--(x)--.
                  .      \
                  \      |
                  |      |
            .<--- P --->(x)--->.
                  |      |\
                  |      . \
                  /      (most extreme out of the samples)
                  .
                  
      - since multiple positions can point to the same position (e.g. a hill),
        we merge those, but height it in means of a sector (how bread/wide the
        hill is).
    
   Parameter(s):
    _this: parameters (array of array [key (string), value (any)])
    
           - required:
           
             - "position" (position)
             
           - optional:
           
             - "refine" (int 0 - 2)
               0: no sample refinement
               1: refine peak and valleys
               2: refine peaks only
               - default = 1
               
             - "gradientThreshold" (scalar)
               max. gradient below terrain is considered flat
               - default = 2.0
               
             - "sampleSpacing" (array of scalar)
               sample positions in m taken on each ray
               - default = [75, 250, 500]
               
             - "sampleRange" ([start (scalar), end (scalar)])
               - default = [0, 360]  
               
             - "sampleSector" (scalar)
               360 / N = number of sample-rays
               - default = 10 degree (36 sample-rays à count(sampleSpacing) samples)
               
             - "refinementSector" (scalar)
               360 / N = number of refinement sample-rays, where
               the most extreme is followed further (peak/valley)
               - default = 60 degree (6 sample-rays à one sample)
               
             - "refinementDistance" (scalar)
               length of refinement sample-rays in m. (or how exact peaks/
               valleys can be pinpointed)
               - default = 10
             
   Returns:
    array of [type, gradient, direction, position1, ¦ position0 (if refined)]
*/

private ["_position", "_height", "_sampleSpacing", "_sampleRange", "_sampleSector", "_gradientThreshold", "_refinementMode", "_refinementSector", "_refinementDistance"];

_position = [0,0,0];
_height = 0;

_sampleSpacing = [75, 250, 500];
_sampleRange = [0, 360];
_sampleSector = 10;

// any gradient (abs) below this threshold is
// considered "flat"
_gradientThreshold = 2.0;

_refinementMode = 1;
_refinementSector = 60; 
_refinementDistance = 10;

// read parameters
{
   switch (_x select 0) do
   {
      case "position": { _position = _x select 1; };
      case "refine": { _refinementMode = _x select 1; };
      
      case "gradientThreshold": { _gradientThreshold = _x select 1; };
      case "sampleRange": { _sampleRange = _x select 1; };
      case "sampleSpacing": { _sampleSpacing = _x select 1; };
      case "sampleSector": { _sampleSector = _x select 1; };
      case "refinementSector": { _refinementSector = _x select 1; };
      case "refinementDistance": { _refinementDistance = _x select 1; };
   };
} forEach _this;

_height = (_position call RUBE_getPosASL) select 2;


private ["_probe", "_refine", "_characterize"];

// pos, dir => posASL
_probe = {
   (([(_this select 0), _refinementDistance, (_this select 1)] call BIS_fnc_relPos) call RUBE_getPosASL)
};

// [pos, type(up/down)]
_refine = {
   private ["_pos", "_probes", "_p", "_i"];
   
   _pos = _this select 0;
   
   _probes = [];
   _p = 0;
   
   for "_i" from 0 to (360 - _refinementSector) step _refinementSector do
   {
      _probes set [_p, ([_pos, _i] call _probe)];
      _p = _p + 1;
   };
      
   if ((_this select 1) > 0) then
   {
      _p = [_probes, { (_this select 2) }, 0, -1, true] call RUBE_arrayMax;
      if (((_probes select _p) select 2) > (_pos select 2)) then
      {
         _pos = [(_probes select _p), (_this select 1)] call _refine;
      };
   } else {
      _p = [_probes, { (_this select 2) }, 0, -1, true] call RUBE_arrayMin;
      if (((_probes select _p) select 2) < (_pos select 2)) then
      {
         _pos = [(_probes select _p), (_this select 1)] call _refine;
      };
   };
   
   _pos
};



// [dir, probes] -> [typeInt, gradient, direction, position]
_characterize = {
   private ["_direction", "_probes", "_n", "_a", "_type"];
   _direction = _this select 0;
   _probes = _this select 1;
   _type = 0;
   _n = count _probes;

   if (_n == 1) exitWith
   {
      _type = 2;
      // gradient
      _a = atan ((((_probes select (_n - 1)) select 2) - _height) / (_sampleSpacing select (_n - 1)));

      switch (true) do
      {
         case ((abs _a) < _gradientThreshold): 
         { 
            _type = 0; 
         };
         case (_a < 0): 
         { 
            _type = -2; 
         };
      };
      
      [_type, _a, _direction, (_probes select 0)]
   };
   
   private ["_min", "_max", "_minH", "_maxH", "_index", "_pos", "_pos0", "_a", "_distance"];
   
   // extremes (indices! not values)
   _min = [_probes, { (_this select 2) }, 0, (_n - 1), true] call RUBE_arrayMin;
   _max = [_probes, { (_this select 2) }, 0, (_n - 1), true] call RUBE_arrayMax;
   
   // abs. height difference
   _minH = abs (((_probes select _min) select 2) - _height);
   _maxH = abs (((_probes select _max) select 2) - _height);
   
   _index = 0;

   if (_maxH >= _minH) then
   {
      _index = _max;
      _type = 2;
      if (_index != (_n - 1)) then
      {
         _type = 1;
      };
   } else {
      _index = _min;
      _type = -2;
      if (_index != (_n - 1)) then
      {
         _type = -1;
      };
   };
   
   // gradient
   _pos0 = [];
   _pos = _probes select _index;
   _a = atan (((_pos select 2) - _height) / (_sampleSpacing select _index));
   
   // considered flat?
   if ((abs _a) < _gradientThreshold) then
   {
      _type = 0;
   } else {
      if ((_refinementMode == 1) || ((_refinementMode == 2) && (_type > 0))) then
      {
         _pos0 = +_pos;
         _pos = [_pos, _type] call _refine;
         
         _distance = [_pos, _position] call RUBE_getALD;
         _a = atan (((_pos select 2) - _height) / _distance);
      };
   };
   
   if ((count _pos0) == 0) exitWith
   {
      [_type, _a, _direction, _pos]
   };
   
   [_type, _a, _direction, _pos, _pos0]
};


// scan relief
private ["_periphery", "_n", "_s", "_probes"];

_periphery = [];
_n = count _sampleSpacing;
_s = 0;

for "_i" from (_sampleRange select 0) to ((_sampleRange select 1) - _sampleSector) step _sampleSector do
{
   _probes = [];
   for "_j" from 0 to (_n - 1) do 
   {
      _probes set [_j, (([_position, (_sampleSpacing select _j), _i] call BIS_fnc_relPos) call RUBE_getPosASL)];
   };
   
   _periphery set [_s, ([_i, _probes] call _characterize)];
   _s = _s + 1;
};

// filter/merge relief data

// return
_periphery