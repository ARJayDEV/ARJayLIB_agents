/*
   *** modified to return a crew of a given faction, even if the
       vehicle is from another one and some other tweaks here
       and there... ***
       
	Author: Joris-Jan van 't Land

	Description:
	Function to spawn a certain vehicle type with all crew (including turrets).
	The vehicle can either become part of an existing group or create a new group.

	Parameter(s):
	_this select 0: desired position (Array).
	_this select 1: desired azimuth (Number).
	_this select 2: type of the vehicle (String).
	_this select 3: side or existing group (Side or Group).
	_this select 4: faction (string)
	_this select 5: air settings fly?, optional (false OR [[speed, z-speed], height])
	                - default: in air with different speed/height for rotary and static

	Returns:
	Array:
	0: new vehicle (Object).
	1: all crew (Array of Objects).
	2: vehicle's group (Group).
*/

//Validate parameter count
if ((count _this) < 4) exitWith {debugLog "Log: [spawnVehicle] Function requires at least 4 parameters!"; []};

private ["_pos", "_azi", "_type", "_param4", "_faction", "_inAir", "_airSettings", "_grp", "_side", "_newGrp"];
_pos = _this select 0;
_azi = _this select 1;
_type = _this select 2;
_param4 = _this select 3;
_faction = _this select 4;
_inAir = true;
_airSettings = [];
if ((count _this) > 5) then
{
   if ((typeName (_this select 5)) == "ARRAY") then
   {
      _airSettings = _this select 5;
   } else {
      _inAir = _this select 5;
   };
};

//Determine if an actual group was passed or a new one should be created.
if ((typeName _param4) == "SIDE") then
{
	_side = _param4;
	_grp = createGroup _side;
	_newGrp = true;
}
else
{
	_grp = _param4;
	_side = side _grp;
	_newGrp = false;
};

//Validate parameters
if ((typeName _pos) != (typeName [])) exitWith {debugLog "Log: [spawnVehicle] Position (0) must be an Array!"; []};
if ((typeName _azi) != (typeName 0)) exitWith {debugLog "Log: [spawnVehicle] Azimuth (1) must be a Number!"; []};
if ((typeName _type) != (typeName "")) exitWith {debugLog "Log: [spawnVehicle] Type (2) must be a String!"; []};
if ((typeName _grp) != (typeName grpNull)) exitWith {debugLog "Log: [spawnVehicle] Group (3) must be a Group!"; []};

private ["_sim", "_veh", "_crew"];
_sim = getText(configFile >> "CfgVehicles" >> _type >> "simulation");


//Make sure aircraft start at a reasonable height and speed
switch (true) do
{
   case (_inAir && (_sim == "helicopter")):
   {
      if ((count _airSettings) > 0) then
      {
         _pos set [2, (_airSettings select 1)];
         _veh = createVehicle [_type, _pos, [], 0, "FLY"];
         _veh setVelocity [
            ((_airSettings select 0) select 0) * (sin _azi), 
            ((_airSettings select 0) select 0) * (cos _azi), 
            ((_airSettings select 0) select 1)
         ];
      } else {
         _pos set [2, 50];
         _veh = createVehicle [_type, _pos, [], 0, "FLY"];
         _veh setVelocity [5 * (sin _azi), 5 * (cos _azi), 0];
      };
   };
   case (_inAir && (_sim == "airplane")):
   {
      if ((count _airSettings) > 0) then
      {
         _pos set [2, (_airSettings select 1)];
         _veh = createVehicle [_type, _pos, [], 0, "FLY"];
         _veh setVelocity [
            ((_airSettings select 0) select 0) * (sin _azi), 
            ((_airSettings select 0) select 0) * (cos _azi), 
            ((_airSettings select 0) select 1)
         ];
      } else {
         _pos set [2, 85];
         _veh = createVehicle [_type, _pos, [], 0, "FLY"];
         _veh setVelocity [90 * (sin _azi), 90 * (cos _azi), 0];
      };
   };
   default
   {
      _veh = _type createVehicle _pos;
   };
};

//Set the correct direction.
_veh setDir _azi;

//Make sure the vehicle is where it should be.
_veh setPos _pos;

//Spawn the crew and add the vehicle to the group.
_crew = [_veh, _grp, _faction] call RUBE_spawnCrew;
_grp addVehicle _veh;

//If this is a new group, select a leader.
if (_newGrp) then
{
	_grp selectLeader (commander _veh);
};

// unlock the vehicle for players per default
_veh setVehicleLock "UNLOCKED";

// RUBE_auto-droppable?
if (RUBE_ENABLE_AUTO_DROPABLE && (_type in RUBE_TYPELIST_DROPABLE)) then
{
   [_veh] call RUBE_makeDroppable;
};

[_veh, _crew, _grp]