/*
	File: arjay_agent_controller_mission.sqf
	Author: ARJay
	Description: Mission Controller
*/

/*
	Start the AI command controller
*/
arjay_agentControllerMission =
{
	private ["_handle"];
	
	_handle = [] spawn 
	{		
		// debug ----------------------------------------------------------------------------------------------------------------------------
		//if(arjay_debug) then {["--- MISSION CONTROLLER INIT ---------------------------------------------------------------------------"] call arjay_dump;};
		// debug ----------------------------------------------------------------------------------------------------------------------------
		
		while { true } do
		{	
			
			// location clearance checking
			
			private ["_locationName", "_locationData", "_locationClearanceData", "_worldLocation", "_locationPosition", "_countSides", "_locationCanBeCleared", "_locationSides", 
			"_sideLocationData", "_sideData", "_agents", "_vehicles", "_agentCount", "_locationAgentCount"];
			
			{				
				_locationName = _x;
				_locationData = [arjay_missionLocations, _locationName] call Dictionary_fnc_get;
				_locationClearanceData = [arjay_missionLocationClearance, _locationName] call Dictionary_fnc_get;
				_worldLocation = [arjay_worldLocations, _x] call Dictionary_fnc_get;
				_locationPosition = _worldLocation select 2;
				_countSides = 0;
								
				// if this location is allowed to be cleared
				_locationCanBeCleared = _locationClearanceData select 0;
				if!(_locationCanBeCleared) exitWith {};
				
				_locationCanBeCleared = false;
				
				// determine if there are players within the clear radius of a location
				{
					if((_x distance _locationPosition) < arjay_agentLocationClearRadius) exitWith
					{
						_locationCanBeCleared = true;
					};
				} forEach arjay_playerPositions;
				
				_locationSides = _locationData select 0;
				
				// if the location is clearable
				if(_locationCanBeCleared) then
				{		
					_locationAgentCount = 0;
					
					{					
						_sideLocationData = _locationData select 1 select _countSides;
						_sideData = [arjay_agentSideVarNames, _x] call Dictionary_fnc_get;
						
						// get all near units based on side parent config class
						_agents = _locationPosition nearObjects [_sideData select 2, arjay_agentLocationClearRadius];
						_agentCount = count _agents;
						
						// subtract agents that are dead
						{
							if!(alive _x) then
							{
								_agentCount = _agentCount - 1;
							};
						} forEach _agents;
						
						// get all units in vehicles
						_vehicles = nearestObjects [_locationPosition, ["Helicopter","Ship","Car","TANK","Truck","Motorcycle"], arjay_agentLocationClearRadius];
						{
							{
								if((side _x == (_sideData select 1)) && alive _x) then 
								{
									_agentCount = _agentCount + 1;
								};
							} forEach crew _x;
						} forEach _vehicles;						
						
						// debug ----------------------------------------------------------------------------------------------------------------------------
						//if(arjay_debug && (arjay_debugLevel == 3 || arjay_debugLevel > 10)) then {["--- LOCATION %1 (%2) AGENT COUNT: %3", _locationName, _x, _agentCount] call arjay_dump;};
						// debug ----------------------------------------------------------------------------------------------------------------------------
						
						// no agents for this side left alive or present at this location
						// clear the sides location occupation status
						if(_agentCount == 0) then
						{						
							// debug ----------------------------------------------------------------------------------------------------------------------------
							//if(arjay_debug && (arjay_debugLevel == 3 || arjay_debugLevel > 10)) then {["--- LOCATION %1 (%2) CLEARED", _locationName, _x] call arjay_dump;};
							// debug ----------------------------------------------------------------------------------------------------------------------------
														
							// completely clear the location side from all agent system data structures
							[_locationName, _x] call arjay_agentResetMissionLocationSide;
															
							// debug ----------------------------------------------------------------------------------------------------------------------------
							//if(arjay_debug) then {[] call arjay_agentDataStructureSnapShot;};
							// debug ----------------------------------------------------------------------------------------------------------------------------					
						};
						
						_countSides = _countSides + 1;
						
					} forEach _locationSides;
					
					_locationAgentCount = _locationAgentCount + _agentCount;
					
					if(_locationAgentCount == 0) then
					{
						// start the timer to capture the location
						[_locationName, _locationPosition] spawn arjay_agentCaptureLocation;
					};
				};
			
			} forEach (arjay_agentActiveLocations select 0);
			
			sleep arjay_agentMissionControllerCycleTime;			
		};
	};
	
	_handle
};

/*
	Removes a sides occupation status completely from the agent system
*/
arjay_agentResetMissionLocationSide = 
{
	private ["_locationName", "_side", "_locationData", "_locationDataKeys", "_locationDataValues", "_sideIndex", "_sideLocationData", "_marker", "_agents", "_vehicles"];
	
	_locationName = _this select 0;
	_side = _this select 1;
	
	// get the location mission data
	_locationData = [arjay_missionLocations, _locationName] call Dictionary_fnc_get;
	_locationDataKeys = _locationData select 0;
	_locationDataValues = _locationData select 1;
	_sideIndex = _locationDataKeys find _side;
	_sideLocationData = _locationDataValues select _sideIndex;
	
	// remove side map marker
	if(arjay_agentCreateMapMarkers) then
	{
		_marker = _sideLocationData select 2;
		deleteMarker _marker;
	};
	
	// remove this sides values from arjay_missionLocations
	_locationDataKeys = _locationDataKeys - [_side];
	_locationDataValues set [_sideIndex, "remove"];
	_locationDataValues = _locationDataValues - ["remove"];							
	[arjay_missionLocations, _locationName, [_locationDataKeys, _locationDataValues]] call Dictionary_fnc_set;				
	
	// cleanup the location if a side has been cleared from it
	// this means that any agents who were not killed (away from home)
	// or any vehicles associated with the side will be garbage collected
	// and cleaned, removing all trace from the agent system
	
	switch(_side) do
	{
		case "CIV": 
		{
			_agents = [arjay_agentsCivilianByLocation, _locationName] call Dictionary_fnc_get;
			_vehicles = [arjay_agentCivilianVehiclesByLocation, _locationName] call Dictionary_fnc_get;
		};
		case "EAST": 
		{
			_agents = [arjay_agentsEastByLocation, _locationName] call Dictionary_fnc_get;
			_vehicles = [arjay_agentEastVehiclesByLocation, _locationName] call Dictionary_fnc_get;
		};
		case "WEST": 
		{
			_agents = [arjay_agentsWestByLocation, _locationName] call Dictionary_fnc_get;
			_vehicles = [arjay_agentWestVehiclesByLocation, _locationName] call Dictionary_fnc_get;
		};
	};
	
	// if location is currently active
	if(_locationName in (arjay_agentActiveLocations select 0)) then
	{
		[_agents, _vehicles, true] call arjay_depopulateLocation;
	}
	else
	{
		// location is not active just remove agents from data structures
		{
			[_x] call arjay_cleanupAgent;
		} forEach _agents;
		{
			[_x] call arjay_cleanupAgentVehicle;
		} forEach _vehicles;
	};	
};

/*
	Capture location after cleared
*/
arjay_agentCaptureLocation = 
{
	private ["_locationName", "_locationPosition", "_timer", "_captured", "_captureSide", "_players", "_displayUI", "_countInCaptureRange", "_side", "_locationData", "_sideMarkerData", "_markerName", "_marker"];
	
	_locationName = _this select 0;
	_locationPosition = _this select 1;
	
	_timer = 0;
	_captured = false;
	_captureSide = [];
	_players = [];
	
	disableSerialization;
	
	// check that capturing players remain in capture radius
	while{_timer < arjay_agentLocationCaptureTime} do
	{
		_countInCaptureRange = 0;
		_captureSide = [];
		_players = [];
		
		{
			if((_x distance _locationPosition) < arjay_agentLocationClearRadius) then
			{
				_countInCaptureRange = _countInCaptureRange + 1;
				_captureSide set [count _captureSide, side _x];
				_players set [count _players, _x];
			};
		} forEach arjay_players;
		
		if(_timer == 0) then
		{
			// display popup dialog with capture status
			if(isMultiplayer && !arjay_isMultiplayerHost) then
			{
				[_players, "arjay_clientCommandDisplayCaptureDialog", ["Capturing", "..."]] call arjay_sendClientsCommand;
			}
			else
			{
				2 cutRsc ["ARJAY_CAPTURE_DIALOG","PLAIN"];
				_displayUI = uiNamespace getVariable 'ARJAY_CAPTURE_DIALOG';
				(_displayUI displayCtrl 1001) ctrlSetText "Capturing";
				(_displayUI displayCtrl 1002) ctrlSetText "";
			};	
		}
		else
		{
			// display popup dialog with capture status
			if(isMultiplayer && !arjay_isMultiplayerHost) then
			{
				[_players, "arjay_clientCommandUpdateCaptureDialog", ["Capturing", format["%1", (arjay_agentLocationCaptureTime - _timer)]]] call arjay_sendClientsCommand;
			}
			else
			{
				(_displayUI displayCtrl 1001) ctrlSetText "Capturing";
				(_displayUI displayCtrl 1002) ctrlSetText format["%1", (arjay_agentLocationCaptureTime - _timer)];
			};			
		};
		
		if(_countInCaptureRange == 0) exitWith {};
		
		sleep 1;
		
		_timer = _timer + 1;
	};
		
	if(_countInCaptureRange > 0) then
	{
		// captured		
		_side = _captureSide call BIS_fnc_arrayPop;
		_side = format["%1", _side];		
		
		_marker = objNull;
		
		// create new marker for capturing side
		if(arjay_agentCreateMapMarkers) then
		{
			_locationData = [arjay_worldLocations, _locationName] call Dictionary_fnc_get;		
			_sideMarkerData = [arjay_agentSideMarkers, _side] call Dictionary_fnc_get;		
			arjay_agentCountMarkers = arjay_agentCountMarkers + 1;			
						
			_markerName = format["arjay_marker_%1", arjay_agentCountMarkers];
			_marker = createMarker [_markerName, _locationData select 2];
			_marker setMarkerSize [200, 200];
			_marker setMarkerAlpha 1;		
			_marker setMarkerShape (_sideMarkerData select 0);
			_marker setMarkerBrush (_sideMarkerData select 1);			
			_marker setMarkerColor (_sideMarkerData select 2);
		};
		
		// create new location init preset for side
		[arjay_missionLocations, _locationName, [[_side],[[1, 0.5, _marker, 0, []]]]] call Dictionary_fnc_set;
		
		// disable clearance checking as it has just been cleared
		[arjay_missionLocationClearance, _locationName, [false, true]] call Dictionary_fnc_set;
		
		// remove location from initialised locations so it will be re-initialised when it is activated next time
		[arjay_agentInitialisedLocations, _locationName] call Dictionary_fnc_remove;
		
		// debug ----------------------------------------------------------------------------------------------------------------------------
		//if(arjay_debug) then {[] call arjay_agentDataStructureSnapShot;};
		// debug ----------------------------------------------------------------------------------------------------------------------------	
		
		// display popup dialog with capture status
		if(isMultiplayer && !arjay_isMultiplayerHost) then
		{
			[_players, "arjay_clientCommandUpdateCaptureDialog", ["Location Captured", "..."]] call arjay_sendClientsCommand;
		}
		else
		{
			(_displayUI displayCtrl 1001) ctrlSetText "Location Captured";
			(_displayUI displayCtrl 1002) ctrlSetText "";
		};
	}
	else
	{
		// display popup dialog with capture status
		if(isMultiplayer && !arjay_isMultiplayerHost) then
		{
			[_players, "arjay_clientCommandUpdateCaptureDialog", ["Capture Location Failed", "..."]] call arjay_sendClientsCommand;
		}
		else
		{
			(_displayUI displayCtrl 1001) ctrlSetText "Capture Failed";
			(_displayUI displayCtrl 1002) ctrlSetText "";
		};		
	};
};