/*
   Author:
    rübe
    
   Description:
    returns the assigned units of a given vehicle and desired vehicle role
    
   Parameter(s):
    _this select 0: vehicle (object)
    _this select 1: desired positions (string OR array of strings)
                    - string in ["cargo", "commander", "driver", "gunner"]
                    - optional, default = all
                    
   Returns:
    array of units
*/

private ["_vehicle", "_roles", "_units", "_register"];

_vehicle = _this select 0;
_roles = [];
_units = [];

// private function
_register = {
   switch (typeName _this) do
   {
      case "ARRAY": 
      {
         if ((count _this) > 0) then
         {
            _units = _units + _this;
         };
      };
      case "OBJECT":
      {
         if (!isNull _this) then
         {
            _units = _units + [_this];
         };
      };
   };
};

if ((count _this) > 1) then
{
   switch (typeName (_this select 1)) do
   {
      case "ARRAY":  { _roles = _this select 1; };
      case "STRING": { _roles = [(_this select 1)]; };
   };
};

if ((count _roles) == 0) then
{
   _roles = ["cargo", "commander", "driver", "gunner"];
};

// get desired vehicle roles
if ("cargo" in _roles) then { (assignedCargo _vehicle) call _register; };
if ("commander" in _roles) then { (assignedCommander _vehicle) call _register; };
if ("driver" in _roles) then { (assignedDriver _vehicle) call _register; };
if ("gunner" in _roles) then { (assignedGunner _vehicle) call _register; };

// return units
_units