/*
   Author:
    rübe
   
   Description:
    makes sure a given string is of a minimal size, by appending
    some symbol in front of it.
    
   
   Parameter(s):
    _this select 0: input (any)
    _this select 1: minimal size/amount of symbols (integer)
    _this select 2: filler symbol (string, optional)
                    - default: empty string
    _this select 3: prefix? (boolean, optional)
                    - default: true
                    - postfix otherwise
    
   Returns:
    string
*/

private ["_str", "_n", "_min", "_symbol", "_prefix", "_length"];

_str = _this select 0;

if ((typeName _str) != "STRING") then
{
   _str = str _str;
};

_n = count (toArray _str);

_min = _this select 1;
_symbol = " ";
_prefix = true;

if ((count _this) > 2) then
{
   _symbol = _this select 2;
   if ((typeName _symbol) != "STRING") then
   {
      _symbol = str _symbol;
   };
};

if ((count _this) > 3) then
{
   _prefix = _this select 3;
};

_length = count (toArray _symbol);

if (_prefix) then
{
   while {(_n < _min)} do
   {
      _str = _symbol + _str;
      _n = _n + _length;
   };
} else
{
   while {(_n < _min)} do
   {
      _str = _str + _symbol;
      _n = _n + _length;
   };
};

_str