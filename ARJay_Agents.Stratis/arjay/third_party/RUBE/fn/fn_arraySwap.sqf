/*
   Auhtor:
    rübe
    
   Description:
    swaps two array items, changing the original array
    
   Parameter(s):
    _this select 0: array (array)
    _this select 1: first items index (int)
    _this select 2: second items index (int)
   
   Returns:
    array
*/

private ["_tmp"];

_tmp = (_this select 0) select (_this select 1);

if ((_this select 1) == (_this select 2)) exitWith 
{
   (_this select 0)
};

(_this select 0) set [(_this select 1), ((_this select 0) select (_this select 2))];
(_this select 0) set [(_this select 2), _tmp];

(_this select 0)