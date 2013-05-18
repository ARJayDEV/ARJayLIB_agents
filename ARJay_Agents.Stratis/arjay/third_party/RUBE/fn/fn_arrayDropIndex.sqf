/*
   Author:
    rübe
    
   Description:
    returns a new array without the given items
    defined by their index.
    
   Parameter(s):
    _this select 0: list (array)
    _this select 1: indices to be dropped (number OR array of numbers)
    
   Returns:
    array
*/

private ["_filtered", "_drop", "_i"];

_filtered = [];
_drop = _this select 1;
if ((typeName _drop) != "ARRAY") then
{
   _drop = [(_this select 1)];
};

for "_i" from 0 to ((count (_this select 0)) - 1) do
{
   if (!(_i in _drop)) then
   {
      _filtered set [(count _filtered), ((_this select 0) select _i)];
   };
};

_filtered