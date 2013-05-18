/*
   Author:
    rübe
    
   Description:
    supplies/adds armament (weapons and ammo/magazines) to a given object (ammocrate, vehicle, ...)
    
   Parameter(s):
    _this select 0: armament box/vehicle (object)
    _this select 1: weapons (array of [weapon, count])
    _this select 2: ammo/magazines (array of [ammo, count])
    _this select 3: clear box/vehicle armament first (boolean, optional, default = true)
    
   Returns:
    object (armament box/vehicle)
    
   Example:
    
    _ammoBox = [
       ("LocalBasicWeaponsBox" createVehicle [0, 0, 0]),
       [
          ["Binocular", 2],
          ["M16A4_GL", 1],
          ["M16A2GL", 1]
       ],
       [
          ["30Rnd_556x45_Stanag", 64],
          ["30Rnd_556x45_StanagSD", 32],
          ["HandGrenade_West", 12],
          ["1Rnd_HE_M203", 12],
          ["1Rnd_Smoke_M203", 12]
       ] 
    ] call RUBE_setArmament;
    
*/

private ["_obj", "_weapons", "_ammo", "_clear"];

_obj = _this select 0;
_weapons = _this select 1;
_ammo = _this select 2;
_clear = true;

if ((count _this) > 3) then
{
   _clear = _this select 3;
};

// clear armament object
if (_clear) then
{
   clearMagazineCargo _obj;
   clearWeaponCargo _obj;
};


// add ammo
{
   _obj addMagazineCargo _x;
} forEach _ammo;

// add weapons
{
   _obj addWeaponCargo _x;
} forEach _weapons;

// return obj
_obj