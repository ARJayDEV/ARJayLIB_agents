/*
	File: arjay_agent.sqf
	Author: ARJay
	Description: Main Agent Script
*/

arjay_agentGenerateStaticWorldData = false; 
arjay_agentGenerateStaticLocationData = false;
arjay_agentUseStaticWorldLocationData = true; // use world data from agent presets instead of relying on the world config
arjay_agentsActive = false; // agent system active

arjay_agentInitialisedLocations = call Dictionary_fnc_new;
arjay_agentActiveLocations = call Dictionary_fnc_new;
arjay_agents = call Dictionary_fnc_new;
arjay_agentVehicles = call Dictionary_fnc_new;
arjay_agentsKIA = call Dictionary_fnc_new;
arjay_agentsCivilianActive = [];
arjay_agentsEastActive = [];
arjay_agentsWestActive = [];
arjay_agentMissionController = 0 spawn {};
arjay_agentCivilianController = 0 spawn {};
arjay_agentEastController = 0 spawn {};
arjay_agentWestController = 0 spawn {};
arjay_agentCountMarkers = 0;

/*
	Generate static data
*/
arjay_agentsGenerateStaticData = 
{		
	arjay_agentGenerateStaticLocationData = if(count _this > 0) then {_this select 0} else {arjay_agentGenerateStaticLocationData};
	arjay_agentGenerateStaticWorldData = if(count _this > 1) then {_this select 1} else {arjay_agentGenerateStaticWorldData};
	arjay_debug = false;
	
	
	// debug ----------------------------------------------------------------------------------------------------------------------------
	if(arjay_debug) then {["--- INIT ARJay AGENT STATIC DATA GENERATION ---------------------------------------------------------------------------"] call arjay_dump;};
	// debug ----------------------------------------------------------------------------------------------------------------------------
	

	// generate static data to populate world description file
	// this should be run when using agent scripts on a new world 
	// that doesnt have a generated description file
	if(arjay_agentGenerateStaticWorldData) then
	{
		
		['--- WORLD STATIC DATA GENERATION STARTED -------------------------------------------------------------------------------'] call arjay_dump;
		['--- COPY THE FOLLOWING OUTPUT INTO THE WORLD DESCRIPTION FILE ----------------------------------------------------------'] call arjay_dump;
		['--- THIS FILE IS LOCATED IN arjay/static_data/arjay_world_%1.sqf ----------------------------------------',worldName] call arjay_dump;
		
		[] spawn
		{
			[] spawn {["Generating ARJay agent world data, this will take some time. The output of the generation is sent to the RPT. Copy this output once world data has completed", 1,10,1] call arjay_cut;};
		
			if!(arjay_agentUseStaticWorldLocationData) then
			{
				[] call arjay_getWorldLocations;
			};			
		
			[] call arjay_getWorldLocationBuildings;
			
			[] call arjay_getWorldLocationPerimeters;
			
			[] call arjay_getCivilianTaskBuildings;	
		
			[] call arjay_getCivilianBuildings;
			
			[] call arjay_getEastTaskBuildings;

			[] call arjay_getEastBuildings;		

			[] call arjay_getWestTaskBuildings;			
			
			[] call arjay_getWestBuildings;			
			
			['WORLD STATIC DATA GENERATION COMPLETED -------------------------------------------------------------------------------'] call arjay_dump;
		};
	};
	
	// generate static data according to arjay_missionLocations settings
	// this can be run to regenerate the mission locations to re-randomise the location spawn settings
	// if the agent system is running with arjay_agentUseStaticMissionData
	if(arjay_agentGenerateStaticLocationData) then
	{
		if!(arjay_agentGenerateStaticWorldData) then 
		{
			call compileFinal preprocessFileLineNumbers format["arjay\static_data\arjay_world_%1.sqf", worldName];
			
			// debug ----------------------------------------------------------------------------------------------------------------------------
			if(arjay_debug) then {["--- STATIC WORLD DATA LOADED --------------------------------------------------------------------------"] call arjay_dump;};
			// debug ----------------------------------------------------------------------------------------------------------------------------
		};		
	
		['--- MISSION STATIC DATA GENERATION STARTED -------------------------------------------------------------------------------'] call arjay_dump;
		['--- COPY THE FOLLOWING OUTPUT INTO YOUR MISSION DESCRIPTION FILE ----------------------------------------------------------'] call arjay_dump;
		['--- THE MISSION DESCRIPTION FILE IS LOCATED IN arjay/static_data/arjay_mission_%1.sqf -----------------------------------',arjay_missionName] call arjay_dump;
		
		[] spawn
		{
			[] spawn {["Generating ARJay agent mission locations data, this will take some time. The output of the generation is sent to the RPT. Copy this output once mission data has completed", 1,10,1] call arjay_cut;};
			
			[] call arjay_checkMissionLocations;
			
			[] call arjay_initAllLocations;
			
			['MISSION STATIC DATA GENERATION COMPLETED -------------------------------------------------------------------------------'] call arjay_dump;
		};
	};
};

/*
	Initiliase the arjay agent system
*/
arjay_initAgents = 
{		
	// debug ----------------------------------------------------------------------------------------------------------------------------
	//if(arjay_debug) then {	[""] call arjay_dump; [""] call arjay_dump; ["--- INIT ARJay AGENT SYSTEM ---------------------------------------------------------------------------"] call arjay_dump;};
	// debug ----------------------------------------------------------------------------------------------------------------------------

	call compileFinal preprocessFileLineNumbers format["arjay\static_data\arjay_world_%1.sqf", worldName];
		
	// debug ----------------------------------------------------------------------------------------------------------------------------
	//if(arjay_debug) then {["--- STATIC WORLD DATA LOADED --------------------------------------------------------------------------"] call arjay_dump;};
	// debug ----------------------------------------------------------------------------------------------------------------------------
	
	if(arjay_agentUseStaticMissionData) then 
	{
		call compileFinal preprocessFileLineNumbers format["arjay\static_data\arjay_mission_%1.sqf", arjay_missionName];
		
		// debug ----------------------------------------------------------------------------------------------------------------------------
		//if(arjay_debug) then {["--- STATIC MISSION DATA LOADED --------------------------------------------------------------------------"] call arjay_dump;};
		// debug ----------------------------------------------------------------------------------------------------------------------------
	}
	else
	{
		[] call arjay_checkMissionLocations;
	};
	
	if(arjay_agentPreInitLocations) then
	{
		[] call arjay_initAllLocations;
		
		// debug ----------------------------------------------------------------------------------------------------------------------------
		//if(arjay_debug) then {["--- ALL LOCATIONS INITIALISED ---------------------------------------------------------------------------"] call arjay_dump;};
		// debug ----------------------------------------------------------------------------------------------------------------------------
	};
	
	if(arjay_agentCreateMapMarkers) then
	{
		[] call arjay_agentCreateLocationMapMarkers;
		
		// debug ----------------------------------------------------------------------------------------------------------------------------
		//if(arjay_debug) then {["--- MAP MARKERS CREATED -------------------------------------------------------------------------------"] call arjay_dump;};
		// debug ----------------------------------------------------------------------------------------------------------------------------
	};

	arjay_agentsActive = true;
};

/*
	Initiliase all the locations in the world
*/
arjay_initAllLocations = 
{
	private ["_locationName"];
					
	{					
		_locationName = _x;
		[_locationName] call arjay_initLocation;
		
	} forEach (arjay_missionLocations select 0);
};

/*
	Checks the mission locations dictionary for any random settings, picks a side if random detected
*/
arjay_checkMissionLocations =
{
	private ["_profile", "_count", "_side"];

	{
		_profile = [arjay_missionLocations, _x] call Dictionary_fnc_get;		
		_count = 0;
		{
			if(_x == "RANDOM") then {
				_side = (arjay_agentSideVarNames select 0) select random((count (arjay_agentSideVarNames select 0))-1);
				(_profile select 0) set [_count, _side];
			};			
			_count = _count + 1;			
		} forEach (_profile select 0);		
	} forEach (arjay_missionLocations select 0);
	
	// output the checked mission locations for static mission data if required
	if(arjay_agentGenerateStaticLocationData) then
	{
		["arjay_missionLocations = call Dictionary_fnc_new;"] call arjay_dump;
		{
			_profile = [arjay_missionLocations, _x] call Dictionary_fnc_get;
			['[arjay_missionLocations, "%1", %2] call Dictionary_fnc_set;', _x, _profile] call arjay_dump;
		} forEach (arjay_missionLocations select 0);
	};
};

/*
	Create map markers according to location side composition
*/
arjay_agentCreateLocationMapMarkers =
{
	private ["_profile", "_locationData", "_sides", "_sideCount", "_sideMarkerData", "_markerName", "_marker", "_locationProfile"];
	
	{
		_profile = [arjay_missionLocations, _x] call Dictionary_fnc_get;
		_locationData = [arjay_worldLocations, _x] call Dictionary_fnc_get;
		_sides = _profile select 0;
		_sideCount = 0;
		
		{
			_sideMarkerData = [arjay_agentSideMarkers, _x] call Dictionary_fnc_get;
			
			_markerName = format["arjay_marker_%1", arjay_agentCountMarkers];
			_marker = createMarker [_markerName, _locationData select 2];
			_marker setMarkerSize [200, 200];
			_marker setMarkerAlpha 1;		
			_marker setMarkerShape (_sideMarkerData select 0);
			_marker setMarkerBrush (_sideMarkerData select 1);			
			_marker setMarkerColor (_sideMarkerData select 2);
			
			_locationProfile = _profile select 1 select _sideCount;
			_locationProfile set [2, _marker];
			
			// debug ----------------------------------------------------------------------------------------------------------------------------
			
			if(arjay_debug) then {
			
				/*
				_markerName = format["arjay_debugLocationMarker_%1", arjay_agentCountMarkers];
				_marker = createMarker [_markerName, _locationData select 2];
				_marker setMarkerSize [_locationData select 3, _locationData select 4];
				_marker setMarkerAlpha 0.3;
				_marker setMarkerShape "ELLIPSE";
				_marker setMarkerBrush "Solid";
				_marker setMarkerColor "ColorYellow";
				*/
				
				_markerName = format["arjay_debugActivationMarker_%1", arjay_agentCountMarkers];
				_marker = createMarker [_markerName, _locationData select 2];
				_marker setMarkerSize [arjay_agentLocationInitRadius, arjay_agentLocationInitRadius];
				_marker setMarkerAlpha 1;
				_marker setMarkerShape "ELLIPSE";
				_marker setMarkerBrush "Border";
				_marker setMarkerColor "ColorRed";
			};
			
			// debug ----------------------------------------------------------------------------------------------------------------------------
			
			_sideCount = _sideCount + 1;
			arjay_agentCountMarkers = arjay_agentCountMarkers + 1;
		} forEach _sides;
		
	} forEach (arjay_missionLocations select 0);
};


// location based methods --------------------------------------------------------------------------------------------------------------------------

/*
	Set active locations for all passed player positions
	Called from the monitor loop
*/
arjay_agentSetActiveLocations = 
{
	private ["_activatingLocations", "_position", "_nearLocations", "_locationName"];
	
	_activatingLocations = [];

	{
		_position = _x;
		
		// location init by distance to player
		_nearLocations = nearestLocations [_position, ["NameMarine","NameLocal","NameVillage","NameCity","NameCityCapital"], arjay_agentLocationInitRadius];
	
		{					
			_locationName = text _x;
			
			if(!(_locationName in _activatingLocations) && (_locationName in (arjay_missionLocations select 0))) then
			{
				_activatingLocations set [count _activatingLocations, _locationName];
			};		
			
		} forEach _nearLocations;
		
	} forEach arjay_playerPositions;
	
	// location activation
	[_activatingLocations] call arjay_activateLocations;
};

/*
	Check active and de-active locations and activate or deactivate
*/
arjay_activateLocations = 
{	
	private ["_activatingLocations", "_locationName", "_locationStateChanged"];
	
	_activatingLocations = _this select 0;
	
	_locationStateChanged = false;
	
	// locations to activate
	{
		_locationName = _x;
		
		// not already active
		if!(_locationName in (arjay_agentActiveLocations select 0)) then
		{					
			// not already initialised
			if!(_locationName in (arjay_agentInitialisedLocations select 0)) then
			{				
				if!(arjay_agentUseStaticMissionData) then {
					[_locationName] call arjay_initLocation;			
				};
			};
			
			[arjay_agentActiveLocations, _locationName, []] call Dictionary_fnc_set;			
			[_locationName] call arjay_activateLocation;
			_locationStateChanged = true;
		};
		
	} forEach _activatingLocations;	
	
	// locations to de-activate
	{
		_locationName = _x;
		
		if!(_locationName in _activatingLocations) then
		{
			[arjay_agentActiveLocations, _locationName] call Dictionary_fnc_remove;
			
			[_locationName] call arjay_deactivateLocation;
			_locationStateChanged = true;
		};
		
	} forEach (arjay_agentActiveLocations select 0);
	
	// debug ----------------------------------------------------------------------------------------------------------------------------
	/*
	if(_locationStateChanged && arjay_debug && (arjay_debugLevel == 2 || arjay_debugLevel > 10)) then
	{
		["--- INITIALISED LOCATIONS: %1", arjay_agentInitialisedLocations select 0] call arjay_dump;
		["--- ACTIVE LOCATIONS: %1", arjay_agentActiveLocations select 0] call arjay_dump;
		["--- ACTIVE AGENTS: %1", arjay_agents select 0] call arjay_dump;
		["--- ACTIVE AGENT VEHICLES: %1", arjay_agentVehicles select 0] call arjay_dump;
		["--- ACTIVE CIVILIAN AGENTS: %1", arjay_agentsCivilianActive] call arjay_dump;
		["--- ACTIVE EAST AGENTS: %1", arjay_agentsEastActive] call arjay_dump;
		["--- ACTIVE WEST AGENTS: %1", arjay_agentsWestActive] call arjay_dump;
	}
	*/
	// debug ----------------------------------------------------------------------------------------------------------------------------
};

/*
	Initialises a given location
	If not using static mission data initialise locations on the fly as they are activated
*/
arjay_initLocation = 
{
	private ["_locationName", "_locationWorldData", "_locationType", "_locationMissionData", "_locationBuildings", "_count", "_profile", "_side", "_locationClearanceData"];
	
	_locationName = _this select 0;
	
	_locationWorldData = [arjay_worldLocations, _locationName] call Dictionary_fnc_get;
	_locationType = _locationWorldData select 1;
	_locationMissionData = [arjay_missionLocations, _locationName] call Dictionary_fnc_get;	
	_locationBuildings = [arjay_worldBuildingsByLocation, _locationName] call Dictionary_fnc_get;
	
	// debug ----------------------------------------------------------------------------------------------------------------------------
	//if(arjay_debug && (arjay_debugLevel == 1 || arjay_debugLevel > 10)) then {[""] call arjay_dump;};
	//if(arjay_debug && (arjay_debugLevel == 1 || arjay_debugLevel > 10)) then {["--- INIT LOCATION: %1", _locationName] call arjay_dump;};
	// debug ----------------------------------------------------------------------------------------------------------------------------
	
	_count = 0;
	{
		_profile = (_locationMissionData select 1) select _count;
		[_x, _locationName, _locationWorldData, _profile, _locationType, _locationBuildings] call arjay_initAgentLocation;
		_count = _count + 1;	
	} forEach (_locationMissionData select 0);
	
	// reset the buildings in use array
	// so other sides can be reinitialised 
	// at a later point
	arjay_worldBuildingsInUse = [];
	
	[arjay_agentInitialisedLocations, _locationName, []] call Dictionary_fnc_set;
	
	// if this location has been reset after being cleared
	// re allow capture
	_locationClearanceData = [arjay_missionLocationClearance, _locationName] call Dictionary_fnc_get;
	if(_locationClearanceData select 1) then
	{
		[arjay_missionLocationClearance, _locationName, [true, false]] call Dictionary_fnc_set;
	};
};

/*
	Activates a given location
	Spawns agents and vehicles according to location, agent and vehicle profiles
*/
arjay_activateLocation = 
{
	private ["_locationName", "_locationMissionData", "_profile", "_count", "_agents", "_vehicles"];
	
	_locationName = _this select 0;
	_locationMissionData = [arjay_missionLocations, _locationName] call Dictionary_fnc_get;
	
	// debug ----------------------------------------------------------------------------------------------------------------------------
	//if(arjay_debug && (arjay_debugLevel == 1 || arjay_debugLevel > 10)) then {[""] call arjay_dump;};
	//if(arjay_debug && (arjay_debugLevel == 1 || arjay_debugLevel > 10)) then {["--- ACTIVATE LOCATION: %1", _locationName] call arjay_dump;};
	// debug ----------------------------------------------------------------------------------------------------------------------------
	
	_count = 0;
	{
		_profile = (_locationMissionData select 1) select _count;
		
		switch(_x) do
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
		
		[_agents, _vehicles, _x] call arjay_populateLocation;
		
		_count = _count + 1;
	} forEach (_locationMissionData select 0);	
};

/*
	Populates a given location
*/
arjay_populateLocation = 
{
	private ["_agents", "_vehicles", "_side"];
	
	_agents = _this select 0;
	_vehicles = _this select 1;
	_side = _this select 2;
	
	if(typename _agents == "ARRAY") then
	{	
		{
			if(count (arjay_agents select 0) < 144) then
			{
				[_x] call arjay_createAgent;
				
				sleep 0.1;
			};
		} forEach _agents;
	};
	
	if(typename _vehicles == "ARRAY") then
	{	
		{
			[_x] call arjay_createAgentVehicle;
			
			sleep 0.1;
			
		} forEach _vehicles;
	};
};

/*
	De-activates a given location
*/
arjay_deactivateLocation = 
{
	private ["_locationName", "_locationMissionData", "_profile", "_count", "_agents", "_vehicles"];
	
	_locationName = _this select 0;
	_locationMissionData = [arjay_missionLocations, _locationName] call Dictionary_fnc_get;
	
	// debug ----------------------------------------------------------------------------------------------------------------------------
	//if(arjay_debug && (arjay_debugLevel == 1 || arjay_debugLevel > 10)) then {[""] call arjay_dump;};
	//if(arjay_debug && (arjay_debugLevel == 1 || arjay_debugLevel > 10)) then {["--- DE-ACTIVATE LOCATION: %1", _locationName] call arjay_dump;};
	// debug ----------------------------------------------------------------------------------------------------------------------------
	
	_count = 0;
	{
		_profile = (_locationMissionData select 1) select _count;
		
		switch(_x) do
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
		
		[_agents, _vehicles, false] call arjay_depopulateLocation;
		
		_count = _count + 1;
	} forEach (_locationMissionData select 0);
};

/*
	De-Populates a given location
*/
arjay_depopulateLocation = 
{
	private ["_agents", "_vehicles", "_agent", "_vehicle", "_cleanup", "_gcAgentCallback", "_gcVehicleCallback"];
	
	_agents = _this select 0;
	_vehicles = _this select 1;
	_cleanup = _this select 2;
	
	_gcAgentCallback = "arjay_deleteAgent";
	_gcVehicleCallback = "arjay_deleteAgentVehicle";
	
	if(_cleanup) then
	{
		_gcAgentCallback = "arjay_cleanupAgent";
		_gcVehicleCallback = "arjay_cleanupAgentVehicle";
	};	
	
	if(typename _agents == "ARRAY") then
	{	
		{
			_agent = [arjay_agents, _x] call Dictionary_fnc_get;
			[_agent, arjay_agentLocationInitRadius, _gcAgentCallback] call arjay_registerForGarbageCollection;
			
		} forEach _agents;
	};
	
	if(typename _vehicles == "ARRAY") then
	{	
		{
			_vehicle = [arjay_agentVehicles, _x] call Dictionary_fnc_get;
			[_vehicle, arjay_agentLocationInitRadius, _gcVehicleCallback] call arjay_registerForGarbageCollection;
			
		} forEach _vehicles;
	};
};

/*
	Handle agent controllers
*/
arjay_agentHandleControllers =
{
	// mission controller
	if(scriptDone arjay_agentMissionController) then
	{
		arjay_agentMissionController = [] call arjay_agentControllerMission;
	};
	
	// civilian controller
	if(count arjay_agentsCivilianActive > 0) then
	{
		if(scriptDone arjay_agentCivilianController) then
		{
			arjay_agentCivilianController = [] call arjay_agentControllerCivilian;
		};		
	}
	else
	{
		if!(scriptDone arjay_agentCivilianController) then
		{
			terminate arjay_agentCivilianController;
		};
	};	
	
	// east controller
	if(count arjay_agentsEastActive > 0) then
	{
		if(scriptDone arjay_agentEastController) then
		{
			arjay_agentEastController = [] call arjay_agentControllerEast;
		};		
	}
	else
	{
		if!(scriptDone arjay_agentEastController) then
		{
			terminate arjay_agentEastController;
		};
	};
	
	if(count arjay_agentsWestActive > 0) then
	{
		if(scriptDone arjay_agentWestController) then
		{
			arjay_agentWestController = [] call arjay_agentControllerWest;
		};		
	}
	else
	{
		if!(scriptDone arjay_agentWestController) then
		{
			terminate arjay_agentWestController;
		};
	};
};


// agent creation methods --------------------------------------------------------------------------------------------------------------------------


/*
	Create agent
*/
arjay_createAgent = 
{	
	private ["_agentId", "_profile", "_active", "_side", "_class", "_position", "_house", "_building", "_loadout", "_agent", "_agentGroup", "_sideData", "_eventID", "_groupType", "_groupTypeName", "_groupCount"];
	
	_agentId = _this select 0;
		
	_profile = [arjay_agentProfiles, _agentId] call Dictionary_fnc_get;			
	
	_active = [_profile, "active"] call Dictionary_fnc_get;
	
	if(!(_active)) then
	{
		_side = [_profile, "side"] call Dictionary_fnc_get;
		_class = [_profile, "class"] call Dictionary_fnc_get;
		_position = [_profile, "position"] call Dictionary_fnc_get;
		_house = [_profile, "house"] call Dictionary_fnc_get;
		_loadout = [_profile, "loadout"] call Dictionary_fnc_get;
		_groupTypeName = [_profile, "groupType"] call Dictionary_fnc_get;
		_groupCount = [_profile, "groupCount"] call Dictionary_fnc_get;
		_sideData = [arjay_agentSideVarNames, _side] call Dictionary_fnc_get;		
			
		_agent = [_class, _agentId, _sideData select 1, _position] call arjay_createUnit;
		
		if(isNull _agent) exitWith{};

		// store extended building profile if first run
		if( typename _house == "STRING") then
		{
			_building = [arjay_worldBuildings, _house] call Dictionary_fnc_get;
			[_profile, "house", _building] call Dictionary_fnc_set;
		};
			
		_agent setVariable ["arjay_agentProfile", _profile, false];
		_agent setVariable ["arjay_agentBusy", false, false];
		_agent setVariable ["arjay_agentHouseLight", objNull, false];
		_agent setVariable ["arjay_agentHouseLightOn", false, false];
		_agent setVariable ["arjay_agentHouseMusic", objNull, false];
		_agent setVariable ["arjay_agentHouseMusicOn", false, false];
		_agent setVariable ["arjay_agentMeetingRequested", false, false];
		_agent setVariable ["arjay_agentMeetingComplete", false, false];
		_agent setVariable ["arjay_agentMeetingTarget", objNull, false];
		_agent setVariable ["arjay_agentGatheringRequested", false, false];
		_agent setVariable ["arjay_agentGatheringComplete", false, false];
		_agent setVariable ["arjay_agentGatheringTarget", objNull, false];
		_agent setVariable ["arjay_agentIsGroupLeader", false, false];
		
		// event handlers
		_eventID = _agent addEventHandler["Killed", arjay_agentKilled];
		
		// if custom loadout apply it
		if(count(_loadout) > 0) then
		{
			[_agent, _loadout select 0, _loadout select 2] call arjay_setLoadout;
		};		
				
		// if group leader create group members
		// only the leader is an agent, the rest are drones
		if!(_groupTypeName == "") then
		{
			_groupType = [_groupTypeName, _side, _position] call arjay_getGroupType;
			[_agent, _groupCount, _groupType select 2, _side, _position] call arjay_createGroup;
			_agent setVariable ["arjay_agentIsGroupLeader", true, false];
		};
		
		// bugged
		//_agentGroup = group _agent;
		//_agentGroup setBehaviour "SAFE";
		
		// store created agent in data structures
		switch(_side) do
		{
			case "CIV":
			{
				arjay_agentsCivilianActive set [count arjay_agentsCivilianActive, _agentId];
			};
			case "EAST":
			{
				arjay_agentsEastActive set [count arjay_agentsEastActive, _agentId];
			};
			case "WEST":
			{
				arjay_agentsWestActive set [count arjay_agentsWestActive, _agentId];
			};
		};
		
		[arjay_agents, _agentId, _agent] call Dictionary_fnc_set;		
		[_profile, "active", true] call Dictionary_fnc_set;
		
		// debug ----------------------------------------------------------------------------------------------------------------------------
		//if(arjay_debug && (arjay_debugLevel == 2 || arjay_debugLevel > 10)) then {["--- %1 created [%2]", _agentId, _agent] call arjay_dump;};
		// debug ----------------------------------------------------------------------------------------------------------------------------
	};
};

/*
	Delete agent
*/
arjay_deleteAgent = 
{	
	private ["_agentId", "_profile", "_active", "_location", "_side", "_agent", "_groupCount", "_light", "_music"];
	
	_agentId = _this select 0;
	
	_profile = [arjay_agentProfiles, _agentId] call Dictionary_fnc_get;						
	_active = [_profile, "active"] call Dictionary_fnc_get;	
	
	if(_active) then
	{
		_agentId = [_profile, "id"] call Dictionary_fnc_get;
		_side = [_profile, "side"] call Dictionary_fnc_get;
		_location = [_profile, "home"] call Dictionary_fnc_get;
		
		_agent = [arjay_agents, _agentId] call Dictionary_fnc_get;
		
		if(_agent getVariable "arjay_agentIsGroupLeader") then
		{
			_groupCount = [group _agent] call arjay_countGroupAlive;
			[_profile, "groupCount", (_groupCount - 1)] call Dictionary_fnc_set;
		};
		
		if(_agent getVariable "arjay_agentHouseLightOn") then
		{
			_light = _agent getVariable "arjay_agentHouseLight";
			deleteVehicle _light;
		};
		
		if(_agent getVariable "arjay_agentHouseMusicOn") then
		{
			_music = _agent getVariable "arjay_agentHouseMusic";
			deleteVehicle _music;
		};
		
		[arjay_agents, _agentId] call Dictionary_fnc_remove;
		[arjay_agentCommandStates, _agentId] call Dictionary_fnc_remove;
		
		switch(_side) do
		{
			case "CIV":
			{
				arjay_agentsCivilianActive = arjay_agentsCivilianActive - [_agentId];
			};
			case "EAST":
			{
				arjay_agentsEastActive = arjay_agentsEastActive - [_agentId];
			};
			case "WEST":
			{
				arjay_agentsWestActive = arjay_agentsWestActive - [_agentId];
			};
		};
		
		[_profile, "active", false] call Dictionary_fnc_set;
		
		// debug ----------------------------------------------------------------------------------------------------------------------------
		//if(arjay_debug && (arjay_debugLevel == 2 || arjay_debugLevel > 10)) then {["--- %1 deleted", _agentId] call arjay_dump;};
		// debug ----------------------------------------------------------------------------------------------------------------------------	
	};
};

/*
	Cleanup agent
*/
arjay_cleanupAgent = 
{
	private ["_agentId", "_profile", "_side", "_location", "_locationAgents"];
	
	_agentId = _this select 0;
	
	_profile = [arjay_agentProfiles, _agentId] call Dictionary_fnc_get;
	_side = [_profile, "side"] call Dictionary_fnc_get;
	_location = [_profile, "home"] call Dictionary_fnc_get;
	
	// clean up active agent states
	[arjay_agents, _agentId] call Dictionary_fnc_remove;
	[arjay_agentCommandStates, _agentId] call Dictionary_fnc_remove;
	
	// delete agent profile
	[arjay_agentProfiles, _agentId] call Dictionary_fnc_remove;
	
	// delete lookup references
	switch(_side) do
	{
		case "CIV":
		{
			arjay_agentsCivilianActive = arjay_agentsCivilianActive - [_agentId];
			_locationAgents = [arjay_agentsCivilianByLocation, _location] call Dictionary_fnc_get;
			_locationAgents = _locationAgents - [_agentId];
			[arjay_agentsCivilianByLocation, _location, _locationAgents] call Dictionary_fnc_set;
		};
		case "EAST":
		{
			arjay_agentsEastActive = arjay_agentsEastActive - [_agentId];
			_locationAgents = [arjay_agentsEastByLocation, _location] call Dictionary_fnc_get;
			_locationAgents = _locationAgents - [_agentId];
			[arjay_agentsEastByLocation, _location, _locationAgents] call Dictionary_fnc_set;
		};
		case "WEST":
		{
			arjay_agentsWestActive = arjay_agentsWestActive - [_agentId];
			_locationAgents = [arjay_agentsWestByLocation, _location] call Dictionary_fnc_get;
			_locationAgents = _locationAgents - [_agentId];
			[arjay_agentsWestByLocation, _location, _locationAgents] call Dictionary_fnc_set;
		};
	};
	
	// debug ----------------------------------------------------------------------------------------------------------------------------
	//if(arjay_debug && (arjay_debugLevel == 2 || arjay_debugLevel > 10)) then {["--- %1 agent cleanup", _agentId] call arjay_dump;};
	// debug ----------------------------------------------------------------------------------------------------------------------------
};


// agent vehicle creation methods ----------------------------------------------------------------------------------------------------------------------


/*
	Create agent vehicle
*/
arjay_createAgentVehicle = 
{
	private ["_vehicleId", "_profile", "_active", "_class", "_position", "_direction", "_vehicle"];
	
	_vehicleId = _this select 0;
	
	_profile = [arjay_agentVehicleProfiles, _vehicleId] call Dictionary_fnc_get;			
	_active = [_profile, "active"] call Dictionary_fnc_get;
	
	if!(_active) then
	{
		_class = [_profile, "class"] call Dictionary_fnc_get;
		_position = [_profile, "position"] call Dictionary_fnc_get;
		_direction = [_profile, "direction"] call Dictionary_fnc_get;
		
		_vehicle = [_class, _vehicleId, _position, _direction] call arjay_createVehicle;
		
		_vehicle setVariable ["arjay_agentProfile", _profile, false];
		_vehicle setVariable ["arjay_agentInUse", false, false];
		
		if(isNull _vehicle) exitWith{};
		
		[arjay_agentVehicles, _vehicleId, _vehicle] call Dictionary_fnc_set;		
		[_profile, "active", true] call Dictionary_fnc_set;
		
		// debug ----------------------------------------------------------------------------------------------------------------------------
		//if(arjay_debug && (arjay_debugLevel == 2 || arjay_debugLevel > 10)) then {["--- %1 created [%2]", _vehicleId, _vehicle] call arjay_dump;};
		// debug ----------------------------------------------------------------------------------------------------------------------------
	};
};

/*
	Delete agent vehicle
*/
arjay_deleteAgentVehicle = 
{
	private ["_vehicleId", "_profile", "_active", "_side", "_location"];
	
	_vehicleId = _this select 0;
	
	_profile = [arjay_agentVehicleProfiles, _vehicleId] call Dictionary_fnc_get;		
	_active = [_profile, "active"] call Dictionary_fnc_get;

	if(_active) then
	{
		_side = [_profile, "side"] call Dictionary_fnc_get;
		_location = [_profile, "home"] call Dictionary_fnc_get;
	
		[arjay_agentVehicles, _vehicleId] call Dictionary_fnc_remove;		
		[_profile, "active", false] call Dictionary_fnc_set;
		
		// debug ----------------------------------------------------------------------------------------------------------------------------
		//if(arjay_debug && (arjay_debugLevel == 2 || arjay_debugLevel > 10)) then {["--- %1 vehicle deleted", _vehicleId] call arjay_dump;};
		// debug ----------------------------------------------------------------------------------------------------------------------------
	};
};

/*
	Cleanup agent vehicle
*/
arjay_cleanupAgentVehicle = 
{
	private ["_vehicleId", "_profile", "_active", "_side", "_location", "_locationVehicles"];
	
	_vehicleId = _this select 0;
	
	_profile = [arjay_agentVehicleProfiles, _vehicleId] call Dictionary_fnc_get;		
	_active = [_profile, "active"] call Dictionary_fnc_get;
	
	_side = [_profile, "side"] call Dictionary_fnc_get;
	_location = [_profile, "home"] call Dictionary_fnc_get;
	
	// clean up active agent states
	[arjay_agentVehicles, _vehicleId] call Dictionary_fnc_remove;
	
	// delete agent profile
	[arjay_agentVehicleProfiles, _vehicleId] call Dictionary_fnc_remove;
	
	// delete lookup references
	switch(_agentSide) do
	{
		case "CIV":
		{
			_locationVehicles = [arjay_agentsCivilianVehiclesByLocation, _location] call Dictionary_fnc_get;
			_locationVehicles = _locationVehicles - [_vehicleId];
			[arjay_agentsCivilianVehiclesByLocation, _location, _locationVehicles] call Dictionary_fnc_set;
		};
		case "EAST":
		{
			_locationVehicles = [arjay_agentsEastVehiclesByLocation, _location] call Dictionary_fnc_get;
			_locationVehicles = _locationVehicles - [_vehicleId];
			[arjay_agentsEastVehiclesByLocation, _location, _locationVehicles] call Dictionary_fnc_set;
		};
		case "WEST":
		{
			_locationVehicles = [arjay_agentsWestVehiclesByLocation, _location] call Dictionary_fnc_get;
			_locationVehicles = _locationVehicles - [_vehicleId];
			[arjay_agentsWestVehiclesByLocation, _location, _locationVehicles] call Dictionary_fnc_set;
		};
	};
	
	// debug ----------------------------------------------------------------------------------------------------------------------------
	//if(arjay_debug && (arjay_debugLevel == 2 || arjay_debugLevel > 10)) then {["--- %1 agent vehicle cleanup", _vehicleId] call arjay_dump;};
	// debug ----------------------------------------------------------------------------------------------------------------------------
};


// agent event handlers --------------------------------------------------------------------------------------------------------------------------


/*
	Agent killed event handler
*/
arjay_agentKilled =
{
	private ["_agent", "_killer", "_agentId", "_profile", "_side", "_killedByPlayer", "_timeOfDeath", "_groupCount"];
	
	_agent = _this select 0;
	_killer = _this select 1;
	
	_agent switchMove "";
	
	_agentId = vehicleVarName _agent;
	_profile = _agent getVariable "arjay_agentProfile";
	_side = [_profile, "side"] call Dictionary_fnc_get;
	
	_killedByPlayer = isPlayer _killer;
	_timeOfDeath = diag_tickTime;
	
	// store death
	[arjay_agentsKIA, _agentId, [_agent, _agentId, _side, _killedByPlayer, _killer, _timeOfDeath]] call Dictionary_fnc_set;
	
	// if agent is a group leader promote group member from grunt to agent status
	if(_agent getVariable "arjay_agentIsGroupLeader") then
	{
		_groupCount = [group _agent] call arjay_countGroupAlive;
		if(_groupCount > 0) then
		{
			[_agent, _agentId] call arjay_agentPromoteGrunt;
		}
		else
		{
			// cleanup
			[_agentId] call arjay_cleanupAgent;
		};
	}
	else
	{
		// cleanup
		[_agentId] call arjay_cleanupAgent;
	};	
};

/*
	If an agent has been killed and is a group leader, promote a group member to agent status
*/
arjay_agentPromoteGrunt = 
{
	private ["_agent", "_agentId", "_unit", "_eventID"];
	
	_agent = _this select 0;
	_agentId = _this select 1;
	
	_unit = [group _agent] call arjay_getAliveGroupMember;
	
	// debug ----------------------------------------------------------------------------------------------------------------------------
	//if(arjay_debug && (arjay_debugLevel == 2 || arjay_debugLevel > 10)) then {["--- %1 post agent death promotion of %2", _agentId, _unit] call arjay_dump;};
	// debug ----------------------------------------------------------------------------------------------------------------------------
	
	_agent setVehicleVarName format["%1_replaced",_agentId];
	_unit setVehicleVarName _agentId;
	
	[arjay_agents, _agentId, _unit] call Dictionary_fnc_set;
	
	_unit setVariable ["arjay_agentProfile", (_agent getVariable "arjay_agentProfile"), false];
	_unit setVariable ["arjay_agentBusy", (_agent getVariable "arjay_agentBusy"), false];
	_unit setVariable ["arjay_agentHouseLight", (_agent getVariable "arjay_agentHouseLight"), false];
	_unit setVariable ["arjay_agentHouseLightOn", (_agent getVariable "arjay_agentHouseLightOn"), false];
	_unit setVariable ["arjay_agentMeetingRequested", (_agent getVariable "arjay_agentMeetingRequested"), false];
	_unit setVariable ["arjay_agentMeetingComplete", (_agent getVariable "arjay_agentMeetingComplete"), false];
	_unit setVariable ["arjay_agentMeetingTarget", (_agent getVariable "arjay_agentMeetingTarget"), false];
	_unit setVariable ["arjay_agentGatheringRequested", (_agent getVariable "arjay_agentGatheringRequested"), false];
	_unit setVariable ["arjay_agentGatheringComplete", (_agent getVariable "arjay_agentGatheringComplete"), false];
	_unit setVariable ["arjay_agentGatheringTarget", (_agent getVariable "arjay_agentGatheringTarget"), false];
	_unit setVariable ["arjay_agentIsGroupLeader", (_agent getVariable "arjay_agentIsGroupLeader"), false];
	
	// event handlers
	_eventID = _unit addEventHandler["Killed", arjay_agentKilled];	
};