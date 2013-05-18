/*
   Author:
    rübe
    
   Description:
    appends an array onto another one, modifying the
    original array (which is faster than creating a
    new list alltogether)
    
   Parameter(s):
    _this select 0: original list (array)
    _this select 1: items (array)
    _this select n: more lists to append (array)
    
   Returns:
    original list (array)
*/

private ["_list", "_n", "_i"];

_list = (_this select 0);
_n = count _list;

for "_i" from 1 to ((count _this) - 1) do
{
   {
      _list set [_n, _x];
      _n = _n + 1;
   } forEach (_this select _i);
};

_list