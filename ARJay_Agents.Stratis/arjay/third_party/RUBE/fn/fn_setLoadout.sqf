/*
  Author:
   rübe
   
  Description:
   sets/adds to a units loadout
   
  Parameters:
   _this select 0: unit
   _this select 1: weapons (array of strings/weapon-classes)
   _this select 2: magazines (array of array [strings/magazine-classes, count])
   _this select 3: remove all weapons first (boolean; optional, default = true)

   Returns:
    unit
*/

private ["_unit", "_weapons", "_mags", "_clear", "_primary", "_muzzles", "_i"];

_unit = _this select 0;
_weapons = _this select 1;
_mags = _this select 2;
_clear = true;

if ((count _this) > 3) then
{
   _clear = _this select 3;
};

if (_clear) then
{
   removeAllWeapons _unit;
};

{
   for "_i" from 1 to (_x select 1) do
   {
      _unit addMagazine (_x select 0);
   };   
} forEach _mags;

{
   _unit addWeapon _x;
} forEach _weapons;

// select primary weapon
_primary = primaryWeapon _unit;
if (_primary != "") then
{
   /*
   _muzzles = getArray (configFile >> "CfgWeapons" >> _primary >> "muzzles");
   if ((count _muzzles) > 0) then
   {
      _unit selectWeapon (_muzzles select 0);
   } else {
      _unit selectWeapon _primary;
   };
   */
   _unit selectWeapon _primary;
};

_unit