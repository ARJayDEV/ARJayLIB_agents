/*
  Author:
   rübe
   
  Description:
   returns the average of all numbers/items in the given array.
   
   You may pass a custom selector to access complex data
   structures or do some other manipulation first.
   
  Parameters:
   _this select 0: numbers/items (array)
   _this select 1: selector (code, optional)
   _this select 2: start index (optional)
   _this select 3: end index (optional)
   
  Returns:
   number
*/

private ["_avg", "_sum", "_selector", "_i", "_i0", "_i1", "_n"];

_avg = 0;
_sum = 0;
_selector = { _this };
_i0 = 0;
_i1 = -1;

if ((count _this) > 1) then
{
   _selector = _this select 1;
};
if ((count _this) > 2) then
{
   _i0 = _this select 2;
};
if ((count _this) > 3) then
{
   _i1 = _this select 3;
};

_n = count (_this select 0);

if (_i1 < 1) then
{
   _i1 = _n - 1;
};

for "_i" from _i0 to _i1 do
{
   _sum = _sum + (((_this select 0) select _i) call _selector);
};

if (_n > 0) then
{
   _avg = _sum / _n;
};

//
_avg