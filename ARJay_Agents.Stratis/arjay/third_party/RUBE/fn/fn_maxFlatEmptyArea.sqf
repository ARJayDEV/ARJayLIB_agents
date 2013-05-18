/*
   Author:
    rübe
   
   Description:
    returns the maximum flat and empty area at a given position.
    
   Parameter(s):
    _this: parameters (array of array [key (string), value (any)])
    
           - required:
             
             - "position" (position)
           
           - optional:
           
             - "maxGradient" (scalar between 0.0 and 1.0)
               - default = 0.25
             
             - "square" (boolean)
                  if set to true, the returned value will be the
               length of a side of the circles in-square. Otherwise
               the radius of the circle is returned.
               - default = false
             
             - "step" (scalar)
                  the step in meters, the sample radius will grow
               every iteration.
               - default = 2
               
             - "waterMode" (int)
               - 0: restricted water (default)
               - 1: don't care
               - 2: required water
               
             - "onShore" (boolean)
                  if set to true, some water can be within a
               25m radius. 
               - default = false
   Returns:
    scalar
*/
private ["_position", "_maxGradient", "_square", "_step", "_waterMode", "_onShore", "_radius"];

_position = [0,0,0];
_maxGradient = 0.25;
_square = false;
_step = 2;
_waterMode = 0;
_onShore = false;

// read parameters
{
   switch (_x select 0) do
   {
      case "position": { _position = _x select 1; };
      case "maxGradient": { _maxGradient = _x select 1; };
      case "square": { _square = _x select 1; };
      case "step": { _step = _x select 1; };
      case "waterMode": { _waterMode = _x select 1; };
      case "onShore": { _onShore = _x select 1; };
   };
} forEach _this;

_radius = _step;
// isFlatEmpty fix
_position set [2, 0];

// sample position
while {(count (_position isFlatEmpty [
   _radius,
   0,
   _maxGradient,
   _radius,
   _waterMode,
   _onShore,
   objNull
]) > 0)} do
{
   _radius = _radius + _step;
};

_radius = _radius - _step;

// return side of the in-square?
if (_square) then
{
   _radius = 2 * ((cos 45) * _radius);
};

// return area
_radius