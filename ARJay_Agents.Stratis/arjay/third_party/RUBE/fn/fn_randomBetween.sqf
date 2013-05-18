/*
   Author:
    rübe
    
   Description:
    returns a random number between a given min/max number, including
    min. and max.
    
   Parameter(s):
    _this select 0: minimum (number)
    _this select 1: maximum (number)
    _this select 2: round (boolean, optional. Default = false)
                    -> we use `floor (min + rand + 1)` thus min/max are 
                       included in the set of possible values.
*/

private ["_r"];

_r = 0;

if ((count _this) > 2) then
{
   _r = floor ((_this select 0) + (random ((_this select 1) - (_this select 0) + 1)));
} else {
   _r = (_this select 0) + (random ((_this select 1) - (_this select 0)));
};

_r