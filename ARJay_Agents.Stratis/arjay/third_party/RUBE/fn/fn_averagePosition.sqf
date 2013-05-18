/*
   Author:
    rübe
    
   Description:
    returns the average 2d position
    
   Parameter(s):
    _this: array of positions or objects (array)
    
   Returns:
    position
*/

private ["_x", "_y", "_n", "_i", "_p"];

_x = 0;
_y = 0;
_n = count _this;

for "_i" from 0 to (_n - 1) do
{
   if ((typeName (_this select _i)) == "ARRAY") then
   {
      _x = _x + ((_this select _i) select 0);
      _y = _y + ((_this select _i) select 1);
   } else 
   {
      _p = position (_this select _i);
      _x = _x + (_p select 0);
      _y = _y + (_p select 1);
   };
};

// prevent division by zero
if (_n == 0) exitWith
{
   [_x, _y, 0]
};

// return average position
[
   (_x / _n),
   (_y / _n),
   0
]


