/*
   Author:
    rübe
    
   Description:
    check's whether a given string is the suffix (or shifted substring) 
    of another string.
    
   Parameter(s):
    _this select 0: needle (string)
    _this select 1: haystack (string)
    _this select 2: shift/offset (integer)
                    - optional, default = 0 (last letter)
                    - if higher than zero, only the haystack will
                      be shifted (to the left), still comparing
                      the full needle.
    
   Returns:
    boolean
*/

private ["_match", "_needle", "_haystack", "_shift", "_n", "_h", "_i"];

_match = true;

_needle = toArray (_this select 0);
_haystack = toArray (_this select 1);
_shift = 0;
if ((count _this) > 2) then
{
   _shift = _this select 2;
};

_n = (count _needle) - 1;
_h = (count _haystack) - 1;

if (_n > _h) exitWith 
{
   false
};

for "_i" from 0 to _n do
{
   if ((_needle select (_n - _i)) != (_haystack select (_h - _shift - _i))) exitWith
   {
      _match = false;
   };
};

_match