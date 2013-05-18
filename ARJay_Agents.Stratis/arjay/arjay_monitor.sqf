/*
	File: arjay_monitor.sqf
	Author: ARJay
	Description: Main Monitoring Loop
*/

arjay_players = [];
arjay_playerPositions = [];
arjay_isMonitoring = false;

/*
	Main monitor loop
*/
arjay_monitor = 
{
	arjay_isMonitoring = true;
	
	[] spawn
	{
		private ["_position"];
		
		while {arjay_isMonitoring} do
		{
			
			// debug ----------------------------------------------------------------------------------------------------------------------------
			//if(arjay_debug && arjay_debugLevel > 10) then {["-------------------------------------------------------------------------------------------------------"] call arjay_dump;};
			//if(arjay_debug && arjay_debugLevel > 10) then {["--- MONITOR -------------------------------------------------------------------------------------------"] call arjay_dump;};
			// debug ----------------------------------------------------------------------------------------------------------------------------
			
			
			// track players
			[] call arjay_trackPlayers;			
			
			
			// activate agents
			if(arjay_agentsActive) then
			{
				[] call arjay_agentSetActiveLocations;
				
				[] call arjay_getEnvironment;
				
				[] call arjay_agentHandleControllers;
				
				// debug ----------------------------------------------------------------------------------------------------------------------------
				/*
				if(arjay_debug && (arjay_debugLevel == 4 || arjay_debugLevel > 10)) then 
				{
					["--- AGENT CONTROLLER COMMAND STATE --------------------------------------------------------------------"] call arjay_dump;
					{
						[[arjay_agentCommandStates, _x] call Dictionary_fnc_get] call arjay_dump;
					} forEach (arjay_agentCommandStates select 0);
					["-------------------------------------------------------------------------------------------------------"] call arjay_dump;
				};
				*/
				// debug ----------------------------------------------------------------------------------------------------------------------------
				
			};
			

			// garbage collection
			if(arjay_garbageCollectionActive) then
			{
				[] call arjay_collectGarbage;		
			};
			
			sleep arjay_agentMonitorCycleTime;
		};
	};
};

/*
	Track player data
*/
arjay_trackPlayers = 
{
	// get all players
	arjay_players = [];
	arjay_playerPositions = [];
	
	if(isMultiplayer) then
	{
		arjay_players = playableUnits;
	}
	else
	{
		arjay_players set [0, player];
	};
	
	// all players loop
	{
		// player is not flying
		if!(vehicle _x isKindOf "Air") then
		{
			_position = getPos _x;
			arjay_playerPositions set [count arjay_playerPositions, _position];			
		}
		// player is flying
		else
		{
			_position = getPos _x;
			arjay_playerPositions set [count arjay_playerPositions, _position];
		};
	} forEach arjay_players;
};