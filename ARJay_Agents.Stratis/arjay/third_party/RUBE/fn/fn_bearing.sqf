/*
   Author:
    rübe
    
   Description:
    computes the bearing (average direction) of a given set of 
    directions or objects (by converting the directions to vectors, 
    adding them up and computing the resulting angle).
    
    There are several cases, where the correct bearing can't be 
    returned (unless you dare to divide by zero). 
    
   Parameter(s):
    _this: array of directions (scalar) OR array of objects
    
   Returns:
    direction (scalar)
    
   Examples:
   
    _d = [315, 45] call RUBE_bearing; // == 0
    _d = [0, 90] call RUBE_bearing; // == 45
    _d = [270, 180, 90] call RUBE_bearing; // == 180
*/

private ["_directions", "_n", "_bearing"];

_directions = _this;
_n = count _directions;

if (_n == 0) exitWith
{
   0
};

if (_n == 1) exitWith
{
   _bearing = _directions select 0;
   if ((typeName _bearing) != "SCALAR") then
   {
      _bearing = direction _bearing;
   };
   _bearing
};


[
   _directions,
   {
      if ((typeName _this) != "SCALAR") exitWith
      {
         (direction _this)
      };
      if (_this >= 180) exitWith
      {
         ((360 - _this) * -1)
      };
      _this
   }
] call RUBE_arrayMap;



private ["_dx", "_dy"];

_dx = 0;
_dy = 0;

{
   _dx = _dx + (sin _x);
   _dy = _dy + (cos _x);
} forEach _directions;

if (_dx == 0) exitWith
{
   0
};


((round ((abs (_dx atan2 _dy)) * 10)) * 0.1)