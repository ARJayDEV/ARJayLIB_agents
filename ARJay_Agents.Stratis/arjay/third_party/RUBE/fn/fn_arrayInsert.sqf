/*
   Author:
    rübe
    
   Description:
    inserts the items of a given list into another list
    at a given position. Original arrays won't be altered.
    
    Negative insert positions are fine too, so that -1 
    means appending the new items, -2 inserts the new 
    elements before the last element of the original 
    list and so on... 
        
   Parameter(s):
    _this select 0: list of new items (array)
    _this select 1: original list (array)
    _this select 2: insert position (int)
                    (new items start at this position,
                     not after)
   
   Returns:
    array
*/

private ["_list", "_last", "_insertPosition", "_i"];

_list = [];
_last = (count (_this select 1)) - 1;
_insertPosition = _this select 2;

// negative insert position
while {(_insertPosition < 0)} do
{
   _insertPosition = _insertPosition + (_last + 2); 
};

// at front
if (_insertPosition == 0) exitWith
{
   ([(_this select 0), (_this select 1)] call RUBE_arrayAppend)
};

// append || desired insert position out of range
if (_insertPosition > _last) exitWith
{
   ([(_this select 1), (_this select 0)] call RUBE_arrayAppend)
};

// original items prior to insert position
for "_i" from 0 to (_insertPosition - 1) do
{
   _list set [(count _list), ((_this select 1) select _i)];
};

// insert new items
{
   _list set [(count _list), _x];
} forEach (_this select 0);

// original items after the insert position
for "_i" from _insertPosition to _last do
{
   _list set [(count _list), ((_this select 1) select _i)];
};

_list