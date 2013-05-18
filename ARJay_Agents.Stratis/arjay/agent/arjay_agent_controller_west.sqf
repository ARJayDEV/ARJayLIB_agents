/*
	File: arjay_agent_controller_west.sqf
	Author: ARJay
	Description: West Controller
	
	This is a bit of a experiment to get maximum performance out of the arma scheduling system
	The issue is that there may be updwards of 50 active individual civilian agents at any one time
	To handle AI decision making for such a large amount of agents I have tried to avoid
	FSM's (non-scheduled, conditions checked every frame), Spawned functions (scheduled, but 50 running at once!!)
	So I have built this little controller to handle all active faction agents, it runs in a loop with sleeps
	All variables associated with an individual agents AI command are stored in arjay_agentCommandStates to simulate scope 
	so the AI task can be tracked at a later point in time. A bit of an abomination, but reasonably fast for handling large numbers
	of agents without bringing a server to its knees
*/

arjay_agentWestAllowedCommands = ["WALK", "HOUSEWORK", "LOCATION_PATROL", "GARISON_DEFENSIVE_POSITIONS", "MAN_STATIC_WEAPON", "REMOTE_LOCATION_PATROL", "AIR_PATROL"];
//arjay_agentWestAllowedCommands = ["AIR_PATROL"];
arjay_agentWestMoveTimeout = 40;
arjay_agentWestDriveTimeout = 1000;
arjay_agentWestCommands = call Dictionary_fnc_new;

// walk [probability, maxDistance]
arjay_agentWestCommand = call Dictionary_fnc_new;
[arjay_agentWestCommand, "DAY", [0.1, 200]] call Dictionary_fnc_set;
[arjay_agentWestCommand, "EVENING", [0.1, 200]] call Dictionary_fnc_set;
[arjay_agentWestCommand, "NIGHT", [0.1, 200]] call Dictionary_fnc_set;
[arjay_agentWestCommands, "WALK", arjay_agentWestCommand] call Dictionary_fnc_set;

// housework [probability]
arjay_agentWestCommand = call Dictionary_fnc_new;
[arjay_agentWestCommand, "DAY", [0.1]] call Dictionary_fnc_set;
[arjay_agentWestCommand, "EVENING", [0.5]] call Dictionary_fnc_set;
[arjay_agentWestCommand, "NIGHT", [0.1]] call Dictionary_fnc_set;
[arjay_agentWestCommands, "HOUSEWORK", arjay_agentWestCommand] call Dictionary_fnc_set;

// location patrol
arjay_agentWestCommand = call Dictionary_fnc_new;
[arjay_agentWestCommand, "DAY", [0.3]] call Dictionary_fnc_set;
[arjay_agentWestCommand, "EVENING", [0.3]] call Dictionary_fnc_set;
[arjay_agentWestCommand, "NIGHT", [0.1]] call Dictionary_fnc_set;
[arjay_agentWestCommands, "LOCATION_PATROL", arjay_agentWestCommand] call Dictionary_fnc_set;

// garison defensive positions
arjay_agentWestCommand = call Dictionary_fnc_new;
[arjay_agentWestCommand, "DAY", [0.1, 1000]] call Dictionary_fnc_set;
[arjay_agentWestCommand, "EVENING", [0.1, 1000]] call Dictionary_fnc_set;
[arjay_agentWestCommand, "NIGHT", [0.1, 1000]] call Dictionary_fnc_set;
[arjay_agentWestCommands, "GARISON_DEFENSIVE_POSITIONS", arjay_agentWestCommand] call Dictionary_fnc_set;

// man static weapon
arjay_agentWestCommand = call Dictionary_fnc_new;
[arjay_agentWestCommand, "DAY", [0.1, 1000]] call Dictionary_fnc_set;
[arjay_agentWestCommand, "EVENING", [0.1, 1000]] call Dictionary_fnc_set;
[arjay_agentWestCommand, "NIGHT", [0.1, 1000]] call Dictionary_fnc_set;
[arjay_agentWestCommands, "MAN_STATIC_WEAPON", arjay_agentWestCommand] call Dictionary_fnc_set;

// board ground vehicle
arjay_agentWestCommand = call Dictionary_fnc_new;
[arjay_agentWestCommand, "DAY", ["GROUND", 10]] call Dictionary_fnc_set;
[arjay_agentWestCommand, "EVENING", ["GROUND", 10]] call Dictionary_fnc_set;
[arjay_agentWestCommand, "NIGHT", ["GROUND", 10]] call Dictionary_fnc_set;
[arjay_agentWestCommands, "BOARD_GROUND_VEHICLE", arjay_agentWestCommand] call Dictionary_fnc_set;

// board air vehicle
arjay_agentWestCommand = call Dictionary_fnc_new;
[arjay_agentWestCommand, "DAY", ["AIR", 10]] call Dictionary_fnc_set;
[arjay_agentWestCommand, "EVENING", ["AIR", 10]] call Dictionary_fnc_set;
[arjay_agentWestCommand, "NIGHT", ["AIR", 10]] call Dictionary_fnc_set;
[arjay_agentWestCommands, "BOARD_AIR_VEHICLE", arjay_agentWestCommand] call Dictionary_fnc_set;

// board sea vehicle
arjay_agentWestCommand = call Dictionary_fnc_new;
[arjay_agentWestCommand, "DAY", ["SEA", 10]] call Dictionary_fnc_set;
[arjay_agentWestCommand, "EVENING", ["SEA", 10]] call Dictionary_fnc_set;
[arjay_agentWestCommand, "NIGHT", ["SEA", 10]] call Dictionary_fnc_set;
[arjay_agentWestCommands, "BOARD_SEA_VEHICLE", arjay_agentWestCommand] call Dictionary_fnc_set;

// remote location patrol
arjay_agentWestCommand = call Dictionary_fnc_new;
[arjay_agentWestCommand, "DAY", [0.1, 1000]] call Dictionary_fnc_set;
[arjay_agentWestCommand, "EVENING", [0.1, 1000]] call Dictionary_fnc_set;
[arjay_agentWestCommand, "NIGHT", [0.1, 1000]] call Dictionary_fnc_set;
[arjay_agentWestCommands, "REMOTE_LOCATION_PATROL", arjay_agentWestCommand] call Dictionary_fnc_set;

// building patrol
arjay_agentWestCommand = call Dictionary_fnc_new;
[arjay_agentWestCommand, "DAY", [100]] call Dictionary_fnc_set;
[arjay_agentWestCommand, "EVENING", [100]] call Dictionary_fnc_set;
[arjay_agentWestCommand, "NIGHT", [100]] call Dictionary_fnc_set;
[arjay_agentWestCommands, "BUILDING_PATROL", arjay_agentWestCommand] call Dictionary_fnc_set;

// air patrol
arjay_agentWestCommand = call Dictionary_fnc_new;
[arjay_agentWestCommand, "DAY", [0.1, 6000]] call Dictionary_fnc_set;
[arjay_agentWestCommand, "EVENING", [0.1, 6000]] call Dictionary_fnc_set;
[arjay_agentWestCommand, "NIGHT", [0.1, 6000]] call Dictionary_fnc_set;
[arjay_agentWestCommands, "AIR_PATROL", arjay_agentWestCommand] call Dictionary_fnc_set;

/*
	Start the AI command controller
*/
arjay_agentControllerWest =
{
	private ["_handle"];
	
	_handle = [] spawn 
	{
		private ["_agent", "_agentBusy"];
		
		// debug ----------------------------------------------------------------------------------------------------------------------------
		//if(arjay_debug) then {["--- WEST CONTROLLER INIT --------------------------------------------------------------------------"] call arjay_dump;};
		// debug ----------------------------------------------------------------------------------------------------------------------------
		
		while { true } do
		{		
			{
				_agent = [arjay_agents, _x] call Dictionary_fnc_get;

				_agentBusy = _agent getVariable "arjay_agentBusy";	
				
				if!(_agentBusy) then
				{
					// issue a new command
					[_x, _agent] call arjay_agentIssueWestCommand;
				}
				else
				{
					// track current command
					[_x] call arjay_agentTrackIssuedWestCommand;					
				};				
				
				sleep 0.1;
			
			} forEach arjay_agentsWestActive;
						
			sleep arjay_agentWestControllerCycleTime;
			
		};
	};
	
	_handle
};

/*
	Issue a command to an agent
*/
arjay_agentIssueWestCommand = 
{
	private ["_agentId", "_agent", "_dayState", "_commandId", "_commandData", "_probability"];
	
	_agentId = _this select 0;
	_agent = _this select 1;
	
	_dayState = arjay_currentEnvironment select 0;
	
	_commandId = arjay_agentWestAllowedCommands select (random((count arjay_agentWestAllowedCommands)-1));
	_commandData = [arjay_agentWestCommands, _commandId] call Dictionary_fnc_get;
	_commandData = [_commandData, _dayState] call Dictionary_fnc_get;
	
	_probability = _commandData select 0;
	
	// special case for meeting command
	if(_agent getVariable "arjay_agentMeetingRequested") exitWith
	{
		_commandData = [arjay_agentWestCommands, "MEETING_JOIN"] call Dictionary_fnc_get;
		_commandData = [_commandData, _dayState] call Dictionary_fnc_get;
	
		// set agent command state
		[arjay_agentCommandStates, _agentId, [_agent, "MEETING_JOIN", "INIT", _commandData, []]] call Dictionary_fnc_set;
		
		[_agentId] call arjay_agentCommandMEETING_JOIN;
	};
	
	// special case for gathering command
	if(_agent getVariable "arjay_agentGatheringRequested") exitWith
	{
		_commandData = [arjay_agentWestCommands, "GATHERING_JOIN"] call Dictionary_fnc_get;
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
arjay_agentTrackIssuedWestCommand = 
{
	private ["_agentId", "_dayState", "_commandState", "_commandId"];
	
	_agentId = _this select 0;
	
	_dayState = arjay_currentEnvironment select 0;
	
	// get agent command state
	_commandState = [arjay_agentCommandStates, _agentId] call Dictionary_fnc_get;
	_commandId = _commandState select 1;
	
	call compile format['_command = ["%2"] call arjay_agentCommand%1;', _commandId, _agentId];
	
};