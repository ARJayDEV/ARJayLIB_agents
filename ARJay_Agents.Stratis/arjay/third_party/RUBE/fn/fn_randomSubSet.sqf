/*
  Author:
   rübe
   
  Description:
   returns a random subset of a given list
   
  Parameters:
   _this select 0: list of any (array)
   _this select 1: proportion of subset (number from 0.0 to 1.0, optional: default = 0.25 + (random 0.5))
   
  Note:
   - you may get an empty array back if the given list consists of too few objects! 
   
  Returns:
   array
*/

private ["_subset", "_list", "_proportion", "_n", "_i", "_obj"];

_subset = [];
_list = _this select 0;
_proportion = 0.25 + (random 0.5);
if ((count _this) > 1) then
{
   _proportion = _this select 1;
};

_n = round ((count _list) * _proportion);
_i = 0;

while {(count _subset) < _n} do
{
   _obj = _list call RUBE_randomSelect;
   if (!(_obj in _subset)) then
   {
      _subset set [_i, _obj];
      _i = _i + 1;
   };
};

//
_subset