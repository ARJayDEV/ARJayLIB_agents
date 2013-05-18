/*
   Author:
    rübe
   
   Description:
    pop's a random item from an array (returning a random item, while removing
    it from the original array)
    
    - make sure your array is not empty prior to calling this function!
   
   Parameter(s):
    _this: array (array)
    
   Returns:
    any
*/

private ["_size", "_index", "_item", "_i", "_j"];

_size = count _this;
_index = (floor (random _size));
_item = objNull;
_j = 0;

// we shift all items after the pop'ed item to the left 
for "_i" from 0 to (_size - 1) do
{
   if (_i == _index) then
   {
      _item = (_this select _i);
   } else {
      _this set [_j, (_this select _i)];
      _j = _j + 1;
   };
};

// resize original array
_this resize (_size - 1);

// return poped item
_item