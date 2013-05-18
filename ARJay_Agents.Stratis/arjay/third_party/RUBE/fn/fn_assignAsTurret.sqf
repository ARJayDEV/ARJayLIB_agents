/*
   Author:
    rübe
    
   Description:
    well, still better than moveInTurret which simply teleports 
    the unit into a vehicle, this function at least makes the 
    unit walk there first.
    
   Parameter(s):
    _this select 0: unit (object)
    _this select 1: vehicle (object)
    _this select 2: turret path (array)
    
   Returns:
    boolean
*/

_this spawn  {
   private ["_unit", "_vehicle", "_path"];
   
   _unit = _this select 0;
   _vehicle = _this select 1;
   _path = _this select 2;
   
   doStop _unit;
   _unit commandMove (position _vehicle);

   
   waitUntil{(!(alive _unit) || (unitReady _unit))};
   
   _unit assignAsGunner _vehicle;
   [_unit] orderGetIn true;
   _unit moveInTurret [_vehicle, _path];
};

true