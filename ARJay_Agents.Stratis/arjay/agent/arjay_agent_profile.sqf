/*
	File: arjay_agent_profile.sqf
	Author: ARJay
	Description: Agent profile generation
*/

arjay_agentProfileCount = 0;
arjay_agentProfiles = call Dictionary_fnc_new;

arjay_agentVehicleProfileCount = 0;
arjay_agentVehicleProfiles = call Dictionary_fnc_new;

arjay_agentsCivilianByLocation = call Dictionary_fnc_new;
arjay_agentCivilianVehiclesByLocation = call Dictionary_fnc_new;

arjay_agentsEastByLocation = call Dictionary_fnc_new;
arjay_agentEastVehiclesByLocation = call Dictionary_fnc_new;

arjay_agentsWestByLocation = call Dictionary_fnc_new;
arjay_agentWestVehiclesByLocation = call Dictionary_fnc_new;

/*
	Initialises a given location
*/
arjay_initAgentLocation = 
{
	private ["_locationSide","_locationName","_locationWorldData","_locationMissionData","_locationType","_locationBuildings", "_sideData",
	"_sideVarName","_sideBuildings","_sideTaskBuildings","_sideLoadoutSettings","_sideUnitClasses",
	"_sideAgentStoreByLocation","_sideAgentVehicleStoreByLocation","_locationBuildingData",
	"_buildings","_taskBuildings","_locationProfileData","_agents","_vehicles","_taskVehicles","_profile","_loadout","_agentName","_vehicleName", "_group"];
	
	_locationSide = _this select 0;
	_locationName = _this select 1;
	_locationWorldData = _this select 2;
	_locationMissionData = _this select 3;
	_locationType = _this select 4;
	_locationBuildings = _this select 5;
	
	_sideData = [arjay_agentSideVarNames, _locationSide] call Dictionary_fnc_get;
	
	switch(_locationSide) do
	{
		case "CIV":
		{
			_sideVarName = _sideData select 0;
			_sideBuildings = arjay_agentCivilianBuildings;
			_sideTaskBuildings = arjay_agentCivilianTaskBuildings;
			_sideLoadoutSettings = arjay_agentCivilianLoadoutSettings;
			_sideUnitClasses = [_locationSide] call arjay_getUnits;
			_sideAgentStoreByLocation = arjay_agentsCivilianByLocation;
			_sideAgentVehicleStoreByLocation = arjay_agentCivilianVehiclesByLocation;
		};
		case "EAST":
		{
			_sideVarName = _sideData select 0;
			_sideBuildings = arjay_agentEastBuildings;
			_sideTaskBuildings = arjay_agentEastTaskBuildings;
			_sideLoadoutSettings = arjay_agentEastLoadoutSettings;
			_sideUnitClasses = [_locationSide] call arjay_getUnits;
			_sideAgentStoreByLocation = arjay_agentsEastByLocation;
			_sideAgentVehicleStoreByLocation = arjay_agentEastVehiclesByLocation;
		};
		case "WEST":
		{
			_sideVarName = _sideData select 0;
			_sideBuildings = arjay_agentWestBuildings;
			_sideTaskBuildings = arjay_agentWestTaskBuildings;
			_sideLoadoutSettings = arjay_agentWestLoadoutSettings;
			_sideUnitClasses = [_locationSide] call arjay_getUnits;
			_sideAgentStoreByLocation = arjay_agentsWestByLocation;
			_sideAgentVehicleStoreByLocation = arjay_agentWestVehiclesByLocation;
		};
	};
	
	_locationBuildingData = [_locationBuildings, _sideBuildings, _sideTaskBuildings] call arjay_getMatchingLocationBuildings;
	_buildings = _locationBuildingData select 0;
	_taskBuildings = _locationBuildingData select 1;
	
	
	// debug ----------------------------------------------------------------------------------------------------------------------------
	//if(arjay_debug && (arjay_debugLevel == 2 || arjay_debugLevel > 10)) then {["--- %1 %2 INIT - type: %3 - spawn probability: %4 - building count: %5 - task building count: %6",_locationName, _locationSide, _locationType, (_locationMissionData select 0), (count _buildings), (count _taskBuildings)] call arjay_dump;};
	//if(arjay_debug && (arjay_debugLevel == 2 || arjay_debugLevel > 10)) then {["-------------------------------------------------------------------------------------------------------"] call arjay_dump;};
	// debug ----------------------------------------------------------------------------------------------------------------------------	
	
	
	// generate location side profiles
	_locationProfileData = [_locationSide, _locationMissionData, _buildings, _sideUnitClasses] call arjay_generateAgentProfiles;
	_agents = _locationProfileData select 0;
	_vehicles = _locationProfileData select 1;
	
	// populate agent profiles
	[_agents, _sideLoadoutSettings] call arjay_populateAgentProfiles;
	
	// generate task building vehicles	
	_taskVehicles = [_locationMissionData, _taskBuildings] call arjay_generateTaskVehicleProfiles;
	_vehicles = _vehicles + _taskVehicles;
	
	// store profile mappings	
	[_sideAgentStoreByLocation, _locationName, _agents] call Dictionary_fnc_set;
	[_sideAgentVehicleStoreByLocation, _locationName, _vehicles] call Dictionary_fnc_set;
	
	// generate location data for static output if required
	if(arjay_agentGenerateStaticLocationData) then
	{
		[_sideVarName, _locationName, _agents, _vehicles] call arjay_generateStaticLocationData;
	};
	
	// debug ----------------------------------------------------------------------------------------------------------------------------
	
	/*
	if(arjay_debug && (arjay_debugLevel == 2 || arjay_debugLevel > 10)) then
	{
		{
			_profile = [arjay_agentProfiles, _x] call Dictionary_fnc_get;
			_agentName = [_profile, "id"] call Dictionary_fnc_get;
			_loadout = [_profile, "loadout"] call Dictionary_fnc_get;
			_group = [_profile, "groupCount"] call Dictionary_fnc_get;

			["--- %1 agent assigned profile: %2",_agentName, (_profile select 1)] call arjay_dump;
			["--- %1 agent loadout: %2",_agentName, _loadout] call arjay_dump;
			["--- %1 agent groupCount: %2",_agentName, _group] call arjay_dump;
			
		} forEach (_agents);
		{
			_profile = [arjay_agentVehicleProfiles, _x] call Dictionary_fnc_get;
			_vehicleName = [_profile, "id"] call Dictionary_fnc_get;

			["--- %1 vehicle assigned profile: %2",_vehicleName, (_profile select 1)] call arjay_dump;
			
		} forEach (_vehicles);
	};
		
	if(arjay_debug && (arjay_debugLevel == 2 || arjay_debugLevel > 10)) then {["-------------------------------------------------------------------------------------------------------"] call arjay_dump;};
	if(arjay_debug && (arjay_debugLevel == 2 || arjay_debugLevel > 10)) then {["--- %1 %2 INIT COMPLETE - total agents assigned: %3 - total vehicles assigned: %4",_locationName, _locationSide, count(_agents), count(_vehicles)] call arjay_dump;};	
	
	*/
	// debug ----------------------------------------------------------------------------------------------------------------------------		
		
};

/*
	Matches side buildings against location buildings
*/
arjay_getMatchingLocationBuildings = 
{
	private ["_locationBuildings", "_agentBuildings", "_agentTaskBuildings", "_buildings", "_taskBuildings", "_buildingData", "_worldBuildingData", "_mergedBuildingData"];
	
	_locationBuildings = _this select 0;
	_agentBuildings = _this select 1;
	_agentTaskBuildings = _this select 2;
	
	_buildings = [];
	_taskBuildings = [];
	{
		if(_x in (_agentBuildings select 0)) then
		{	
			if!(_x in arjay_worldBuildingsInUse) then
			{
				_buildingData = [_agentBuildings, _x] call Dictionary_fnc_get;
				_worldBuildingData = [arjay_worldBuildings, _x] call Dictionary_fnc_get;
				_mergedBuildingData = _worldBuildingData + [_buildingData select 1, _buildingData select 2, _buildingData select 3];
				_buildings set [count _buildings, _mergedBuildingData];
			}
		};
		if(_x in (_agentTaskBuildings select 0)) then
		{	
			if!(_x in arjay_worldBuildingsInUse) then
			{
				_buildingData = [_agentTaskBuildings, _x] call Dictionary_fnc_get;
				_worldBuildingData = [arjay_worldBuildings, _x] call Dictionary_fnc_get;
				_mergedBuildingData = _worldBuildingData + [_buildingData select 1, _buildingData select 2, _buildingData select 3];
				_taskBuildings set [count _taskBuildings, _mergedBuildingData];
			};
		};
	} forEach _locationBuildings;
	
	[_buildings, _taskBuildings]	
};

/*
	Generate agent profiles for given location 
*/
arjay_generateAgentProfiles = 
{
	private ["_locationSide", "_locationMissionData", "_buildings", "_agents", "_vehicles", "_unitClasses",	"_agentName", "_vehicleName"];
	
	_locationSide = _this select 0;
	_locationMissionData = _this select 1;
	_buildings = _this select 2;
	_unitClasses = _this select 3;

	_agents = [];
	_vehicles = [];
	
	{	
		if(random 1 < (_locationMissionData select 0)) then
		{
			_agentName = [_x, _unitClasses, _locationSide, _locationMissionData] call arjay_assignAgentProfile;
			_agents set [count _agents, _agentName];
			
			arjay_worldBuildingsInUse set [count arjay_worldBuildingsInUse, _x select 0];
			
			if(arjay_agentCreateVehicles) then
			{
				if(random 1 < (_locationMissionData select 1)) then
				{
					_vehicleName = [_x, _locationSide, _agentName] call arjay_assignAgentVehicleProfile;
					_vehicles set [count _vehicles, _vehicleName];
				};
			};
		};	
		
	} forEach _buildings;
	
	[_agents, _vehicles]
};

/*
	Assign agent profile
*/
arjay_assignAgentProfile = 
{		
	private ["_buildingData", "_agentClasses", "_side", "_locationData", "_buildingId", "_location", "_position", "_countPositions", "_positions", "_agentClass", "_agentName", "_profile", "_groupTypes", "_groupTypeName", "_groupType"];
			
	_buildingData = _this select 0;
	_agentClasses = _this select 1;
	_side = _this select 2;
	_locationData = _this select 3;

	_buildingId = _buildingData select 0;
	_location = _buildingData select 1;
	_position = _buildingData select 4;
	_countPositions = _buildingData select 5;
	_positions = _buildingData select 6;
	
	if(_countPositions>0) then
	{
		_position = _positions select (random((count _positions)-1));
	};
	
	_agentClass = _agentClasses select (random((count _agentClasses)-1));
	_agentName = format ["arjay_agent_%1", arjay_agentProfileCount];
		
	_profile = call Dictionary_fnc_new;
	[_profile, "id", _agentName] call Dictionary_fnc_set;
	[_profile, "active", false] call Dictionary_fnc_set;
	[_profile, "side", _side] call Dictionary_fnc_set;
	[_profile, "class", _agentClass] call Dictionary_fnc_set;
	[_profile, "home", _location] call Dictionary_fnc_set;
	[_profile, "house", _buildingId] call Dictionary_fnc_set;
	[_profile, "position", _position] call Dictionary_fnc_set;
	[_profile, "vehicle", ""] call Dictionary_fnc_set;
	[_profile, "loadout", []] call Dictionary_fnc_set;
	[_profile, "currentPosition", _position] call Dictionary_fnc_set;
	[_profile, "groupType", ""] call Dictionary_fnc_set;
	[_profile, "groupCount", 1] call Dictionary_fnc_set;
	
	// civilians arent grouped
	if(_side != "CIV") then
	{	
		// assign group settings to agent profile if probable
		if(random 1 < (_locationData select 3)) then
		{			
			// select the group type
			_groupTypes = _locationData select 4;			
			_groupTypeName = _groupTypes select (random((count _groupTypes)-1));
			_groupType = [_groupTypeName, _side, _position] call arjay_getGroupType;
			
			// reset the agent class to a leader
			[_profile, "class", _groupType select 0] call Dictionary_fnc_set;
			
			[_profile, "groupCount", _groupType select 1] call Dictionary_fnc_set;
			[_profile, "groupType", _groupTypeName] call Dictionary_fnc_set;
		};
	};
		
	[arjay_agentProfiles, _agentName, _profile] call Dictionary_fnc_set;
	arjay_agentProfileCount = arjay_agentProfileCount + 1;
	
	_agentName
};

/*
	Assign vehicle profile
*/
arjay_assignAgentVehicleProfile = 
{		
	private ["_buildingData", "_side", "_agentName", "_location", "_vehicleClass", "_parkingPosition", "_parkingDirection", "_vehicleName", "_ownerProfile", "_profile"];
			
	_buildingData = _this select 0;
	_side = _this select 1;
	_agentName = if(count _this > 2) then {_this select 2} else {""};

	_location = _buildingData select 1;
	_vehicleClass = _buildingData select 8;
	_parkingPosition = _buildingData select 9;
	_parkingDirection = _buildingData select 10;		
	
	_vehicleName = format ["arjay_vehicle_%1", arjay_agentVehicleProfileCount];
			
	_profile = call Dictionary_fnc_new;
	[_profile, "id", _vehicleName] call Dictionary_fnc_set;
	[_profile, "active", false] call Dictionary_fnc_set;
	[_profile, "side", _side] call Dictionary_fnc_set;
	[_profile, "class", _vehicleClass] call Dictionary_fnc_set;
	[_profile, "home", _location] call Dictionary_fnc_set;
	[_profile, "position", _parkingPosition] call Dictionary_fnc_set;
	[_profile, "direction", _parkingDirection] call Dictionary_fnc_set;
	[_profile, "owner", _agentName] call Dictionary_fnc_set;
	
	if!(_agentName == "") then
	{
		_ownerProfile = [arjay_agentProfiles, _agentName] call Dictionary_fnc_get;
		[_ownerProfile, "vehicle", _vehicleName] call Dictionary_fnc_set;
	};
	
	[arjay_agentVehicleProfiles, _vehicleName, _profile] call Dictionary_fnc_set;		
	arjay_agentVehicleProfileCount = arjay_agentVehicleProfileCount + 1;
	
	_vehicleName
};

/*
	Populates agent profiles
*/
arjay_populateAgentProfiles = 
{
	private ["_agents", "_loadoutSettings"];
	
	_agents = _this select 0;
	_loadoutSettings = _this select 1;
	
	if(count _agents > 0) then
	{		
		// set loadout
		[_agents, _loadoutSettings] call arjay_setAgentLoadout;
	};
};

/*
	Loop through agents and assign loadouts
*/
arjay_setAgentLoadout = 
{		
	private ["_agents", "_loadouts", "_profile", "_loadout", "_loadoutProbability"];
	
	_agents = _this select 0;
	_loadouts = _this select 1;
	
	{		
		_profile = [arjay_agentProfiles, _x] call Dictionary_fnc_get;
		_loadout = (_loadouts select 0) select (random((count (_loadouts select 0))-1));
		_loadout = [_loadouts, _loadout] call Dictionary_fnc_get;
		
		_loadoutProbability = _loadout select 1;
		
		if((random 1) < _loadoutProbability) then
		{
			[_profile, "loadout", _loadout] call Dictionary_fnc_set;				
		};
	
	} forEach _agents;
};

/*
	Generate agent profiles for given location 
*/
arjay_generateTaskVehicleProfiles = 
{
	private ["_locationMissionData", "_buildings", "_vehicles", "_vehicleClass", "_vehicleName"];
	
	_locationMissionData = _this select 0;
	_buildings = _this select 1;

	_vehicles = [];
	
	{		
		if(arjay_agentCreateVehicles) then
		{
			if(random 1 < (_locationMissionData select 1)) then
			{
				_vehicleClass = _x select 8;
				if!(_vehicleClass == "") then
				{
					_vehicleName = [_x] call arjay_assignAgentVehicleProfile;
					_vehicles set [count(_vehicles), _vehicleName];
				};
				
				arjay_worldBuildingsInUse set [count arjay_worldBuildingsInUse, _x select 0];
			};
		};
		
	} forEach _buildings;
	
	_vehicles
};

/*
	Generate static location data
*/
arjay_generateStaticLocationData = 
{
	private ["_agents", "_vehicles", "_locationSide", "_locationName", "_profile"];

	_locationSide = _this select 0;	
	_locationName = _this select 1;
	_agents = _this select 2;
	_vehicles = _this select 3;

	if(count(_agents) > 0) then
	{
		[""] call arjay_dump;
		
		["// Location: %1", _locationName] call arjay_dump;		
		{
			_profile = [arjay_agentProfiles, _x] call Dictionary_fnc_get;
			
			['[arjay_agentProfiles, "%1", %2] call Dictionary_fnc_set;', _x, _profile] call arjay_dump;
			
		} forEach (_agents);
			
		["_agents = [];"] call arjay_dump;
		
		{
			['_agents set [count _agents, "%1"];', _x] call arjay_dump;
			
		} forEach (_agents);
				
		['[arjay_agents%1ByLocation, "%2", _agents] call Dictionary_fnc_set;', _locationSide, _locationName] call arjay_dump;
		
		{
			_profile = [arjay_agentVehicleProfiles, _x] call Dictionary_fnc_get;
			
			['[arjay_agentVehicleProfiles, "%1", %2] call Dictionary_fnc_set;', _x, _profile] call arjay_dump;
			
		} forEach (_vehicles);
		
		["_vehicles = [];"] call arjay_dump;
		
		{
			['_vehicles set [count _vehicles, "%1"];', _x] call arjay_dump;
			
		} forEach (_vehicles);
				
		['[arjay_agents%1VehiclesByLocation, "%2", _vehicles] call Dictionary_fnc_set;', _locationSide, _locationName] call arjay_dump;
		
		['[arjay_agentInitialisedLocations, "%1", []] call Dictionary_fnc_set;', _locationName] call arjay_dump;
	};
};