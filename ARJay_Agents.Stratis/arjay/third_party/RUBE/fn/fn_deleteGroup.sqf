/*
   Author:
    rübe
   
   Description:
    deletes any assigned vehicles, all of the groups units and
    finally the group itself.
    
   Parameter(s):
    _this: group (group)
    
    OR
    
    _this select 0: group (group)
    _this select 1: delete vehicles (boolean)
    
   Returns:
    void
*/

private ["_group", "_deleteVehicles", "_vehicles"];

_group = _this;
_deleteVehicles = true;
if ((typeName _this) == "ARRAY") then
{
   _group = _this select 0;
   _deleteVehicles = _this select 1;
};

_vehicles = _group call RUBE_getGroupVehicles;

// delete all units
{
   deleteVehicle _x;
} forEach (units _group);

// delete all vehicles
if (_deleteVehicles && ((count _vehicles) > 0)) then
{
   {
      deleteVehicle _x;
   } forEach (_vehicles select 0);
};

// delete the group
deleteGroup _group;