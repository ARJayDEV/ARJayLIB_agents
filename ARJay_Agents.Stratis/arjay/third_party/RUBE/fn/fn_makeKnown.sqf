/*
   Author:
    rübe
    
   Description:
    makes a set of objects/groups known to each other and/or
    reveals only one-sided.
    
   Parameter(s):
    _this: know each other (array of objects and/or groups)
    
   OR (alternative syntax)
   
    _this select 0: know each other (array of objects and/or groups)
    _this select 1: targets (array of objects and/or groups)
   
   Returns:
    void
*/

private ["_known", "_targets", "_reveal", "_k", "_i", "_j"];

_known = _this;
_targets = [];

if ((count _this) == 0) exitWith {};

if ((typeName (_this select 0)) == "ARRAY") then
{
   _known = _this select 0;
   if ((count _this) > 1) then
   {
      _targets = _this select 1;
   };
};

// private function to reveal group or object
_reveal = {
   if ((typeName (_this select 1)) == "GROUP") then
   {
      //(_this select 0) reveal (leader (_this select 1));
      {
         (_this select 0) reveal _x;
      } forEach (units (_this select 1));
   } else
   {
      (_this select 0) reveal (_this select 1);
   };
};

// make known to each other
_k = count _known;

if (_k > 1) then
{
   for "_i" from 0 to (_k - 2) do
   {
      for "_j" from (_i + 1) to (_k - 1) do
      {
         [(_known select _i), (_known select _j)] call _reveal;
         [(_known select _j), (_known select _i)] call _reveal;
      };
   };
};

// reveal targets only
if ((count _targets) > 0) then
{
   for "_i" from 0 to (_k - 1) do
   {
      {
         [(_known select _i), _x] call _reveal;
      } forEach _targets;
   };
};