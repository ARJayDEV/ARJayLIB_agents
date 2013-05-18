/*
   Author:
    rübe
    
   Description:
    returns all vehicles any unit in the given group is assigned to
    and a list of the vehicles roles (driver and turrets, which includes
    commanders or the ordinary "gunner", and cargo).
    
   Parameter(s):
    _this: group
    
   Returns:
    empty array if no vehicles are assigned OR
    [
       0: array of vehicles,
       1: array of [unit, vehicle, role] where
          role is: ["Driver"]
                   ["Commander", turretPath],
                   ["Gunner", turretPath],
                   ["Turret", turretPath],
                   ["Cargo"]
    ]
*/

private ["_group", "_vehicles", "_roles", "_assigned"];

_group = _this;
_vehicles = [];
_roles = [];

// search all vehicles
{
   _assigned = assignedVehicle _x;
   if (!(isNull _assigned)) then
   {
      if (!(_assigned in _vehicles)) then
      {
         _vehicles set [(count _vehicles), _assigned];
      };
   };
} forEach (units _group);

// return if no vehicles were found
if ((count _vehicles) == 0) exitWith
{
   []
};

// get roles
{
   private ["_veh", "_avr"];
   _veh = _x;
   {
      _avr = assignedVehicleRole _x;
      if ((count _avr) > 0) then
      {
         if ((_avr select 0) == "Turret") then
         {
            switch (true) do
            {
               case ((commander _veh) == _x):
               {
                  _avr set [0, "Commander"];
               };
               case ((gunner _veh) == _x):
               {
                  _avr set [0, "Gunner"];
               };
            };
         };
         _roles set [(count _roles), [_x, _veh, _avr]];
      } else
      {
         _roles set [(count _roles), [_x, _veh, ["Cargo"]]];
      };
   } forEach (crew _x);
} forEach _vehicles;

// return
[_vehicles, _roles]