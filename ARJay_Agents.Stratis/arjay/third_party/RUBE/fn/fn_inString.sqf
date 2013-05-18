/*
   Author:
    rübe
    
   Description:
    check's whether a given string is a substring of/in another
    string.
    
   Parameter(s):
    _this select 0: needle (string)
    _this select 1: haystack (string)
    
   Returns:
    boolean
*/

private ["_match", "_needle", "_haystack", "_n", "_h", "_index", "_i"];

_match = false;

_needle = toArray (_this select 0);
_haystack = toArray (_this select 1);

_n = count _needle;
_h = count _haystack;

if (_n > _h) exitWith 
{
   false
};

_index = 0;

for "_i" from 0 to (_h - 1) do
{
   if ((_haystack select _i) == (_needle select _index)) then
   {
      _index = _index + 1;
   } else 
   {
      _index = 0;
   };
   
   // needle found!
   if (_index == (_n - 1)) exitWith
   {
      _match = true;
   };
};

// return result
_match