/*
   Author:
    rübe
    
   Description:
    reverses/flips an array, modifying the original one! (we swap items
    and do not create/return a new array)
    
   Parameter(s):
    _this: original array
    
   Returns:
    array
*/

private ["_size", "_i"];

_size = count _this;

if (_size > 1) then
{
   for "_i" from 0 to ((floor (_size * 0.5)) - 1) do
   {
      [_this, _i, ((_size - 1) - _i)] call RUBE_arraySwap;
   };
};

_this