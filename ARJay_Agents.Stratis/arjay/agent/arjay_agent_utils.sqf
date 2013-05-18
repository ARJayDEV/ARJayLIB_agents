/*
	File: arjay_move.sqf
	Author: ARJay
	Description: Utility methods for agents
*/

/*
	Add waypoint
*/
arjay_agentAddWaypoint = 
{
	private ["_group", "_position", "_radius", "_type", "_formation", "_behaviour", "_combatMode", "_speed",  "_completionRadius", "_timeout", "_description", "_waypoints", "_waypoint"];

	_group = _this select 0;
	_position = _this select 1;
	_radius = if(count _this > 2) then {_this select 2} else {0};
	_type = if(count _this > 3) then {_this select 3} else {"MOVE"};
	_formation = if(count _this > 4) then {_this select 4} else {"COLUMN"};
	//_behaviour = if(count _this > 5) then {_this select 5} else {"SAFE"}; // bugged
	_combatMode = if(count _this > 6) then {_this select 6} else {"NO CHANGE"};
	_speed = if(count _this > 7) then {_this select 7} else {"LIMITED"};
	_completionRadius = if(count _this > 8) then {_this select 8} else {-1};
	_timeout = if(count _this > 9) then {_this select 9} else {[]};
	_description = if(count _this > 10) then {_this select 10} else {""};
	
	_waypoint = _group addWaypoint [_position, _radius];
	_waypoint setWaypointDescription _description;
	
	if (_type != "") then { _waypoint setWaypointType _type; };
	if (_formation != "") then { _waypoint setWaypointFormation _formation;	};
	//if (_behaviour != "") then { _waypoint setWaypointBehaviour _behaviour; }; // bugged
	if (_combatMode != "") then	{ _waypoint setWaypointCombatMode _combatMode; };
	if (_speed != "") then { _waypoint setWaypointSpeed _speed;	};
	if (_completionRadius >= 0) then { _waypoint setWaypointCompletionRadius _completionRadius;	};
	if ((count _timeout) == 3) then	{ _waypoint setWaypointTimeout _timeout; };
	
	
	_group setCurrentWaypoint _waypoint;

	_waypoint
};

/*
	Clear waypoints
*/
arjay_agentClearWaypoints = 
{
	private ["_group"];
	
	_group = _this select 0;
	
	while { count (waypoints _group) > 0 } do
	{
		deleteWaypoint ((waypoints _group) select 0);
	};
};

/*
	Get suitable task building for an agent
*/
arjay_agentGetNearestTaskBuildings = 
{		
	private ["_target", "_taskBuildings", "_radius", "_foundBuildings", "_nearBuildings", "_className"];
	
	_target = _this select 0;
	_taskBuidlings = _this select 1;
	_radius = if(count _this > 2) then {_this select 2} else {500};
	
	_foundBuildings = [];
	
	while {count _foundBuildings == 0} do
	{
		_nearBuildings = (getPos _target) nearObjects ["House_F", _radius];
		
		// find any task buidlings within the radius
		if(count _nearBuildings > 0) then
		{
			{
				_className = typeOf _x;
				if(_className in _taskBuidlings) then
				{
					// debug ----------------------------------------------------------------------------------------------------------------------------
					//if(arjay_debug && (arjay_debugLevel == 4 || arjay_debugLevel > 10)) then {["FOUND TASK BUILDING [%1] IN RADIUS %2",_className, _radius] call arjay_dump;};
					// debug ----------------------------------------------------------------------------------------------------------------------------
					
					_foundBuildings set [count _foundBuildings, _x];
				};			
			} forEach _nearBuildings;		
		};
		
		if(count _foundBuildings == 0) then
		{
			_radius = _radius + 1000;
		};
	};
	
	_foundBuildings
};

/*
	Get suitable vehicle for an agent
*/
arjay_agentGetVehicle = 
{		
	private ["_target", "_type", "_radius", "_agentId", "_profile", "_vehicle", "_nearVehicles"];
	
	_target = _this select 0;
	_type = _this select 1;
	_radius = if(count _this > 2) then {_this select 2} else {500};
	
	_agentId = vehicleVarName _target;
	_profile = [arjay_agentProfiles, _agentId] call Dictionary_fnc_get;
	_vehicle = [_profile, "vehicle"] call Dictionary_fnc_get;
	_vehicle = [arjay_agentVehicles, _vehicle] call Dictionary_fnc_get;
	
	scopeName "main";
	
	if!(isNull _vehicle) then
	{	
		if(!(_vehicle isKindOf _type) || !(alive _vehicle)) then
		{
			_nearVehicles = (getPos _target) nearObjects [_type,_radius];	
			{
				_vehicle = _x;
				breakTo "main";
			} forEach _nearVehicles;
		}
	}
	else
	{
		_nearVehicles = (getPos _target) nearObjects [_type,_radius];		
		{
			_vehicle = _x;
			breakTo "main";
		} forEach _nearVehicles;
	};
	
	_vehicle
};

/*
	Get suitable vehicle for an agent
*/
arjay_agentGetOwnVehicle = 
{		
	private ["_target", "_agentId", "_profile", "_vehicle", "_result"];
	
	_target = _this select 0;
	
	_agentId = vehicleVarName _target;
	_profile = [arjay_agentProfiles, _agentId] call Dictionary_fnc_get;
	_vehicle = [_profile, "vehicle"] call Dictionary_fnc_get;
	_vehicle = [arjay_agentVehicles, _vehicle] call Dictionary_fnc_get;
	_result = objNull;

	if!(isNull _vehicle) then
	{	
		if(alive _vehicle) exitWith
		{
			_result = _vehicle
		};
	};
	
	_result
};

/*
	Gets a meeting partner
*/
arjay_agentGetMeetingPartner = 
{
	private ["_target", "_agentId", "_profile", "_partnerFound", "_nearUnits"];
	
	_target = _this select 0;
	
	_agentId = vehicleVarName _target;
	_profile = [arjay_agentProfiles, _agentId] call Dictionary_fnc_get;
	_partnerFound = false;
	scopeName "main";
	
	_nearUnits = nearestObjects [_target, ["C_man_1"], 100];
	
	{		
		_profile = _x getVariable ["arjay_agentProfile", []];
		if(count _profile > 0 && (vehicleVarName _target != vehicleVarName _x) && alive _x) then
		{
			// debug ----------------------------------------------------------------------------------------------------------------------------
			//if(arjay_debug && (arjay_debugLevel == 4 || arjay_debugLevel > 10)) then {["%1 - request meeting with %2", vehicleVarName _target, vehicleVarName _x] call arjay_dump;};
			// debug ----------------------------------------------------------------------------------------------------------------------------
			
			_x setVariable ["arjay_agentMeetingRequested", true, false];
			_x setVariable ["arjay_agentMeetingTarget", _target, false];
			_partnerFound = true;
			breakTo "main";
		}		
	} forEach _nearUnits;
	
	if!(_partnerFound) then
	{
		_target setVariable ["arjay_agentMeetingComplete", true, false];
	};
};

/*
	Gets gathering partners
*/
arjay_agentGetGatheringPartners = 
{
	private ["_target", "_nearUnits", "_profile", "_partners"];
	
	_target = _this select 0;
	
	_nearUnits = nearestObjects [_target, ["C_man_1"], 100];
	_partners = [];
	
	{		
		_profile = _x getVariable ["arjay_agentProfile", []];
		if(count _profile > 0 && (vehicleVarName _target != vehicleVarName _x) && alive _x) then
		{
			// debug ----------------------------------------------------------------------------------------------------------------------------
			//if(arjay_debug && (arjay_debugLevel == 4 || arjay_debugLevel > 10)) then {["%1 - request gathering with %2", vehicleVarName _target, vehicleVarName _x] call arjay_dump;};
			// debug ----------------------------------------------------------------------------------------------------------------------------
			
			_x setVariable ["arjay_agentGatheringComplete", false, false];
			_x setVariable ["arjay_agentGatheringRequested", true, false];
			_x setVariable ["arjay_agentGatheringTarget", _target, false];
			
			_partners set [count _partners, _x];
		}		
	} forEach _nearUnits;
	
	_partners
};

/*
	Gets a random nearby target
*/
arjay_agentGetRandomTarget = 
{
	private ["_target", "_radius", "_probTargetPlayer", "_player", "_knows", "_randomTarget", "_nearTargets"];
	
	_target = _this select 0;
	_radius = _this select 1;
	
	_probTargetPlayer = 0.1;
	_player = arjay_players select (random((count arjay_players)-1));
	_knows = _target knowsAbout _player;
	_randomTarget = objNull;
	
	if(random 1 < _probTargetPlayer && _knows > 0) then 
	{
		_randomTarget = _player;
	}
	else
	{
		_nearTargets = (getPos _target) nearObjects ["Man",50];		
		_nearTargets = _nearTargets - [_target];
		
		if((count _nearTargets) > 0) then
		{	
			_randomTarget = _nearTargets select (random((count _nearTargets)-1));
		}
	};
	
	// debug ----------------------------------------------------------------------------------------------------------------------------
	//if(arjay_debug && (arjay_debugLevel == 4 || arjay_debugLevel > 10)) then {["%1 - found nearby random target: %2", vehicleVarName _target, _randomTarget] call arjay_dump;};
	// debug ----------------------------------------------------------------------------------------------------------------------------
	
	_randomTarget
};

/*
	Gets a random nearby player
*/
arjay_agentGetRandomPlayer = 
{
	private ["_target", "_probTargetPlayer", "_player", "_knows", "_randomTarget"];
	
	_target = _this select 0;
	
	_player = arjay_players select (random((count arjay_players)-1));
	_knows = _target knowsAbout _player;
	_randomTarget = objNull;
	
	if(_knows > 0) then 
	{
		_randomTarget = _player;
	};
	
	// debug ----------------------------------------------------------------------------------------------------------------------------
	//if(arjay_debug && (arjay_debugLevel == 4 || arjay_debugLevel > 10)) then {["%1 - found nearby random target: %2", vehicleVarName _target, _randomTarget] call arjay_dump;};
	// debug ----------------------------------------------------------------------------------------------------------------------------
	
	_randomTarget
};

/*
	Outputs a snapshot of the various data structures
*/
arjay_agentDataStructureSnapShot = 
{
	private ["_target", "_probTargetPlayer", "_player", "_knows", "_randomTarget"];
	
	[""] call arjay_dump;
	["--- DATA STRUCTURE SNAPSHOT STARTED -------------------------------------------------------------------------------"] call arjay_dump;
	[""] call arjay_dump;
	
		
	// location
	["--- arjay_missionLocations"] call arjay_dump;
	{
		["key: %1 value: %2",_x, ([arjay_missionLocations, _x] call Dictionary_fnc_get) ] call arjay_dump;
	} forEach (arjay_missionLocations select 0);
	
	["-------------------------------------------------------------------------------------------------------------------"] call arjay_dump;
	["--- arjay_agentInitialisedLocations"] call arjay_dump;
	{
		["key: %1 value: %2",_x, ([arjay_agentInitialisedLocations, _x] call Dictionary_fnc_get) ] call arjay_dump;
	} forEach (arjay_agentInitialisedLocations select 0);
	
	["-------------------------------------------------------------------------------------------------------------------"] call arjay_dump;
	["--- arjay_agentActiveLocations"] call arjay_dump;
	{
		["key: %1 value: %2",_x, ([arjay_agentActiveLocations, _x] call Dictionary_fnc_get) ] call arjay_dump;
	} forEach (arjay_agentActiveLocations select 0);
	
	
	// global
	["-------------------------------------------------------------------------------------------------------------------"] call arjay_dump;
	["--- arjay_agentProfiles"] call arjay_dump;
	{
		["key: %1 value: %2",_x, ([arjay_agentProfiles, _x] call Dictionary_fnc_get select 1) ] call arjay_dump;
	} forEach (arjay_agentProfiles select 0);
	
	["-------------------------------------------------------------------------------------------------------------------"] call arjay_dump;
	["--- arjay_agentVehicleProfiles"] call arjay_dump;
	{
		["key: %1 value: %2",_x, ([arjay_agentVehicleProfiles, _x] call Dictionary_fnc_get select 1) ] call arjay_dump;
	} forEach (arjay_agentVehicleProfiles select 0);
	
	["-------------------------------------------------------------------------------------------------------------------"] call arjay_dump;
	["--- arjay_agents"] call arjay_dump;
	{
		["key: %1 value: %2",_x, ([arjay_agents, _x] call Dictionary_fnc_get) ] call arjay_dump;
	} forEach (arjay_agents select 0);
	
	["-------------------------------------------------------------------------------------------------------------------"] call arjay_dump;
	["--- arjay_agentVehicles"] call arjay_dump;
	{
		["key: %1 value: %2",_x, ([arjay_agentVehicles, _x] call Dictionary_fnc_get) ] call arjay_dump;
	} forEach (arjay_agentVehicles select 0);
	
	["-------------------------------------------------------------------------------------------------------------------"] call arjay_dump;
	["--- arjay_agentsKIA"] call arjay_dump;
	{
		["key: %1 value: %2",_x, ([arjay_agentsKIA, _x] call Dictionary_fnc_get) ] call arjay_dump;
	} forEach (arjay_agentsKIA select 0);
	
	
	// civilian
	["-------------------------------------------------------------------------------------------------------------------"] call arjay_dump;
	["--- arjay_agentCommandStates"] call arjay_dump;
	{
		["key: %1 value: %2",_x, ([arjay_agentCommandStates, _x] call Dictionary_fnc_get) ] call arjay_dump;
	} forEach (arjay_agentCommandStates select 0);
	
	["-------------------------------------------------------------------------------------------------------------------"] call arjay_dump;
	["--- arjay_agentsCivilianActive"] call arjay_dump;
	{
		["value: %1",_x] call arjay_dump;
	} forEach (arjay_agentsCivilianActive);
	
	["-------------------------------------------------------------------------------------------------------------------"] call arjay_dump;
	["--- arjay_agentsCivilianByLocation"] call arjay_dump;
	{
		["key: %1 value: %2",_x, ([arjay_agentsCivilianByLocation, _x] call Dictionary_fnc_get) ] call arjay_dump;
	} forEach (arjay_agentsCivilianByLocation select 0);
	
	["-------------------------------------------------------------------------------------------------------------------"] call arjay_dump;
	["--- arjay_agentsCivilianVehiclesByLocation"] call arjay_dump;
	{
		["key: %1 value: %2",_x, ([arjay_agentsCivilianVehiclesByLocation, _x] call Dictionary_fnc_get) ] call arjay_dump;
	} forEach (arjay_agentsCivilianVehiclesByLocation select 0);
	
	
	// east
	["-------------------------------------------------------------------------------------------------------------------"] call arjay_dump;
	["--- arjay_agentsEastActive"] call arjay_dump;
	{
		["value: %1",_x] call arjay_dump;
	} forEach (arjay_agentsEastActive);
	
	["-------------------------------------------------------------------------------------------------------------------"] call arjay_dump;
	["--- arjay_agentsEastByLocation"] call arjay_dump;
	{
		["key: %1 value: %2",_x, ([arjay_agentsEastByLocation, _x] call Dictionary_fnc_get) ] call arjay_dump;
	} forEach (arjay_agentsEastByLocation select 0);
	
	["-------------------------------------------------------------------------------------------------------------------"] call arjay_dump;
	["--- arjay_agentsEastVehiclesByLocation"] call arjay_dump;
	{
		["key: %1 value: %2",_x, ([arjay_agentsEastVehiclesByLocation, _x] call Dictionary_fnc_get) ] call arjay_dump;
	} forEach (arjay_agentsEastVehiclesByLocation select 0);
	
	
	// west
	["-------------------------------------------------------------------------------------------------------------------"] call arjay_dump;
	["--- arjay_agentsWestActive"] call arjay_dump;
	{
		["value: %1",_x] call arjay_dump;
	} forEach (arjay_agentsWestActive);	
	
	["-------------------------------------------------------------------------------------------------------------------"] call arjay_dump;
	["--- arjay_agentsWestByLocation"] call arjay_dump;
	{
		["key: %1 value: %2",_x, ([arjay_agentsWestByLocation, _x] call Dictionary_fnc_get) ] call arjay_dump;
	} forEach (arjay_agentsWestByLocation select 0);
		
	["-------------------------------------------------------------------------------------------------------------------"] call arjay_dump;
	["--- arjay_agentsWestVehiclesByLocation"] call arjay_dump;
	{
		["key: %1 value: %2",_x, ([arjay_agentsWestVehiclesByLocation, _x] call Dictionary_fnc_get) ] call arjay_dump;
	} forEach (arjay_agentsWestVehiclesByLocation select 0);

	
	[""] call arjay_dump;
	["--- DATA STRUCTURE SNAPSHOT COMPLETE ------------------------------------------------------------------------------"] call arjay_dump;
	[""] call arjay_dump;
};