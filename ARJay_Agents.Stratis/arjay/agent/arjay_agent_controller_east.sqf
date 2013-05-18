/*
	File: arjay_agent_controller_east.sqf
	Author: ARJay
	Description: East Controller
	
	This is a bit of a experiment to get maximum performance out of the arma scheduling system
	The issue is that there may be updwards of 50 active individual civilian agents at any one time
	To handle AI decision making for such a large amount of agents I have tried to avoid
	FSM's (non-scheduled, conditions checked every frame), Spawned functions (scheduled, but 50 running at once!!)
	So I have built this little controller to handle all active faction agents, it runs in a loop with sleeps
	All variables associated with an individual agents AI command are stored in arjay_agentCommandStates to simulate scope 
	so the AI task can be tracked at a later point in time. A bit of an abomination, but reasonably fast for handling large numbers
	of agents without bringing a server to its knees
*/

arjay_agentEastAllowedCommands = ["WALK", "HOUSEWORK", "LOCATION_PATROL", "GARISON_DEFENSIVE_POSITIONS", "MAN_STATIC_WEAPON", "REMOTE_LOCATION_PATROL", "AIR_PATROL"];
//arjay_agentEastAllowedCommands = ["REMOTE_LOCATION_PATROL"];
arjay_agentEastMoveTimeout = 40;
arjay_agentEastDriveTimeout = 1000;
arjay_agentEastCommands = call Dictionary_fnc_new;

// walk [probability, maxDistance]
arjay_agentEastCommand = call Dictionary_fnc_new;
[arjay_agentEastCommand, "DAY", [0.1, 200]] call Dictionary_fnc_set;
[arjay_agentEastCommand, "EVENING", [0.1, 200]] call Dictionary_fnc_set;
[arjay_agentEastCommand, "NIGHT", [0.1, 200]] call Dictionary_fnc_set;
[arjay_agentEastCommands, "WALK", arjay_agentEastCommand] call Dictionary_fnc_set;

// housework [probability]
arjay_agentEastCommand = call Dictionary_fnc_new;
[arjay_agentEastCommand, "DAY", [0.1]] call Dictionary_fnc_set;
[arjay_agentEastCommand, "EVENING", [0.5]] call Dictionary_fnc_set;
[arjay_agentEastCommand, "NIGHT", [0.1]] call Dictionary_fnc_set;
[arjay_agentEastCommands, "HOUSEWORK", arjay_agentEastCommand] call Dictionary_fnc_set;

// location patrol
arjay_agentEastCommand = call Dictionary_fnc_new;
[arjay_agentEastCommand, "DAY", [0.3]] call Dictionary_fnc_set;
[arjay_agentEastCommand, "EVENING", [0.3]] call Dictionary_fnc_set;
[arjay_agentEastCommand, "NIGHT", [0.1]] call Dictionary_fnc_set;
[arjay_agentEastCommands, "LOCATION_PATROL", arjay_agentEastCommand] call Dictionary_fnc_set;

// garison defensive positions
arjay_agentEastCommand = call Dictionary_fnc_new;
[arjay_agentEastCommand, "DAY", [0.1, 1000]] call Dictionary_fnc_set;
[arjay_agentEastCommand, "EVENING", [0.1, 1000]] call Dictionary_fnc_set;
[arjay_agentEastCommand, "NIGHT", [0.1, 1000]] call Dictionary_fnc_set;
[arjay_agentEastCommands, "GARISON_DEFENSIVE_POSITIONS", arjay_agentEastCommand] call Dictionary_fnc_set;

// man static weapon
arjay_agentEastCommand = call Dictionary_fnc_new;
[arjay_agentEastCommand, "DAY", [0.1, 1000]] call Dictionary_fnc_set;
[arjay_agentEastCommand, "EVENING", [0.1, 1000]] call Dictionary_fnc_set;
[arjay_agentEastCommand, "NIGHT", [0.1, 1000]] call Dictionary_fnc_set;
[arjay_agentEastCommands, "MAN_STATIC_WEAPON", arjay_agentEastCommand] call Dictionary_fnc_set;

// board ground vehicle
arjay_agentEastCommand = call Dictionary_fnc_new;
[arjay_agentEastCommand, "DAY", ["GROUND", 10]] call Dictionary_fnc_set;
[arjay_agentEastCommand, "EVENING", ["GROUND", 10]] call Dictionary_fnc_set;
[arjay_agentEastCommand, "NIGHT", ["GROUND", 10]] call Dictionary_fnc_set;
[arjay_agentEastCommands, "BOARD_GROUND_VEHICLE", arjay_agentEastCommand] call Dictionary_fnc_set;

// board air vehicle
arjay_agentEastCommand = call Dictionary_fnc_new;
[arjay_agentEastCommand, "DAY", ["AIR", 10]] call Dictionary_fnc_set;
[arjay_agentEastCommand, "EVENING", ["AIR", 10]] call Dictionary_fnc_set;
[arjay_agentEastCommand, "NIGHT", ["AIR", 10]] call Dictionary_fnc_set;
[arjay_agentEastCommands, "BOARD_AIR_VEHICLE", arjay_agentEastCommand] call Dictionary_fnc_set;

// board sea vehicle
arjay_agentEastCommand = call Dictionary_fnc_new;
[arjay_agentEastCommand, "DAY", ["SEA", 10]] call Dictionary_fnc_set;
[arjay_agentEastCommand, "EVENING", ["SEA", 10]] call Dictionary_fnc_set;
[arjay_agentEastCommand, "NIGHT", ["SEA", 10]] call Dictionary_fnc_set;
[arjay_agentEastCommands, "BOARD_SEA_VEHICLE", arjay_agentEastCommand] call Dictionary_fnc_set;

// dismount vehicle
arjay_agentEastCommand = call Dictionary_fnc_new;
[arjay_agentEastCommand, "DAY", [10]] call Dictionary_fnc_set;
[arjay_agentEastCommand, "EVENING", [10]] call Dictionary_fnc_set;
[arjay_agentEastCommand, "NIGHT", [10]] call Dictionary_fnc_set;
[arjay_agentEastCommands, "DISMOUNT_VEHICLE", arjay_agentEastCommand] call Dictionary_fnc_set;

// remote location patrol
arjay_agentEastCommand = call Dictionary_fnc_new;
[arjay_agentEastCommand, "DAY", [0.1, 500]] call Dictionary_fnc_set;
[arjay_agentEastCommand, "EVENING", [0.1, 3000]] call Dictionary_fnc_set;
[arjay_agentEastCommand, "NIGHT", [0.1, 3000]] call Dictionary_fnc_set;
[arjay_agentEastCommands, "REMOTE_LOCATION_PATROL", arjay_agentEastCommand] call Dictionary_fnc_set;

// building patrol
arjay_agentEastCommand = call Dictionary_fnc_new;
[arjay_agentEastCommand, "DAY", [20]] call Dictionary_fnc_set;
[arjay_agentEastCommand, "EVENING", [20]] call Dictionary_fnc_set;
[arjay_agentEastCommand, "NIGHT", [20]] call Dictionary_fnc_set;
[arjay_agentEastCommands, "BUILDING_PATROL", arjay_agentEastCommand] call Dictionary_fnc_set;

// air patrol
arjay_agentEastCommand = call Dictionary_fnc_new;
[arjay_agentEastCommand, "DAY", [0.1, 6000]] call Dictionary_fnc_set;
[arjay_agentEastCommand, "EVENING", [0.1, 6000]] call Dictionary_fnc_set;
[arjay_agentEastCommand, "NIGHT", [0.1, 6000]] call Dictionary_fnc_set;
[arjay_agentEastCommands, "AIR_PATROL", arjay_agentEastCommand] call Dictionary_fnc_set;

/*
	Start the AI command controller
*/
arjay_agentControllerEast =
{
	private ["_handle"];
	
	_handle = [] spawn 
	{
		private ["_agent", "_agentBusy"];
		
		// debug ----------------------------------------------------------------------------------------------------------------------------
		//if(arjay_debug) then {["--- EAST CONTROLLER INIT --------------------------------------------------------------------------"] call arjay_dump;};
		// debug ----------------------------------------------------------------------------------------------------------------------------
		
		while { true } do
		{		
			{
				_agent = [arjay_agents, _x] call Dictionary_fnc_get;

				_agentBusy = _agent getVariable "arjay_agentBusy";	
				
				if!(_agentBusy) then
				{
					// issue a new command
					[_x, _agent] call arjay_agentIssueEastCommand;
				}
				else
				{
					// track current command
					[_x] call arjay_agentTrackIssuedEastCommand;					
				};				
				
				sleep 0.1;
			
			} forEach arjay_agentsEastActive;
						
			sleep arjay_agentEastControllerCycleTime;
			
		};
	};
	
	_handle
};

/*
	Issue a command to an agent
*/
arjay_agentIssueEastCommand = 
{
	private ["_agentId", "_agent", "_dayState", "_commandId", "_commandData", "_probability"];
	
	_agentId = _this select 0;
	_agent = _this select 1;
	
	_dayState = arjay_currentEnvironment select 0;
	
	_commandId = arjay_agentEastAllowedCommands select (random((count arjay_agentEastAllowedCommands)-1));
	_commandData = [arjay_agentEastCommands, _commandId] call Dictionary_fnc_get;
	_commandData = [_commandData, _dayState] call Dictionary_fnc_get;
	
	_probability = _commandData select 0;
	
	// special case for meeting command
	if(_agent getVariable "arjay_agentMeetingRequested") exitWith
	{
		_commandData = [arjay_agentEastCommands, "MEETING_JOIN"] call Dictionary_fnc_get;
		_commandData = [_commandData, _dayState] call Dictionary_fnc_get;
	
		// set agent command state
		[arjay_agentCommandStates, _agentId, [_agent, "MEETING_JOIN", "INIT", _commandData, []]] call Dictionary_fnc_set;
		
		[_agentId] call arjay_agentCommandMEETING_JOIN;
	};
	
	// special case for gathering command
	if(_agent getVariable "arjay_agentGatheringRequested") exitWith
	{
		_commandData = [arjay_agentEastCommands, "GATHERING_JOIN"] call Dictionary_fnc_get;
		_commandData = [_commandData, _dayState] call Dictionary_fnc_get;
	
		// set agent command state
		[arjay_agentCommandStates, _agentId, [_agent, "GATHERING_JOIN", "INIT", _commandData, []]] call Dictionary_fnc_set;
		
		[_agentId] call arjay_agentCommandGATHERING_JOIN;
	};
	
	if(random 1 < _probability) then 
	{	
		// set agent command state
		[arjay_agentCommandStates, _agentId, [_agent, _commandId, "INIT", _commandData, []]] call Dictionary_fnc_set;
		
		switch(_commandId) do
		{
			case "IDLE": { [_agentId] call arjay_agentCommandIDLE; };
			case "WALK": { [_agentId] call arjay_agentCommandWALK; };
			case "HOUSEWORK": { [_agentId] call arjay_agentCommandHOUSEWORK; };
			case "SLEEP": { [_agentId] call arjay_agentCommandSLEEP; };
			case "OBSERVE": { [_agentId] call arjay_agentCommandOBSERVE; };
			case "CAMPFIRE": { [_agentId] call arjay_agentCommandCAMPFIRE; };
			case "MEETING_INIT": { [_agentId] call arjay_agentCommandMEETING_INIT; };
			case "GATHERING_INIT": { [_agentId] call arjay_agentCommandGATHERING_INIT; };
			case "LOCATION_PATROL": { [_agentId] call arjay_agentCommandLOCATION_PATROL; };
			case "GARISON_DEFENSIVE_POSITIONS": { [_agentId] call arjay_agentCommandGARISON_DEFENSIVE_POSITIONS; };
			case "MAN_STATIC_WEAPON": { [_agentId] call arjay_agentCommandMAN_STATIC_WEAPON; };
			case "REMOTE_LOCATION_PATROL": { [_agentId] call arjay_agentCommandREMOTE_LOCATION_PATROL; };
			case "AIR_PATROL": { [_agentId] call arjay_agentCommandAIR_PATROL; };
		};
	};	
};

/*
	Track the issued command
*/
arjay_agentTrackIssuedEastCommand = 
{
	private ["_agentId", "_dayState", "_commandState", "_commandId"];
	
	_agentId = _this select 0;
	
	_dayState = arjay_currentEnvironment select 0;
	
	// get agent command state
	_commandState = [arjay_agentCommandStates, _agentId] call Dictionary_fnc_get;
	_commandId = _commandState select 1;
	
	call compile format['_command = ["%2"] call arjay_agentCommand%1;', _commandId, _agentId];	
};

/*
	Agent AI Command LOCATION PATROL
*/
arjay_agentCommandLOCATION_PATROL = 
{
	private ["_agentId","_agent","_commandState","_commandStateId","_commandData","_commandVars","_agentGroup","_profile","_location","_perimeter","_positions","_position","_waypoint"];
	
	_agentId = _this select 0;
	
	// get agent command state
	_commandState = [arjay_agentCommandStates, _agentId] call Dictionary_fnc_get;
	_agent = _commandState select 0;
	_commandStateId = _commandState select 2;
	_commandData = _commandState select 3;
	_commandVars = _commandState select 4;
	_agentGroup = group _agent;
	
	switch(_commandStateId) do
	{
		case "INIT":
		{
			_agent setVariable ["arjay_agentBusy", true, false];
			
			_profile = _agent getVariable "arjay_agentProfile";
			_location = [_profile, "home"] call Dictionary_fnc_get;
			
			_positions = [];
			_perimeter = [arjay_worldLocationPerimeters, _location] call Dictionary_fnc_get;
			
			_positions = _positions + _perimeter;
			
			[_agentGroup] call arjay_agentClearWaypoints;
			
			if(count _positions > 0) then
			{
				_position = _positions call BIS_fnc_arrayPop;

				_waypoint = [_agentGroup, _position, 0] call arjay_agentAddWaypoint;
			
				_commandState set [2, "MOVE"];			
				_commandVars set [0, _positions];
			}
			else
			{
				_commandState set [2, "COMPLETE"];
			};		
		};
		case "MOVE":
		{			
			_positions = _commandVars select 0;
			
			if(count _positions == 0) then
			{
				_commandState set [2, "COMPLETE"];
			}
			else
			{
				if(unitReady _agent) then
				{				
					_position = _positions call BIS_fnc_arrayPop;
					_waypoint = [_agentGroup, _position, 0] call arjay_agentAddWaypoint;
				};
			};
		};
		case "COMPLETE":
		{
			_agent setVariable ["arjay_agentBusy", false, false];
		};
	};
};

/*
	Agent AI Command GARISON DEFENSIVE POSITIONS
*/
arjay_agentCommandGARISON_DEFENSIVE_POSITIONS = 
{
	private ["_agentId","_agent","_commandState","_commandStateId","_commandData","_commandVars","_agentGroup","_positions","_position","_garisonBuildings","_building","_unit", "_timer", "_timeout"];
	
	_agentId = _this select 0;
	
	// get agent command state
	_commandState = [arjay_agentCommandStates, _agentId] call Dictionary_fnc_get;
	_agent = _commandState select 0;
	_commandStateId = _commandState select 2;
	_commandData = _commandState select 3;
	_commandVars = _commandState select 4;
	_agentGroup = group _agent;
	
	switch(_commandStateId) do
	{
		case "INIT":
		{
			_agent setVariable ["arjay_agentBusy", true, false];
			
			_garisonBuildings = nearestObjects [getPos _agent, arjay_militaryGarisonBuildings, 100];
			
			if(count _garisonBuildings > 0) then
			{
				_building = _garisonBuildings select (random((count _garisonBuildings)-1));
				
				if(count units _agentGroup > 1) then
				{
					_positions = [_building] call arjay_getBuildingPositions;
					
					{
						_unit = units _agentGroup select _i;
						_agent setSpeedMode "LIMITED";
						_agent doMove _x;
					} forEach _positions;
					
					_commandVars set [0, _building];
					_commandVars set [1, 0];
					_commandState set [2, "GARISON"];
				}
				else
				{
					_position = [_building] call arjay_getRandomBuildingPosition;
					_agent setSpeedMode "LIMITED";
					_agent doMove _position;
					
					_commandVars set [0, _building];
					_commandVars set [1, 0];
					_commandState set [2, "GARISON"];					
				};
			}
			else
			{
				_commandState set [2, "COMPLETE"];
			};		
		};
		case "GARISON":
		{
			if(unitReady _agent) then
			{	
				_timer = _commandVars select 1;
				_timeout = _commandData select 1;	
				
				if(_timer > _timeout) then
				{		
					_commandState set [2, "COMPLETE"];
				};
				
				_timer = _timer + 1;
				
				_commandVars set [1, _timer];
			};
		};
		case "COMPLETE":
		{
			_agent setVariable ["arjay_agentBusy", false, false];
		};
	};
};

/*
	Agent AI Command MAN STATIC WEAPON
*/
arjay_agentCommandMAN_STATIC_WEAPON = 
{
	private ["_agentId","_commandState","_agent","_commandStateId","_commandData","_commandVars","_agentGroup","_staticWeapons","_weapon","_positionCount","_timer","_timeout"];
	
	_agentId = _this select 0;
	
	// get agent command state
	_commandState = [arjay_agentCommandStates, _agentId] call Dictionary_fnc_get;
	_agent = _commandState select 0;
	_commandStateId = _commandState select 2;
	_commandData = _commandState select 3;
	_commandVars = _commandState select 4;
	_agentGroup = group _agent;
	
	switch(_commandStateId) do
	{
		case "INIT":
		{
			_agent setVariable ["arjay_agentBusy", true, false];
			
			_staticWeapons = nearestObjects [getPos _agent, ["StaticWeapon"], 100];			
			_staticWeapons = [_staticWeapons] call arjay_filterInUseVehicles;
			
			if(count _staticWeapons > 0) then
			{
				_weapon = _staticWeapons select (random((count _staticWeapons)-1));
				
				_weapon setVariable ["arjay_agentInUse", true, false];
				
				_positionCount = ([_weapon] call arjay_getEmptyVehiclePositions) select 1;
				
				if(_positionCount > 0) then
				{
					_agent assignAsGunner _weapon;
					[_agent] orderGetIn true;
					
					_commandVars set [0, _weapon];
					_commandVars set [1, 0];
					_commandState set [2, "MAN"];
				}
				else
				{
					_commandState set [2, "COMPLETE"];
				};				
			}
			else
			{
				_commandState set [2, "COMPLETE"];
			};
		};
		case "MAN":
		{
			if(unitReady _agent) then
			{	
				_timer = _commandVars select 1;
				_timeout = _commandData select 1;	
				
				if(_timer > _timeout) then
				{		
					_weapon = _commandVars select 0;
					_weapon setVariable ["arjay_agentInUse", false, false];
					_commandState set [2, "COMPLETE"];
				};
				
				_timer = _timer + 1;
				
				_commandVars set [1, _timer];
			};
		};
		case "COMPLETE":
		{
			unassignVehicle _agent;
					
			_agent setVariable ["arjay_agentBusy", false, false];
		};
	};
};

/*
	Agent AI Command BOARD VEHICLE
*/
arjay_agentCommandBOARD_VEHICLE = 
{
	private ["_agentId","_commandState","_agent","_commandStateId","_commandData","_commandVars","_agentGroup","_type","_vehicles","_vehicle",
	"_hasRoom","_vehicleAssignments","_boarded","_timer","_timeout","_callbackCommandData","_callbackVars"];
	
	_agentId = _this select 0;
	
	// get agent command state
	_commandState = [arjay_agentCommandStates, _agentId] call Dictionary_fnc_get;
	_agent = _commandState select 0;
	_commandStateId = _commandState select 2;
	_commandData = _commandState select 3;
	_commandVars = _commandState select 4;
	_agentGroup = group _agent;
	
	switch(_commandStateId) do
	{
		case "INIT":
		{			
			_type = _commandData select 0;
			switch(_type) do
			{
				case "GROUND": { _vehicles = nearestObjects [getPos _agent, ["Car","TANK","Truck","Motorcycle"], 100]; };
				case "SEA": { _vehicles = nearestObjects [getPos _agent, ["Ship"], 100]; };
				case "AIR": { _vehicles = nearestObjects [getPos _agent, ["Helicopter"], 100]; };
			};
			
			_vehicles = [_vehicles] call arjay_filterInUseVehicles;
			
			if(count _vehicles > 0) then
			{
				_vehicle = _vehicles select (random((count _vehicles)-1));				
				_hasRoom = [_agentGroup, _vehicle] call arjay_vehicleHasRoomForGroup;
				
				if(_hasRoom) then
				{
					_vehicleAssignments = [_agentGroup, _vehicle] call arjay_assignGroupToVehicle;
					
					_vehicle setVariable ["arjay_agentInUse", true, false];
					_vehicle setVariable ["arjay_boardPosition", getPos _vehicle, false];
					_commandVars set [1, _vehicle];
					_commandVars set [2, _vehicleAssignments];
					_commandVars set [3, 0];
					_commandState set [2, "BOARD"];
				}
				else
				{
					_commandVars set [1, objNull];
					_commandVars set [2, []];
					_commandState set [2, "COMPLETE"];
				};				
			}
			else
			{
				_commandVars set [1, objNull];
				_commandVars set [2, []];
				_commandState set [2, "COMPLETE"];
			};
		};
		case "BOARD":
		{
			_vehicle = _commandVars select 1;
			_vehicleAssignments = _commandVars select 2;
			
			_boarded = [_agentGroup, _vehicle] call arjay_isGroupInVehicle;
			
			if!(_boarded) then
			{
				_timer = _commandVars select 3;
				_timeout = _commandData select 1;	
				
				if(_timer > _timeout) then
				{		
					[_vehicleAssignments, _vehicle] call arjay_forceGroupToVehicle;
					_commandState set [2, "COMPLETE"];
				};
				
				_timer = _timer + 1;
				
				_commandVars set [3, _timer];
			}
			else
			{
				_commandState set [2, "COMPLETE"];
			};
		};
		case "COMPLETE":
		{
			_vehicle = _commandVars select 1;
			_vehicleAssignments = _commandVars select 2;
			
			_callbackCommandData = _commandVars select 0;
			_callbackVars = (_callbackCommandData select 3);
			_callbackVars set [0, _vehicle];
			_callbackVars set [1, _vehicleAssignments];			
			
			// set agent command state
			[arjay_agentCommandStates, _agentId, [_agent, (_callbackCommandData select 0), (_callbackCommandData select 1), (_callbackCommandData select 2), _callbackVars]] call Dictionary_fnc_set;
		};
	};
};

/*
	Agent AI Command DISMOUNT VEHICLE
*/
arjay_agentCommandDISMOUNT_VEHICLE = 
{
	private ["_agentId","_commandState","_agent","_commandStateId","_commandData","_commandVars","_agentGroup","_vehicle",
	"_vehicleAssignments","_allReady","_timer","_timeout","_callbackCommandData","_callbackVars"];
	
	_agentId = _this select 0;
	
	// get agent command state
	_commandState = [arjay_agentCommandStates, _agentId] call Dictionary_fnc_get;
	_agent = _commandState select 0;
	_commandStateId = _commandState select 2;
	_commandData = _commandState select 3;
	_commandVars = _commandState select 4;
	_agentGroup = group _agent;
	
	switch(_commandStateId) do
	{
		case "INIT":
		{			
			_vehicle = _commandVars select 1;
			_vehicleAssignments = _commandVars select 2;
			
			[_vehicleAssignments, _vehicle] call arjay_groupDismountVehicle;
			_commandState set [2, "DISMOUNT"];
		};
		case "DISMOUNT":
		{
			_allReady = [_agentGroup] call arjay_isGroupReady;
			
			if(_allReady) then
			{
				_commandState set [2, "COMPLETE"];
			};
		};
		case "COMPLETE":
		{			
			_callbackCommandData = _commandVars select 0;
			_callbackVars = (_callbackCommandData select 3);
			
			// set agent command state
			[arjay_agentCommandStates, _agentId, [_agent, (_callbackCommandData select 0), (_callbackCommandData select 1), (_callbackCommandData select 2), _callbackVars]] call Dictionary_fnc_set;
		};
	};
};

/*
	Agent AI Command BUILDING PATROL
*/
arjay_agentCommandBUILDING_PATROL = 
{
	private ["_agentId","_commandState","_agent","_commandStateId","_commandData","_commandVars","_agentGroup","_maxBuildings","_locationName","_locationBuildings","_positions",
	"_worldBuilding","_buildingPosition","_buildingCountPosition","_buildingPositions","_position","_waypoint","_callbackCommandData","_callbackVars"];
	
	_agentId = _this select 0;
	
	// get agent command state
	_commandState = [arjay_agentCommandStates, _agentId] call Dictionary_fnc_get;
	_agent = _commandState select 0;
	_commandStateId = _commandState select 2;
	_commandData = _commandState select 3;
	_commandVars = _commandState select 4;
	_agentGroup = group _agent;
	
	switch(_commandStateId) do
	{
		case "INIT":
		{	
			_maxBuildings = _commandData select 0;
			_locationName = _commandData select 1;
			
			_locationBuildings = [arjay_worldBuildingsByLocation, _locationName] call Dictionary_fnc_get;
			_positions = [];
			
			[_agentGroup] call arjay_agentClearWaypoints;
			
			if(count _locationBuildings > 0) then
			{
				if(count _locationBuildings < _maxBuildings) then
				{
					{
						_worldBuilding = [arjay_worldBuildings, _x] call Dictionary_fnc_get;
						_buildingPosition = _worldBuilding select 4;
						_buildingCountPosition = _worldBuilding select 5;
						_buildingPositions = _worldBuilding select 6;
						
						if(count _buildingPositions > 0) then
						{
							_position = _buildingPositions select (random((count _buildingPositions)-1));
						}
						else
						{
							_position = _buildingPosition;
						};
						
						_positions set [count _positions, _position];
					} forEach _locationBuildings;
				}
				else
				{
					{
						if(random 1 < 0.5) then
						{
							while { count _positions < _maxBuildings} do
							{
								_worldBuilding = [arjay_worldBuildings, _x] call Dictionary_fnc_get;
								_buildingPosition = _worldBuilding select 4;
								_buildingCountPosition = _worldBuilding select 5;
								_buildingPositions = _worldBuilding select 6;
								
								if(_buildingCountPosition > 0) then
								{
									_position = _buildingPositions select (random((count _buildingPositions)-1));
								}
								else
								{
									_position = _buildingPosition;
								};
								
								_positions set [count _positions, _position];
							};
						};
					} forEach _locationBuildings;
				};

				if(count _positions == 0) then
				{
					_commandState set [2, "COMPLETE"];
				}
				else
				{
					_position = _positions call BIS_fnc_arrayPop;
					_waypoint = [_agentGroup, _position, 1] call arjay_agentAddWaypoint;
					
					_commandState set [2, "PATROL"];			
					_commandVars set [1, _positions];		
				};						
			}
			else
			{
				_commandState set [2, "COMPLETE"];
			};
		};
		case "PATROL":
		{			
			_positions = _commandVars select 1;

			if(count _positions == 0) then
			{				
				_commandState set [2, "COMPLETE"];
			}
			else
			{
				if(currentWaypoint _agentGroup == count waypoints _agentGroup) then
				{				
					_position = _positions call BIS_fnc_arrayPop;
					_waypoint = [_agentGroup, _position, 1] call arjay_agentAddWaypoint;
				};
			};
		};
		case "COMPLETE":
		{
			_callbackCommandData = _commandVars select 0;
			_callbackVars = (_callbackCommandData select 3);
			
			// set agent command state
			[arjay_agentCommandStates, _agentId, [_agent, (_callbackCommandData select 0), (_callbackCommandData select 1), (_callbackCommandData select 2), _callbackVars]] call Dictionary_fnc_set;
		};
	};
};

/*
	Agent AI Command REMOTE LOCATION PATROL
*/
arjay_agentCommandREMOTE_LOCATION_PATROL = 
{
	private ["_agentId","_commandState","_agent","_commandStateId","_commandData","_commandVars","_agentGroup","_radius","_nearestLocations",
	"_location","_locationPosition","_locationName","_nearRoads","_road","_parkingPosition","_dayState","_newCommandData","_vehicle","_waypoint",
	"_vehicleAssignments","_allReady", "_agentSide", "_locationData", "_locationSides","_civilianAgents", "_sideData", "_enemyGroup"];
	
	_agentId = _this select 0;
	
	// get agent command state
	_commandState = [arjay_agentCommandStates, _agentId] call Dictionary_fnc_get;
	_agent = _commandState select 0;
	_commandStateId = _commandState select 2;
	_commandData = _commandState select 3;
	_commandVars = _commandState select 4;
	_agentGroup = group _agent;
	
	switch(_commandStateId) do
	{
		case "INIT":
		{
			_agent setVariable ["arjay_agentBusy", true, false];
			
			_radius = _commandData select 1;
			_nearestLocations = nearestLocations [getPos _agent, ["NameLocal","NameVillage","NameCity","NameCityCapital"], _radius];
			
			[_agentGroup] call arjay_agentClearWaypoints;
			
			if(count _nearestLocations > 0) then
			{				
				_location = _nearestLocations select 1 + (random((count _nearestLocations)-2));
				_locationPosition = position _location;
				_locationName = text _location;
				
				_nearRoads = _locationPosition nearRoads 200;
				if(count _nearRoads > 0) then
				{	
					_road = _nearRoads select (random((count _nearRoads)-1));
					_parkingPosition = getPosATL _road;					
				} 
				else
				{
					_parkingPosition = _locationPosition;
				};
				
				_commandVars set [0, objNull];
				_commandVars set [1, []];
				_commandVars set [2, _locationName];
				_commandVars set [3, _locationPosition];
				_commandVars set [4, _parkingPosition];
				
				_dayState = arjay_currentEnvironment select 0;
				_newCommandData = [arjay_agentEastCommands, "BOARD_GROUND_VEHICLE"] call Dictionary_fnc_get;
				_newCommandData = [_newCommandData, _dayState] call Dictionary_fnc_get;
			
				// set agent command state
				// store current command details in the new commands var array so it can return when done
				[arjay_agentCommandStates, _agentId, [_agent, "BOARD_VEHICLE", "INIT", _newCommandData, [["REMOTE_LOCATION_PATROL", "TRAVEL_START", _commandData, _commandVars]]]] call Dictionary_fnc_set;
				
				[_agentId] call arjay_agentCommandBOARD_VEHICLE;
			}
			else
			{
				_commandState set [2, "COMPLETE"];
			};
		};
		case "TRAVEL_START":
		{	
			_vehicle = _commandVars select 0;
			_vehicleAssignments = _commandVars select 1;
			_parkingPosition = _commandVars select 4;
			
			if!(isNull _vehicle) then 
			{
				_waypoint = [_agentGroup, _parkingPosition, 5] call arjay_agentAddWaypoint;
				_commandState set [2, "TRAVEL"];
			}
			else
			{
				_commandState set [2, "COMPLETE"];
			};
		};
		case "TRAVEL":
		{
			if(currentWaypoint _agentGroup == count waypoints _agentGroup) then
			{		
				_vehicle = _commandVars select 0;
				_vehicleAssignments = _commandVars select 1;
				
				// dismount leaving gunners				
				if(random 1 < 0.5) then
				{
					[_vehicleAssignments, _vehicle, false] call arjay_groupDismountVehicle;
				}
				else
				{
					[_vehicleAssignments, _vehicle] call arjay_groupDismountVehicle;
				};
				
				_commandState set [2, "PATROL"];
			}
		};
		case "PATROL":
		{
			_vehicle = _commandVars select 0;
			
			_allReady = [_agentGroup] call arjay_isGroupReady;
			
			if(_allReady) then
			{
				_locationName = _commandVars select 2;				
				_agentSide = format["%1", side _agent];
				
				if(_locationName in (arjay_missionLocations select 0)) then
				{				
					_locationData = [arjay_missionLocations, _locationName] call Dictionary_fnc_get;
					_locationSides = _locationData select 0;

					if("CIV" in _locationSides) then
					{
						if(((_agentSide == "EAST") && (arjay_agentEastAttackCivilians)) || ((_agentSide == "WEST") && (arjay_agentWestAttackCivilians))) then
						{
							_sideData = [arjay_agentSideVarNames, _agentSide] call Dictionary_fnc_get;
							_civilianAgents = [arjay_agentsCivilianByLocation, _locationName] call Dictionary_fnc_get;
							
							{
								if(_x in (arjay_agents select 0)) then
								{							
									_enemyGroup = createGroup (_sideData select 3);
									[_x] join _enemyGroup;
								}
							} forEach _civilianAgents;
						};
					};		
				};
			
				_dayState = arjay_currentEnvironment select 0;
				_newCommandData = [arjay_agentEastCommands, "BUILDING_PATROL"] call Dictionary_fnc_get;
				_newCommandData = [_newCommandData, _dayState] call Dictionary_fnc_get;
				_newCommandData set [count _newCommandData, _locationName];
			
				// set agent command state
				// store current command details in the new commands var array so it can return when done
				[arjay_agentCommandStates, _agentId, [_agent, "BUILDING_PATROL", "INIT", _newCommandData, [["REMOTE_LOCATION_PATROL", "BOARD", _commandData, _commandVars]]]] call Dictionary_fnc_set;
				
				[_agentId] call arjay_agentCommandBUILDING_PATROL;
			};			
		};
		case "BOARD":
		{
			_vehicle = _commandVars select 0;
			_vehicleAssignments = _commandVars select 1;
			
			[_vehicleAssignments, _vehicle] call arjay_groupMountVehicle;
			
			_dayState = arjay_currentEnvironment select 0;
			_newCommandData = [arjay_agentEastCommands, "BOARD_GROUND_VEHICLE"] call Dictionary_fnc_get;
			_newCommandData = [_newCommandData, _dayState] call Dictionary_fnc_get;
		
			// set agent command state
			// store current command details in the new commands var array so it can return when done
			[arjay_agentCommandStates, _agentId, [_agent, "BOARD_VEHICLE", "BOARD", _newCommandData, [["REMOTE_LOCATION_PATROL", "RTB", _commandData, _commandVars], _vehicle, _vehicleAssignments, 0]]] call Dictionary_fnc_set;
			
			[_agentId] call arjay_agentCommandBOARD_VEHICLE;
		};
		case "RTB":
		{
			_vehicle = _commandVars select 0;
			_parkingPosition = _vehicle getVariable "arjay_boardPosition";
			_waypoint = [_agentGroup, _parkingPosition, 5] call arjay_agentAddWaypoint;
			_commandState set [2, "RTB_TRAVEL"];			
		};
		case "RTB_TRAVEL":
		{
			if(currentWaypoint _agentGroup == count waypoints _agentGroup) then
			{	
				_vehicle = _commandVars select 0;
				_vehicleAssignments = _commandVars select 1;				
				
				[_vehicleAssignments, _vehicle] call arjay_groupDismountVehicle;				
				
				_commandState set [2, "COMPLETE"];
			}
		};
		case "COMPLETE":
		{			
			_vehicle = _commandVars select 0;
			_vehicle setVariable ["arjay_agentInUse", false, false];
			_agent setVariable ["arjay_agentBusy", false, false];
		};
	};
};

/*
	Agent AI Command AIR PATROL
*/
arjay_agentCommandAIR_PATROL = 
{
	private ["_agentId","_commandState","_agent","_commandStateId","_commandData","_commandVars","_agentGroup","_radius","_nearestLocations",
	"_positions","_position","_parkingPosition","_dayState","_newCommandData","_vehicle","_waypoint","_vehicleAssignments"];
	
	_agentId = _this select 0;
	
	// get agent command state
	_commandState = [arjay_agentCommandStates, _agentId] call Dictionary_fnc_get;
	_agent = _commandState select 0;
	_commandStateId = _commandState select 2;
	_commandData = _commandState select 3;
	_commandVars = _commandState select 4;
	_agentGroup = group _agent;
	
	switch(_commandStateId) do
	{
		case "INIT":
		{
			_agent setVariable ["arjay_agentBusy", true, false];
			
			_radius = _commandData select 1;
			_nearestLocations = nearestLocations [getPos _agent, ["NameLocal","NameVillage","NameCity","NameCityCapital"], _radius];
			
			[_agentGroup] call arjay_agentClearWaypoints;
			
			if(count _nearestLocations > 0) then
			{
				_positions = [];
				{
					_positions set [count _positions, position _x];
				} forEach _nearestLocations;
				
				// shuffle the locations
				_positions = [
				   _positions, 
				   {
					  (random 1)
				   }
				] call RUBE_shellSort;
				
				_commandVars set [0, objNull];
				_commandVars set [1, []];
				_commandVars set [2, _positions];
				
				_dayState = arjay_currentEnvironment select 0;
				_newCommandData = [arjay_agentEastCommands, "BOARD_AIR_VEHICLE"] call Dictionary_fnc_get;
				_newCommandData = [_newCommandData, _dayState] call Dictionary_fnc_get;
			
				// set agent command state
				// store current command details in the new commands var array so it can return when done
				[arjay_agentCommandStates, _agentId, [_agent, "BOARD_VEHICLE", "INIT", _newCommandData, [["AIR_PATROL", "TRAVEL_START", _commandData, _commandVars]]]] call Dictionary_fnc_set;
				
				[_agentId] call arjay_agentCommandBOARD_VEHICLE;
			}
			else
			{
				_commandState set [2, "COMPLETE"];
			};
		};
		case "TRAVEL_START":
		{	
			_vehicle = _commandVars select 0;
			_positions = _commandVars select 2;
			
			if!(isNull _vehicle) then 
			{
				_position = _positions call BIS_fnc_arrayPop;
				_waypoint = [_agentGroup, _position, 1] call arjay_agentAddWaypoint;
				_commandState set [2, "PATROL"];
			}
			else
			{
				_commandState set [2, "COMPLETE"];
			};
		};
		case "PATROL":
		{			
			_positions = _commandVars select 2;

			if(count _positions == 0) then
			{				
				_commandState set [2, "RTB"];
			}
			else
			{
				if(currentWaypoint _agentGroup == count waypoints _agentGroup) then
				{				
					_position = _positions call BIS_fnc_arrayPop;
					_waypoint = [_agentGroup, _position, 1] call arjay_agentAddWaypoint;
				};
			};
		};
		case "RTB":
		{
			_vehicle = _commandVars select 0;
			_parkingPosition = _vehicle getVariable "arjay_boardPosition";
			_waypoint = [_agentGroup, _parkingPosition, 0] call arjay_agentAddWaypoint;
			_commandState set [2, "RTB_TRAVEL"];			
		};
		case "RTB_TRAVEL":
		{
			if(currentWaypoint _agentGroup == count waypoints _agentGroup) then
			{	
				_vehicle = _commandVars select 0;
				_vehicleAssignments = _commandVars select 1;				
				
				[_vehicleAssignments, _vehicle] call arjay_groupDismountVehicle;				
				
				_commandState set [2, "COMPLETE"];
			}
		};
		case "COMPLETE":
		{			
			_vehicle = _commandVars select 0;
			_vehicle setVariable ["arjay_agentInUse", false, false];
			_agent setVariable ["arjay_agentBusy", false, false];
		};
	};
};