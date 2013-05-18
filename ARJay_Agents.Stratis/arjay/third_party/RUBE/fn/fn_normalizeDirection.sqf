/*
   Author:
    rübe
    
   Description:
    normalizes a direction so it's in the range from 0 to 359
    
   Parameter(s):
    _this: direction (scalar)
    
   Returns:
    normalized direction (scalar)
*/

private ["_dir"];

_dir = _this;

while {(_dir < 0)} do
{
   _dir = _dir + 360;
};

(_dir % 360)