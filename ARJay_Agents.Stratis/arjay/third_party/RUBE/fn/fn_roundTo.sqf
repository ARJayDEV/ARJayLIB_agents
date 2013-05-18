/*
  Author:
   rübe
   
  Description:
   round a given value to the next value that divides to a given factor.
  
  Parameters:
   _this select 0: value (number)
   _this select 1: factor/divisor (number)
   _this select 2: mode (optional, default = round)
                   - mode in ["round", "floor", "ceil"]
   
  Example:
   _v = [8.33, 0.25] call RUBE_rountTo;
   // _v = 8.25
*/

private ["_value", "_factor", "_mode", "_mod"];

_value = _this select 0;
_factor = _this select 1;
_mode = "round";
if ((count _this) > 2) then
{
   _mode = _this select 2;
};

_mod = _value % _factor;

switch (_mode) do
{
   case "floor":
   {
      _value = _value - _mod;
   };
   case "ceil":
   {
      _value = _value + (_factor - _mod);
   };
   default
   {
      if (_mod > (_factor * 0.5)) then
      {
         _value = _value + (_factor - _mod);
      } else {
         _value = _value - _mod;
      };
   };
};

_value