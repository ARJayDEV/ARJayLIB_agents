/*
   Author:
    rübe
    
   Description:
    spawns a circle-formation of objects. The circle is defined with a given
    radius, the object's width and an optional margin. Thus, you can't easily
    predict, how many objects will be spawned...
    
    The used position lies not on the radius(!) but in the middle of the `outer`
    side of the formed triangle:
    
    Triangle fragment/sector and returned/used positions (X, E):
                  |
            X . . . .  A (X)      < returned abs. angle (alpha (A) + alpha/2)
            . ____E___  .       <
           .  \       /\  .   <
          .    \     /  \  .< 
              r \  r/ -> E  . <- half the angle/triangle
                 \ /      \ .   
       center ->  /________\. 
      position  C      r   .  B (X)
                          .
                        .    <- points should mark the circle, 
                                  boy does my ASCI-Kungfu suck, :/ 
                                 hehe
    
   Parameter(s):
    _this select 0: edge-positions (E):
                    array of object data structures OR 
                    array of function(s), OR
                    empty array for no edge-position obj/fun.
                    
    _this select 1: corner-positions (X):
                    array of object data structures OR 
                    array of function(s), OR
                    empty array for no edge-position obj/fun.

    _this select 2: center position (position)
    _this select 3: radius in meters (number OR array of [radius, lazy])
                    - `lazy` (number):
                      not given OR -2: exact radius (but probably no perfect ring/with a gap)
                      0: incr. or decrease radius to form a perfect ring without gap
                      1: increase radius to form a perfect ring without gap
                     -1: decrease radius to form a perfect ring without gap
                     -> default is exact
                     -> we simply round the angle to the next divisor of 360, thus this
                        works nice on full as well as for lot's other commen arc-lenghts,
                        though it's not needed, if you don't care for symmetry.
                     
    _this select 4: width of the circle-position-gap/object-width in meters (number)
    _this select 5: margin/spacing in meters (number, optional)
    _this select 6: direction(/arc length) (number OR array [dir, arc-length], optional)
                    - default: [0, 360] for a full circle starting at 0 degree abs. (north)
   
      - Object data structure:
           array [
              object class (string),
              position offset (array),
              rotation (number),
              pitch (number, optional),
              bank (number, optional)
           ]
           
         OR
         
         object class (string)
   
      - Custom Function/Code get's passed either:
           _this select 0: edge position (E)
           _this select 1: edge angle (C->E)
     
         OR
     
           _this select 0: corner position (X)
           _this select 1: corner angle (C->X)
   
   
   -> If multiple objects/functions are given (for E or X), we alternate between 
      them. 
   
   
   Returns:
    array of spawned objects OR array of whatever your custom function returns
    
*/

private ["_edge", "_corner", "_edgePositions", "_cornerPositions", "_edgeFun", "_cornerFun", "_step", "_position", "_radius", "_radiusCorrection", "_width", "_w2", "_direction", "_arc", "_alpha", "_a2", "_height", "_divisors", "_ac", "_manipulator", "_findNextDivisor"];

// init objects/functions
_edge   = _this select 0;
_corner = _this select 1;

_edgePositions   = count _edge;
_cornerPositions = count _corner;

_edgeFun   = false;
_cornerFun = false;

_step = 0;

if (_edgePositions > 0) then
{
   switch (typeName (_edge select 0)) do
   {
      case "ARRAY":  {};
      case "STRING": {};
      case "CODE": { _edgeFun = true; };
      default {
         _edgePositions = 0;
      };
   };
};

if (_cornerPositions > 0) then
{
   switch (typeName (_corner select 0)) do
   {
      case "ARRAY":  {};
      case "STRING": {};
      case "CODE": { _cornerFun = true; };
      default {
         _cornerPositions = 0;
      };
   };
};

// init/calculate circle definition
_position = _this select 2;
_radius = _this select 3;
_radiusCorrection = -2;
if ((typeName _radius) == "ARRAY") then
{
   _radius = (_this select 3) select 0;
   _radiusCorrection = (_this select 3) select 1;
};

_width = _this select 4;
if ((count _this) > 5) then
{
   _width = _width + (_this select 5);
};
_direction = 0;
_arc = 360.01;
if ((count _this) > 6) then
{
   if ((typeName (_this select 6)) == "ARRAY") then
   {
      _direction = (_this select 6) select 0;
      _arc = ((_this select 6) select 1) + 0.01;
   } else {
      _direction = _this select 6;
   };
};

// caluclate needed angle/height
_w2 = _width * 0.5;
_alpha = 2 * (asin (_w2 / _radius));
_a2 = _alpha * 0.5;
_height = sqrt ((_radius * _radius) - (_w2 * _w2));

// we may need to fix _alpha for a perfect circle
_divisors = [2, 3, 4, 5, 6, 8, 9, 10, 12, 15, 18, 20, 24, 30, 36, 40, 45, 60, 72, 90, 120, 180];
_findNextDivisor = {
   private["_a", "_dec", "_inc", "_b", "_diff"];
   _a = _this select 0;
   _dec = _this select 1;
   _inc = _this select 2;
   
   _b = 1;
   _diff = abs (_a - _b);
   {
      if (_x < _a) then
      {
         if (_dec && (abs (_a - _x)) < _diff) then
         {
            _b = _x;
            _diff = abs (_a - _x);
         };
      } else {
         if (_inc && (abs (_a - _x)) < _diff) then
         {
            _b = _x;
            _diff = abs (_a - _x);
         };
      };
   } forEach _divisors;
   
   _b
};
if (_radiusCorrection > -2) then
{
   _ac = 1;
   switch (_radiusCorrection) do
   {
      // auto
      case 0: 
      {
         _ac = [_alpha, true, true] call _findNextDivisor;
      };
      // increase
      case 1: 
      {
         _ac = [_alpha, true, false] call _findNextDivisor;
      };
      // decrease
      case -1: 
      {
         _ac = [_alpha, false, true] call _findNextDivisor;
      };
   };
   if (_ac > 1) then
   {
      _alpha = _ac;
      _a2 = _alpha * 0.5;
      // new height! (we don't need radius anymore)
      _height = (_w2/(tan _a2));
   };
};



// manipulators
_manipulator = {
   private ["_selected", "_class", "_pos", "_dir", "_pitch", "_bank", "_vec", "_obj"];
   _selected = (_this select 2) select (_step % (_this select 3));
   _class = "";
   _pos = _this select 0;
   _dir = _this select 1;
   _pitch = 0;
   _bank = 0;
   if ((typeName _selected) == "STRING") then
   {
      if (_selected != "") then
      {
         _class = _selected;
      };
   } else {
      if ((count _selected) > 0) then
      {
         _class = _selected select 0;
         // apply offset
         if ((count _selected) > 1) then 
         {
            _vec = [(_selected select 1), ((360 - _dir) % 360)] call BIS_fnc_rotateVector2D;
            _pos = [
               ((_pos select 0) + (_vec select 0)),
               ((_pos select 1) + (_vec select 1)),
               ((_selected select 1) select 2) 
            ];
         }; 
         // rotation
         if ((count _selected) > 2) then
         {
            _dir = _dir + (_selected select 2);
         };
         // pitch/bank
         if ((count _selected) > 3) then { _pitch = _selected select 3; };
         if ((count _selected) > 4) then { _bank  = _selected select 4; };
      };
   };
   
   _obj = objNull;
   
   if (_class != "") then
   {
      _obj = createVehicle [_class, _pos, [], 0, "NONE"];
      _obj setDir _dir;
      _obj setPos _pos;
      if (_pitch != 0 || _bank != 0) then
      {
         [_obj, _pitch, _bank] call BIS_fnc_setPitchBank;
      };
   };
   
   _obj
};



private["_objects", "_a0", "_a1", "_a", "_p"];
_objects = [];

_a0 = _direction;
_a1 = _direction + (_arc - _alpha);
while {_a0 < _a1} do
{
   // edge position
   if (_edgePositions > 0) then
   {
      _a = (_a0 + _a2) % 360;
      _p = [
         ((_position select 0) + (_height * (sin _a))),
         ((_position select 1) + (_height * (cos _a))),
         0
      ];
      if (_edgeFun) then
      {
         _objects = _objects + [
            ([_p, _a] call (_edge select (_step % _edgePositions)))
         ];
      } else {
         _objects = _objects + [
            ([_p, _a, _edge, _edgePositions] call _manipulator)
         ]; 
      };
   };
   // corner position
   if (_cornerPositions > 0) then
   {
      _a = (_a0 + _alpha) % 360;
      _p = [
         ((_position select 0) + (_height * (sin _a))),
         ((_position select 1) + (_height * (cos _a))),
         0
      ];
      if (_cornerFun) then
      {
         _objects = _objects + [
            ([_p, _a] call (_corner select (_step % _cornerPositions)))
         ];
      } else {
         _objects = _objects + [
            ([_p, _a, _corner, _cornerPositions] call _manipulator)
         ]; 
      };
   };
   
   _a0 = _a0 + _alpha;
   _step = _step + 1;
}; 


// return objects
_objects

