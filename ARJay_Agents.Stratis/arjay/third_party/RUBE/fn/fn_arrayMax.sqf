/*
   Author:
    rübe
    
   Description:
    returns the item (value or index) with the highest value
    
   Parameter(s):
    _this select 0: items (array)
    _this select 1: selector/manipulator (code, optional)
                    - gets passed the current item,
                      has to return scalar
                      - default = { _this }
    _this select 2: start/from index (int, optional)
    _this select 3: end/to index (int, optional)
                    - (n < 1) -> (count list - 1)
    _this select 4: return index (bool, optional)
                    
   Returns:
    item (any)
*/

private ["_list", "_selector", "_returnIndex", "_index", "_current", "_next", "_i0", "_i1", "_i"];

_list = _this select 0;
_selector = { _this };
_returnIndex = false;
_index = 0;
_current = 0;
_next = 0;

_i0 = 1;
_i1 = 0;

if ((count _this) > 1) then
{
   _selector = _this select 1;
};
if ((count _this) > 2) then
{
   _index = _this select 2;
   _i0 = _index + 1;
};
if ((count _this) > 3) then
{
   _i1 = _this select 3;
   if (_i1 < 1) then
   {
      _i1 = (count _list) - 1;
   };
} else {
   _i1 = (count _list) - 1;
};
if ((count _this) > 4) then
{
   _returnIndex = _this select 4;
};


_current = (_list select _index) call _selector;

for "_i" from _i0 to _i1 do
{
   _next = (_list select _i) call _selector;
   if (_next > _current) then
   {
      _index = _i;
      _current = _next;
   };
};

// return
if (_returnIndex) exitWith
{
   _index
};
(_list select _index)