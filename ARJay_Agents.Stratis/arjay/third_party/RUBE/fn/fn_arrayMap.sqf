/*
   Author:
    rübe
    
   Description:
    applys a function to every item in an array, altering
    the original array per default.
    
   Parameter(s):
    _this select 0: list (array)
    _this select 1: function (code)
    _this select 2: copy (boolean, optional; default = false)
    
   Returns:
    array
*/

private ["_list"];

_list = _this select 0;

if ((count _this) > 2) then
{
   if (_this select 2) then
   {
      _list = +(_this select 0);
   };
};

for "_i" from 0 to ((count _list) - 1) do
{
   _list set [_i, ((_list select _i) call (_this select 1))];
};

_list