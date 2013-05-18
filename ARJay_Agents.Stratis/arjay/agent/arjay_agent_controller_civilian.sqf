/*
	File: arjay_agent_controller_civilian.sqf
	Author: ARJay
	Description: Civilian Controller
	
	This is a bit of a experiment to get maximum performance out of the arma scheduling system
	The issue is that there may be updwards of 50 active individual civilian agents at any one time
	To handle AI decision making for such a large amount of agents I have tried to avoid
	FSM's (non-scheduled, conditions checked every frame), Spawned functions (scheduled, but 50 running at once!!)
	So I have built this little controller to handle all active faction agents, it runs in a loop with sleeps
	All variables associated with an individual agents AI command are stored in arjay_agentCommandStates to simulate scope 
	so the AI task can be tracked at a later point in time. A bit of an abomination, but reasonably fast for handling large numbers
	of agents without bringing a server to its knees
*/

//arjay_agentCivilianAllowedCommands = ["IDLE", "WALK", "HOUSEWORK", "SLEEP", "OBSERVE", "CAMPFIRE", "ROGUE", "IED", "SUICIDE_BOMBER", "MEETING_INIT", "GATHERING_INIT", "TASK"];
arjay_agentCivilianAllowedCommands = ["IDLE", "WALK", "HOUSEWORK", "SLEEP", "OBSERVE", "CAMPFIRE", "MEETING_INIT", "GATHERING_INIT", "TASK"];
arjay_agentCivilianMoveTimeout = 40;
arjay_agentCivilianDriveTimeout = 1000;
arjay_agentCommandStates = call Dictionary_fnc_new;
arjay_agentCivilianCommands = call Dictionary_fnc_new;

// idle [probability, timeout]
arjay_agentCivilianCommand = call Dictionary_fnc_new;
[arjay_agentCivilianCommand, "DAY", [0.1, 5]] call Dictionary_fnc_set;
[arjay_agentCivilianCommand, "EVENING", [0.1, 60]] call Dictionary_fnc_set;
[arjay_agentCivilianCommand, "NIGHT", [0.1, 60]] call Dictionary_fnc_set;
[arjay_agentCivilianCommands, "IDLE", arjay_agentCivilianCommand] call Dictionary_fnc_set;

// walk [probability, maxDistance]
arjay_agentCivilianCommand = call Dictionary_fnc_new;
[arjay_agentCivilianCommand, "DAY", [0.25, 60]] call Dictionary_fnc_set;
[arjay_agentCivilianCommand, "EVENING", [0.1, 60]] call Dictionary_fnc_set;
[arjay_agentCivilianCommand, "NIGHT", [0.01, 60]] call Dictionary_fnc_set;
[arjay_agentCivilianCommands, "WALK", arjay_agentCivilianCommand] call Dictionary_fnc_set;

// housework [probability]
arjay_agentCivilianCommand = call Dictionary_fnc_new;
[arjay_agentCivilianCommand, "DAY", [0.1]] call Dictionary_fnc_set;
[arjay_agentCivilianCommand, "EVENING", [0.5]] call Dictionary_fnc_set;
[arjay_agentCivilianCommand, "NIGHT", [0.01]] call Dictionary_fnc_set;
[arjay_agentCivilianCommands, "HOUSEWORK", arjay_agentCivilianCommand] call Dictionary_fnc_set;

// sleep [probability, timeout]
arjay_agentCivilianCommand = call Dictionary_fnc_new;
[arjay_agentCivilianCommand, "DAY", [0, 1000]] call Dictionary_fnc_set;
[arjay_agentCivilianCommand, "EVENING", [0.1, 3000]] call Dictionary_fnc_set;
[arjay_agentCivilianCommand, "NIGHT", [0.9, 3000]] call Dictionary_fnc_set;
[arjay_agentCivilianCommands, "SLEEP", arjay_agentCivilianCommand] call Dictionary_fnc_set;

// observe [probability, timeout]
arjay_agentCivilianCommand = call Dictionary_fnc_new;
[arjay_agentCivilianCommand, "DAY", [0.1, 10]] call Dictionary_fnc_set;
[arjay_agentCivilianCommand, "EVENING", [0.01, 10]] call Dictionary_fnc_set;
[arjay_agentCivilianCommand, "NIGHT", [0, 10]] call Dictionary_fnc_set;
[arjay_agentCivilianCommands, "OBSERVE", arjay_agentCivilianCommand] call Dictionary_fnc_set;

// campfire [probability, timeout]
arjay_agentCivilianCommand = call Dictionary_fnc_new;
[arjay_agentCivilianCommand, "DAY", [0, 100]] call Dictionary_fnc_set;
[arjay_agentCivilianCommand, "EVENING", [0.1, 100]] call Dictionary_fnc_set;
[arjay_agentCivilianCommand, "NIGHT", [0.2, 100]] call Dictionary_fnc_set;
[arjay_agentCivilianCommands, "CAMPFIRE", arjay_agentCivilianCommand] call Dictionary_fnc_set;

// rogue [probability, timeout]
arjay_agentCivilianCommand = call Dictionary_fnc_new;
[arjay_agentCivilianCommand, "DAY", [0.01, 5, "WEST"]] call Dictionary_fnc_set;
[arjay_agentCivilianCommand, "EVENING", [0, 5, "WEST"]] call Dictionary_fnc_set;
[arjay_agentCivilianCommand, "NIGHT", [0, 5, "WEST"]] call Dictionary_fnc_set;
[arjay_agentCivilianCommands, "ROGUE", arjay_agentCivilianCommand] call Dictionary_fnc_set;

// ied [probability, timeout]
arjay_agentCivilianCommand = call Dictionary_fnc_new;
[arjay_agentCivilianCommand, "DAY", [0.01, 30, "WEST"]] call Dictionary_fnc_set;
[arjay_agentCivilianCommand, "EVENING", [0.01, 30, "WEST"]] call Dictionary_fnc_set;
[arjay_agentCivilianCommand, "NIGHT", [0.01, 30, "WEST"]] call Dictionary_fnc_set;
[arjay_agentCivilianCommands, "IED", arjay_agentCivilianCommand] call Dictionary_fnc_set;

// suicide [probability, timeout]
arjay_agentCivilianCommand = call Dictionary_fnc_new;
[arjay_agentCivilianCommand, "DAY", [0.01, 30, "WEST"]] call Dictionary_fnc_set;
[arjay_agentCivilianCommand, "EVENING", [0.01, 30, "WEST"]] call Dictionary_fnc_set;
[arjay_agentCivilianCommand, "NIGHT", [0.01, 30, "WEST"]] call Dictionary_fnc_set;
[arjay_agentCivilianCommands, "SUICIDE_BOMBER", arjay_agentCivilianCommand] call Dictionary_fnc_set;

// meeting init [probability]
arjay_agentCivilianCommand = call Dictionary_fnc_new;
[arjay_agentCivilianCommand, "DAY", [0.1]] call Dictionary_fnc_set;
[arjay_agentCivilianCommand, "EVENING", [0.1]] call Dictionary_fnc_set;
[arjay_agentCivilianCommand, "NIGHT", [0.01]] call Dictionary_fnc_set;
[arjay_agentCivilianCommands, "MEETING_INIT", arjay_agentCivilianCommand] call Dictionary_fnc_set;

// meeting join [timeout]
arjay_agentCivilianCommand = call Dictionary_fnc_new;
[arjay_agentCivilianCommand, "DAY", [30]] call Dictionary_fnc_set;
[arjay_agentCivilianCommand, "EVENING", [30]] call Dictionary_fnc_set;
[arjay_agentCivilianCommand, "NIGHT", [30]] call Dictionary_fnc_set;
[arjay_agentCivilianCommands, "MEETING_JOIN", arjay_agentCivilianCommand] call Dictionary_fnc_set;

// gathering init [probability, timeout]
arjay_agentCivilianCommand = call Dictionary_fnc_new;
[arjay_agentCivilianCommand, "DAY", [0.1, 30]] call Dictionary_fnc_set;
[arjay_agentCivilianCommand, "EVENING", [0.01, 30]] call Dictionary_fnc_set;
[arjay_agentCivilianCommand, "NIGHT", [0, 30]] call Dictionary_fnc_set;
[arjay_agentCivilianCommands, "GATHERING_INIT", arjay_agentCivilianCommand] call Dictionary_fnc_set;

// gathering join []
arjay_agentCivilianCommand = call Dictionary_fnc_new;
[arjay_agentCivilianCommand, "DAY", []] call Dictionary_fnc_set;
[arjay_agentCivilianCommand, "EVENING", []] call Dictionary_fnc_set;
[arjay_agentCivilianCommand, "NIGHT", []] call Dictionary_fnc_set;
[arjay_agentCivilianCommands, "GATHERING_JOIN", arjay_agentCivilianCommand] call Dictionary_fnc_set;

// task
arjay_agentCivilianCommand = call Dictionary_fnc_new;
[arjay_agentCivilianCommand, "DAY", [0.01, 30]] call Dictionary_fnc_set;
[arjay_agentCivilianCommand, "EVENING", [0.1, 30]] call Dictionary_fnc_set;
[arjay_agentCivilianCommand, "NIGHT", [0, 30]] call Dictionary_fnc_set;
[arjay_agentCivilianCommands, "TASK", arjay_agentCivilianCommand] call Dictionary_fnc_set;

// drive to
arjay_agentCivilianCommand = call Dictionary_fnc_new;
[arjay_agentCivilianCommand, "DAY", []] call Dictionary_fnc_set;
[arjay_agentCivilianCommand, "EVENING", []] call Dictionary_fnc_set;
[arjay_agentCivilianCommand, "NIGHT", []] call Dictionary_fnc_set;
[arjay_agentCivilianCommands, "DRIVE_TO", arjay_agentCivilianCommand] call Dictionary_fnc_set;

/*
	Start the AI command controller
*/
arjay_agentControllerCivilian =
{
	private ["_handle"];
	
	_handle = [] spawn 
	{
		private ["_agent", "_agentBusy"];
		
		// debug ----------------------------------------------------------------------------------------------------------------------------
		//if(arjay_debug) then {["--- CIVILIAN CONTROLLER INIT --------------------------------------------------------------------------"] call arjay_dump;};
		// debug ----------------------------------------------------------------------------------------------------------------------------
		
		while { true } do
		{		
			{
				_agent = [arjay_agents, _x] call Dictionary_fnc_get;

				_agentBusy = _agent getVariable "arjay_agentBusy";	
				
				if!(_agentBusy) then
				{
					// issue a new command
					[_x, _agent] call arjay_agentIssueCivilianCommand;
				}
				else
				{
					// track current command
					[_x] call arjay_agentTrackIssuedCivilianCommand;					
				};				
				
				sleep 0.1;
			
			} forEach arjay_agentsCivilianActive;
						
			sleep arjay_agentCivilianControllerCycleTime;
			
		};
	};
	
	_handle
};

/*
	Issue a command to an agent
*/
arjay_agentIssueCivilianCommand = 
{
	private ["_agentId", "_agent", "_dayState", "_commandId", "_commandData", "_probability"];
	
	_agentId = _this select 0;
	_agent = _this select 1;
	
	_dayState = arjay_currentEnvironment select 0;
	
	_commandId = arjay_agentCivilianAllowedCommands select (random((count arjay_agentCivilianAllowedCommands)-1));
	_commandData = [arjay_agentCivilianCommands, _commandId] call Dictionary_fnc_get;
	_commandData = [_commandData, _dayState] call Dictionary_fnc_get;
	
	_probability = _commandData select 0;
	
	// special case for meeting command
	if(_agent getVariable "arjay_agentMeetingRequested") exitWith
	{
		_commandData = [arjay_agentCivilianCommands, "MEETING_JOIN"] call Dictionary_fnc_get;
		_commandData = [_commandData, _dayState] call Dictionary_fnc_get;
	
		// set agent command state
		[arjay_agentCommandStates, _agentId, [_agent, "MEETING_JOIN", "INIT", _commandData, []]] call Dictionary_fnc_set;
		
		[_agentId] call arjay_agentCommandMEETING_JOIN;
	};
	
	// special case for gathering command
	if(_agent getVariable "arjay_agentGatheringRequested") exitWith
	{
		_commandData = [arjay_agentCivilianCommands, "GATHERING_JOIN"] call Dictionary_fnc_get;
		_commandData = [_commandData, _dayState] call Dictionary_fnc_get;
	
		// set agent command state
		[arjay_agentCommandStates, _agentId, [_agent, "GATHERING_JOIN", "INIT", _commandData, []]] call Dictionary_fnc_set;
		
		[_agentId] call arjay_agentCommandGATHERING_JOIN;
	};
	
	// special case for rogue command
	if(_commandId == "ROGUE") then
	{
		if([_agent] call arjay_isArmed) then
		{
			_probability = _commandData select 0;
		}
		else
		{
			_probability = 0;
		}
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
			case "ROGUE": { [_agentId] call arjay_agentCommandROGUE; };
			case "IED": { [_agentId] call arjay_agentCommandIED; };
			case "SUICIDE_BOMBER": { [_agentId] call arjay_agentCommandSUICIDE_BOMBER; };
			case "MEETING_INIT": { [_agentId] call arjay_agentCommandMEETING_INIT; };
			case "GATHERING_INIT": { [_agentId] call arjay_agentCommandGATHERING_INIT; };
			case "TASK": { [_agentId] call arjay_agentCommandTASK; };
		};
	};	
};

/*
	Track the issued command
*/
arjay_agentTrackIssuedCivilianCommand = 
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
	Agent AI Command IDLE
*/
arjay_agentCommandIDLE = 
{
	private ["_agentId", "_agent", "_commandState", "_commandStateId", "_commandData", "_commandVars", "_timer", "_timeout"];
	
	_agentId = _this select 0;
	
	// get agent command state
	_commandState = [arjay_agentCommandStates, _agentId] call Dictionary_fnc_get;
	_agent = _commandState select 0;
	_commandStateId = _commandState select 2;
	_commandData = _commandState select 3;
	_commandVars = _commandState select 4;
	
	switch(_commandStateId) do
	{
		case "INIT":
		{
			_agent setVariable ["arjay_agentBusy", true, false];
			
			_commandVars set [0, 0];
			_commandState set [2, "IDLING"];		
			
			if((random 1) < 0.5) then
			{
				_agent action ["SITDOWN",_agent];
			}
			else
			{
				if(isMultiplayer && !arjay_isMultiplayerHost && arjay_agentBroadcastAgentAnimations) then
				{
					["arjay_clientCommandSwitchMove", [_agent, "InBaseMoves_HandsBehindBack1"]] call arjay_broadcastClientCommand;
				}
				else
				{
					_agent switchMove "InBaseMoves_HandsBehindBack1";
				};
			};			
		};
		case "IDLING":
		{			
			_timer = _commandVars select 0;
			_timeout = _commandData select 1;
			
			if(_timer > _timeout) then
			{				
				_agent playMove "";
				_commandState set [2, "COMPLETE"];
			};
			
			_timer = _timer + 1;
			
			_commandVars set [0, _timer];
		};
		case "COMPLETE":
		{
			_agent setVariable ["arjay_agentBusy", false, false];
		};
	};
};

/*
	Agent AI Command WALK
*/
arjay_agentCommandWALK = 
{
	private ["_agentId","_agent","_commandState","_commandStateId","_commandData","_commandVars","_maxDistance","_positions","_distance","_position","_debugObject"];
	
	_agentId = _this select 0;
	
	// get agent command state
	_commandState = [arjay_agentCommandStates, _agentId] call Dictionary_fnc_get;
	_agent = _commandState select 0;
	_commandStateId = _commandState select 2;
	_commandData = _commandState select 3;
	_commandVars = _commandState select 4;
	
	switch(_commandStateId) do
	{
		case "INIT":
		{
			_agent setVariable ["arjay_agentBusy", true, false];	
			
			_maxDistance = _commandData select 1;

			_positions = [];
				
			for "_i" from 0 to (5) do 
			{
				_distance = random _maxDistance;
				_position = [_agent, _distance] call arjay_getRandomRelativePositionLand;
				_positions set [count _positions, _position];
			};
			
			_position = _positions call BIS_fnc_arrayPop;
			_agent setSpeedMode "LIMITED";
			_agent doMove _position;
			
			_commandState set [2, "WALK"];			
			_commandVars set [0, _positions];			
		};
		case "WALK":
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
					_agent setSpeedMode "LIMITED";
					_agent doMove _position;
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
	Agent AI Command HOUSEWORK
*/
arjay_agentCommandHOUSEWORK = 
{
	private ["_agentId","_agent","_commandState","_commandStateId","_commandData","_commandVars","_profile","_house","_building","_housePositions","_positions","_position","_positionCount","_dayState","_light","_music"];
	
	_agentId = _this select 0;
	
	// get agent command state
	_commandState = [arjay_agentCommandStates, _agentId] call Dictionary_fnc_get;
	_agent = _commandState select 0;
	_commandStateId = _commandState select 2;
	_commandData = _commandState select 3;
	_commandVars = _commandState select 4;
	
	switch(_commandStateId) do
	{
		case "INIT":
		{
			_agent setVariable ["arjay_agentBusy", true, false];	

			_profile = _agent getVariable "arjay_agentProfile";
			_house = [_profile, "house"] call Dictionary_fnc_get;
			_position = _house select 4;
			_positionCount = _house select 5;
			_housePositions = _house select 6;
			
			_positions = [];			
			
			if(_positionCount == 0) then
			{
				_positions set [0, _position];
			}
			else
			{
				_positions = _positions + _housePositions;
			};
			
			if(count _positions == 0) then
			{
				_commandState set [2, "COMPLETE"];
			}
			else
			{				
				_position = _positions call BIS_fnc_arrayPop;
				_agent setSpeedMode "LIMITED";
				_agent doMove _position;
				
				_commandState set [2, "TRAVEL"];			
				_commandVars set [0, _positions];		
			};						
		};
		case "TRAVEL":
		{			
			if(unitReady _agent) then
			{		
				_dayState = arjay_currentEnvironment select 0;
			
				if(arjay_agentCreateHouseMusic) then
				{
					if(_dayState == "DAY" || _dayState == "EVENING") then
					{
						_profile = _agent getVariable "arjay_agentProfile";
						_house = [_profile, "house"] call Dictionary_fnc_get;
						_position = _house select 4;					
						
						if!(_agent getVariable "arjay_agentHouseMusicOn") then
						{
							_building = _position nearestObject "House";
							_music = [_building] call arjay_addAmbientRoomMusic;
							_agent setVariable ["arjay_agentHouseMusic", _music, false];
							_agent setVariable ["arjay_agentHouseMusicOn", true, false];
						};										
					};
				};
					
				if(arjay_agentCreateHouseLights) then
				{
					if(_dayState == "EVENING" || _dayState == "NIGHT") then
					{
						_profile = _agent getVariable "arjay_agentProfile";
						_house = [_profile, "house"] call Dictionary_fnc_get;
						_position = _house select 4;				
						
						if!(_agent getVariable "arjay_agentHouseLightOn") then
						{
							_building = _position nearestObject "House";
							_light = [_building] call arjay_addAmbientRoomLight;
							_agent setVariable ["arjay_agentHouseLight", _light, false];
							_agent setVariable ["arjay_agentHouseLightOn", true, false];
						};										
					};
				};
				
				_commandState set [2, "HOUSEWORK"];
			};
		};
		case "HOUSEWORK":
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
					_agent setSpeedMode "LIMITED";
					_agent doMove _position;
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
	Agent AI Command SLEEP
*/
arjay_agentCommandSLEEP = 
{
	private ["_agentId","_agent","_commandState","_commandStateId","_commandData","_commandVars","_profile","_house","_building","_position","_dayState","_light","_music","_timer","_timeout"];
	
	_agentId = _this select 0;
	
	// get agent command state
	_commandState = [arjay_agentCommandStates, _agentId] call Dictionary_fnc_get;
	_agent = _commandState select 0;
	_commandStateId = _commandState select 2;
	_commandData = _commandState select 3;
	_commandVars = _commandState select 4;
	
	switch(_commandStateId) do
	{
		case "INIT":
		{
			_agent setVariable ["arjay_agentBusy", true, false];	

			_profile = _agent getVariable "arjay_agentProfile";
			_position = [_profile, "position"] call Dictionary_fnc_get;
			
			_agent setSpeedMode "LIMITED";
			_agent doMove _position;
			
			_commandState set [2, "TRAVEL"];			
		};
		case "TRAVEL":
		{			
			if(unitReady _agent) then
			{		
				_dayState = arjay_currentEnvironment select 0;
			
				if(arjay_agentCreateHouseLights) then
				{
					if(_dayState == "EVENING" || _dayState == "NIGHT") then
					{			
						if	(_agent getVariable "arjay_agentHouseLightOn") then
						{
							_light = _agent getVariable "arjay_agentHouseLight";
							deleteVehicle _light;
							_agent setVariable ["arjay_agentHouseLight", objNull, false];
							_agent setVariable ["arjay_agentHouseLightOn", false, false];
						};
					};
				};
				
				if(arjay_agentCreateHouseMusic) then
				{
					if(_dayState == "EVENING" || _dayState == "NIGHT") then
					{						
						if!(_agent getVariable "arjay_agentHouseMusicOn") then
						{
							_music = _agent getVariable "arjay_agentHouseMusic";
							deleteVehicle _music;
							_agent setVariable ["arjay_agentHouseMusic", objNull, false];
							_agent setVariable ["arjay_agentHouseMusicOn", false, false];
						};										
					};
				};
				
				_agent playMove "AinjPpneMstpSnonWnonDnon_injuredHealed";
				
				_commandState set [2, "SLEEP"];
				_commandVars set [0, 0];
			};
		};
		case "SLEEP":
		{					
			_timer = _commandVars select 0;
			_timeout = _commandData select 1;
			
			if(_timer > _timeout) then
			{
				_agent playMove "";
				_commandState set [2, "COMPLETE"];
			};
			
			_timer = _timer + 1;
			
			_commandVars set [0, _timer];
		};
		case "COMPLETE":
		{
			_agent setVariable ["arjay_agentBusy", false, false];
		};
	};
};

/*
	Agent AI Command OBSERVE
*/
arjay_agentCommandOBSERVE = 
{
	private ["_agentId", "_agent", "_commandState", "_commandStateId", "_commandData", "_commandVars", "_target", "_position", "_timer", "_timeout"];
	
	_agentId = _this select 0;
	
	// get agent command state
	_commandState = [arjay_agentCommandStates, _agentId] call Dictionary_fnc_get;
	_agent = _commandState select 0;
	_commandStateId = _commandState select 2;
	_commandData = _commandState select 3;
	_commandVars = _commandState select 4;
	
	switch(_commandStateId) do
	{
		case "INIT":
		{
			_agent setVariable ["arjay_agentBusy", true, false];

			_target = [_agent, 50] call arjay_agentGetRandomTarget;
			if!(isNull _target) then
			{
				_position = [getPosASL _target, random 10, random 360] call BIS_fnc_relPos;
				_agent setSpeedMode "LIMITED";
				_agent doMove _position;
			};
			
			_commandState set [2, "TRAVEL"];
			_commandVars set [0, _target];			
		};
		case "TRAVEL":
		{			
			if(unitReady _agent) then
			{			
				
				_target = _commandVars select 0;
			
				if!(_target == objNull) then
				{
					_agent doWatch _target;
				};

				if(random 1 < 0.3) then
				{
					if(isMultiplayer && !arjay_isMultiplayerHost && arjay_agentBroadcastAgentAnimations) then
					{
						["arjay_clientCommandSwitchMove", [_agent, "InBaseMoves_HandsBehindBack1"]] call arjay_broadcastClientCommand;
					}
					else
					{
						_agent switchMove "InBaseMoves_HandsBehindBack1";
					};
				};
				
				_commandState set [2, "OBSERVE"];
				_commandVars set [1, 0];
			};
		};
		case "OBSERVE":
		{					
			_timer = _commandVars select 1;
			_timeout = _commandData select 1;
			
			if(_timer > _timeout) then
			{				
				_agent playMove "";
				_commandState set [2, "COMPLETE"];
			};
			
			_timer = _timer + 1;
			
			_commandVars set [1, _timer];
		};
		case "COMPLETE":
		{
			_agent setVariable ["arjay_agentBusy", false, false];
		};
	};
};

/*
	Agent AI Command CAMPFIRE
*/
arjay_agentCommandCAMPFIRE = 
{
	private ["_agentId","_agent","_commandState","_commandStateId","_commandData","_commandVars","_position","_fire","_timer","_timeout"];
	
	_agentId = _this select 0;
	
	// get agent command state
	_commandState = [arjay_agentCommandStates, _agentId] call Dictionary_fnc_get;
	_agent = _commandState select 0;
	_commandStateId = _commandState select 2;
	_commandData = _commandState select 3;
	_commandVars = _commandState select 4;
	
	switch(_commandStateId) do
	{
		case "INIT":
		{
			_agent setVariable ["arjay_agentBusy", true, false];
			
			_position = (getPosASL _agent) findEmptyPosition[20, 40, "FirePlace_burning_F"];
			
			if(count _position == 0) then
			{				
				_commandState set [2, "COMPLETE"];
			}
			else
			{
				_agent setSpeedMode "LIMITED";
				_agent doMove _position;

				_commandState set [2, "TRAVEL"];
			};			
		};
		case "TRAVEL":
		{			
			if(unitReady _agent) then
			{			
				
				_agent action ["SITDOWN",_agent];

				_fire = "FirePlace_burning_F" createVehicle (_firePosition);

				_agent lookAt _fire;
				
				_commandState set [2, "CAMPFIRE"];
				_commandVars set [0, _fire];
				_commandVars set [1, 0];
			};
		};
		case "CAMPFIRE":
		{			
			_fire = _commandVars select 0;			
			_timer = _commandVars select 1;
			_timeout = _commandData select 1;			
			
			if(_timer > _timeout) then
			{
				_agent playMove "";
				deleteVehicle _fire;
				_commandState set [2, "COMPLETE"];
			};
			
			_timer = _timer + 1;
			
			_commandVars set [1, _timer];
		};
		case "COMPLETE":
		{
			_agent setVariable ["arjay_agentBusy", false, false];
		};
	};
};

/*
	Agent AI Command ROGUE
*/
arjay_agentCommandROGUE = 
{
	private ["_agentId","_agent","_commandState","_commandStateId","_commandData","_commandVars","_targetSide","_sideData","_unit","_position","_enemyGroup","_timer","_timeout"];
	
	_agentId = _this select 0;
	
	// get agent command state
	_commandState = [arjay_agentCommandStates, _agentId] call Dictionary_fnc_get;
	_agent = _commandState select 0;
	_commandStateId = _commandState select 2;
	_commandData = _commandState select 3;
	_commandVars = _commandState select 4;
	
	switch(_commandStateId) do
	{
		case "INIT":
		{
			_agent setVariable ["arjay_agentBusy", true, false];
			
			_targetSide = _commandData select 2;			
			_sideData = [arjay_agentSideVarNames, _targetSide] call Dictionary_fnc_get;
			
			// get all near units based on side parent config class
			_units = getPos _agent nearObjects [_sideData select 2, 100];
			
			if(count _units > 0) then
			{
				_unit = _units select (random((count _units)-1));
				_position = [getPos _unit, random 5, random 360] call BIS_fnc_relPos;
				//_agent setSpeedMode "FULL";
				_agent doMove _position;
				_commandVars set [0, _unit];
				_commandState set [2, "TRAVEL"];
			}
			else
			{
				_commandState set [2, "COMPLETE"];
			};									
		};
		case "TRAVEL":
		{			
			if(unitReady _agent) then
			{
				_targetSide = _commandData select 2;
				_sideData = [arjay_agentSideVarNames, _targetSide] call Dictionary_fnc_get;
				_unit = _commandVars select 0;
				_enemyGroup = createGroup (_sideData select 3);
				//_agent setBehaviour "AWARE";
				//_agent reveal _unit;
				_agent doTarget _unit;
				_commandState set [2, "ROGUE"];
				_commandVars set [1, 0];
			};
		};
		case "ROGUE":
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
		case "COMPLETE":
		{
			_agent setVariable ["arjay_agentBusy", false, false];
		};
	};
};

/*
	Agent AI Command IED
*/
arjay_agentCommandIED = 
{
	private ["_agentId","_agent","_commandState","_commandStateId","_commandData","_commandVars","_nearRoads","_position","_profile","_house","_ied","_timer","_timeout","_targetSide","_sideData","_units"];
	
	_agentId = _this select 0;
	
	// get agent command state
	_commandState = [arjay_agentCommandStates, _agentId] call Dictionary_fnc_get;
	_agent = _commandState select 0;
	_commandStateId = _commandState select 2;
	_commandData = _commandState select 3;
	_commandVars = _commandState select 4;
	
	switch(_commandStateId) do
	{
		case "INIT":
		{
			_agent setVariable ["arjay_agentBusy", true, false];
			
			_position = [getPos _agent, 200] call arjay_getSideOfRoadPosition;
			
			_agent setSpeedMode "LIMITED";
			_agent doMove _position;
			_commandVars set [0, _position];
			_commandState set [2, "TRAVEL_TO_IED"];			
		};
		case "TRAVEL_TO_IED":
		{			
			if(unitReady _agent) then
			{		
				_position = _commandVars select 0;
				
				// place ied
				_ied = "FirePlace_burning_F" createVehicle (_position);
				
				_profile = _agent getVariable "arjay_agentProfile";
				_house = [_profile, "house"] call Dictionary_fnc_get;
				_position = _house select 4;
				_agent setSpeedMode "FULL";
				_agent doMove _position;
				
				_commandState set [2, "TRAVEL_TO_COVER"];
				_commandVars set [1, _ied];
			};
		};
		case "TRAVEL_TO_COVER":
		{			
			if(unitReady _agent) then
			{		
				_ied = _commandVars select 1;
				
				// watch ied position
				
				_agent doWatch _ied;
				
				_commandState set [2, "WAIT"];
				_commandVars set [2, 0];
			};
		};
		case "WAIT":
		{			
			_position = _commandVars select 0;
			_timer = _commandVars select 2;
			_timeout = _commandData select 1;
			_targetSide = _commandData select 2;
			
			_sideData = [arjay_agentSideVarNames, _targetSide] call Dictionary_fnc_get;
			
			// get all near units based on side parent config class
			_units = _position nearObjects [_sideData select 2, 10];
			
			if(count _units > 0) then
			{
				//["TRIGGER IED!!!!!!!!!!!!!!!!!!!!!!!!"] call arjay_dump;
			};
			
			if(_timer > _timeout) then
			{
				_commandState set [2, "COMPLETE"];
			};
			
			_timer = _timer + 1;
			
			_commandVars set [2, _timer];
		};
		case "COMPLETE":
		{
			_agent setVariable ["arjay_agentBusy", false, false];
		};
	};
};

/*
	Agent AI Command SUICIDE BOMBER
*/
arjay_agentCommandSUICIDE_BOMBER = 
{
	private ["_agentId","_agent","_commandState","_commandStateId","_commandData","_commandVars","_targetSide","_sideData","_units","_unit","_position"];
	
	_agentId = _this select 0;
	
	// get agent command state
	_commandState = [arjay_agentCommandStates, _agentId] call Dictionary_fnc_get;
	_agent = _commandState select 0;
	_commandStateId = _commandState select 2;
	_commandData = _commandState select 3;
	_commandVars = _commandState select 4;
	
	switch(_commandStateId) do
	{
		case "INIT":
		{
			_agent setVariable ["arjay_agentBusy", true, false];
			
			_targetSide = _commandData select 2;			
			_sideData = [arjay_agentSideVarNames, _targetSide] call Dictionary_fnc_get;
			
			// get all near units based on side parent config class
			_units = getPos _agent nearObjects [_sideData select 2, 100];
			
			if(count _units > 0) then
			{
				_unit = _units select (random((count _units)-1));
				_position = getPos _unit;
				_agent setSpeedMode "FULL";
				_agent doMove _position;
				_commandVars set [0, _unit];
				_commandState set [2, "TRAVEL"];
			}
			else
			{
				_commandState set [2, "COMPLETE"];
			};						
		};
		case "TRAVEL":
		{			
			_unit = _commandVars select 0;
			
			[_unit, _agent] spawn 
			{
				private ["_unit","_agent"];
				
				_unit = _this select 0;
				_agent = _this select 1;
				
				while { ((getPos _agent) distance (getPos _unit)) < 2 } do
				{
					_agent setSpeedMode "FULL";
					_agent doMove getPos _unit;
				};
				
				_object = "GrenadeHand" createVehicle (getPos _agent);
			};		
			
			_commandState set [2, "COMPLETE"];
		};
		case "COMPLETE":
		{
			_agent setVariable ["arjay_agentBusy", false, false];
		};
	};
};

/*
	Agent AI Command MEETING INITIATE
*/
arjay_agentCommandMEETING_INIT = 
{
	private ["_agentId","_agent","_commandState","_commandStateId","_commandData","_commandVars"];
	
	_agentId = _this select 0;
	
	// get agent command state
	_commandState = [arjay_agentCommandStates, _agentId] call Dictionary_fnc_get;
	_agent = _commandState select 0;
	_commandStateId = _commandState select 2;
	_commandData = _commandState select 3;
	_commandVars = _commandState select 4;
	
	switch(_commandStateId) do
	{
		case "INIT":
		{
			_agent setVariable ["arjay_agentBusy", true, false];

			[_agent] call arjay_agentGetMeetingPartner;
			_commandState set [2, "WAIT"];
		};
		case "WAIT":
		{			
			if(_agent getVariable "arjay_agentMeetingComplete") then
			{
				_agent playMove "";
				_commandState set [2, "COMPLETE"];
			};
		};
		case "COMPLETE":
		{
			_agent setVariable ["arjay_agentBusy", false, false];
		};
	};
};

/*
	Agent AI Command MEETING JOIN
*/
arjay_agentCommandMEETING_JOIN = 
{
	private ["_agentId","_agent","_commandState","_commandStateId","_commandData","_commandVars","_target","_position","_timer","_timeout"];
	
	_agentId = _this select 0;
	
	// get agent command state
	_commandState = [arjay_agentCommandStates, _agentId] call Dictionary_fnc_get;
	_agent = _commandState select 0;
	_commandStateId = _commandState select 2;
	_commandData = _commandState select 3;
	_commandVars = _commandState select 4;
	
	switch(_commandStateId) do
	{
		case "INIT":
		{
			_agent setVariable ["arjay_agentBusy", true, false];

			_target = _agent getVariable "arjay_agentMeetingTarget";
			_position = getPosASL _target;
			_agent setSpeedMode "LIMITED";
			_agent doMove _position;
			_commandState set [2, "TRAVEL"];			
			_commandVars set [0, _target];
			_agent setVariable ["arjay_agentMeetingRequested", false, false];
		};
		case "TRAVEL":
		{			
			if(unitReady _agent) then
			{		
				_target = _commandVars select 0;
				_agent lookAt _target;
				_target lookAt _agent;

				if!(_agent distance _target > 10) then
				{
					if(random 1 < 0.5) then
					{
						if(isMultiplayer && !arjay_isMultiplayerHost && arjay_agentBroadcastAgentAnimations) then
						{
							["arjay_clientCommandSwitchMove", [_agent, "acts_PointingLeftUnarmed"]] call arjay_broadcastClientCommand;
							["arjay_clientCommandSwitchMove", [_target, "acts_StandingSpeakingUnarmed"]] call arjay_broadcastClientCommand;
						}
						else
						{
							_agent switchMove "acts_PointingLeftUnarmed";
							_target switchMove "acts_StandingSpeakingUnarmed";
						};						
					}
					else
					{
						if(isMultiplayer && !arjay_isMultiplayerHost && arjay_agentBroadcastAgentAnimations) then
						{
							["arjay_clientCommandSwitchMove", [_agent, "acts_StandingSpeakingUnarmed"]] call arjay_broadcastClientCommand;
							["arjay_clientCommandSwitchMove", [_target, "acts_PointingLeftUnarmed"]] call arjay_broadcastClientCommand;
						}
						else
						{
							_agent switchMove "acts_StandingSpeakingUnarmed";
							_target switchMove "acts_PointingLeftUnarmed";
						};
					};
				};
				
				_commandState set [2, "MEETING"];			
				_commandVars set [1, 0];
			};
		};
		case "MEETING":
		{			
			_timer = _commandVars select 1;
			_timeout = _commandData select 0;			
			
			if(_timer > _timeout) then
			{
				_target = _commandVars select 0;
				
				_agent playMove "";
				_target setVariable ["arjay_agentMeetingComplete", true, false];
				_agent setVariable ["arjay_agentMeetingTarget", objNull, false];				
				_commandState set [2, "COMPLETE"];
			};
			
			_timer = _timer + 1;
			
			_commandVars set [1, _timer];
		};
		case "COMPLETE":
		{
			_agent setVariable ["arjay_agentBusy", false, false];				
		};
	};
};

/*
	Agent AI Command GATHERING INITIATE
*/
arjay_agentCommandGATHERING_INIT = 
{
	private ["_agentId","_agent","_commandState","_commandStateId","_commandData","_commandVars","_position","_partners","_timer","_timeout"];
	
	_agentId = _this select 0;
	
	// get agent command state
	_commandState = [arjay_agentCommandStates, _agentId] call Dictionary_fnc_get;
	_agent = _commandState select 0;
	_commandStateId = _commandState select 2;
	_commandData = _commandState select 3;
	_commandVars = _commandState select 4;
	
	switch(_commandStateId) do
	{
		case "INIT":
		{
			_agent setVariable ["arjay_agentBusy", true, false];
			
			_position = getPosASL _agent findEmptyPosition[10, 100, "O_Ka60_F"];
			
			if(count _position > 0) then
			{
				_agent setSpeedMode "LIMITED";
				_agent doMove _position;
				_commandState set [2, "TRAVEL"];
			}
			else
			{
				_commandState set [2, "COMPLETE"];				
			};
		};
		case "TRAVEL":
		{			
			if(unitReady _agent) then
			{			
				_partners = [_agent] call arjay_agentGetGatheringPartners;
				_commandState set [2, "WAIT"];
				_commandVars set [0, _partners];
				_commandVars set [1, 0];
			};
		};
		case "WAIT":
		{	
			_partners = _commandVars select 0;
			_timer = _commandVars select 1;
			_timeout = _commandData select 1;		
			
			if(_timer > _timeout) then
			{				
				_agent playMove "";
				
				{
					_x setVariable ["arjay_agentGatheringRequested", false, false];
					_x setVariable ["arjay_agentGatheringComplete", true, false];
					_x setVariable ["arjay_agentGatheringTarget", objNull, false];					
					
				} forEach _partners;
				
				_agent setVariable ["arjay_agentGatheringRequested", false, false];
				_agent setVariable ["arjay_agentGatheringComplete", true, false];
				_agent setVariable ["arjay_agentGatheringTarget", objNull, false];				
				_commandState set [2, "COMPLETE"];
			};
			
			_timer = _timer + 1;
			
			_commandVars set [1, _timer];
		};
		case "COMPLETE":
		{
			_agent setVariable ["arjay_agentBusy", false, false];
		};
	};
};

/*
	Agent AI Command GATHERING JOIN
*/
arjay_agentCommandGATHERING_JOIN = 
{
	private ["_agentId","_agent","_commandState","_commandStateId","_commandData","_commandVars","_target","_position"];
	
	_agentId = _this select 0;
	
	// get agent command state
	_commandState = [arjay_agentCommandStates, _agentId] call Dictionary_fnc_get;
	_agent = _commandState select 0;
	_commandStateId = _commandState select 2;
	_commandData = _commandState select 3;
	_commandVars = _commandState select 4;
	
	switch(_commandStateId) do
	{
		case "INIT":
		{
			_agent setVariable ["arjay_agentBusy", true, false];

			_target = _agent getVariable "arjay_agentGatheringTarget";
			_position = [getPosASL _target, random 5, random 360] call BIS_fnc_relPos;
			_agent setSpeedMode "LIMITED";
			_agent doMove _position;
			_commandState set [2, "TRAVEL"];
			_commandVars set [0, _target];
			_agent setVariable ["arjay_agentGatheringRequested", false, false];
		};
		case "TRAVEL":
		{			
			if(unitReady _agent) then
			{			
				_target = _commandVars select 0;
				_agent lookAt _target;
				_target lookAt _agent;

				if(_agent distance _target < 5) then
				{
					if(random 1 < 0.5) then
					{
						if(isMultiplayer && !arjay_isMultiplayerHost && arjay_agentBroadcastAgentAnimations) then
						{
							["arjay_clientCommandSwitchMove", [_agent, "acts_PointingLeftUnarmed"]] call arjay_broadcastClientCommand;
						}
						else
						{
							_agent switchMove "acts_PointingLeftUnarmed";
						};
					}
					else
					{
						if(isMultiplayer && !arjay_isMultiplayerHost && arjay_agentBroadcastAgentAnimations) then
						{
							["arjay_clientCommandSwitchMove", [_agent, "acts_StandingSpeakingUnarmed"]] call arjay_broadcastClientCommand;
						}
						else
						{
							_agent switchMove "acts_StandingSpeakingUnarmed";
						};
					};
				};
					
				_commandState set [2, "GATHERING"];
			};
		};
		case "GATHERING":
		{			
			if(_agent getVariable "arjay_agentGatheringComplete") then
			{				
				_agent playMove "";
				_commandState set [2, "COMPLETE"];
			};
		};
		case "COMPLETE":
		{
			_agent setVariable ["arjay_agentBusy", false, false];
		};
	};
};

/*
	Agent AI Command TASK
*/
arjay_agentCommandTASK = 
{
	private ["_agentId", "_agent", "_commandState", "_commandStateId", "_commandData", "_commandVars", "_radius", "_nearTaskBuildings", "_building", "_position", "_agentPosition", "_vehicle", "_dayState", "_newCommandData", "_timer", "_timeout"];
	
	_agentId = _this select 0;
	
	// get agent command state
	_commandState = [arjay_agentCommandStates, _agentId] call Dictionary_fnc_get;
	_agent = _commandState select 0;
	_commandStateId = _commandState select 2;
	_commandData = _commandState select 3;
	_commandVars = _commandState select 4;
	
	switch(_commandStateId) do
	{
		case "INIT":
		{
			_agent setVariable ["arjay_agentBusy", true, false];
					
			//_radius = 100 + random 10000;
			_radius = 1000;
			
			_nearTaskBuildings = [_agent, arjay_civilianTaskBuildings, _radius] call arjay_agentGetNearestTaskBuildings;
			
			// return a random building
			if(count _nearTaskBuildings > 0) then
			{
				_building = _nearTaskBuildings select (random((count _nearTaskBuildings)-1));
				
				_position = getPosASL _building;
				_agentPosition = getPosASL _agent;
				
				_commandVars set [0, _building];
				_commandVars set [1, _position];
				_commandVars set [2, 0];
				
				if(_agentPosition distance _position > 1000) then
				{
					// switch to drive to command
					_vehicle = [_agent] call arjay_agentGetOwnVehicle;
					
					if!(isNull _vehicle) then
					{						
						_dayState = arjay_currentEnvironment select 0;
						_newCommandData = [arjay_agentCivilianCommands, "DRIVE_TO"] call Dictionary_fnc_get;
						_newCommandData = [_newCommandData, _dayState] call Dictionary_fnc_get;
					
						// set agent command state
						// store current command details in the new commands var array so it can return when done
						[arjay_agentCommandStates, _agentId, [_agent, "DRIVE_TO", "INIT", _newCommandData, [["TASK", "TRAVEL_TO_BUILDING", _commandData, _commandVars], _vehicle, _position]]] call Dictionary_fnc_set;
						
						[_agentId] call arjay_agentCommandDRIVE_TO;
					}
					else
					{
						_commandState set [2, "COMPLETE"];
					};
				}
				else
				{
					_agent setSpeedMode "LIMITED";
					_agent doMove _position;
					_commandState set [2, "TRAVEL_TO_BUILDING"];
				};			
			}
			else
			{
				_commandState set [2, "COMPLETE"];
			};
		};
		case "TRAVEL_TO_BUILDING":
		{			
			_building = _commandVars select 0;
			if(unitReady _agent) then
			{			
				_position = [_building] call arjay_getRandomBuildingPosition;
				_agent setSpeedMode "LIMITED";
				_agent doMove _position;
				_commandState set [2, "TRAVEL_TO_BUILDING_POSITON"];
			}
			else
			{
				_timer = _commandVars select 2;
				if(_timer > arjay_agentCivilianMoveTimeout) then
				{
					doStop _agent;
					_commandState set [2, "COMPLETE"];
				};
				
				_timer = _timer + 1;			
				_commandVars set [2, _timer];
			};
		};
		case "TRAVEL_TO_BUILDING_POSITON":
		{
			if(unitReady _agent) then
			{
				_commandVars set [2, 0];
				_commandState set [2, "TASK"];
			};
		};
		case "TASK":
		{			
			_timer = _commandVars select 2;
			_timeout = _commandData select 1;			
			
			if(_timer > _timeout) then
			{		
				_commandState set [2, "COMPLETE"];
			};
			
			_timer = _timer + 1;
			
			_commandVars set [2, _timer];
		};
		case "COMPLETE":
		{
			_agent setVariable ["arjay_agentBusy", false, false];
		};
	};
};

/*
	Agent AI Command DRIVE TO
*/
arjay_agentCommandDRIVE_TO = 
{
	private ["_agentId", "_agent", "_commandState", "_commandStateId", "_commandData", "_commandVars", "_vehicle", "_position", "_timer", "_callbackCommandData"];
	
	_agentId = _this select 0;
	
	// get agent command state
	_commandState = [arjay_agentCommandStates, _agentId] call Dictionary_fnc_get;
	_agent = _commandState select 0;
	_commandStateId = _commandState select 2;
	_commandData = _commandState select 3;
	_commandVars = _commandState select 4;
	
	switch(_commandStateId) do
	{
		case "INIT":
		{			
			_vehicle = _commandVars select 1;
			
			_position = getPosASL _vehicle;
			_agent setSpeedMode "LIMITED";
			_agent doMove _position;
			_commandVars set [3, 0];
			_commandState set [2, "TRAVEL_TO_VEHICLE"];
		};
		case "TRAVEL_TO_VEHICLE":
		{			
			if(unitReady _agent) then
			{				
				_vehicle = _commandVars select 1;
				
				_agent assignAsDriver _vehicle;
				[_agent] orderGetIn true;
				_commandVars set [3, 0];
				_commandState set [2, "GET_IN_VEHICLE"];			
			}
			else
			{
				_timer = _commandVars select 3;
				if(_timer > arjay_agentCivilianMoveTimeout) then
				{
					doStop _agent;
					_commandState set [2, "COMPLETE"];
				};
				
				_timer = _timer + 1;			
				_commandVars set [3, _timer];
			};
		};
		case "GET_IN_VEHICLE":
		{			
			if(unitReady _agent) then
			{			
				_vehicle = _commandVars select 1;
				
				if(_agent in _vehicle) then 
				{					
					_position = _commandVars select 2;
					_position = [_position] call arjay_getSideOfRoadPosition;
					
					_agent setSpeedMode "LIMITED";
					_agent doMove _position;
					_commandVars set [3, 0];
					_commandState set [2, "TRAVEL_TO_PARKING_POSITION"];
				};
			};
		};
		case "TRAVEL_TO_PARKING_POSITION":
		{			
			if(unitReady _agent) then
			{			
				[_agent] orderGetIn false;
				_commandState set [2, "GET_OUT_VEHICLE"];
			}
			else
			{
				_timer = _commandVars select 3;
				if(_timer > arjay_agentCivilianDriveTimeout) then
				{
					doStop _agent;
					[_target] orderGetIn false;	
					_commandState set [2, "COMPLETE"];
				};
				
				_timer = _timer + 1;			
				_commandVars set [3, _timer];
			};
		};
		case "GET_OUT_VEHICLE":
		{			
			if(unitReady _agent) then
			{			
				_vehicle = _commandVars select 1;
				
				if!(_agent in _vehicle) then 
				{
					_commandState set [2, "COMPLETE"];
				};
			};
		};
		case "COMPLETE":
		{
			_callbackCommandData = _commandVars select 0;
			_position = _commandVars select 2;
			
			_agent setSpeedMode "LIMITED";
			_agent doMove _position;
			// set agent command state
			[arjay_agentCommandStates, _agentId, [_agent, (_callbackCommandData select 0), (_callbackCommandData select 1), (_callbackCommandData select 2), (_callbackCommandData select 3)]] call Dictionary_fnc_set;
		};
	};
};