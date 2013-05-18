/*
  Author:
   rübe
   
  Description:
   removes specific weapons for all units
   
  Parameters:
   _this select 0: unit or list of units (vehicle OR array-of-vehicles)
   _this select 1: weapon to be removed (string-of-weapon OR array [weapon, mags])
   _this select n: more weapons to be removed
*/

private ["_units", "_n", "_unit", "_weapon"];

_units = _this select 0;
if ((typeName _units) != "ARRAY") then
{
   _units = [(_this select 0)];
};


_n = (count _this) - 1;

{
   _unit = _x;
   for "_i" from 1 to _n do {
      _weapon = _this select _i;

      if ((typeName _weapon) == "ARRAY") then
      {
         if ((_weapon select 1) != "") then
         {
            while {(_weapon select 1) in (magazines _unit)} do {
               _unit removeMagazines (_weapon select 1);
            };
         };
         if ((_weapon select 0) != "") then
         {         
            while {_unit hasWeapon (_weapon select 0)} do {
               _unit removeWeapon (_weapon select 0);
            };
         };
      } else {
         while {_unit hasWeapon _weapon} do {
            _unit removeWeapon _weapon;
         };
      };
   };
} forEach _units;

//
true