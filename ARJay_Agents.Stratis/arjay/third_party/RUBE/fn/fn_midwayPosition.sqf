/*
  Author:
   rübe
   
  Description:
   returns the midway (or relative) position of two positions
   
  Parameter(s):
   _this select 0: first position 
   _this select 1: second position
   _this select 2: relation ([0.0 - 1.0] optional, default = 0.5)
                   where 0.0 is the second position and
                   1.0 the first one.
   
  Returns:
   position
*/

private ["_x", "_y", "_a", "_b"];

_x = _this select 0;
_y = _this select 1;

_a = 0.5;
if ((count _this) > 2) then
{
   _a = _this select 2;
};

_b = (1.0 - _a);
_a = _a;

[
   (((_x select 0) * _a) + ((_y select 0) * _b)),
   (((_x select 1) * _a) + ((_y select 1) * _b)),
   (((_x select 2) * _a) + ((_y select 2) * _b))
]