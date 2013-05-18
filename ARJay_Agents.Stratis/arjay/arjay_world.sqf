/*
	File: arjay_world.sqf
	Author: ARJay
	Description: Get data about the current world and environment
	These methods are used to create data for hard coded world data.
	See static_data/arjay_world_Stratis.sqf for the results of the data collection for Stratis.
	These are meant to be run only when using arjay agents in a new world (that doesnt have a static_data/arjay_world_WORLDNAME.sqf created already).
	These are not meant for running in mission, they are expensive and slow!
*/

arjay_worldGenerateSpawnPositions = true;

arjay_locationBuildings = [];
arjay_worldBuildingsByLocation = call Dictionary_fnc_new;
arjay_worldBuildings = call Dictionary_fnc_new;
arjay_worldBuildingsInUse = [];

arjay_worldLocations = call Dictionary_fnc_new;
arjay_worldLocationPerimeters = call Dictionary_fnc_new;

arjay_agentCivilianBuildings = call Dictionary_fnc_new;
arjay_agentCivilianTaskBuildings = call Dictionary_fnc_new;

arjay_agentEastBuildings = call Dictionary_fnc_new;
arjay_agentEastTaskBuildings = call Dictionary_fnc_new;

arjay_agentWestBuildings = call Dictionary_fnc_new;
arjay_agentWestTaskBuildings = call Dictionary_fnc_new;

/*
	Sets the world location dictionary from cfgworlds config file
*/
arjay_getWorldLocations = 
{
	private ["_config", "_count", "_item", "_type", "_name", "_position", "_radiusA", "_radiusB"];

	_config = configFile >> "CfgWorlds" >> worldName >> "Names";	
	_count = count _config;
	
	for "_i" from 0 to (_count-1) do 
	{
		_item = _config select _i;		
		_type =  getText (_item >> "type");
		if ((_type == "NameLocal") || (_type == "NameVillage") || (_type == "NameCity") || (_type == "NameCityCapital")) then 
		{
			_name =  getText (_item >> "name");
			_position =  getArray (_item >> "position");
			_radiusA = getNumber (_item >> "radiusA");
			_radiusB = getNumber (_item >> "radiusB");
			
			[arjay_worldLocations, _name, [_name, _type, _position, _radiusA, _radiusB]] call Dictionary_fnc_set;
			['[arjay_worldLocations, "%1", ["%1", "%2", %3, %4, %5]] call Dictionary_fnc_set;',_name, _type, _position, _radiusA, _radiusB] call arjay_dump;
		};		
	};
	
	for "_i" from 0 to (_count-1) do 
	{
		_item = _config select _i;		
		_type =  getText (_item >> "type");
		if ((_type == "NameMarine")) then 
		{
			_name =  getText (_item >> "name");
			_position =  getArray (_item >> "position");
			_radiusA = getNumber (_item >> "radiusA");
			_radiusB = getNumber (_item >> "radiusB");
			
			[arjay_worldLocations, _name, [_name, _type, _position, _radiusA, _radiusB]] call Dictionary_fnc_set;
			['[arjay_worldLocations, "%1", ["%1", "%2", %3, %4, %5]] call Dictionary_fnc_set;',_name, _type, _position, _radiusA, _radiusB] call arjay_dump;
		};		
	};
};

/*
	Sets the world location buildings dictionary from locations set in arjay_getWorldLocations
*/
arjay_getWorldLocationBuildings = 
{	
	private ["_name", "_locationType", "_position", "_direction", "_radiusA", "_radiusB", "_locationBuildings", "_buildings", "_className", "_positionCount", "_positions"];
	
	{
		_name = _x select 0;
		_locationType = _x select 1;
		_position = _x select 2;
		_radiusA = _x select 3;
		_radiusB = _x select 4;
		
		_buildings = _position nearObjects ["House_F", _radiusA];
		
		
		// loop buildings to build a buildings by location map
		arjay_locationBuildings = [];
		['arjay_locationBuildings = [];'] call arjay_dump;
		{			
			// store if building key not already defined
			if!(str _x in (arjay_worldBuildings select 0)) then
			{
				arjay_locationBuildings set [count arjay_locationBuildings, str _x];
				['arjay_locationBuildings set [count arjay_locationBuildings, "%1"];',str _x] call arjay_dump;
			};
			
		} forEach _buildings;
		
		[arjay_worldBuildingsByLocation, _name, arjay_locationBuildings] call Dictionary_fnc_set;
		['[arjay_worldBuildingsByLocation, "%1", arjay_locationBuildings] call Dictionary_fnc_set;',_name] call arjay_dump;
		
		
		// loop buildings for a given location to build a map of all world buildings
		{			
			_position = getPos _x;
			_direction = direction _x;
			_className = typeOf _x;
			
			// get internal building positions
			_positionCount = 0;
			_positions = [];
			while {(str(_x buildingPos _positionCount) != "[0,0,0]") && (_positionCount < 20)} do 
			{
				_positions set [count _positions, _x buildingPos _positionCount];
				_positionCount = _positionCount + 1;
			};
			
			// store if building key not already defined
			if!(str _x in (arjay_worldBuildings select 0)) then
			{
				[arjay_worldBuildings, str _x, [str _x, _name, _locationType, _className, _position, _positionCount, _positions, _direction]] call Dictionary_fnc_set;
				['[arjay_worldBuildings, "%1", ["%1", "%2", "%3", "%4", %5, %6, %7, %8]] call Dictionary_fnc_set;',_x, _name, _locationType, _className, _position, _positionCount, _positions, _direction] call arjay_dump;
			};
			
		} forEach _buildings;		
		
	} forEach (arjay_worldLocations select 1);
};

/*
	Plots location perimeter using rubes excellent convex hull script
*/
arjay_getWorldLocationPerimeters = 
{	
	private ["_countMarkers", "_countPositions", "_name", "_position", "_plot", "_plotRadius","_locationBuildings", "_positions"];
	
	_countMarkers = 0;
	_countPositions = 0;
	
	{		
		_name = _x select 0;
		_position = _x select 2;
		_plot = _x select 5;
		_plotRadius = _x select 6;
		
		if(_plot) then
		{
			_locationBuildings = _position nearObjects ["House_F", _plotRadius];			
			
			_positions = [_locationBuildings, 20, 30] call RUBE_convexHull;
			
			[arjay_worldLocationPerimeters, _name, _positions] call Dictionary_fnc_set;
			['[arjay_worldLocationPerimeters, "%1", %2] call Dictionary_fnc_set;',_name, _positions] call arjay_dump;
			
			/*
			
			_markerName = format["arjay_debugLocationMarker_%1", _countMarkers];
			_marker = createMarker [_markerName, _position];
			_marker setMarkerSize [_plotRadius, _plotRadius];
			_marker setMarkerAlpha 0.3;
			_marker setMarkerShape "ELLIPSE";
			_marker setMarkerBrush "Solid";
			_marker setMarkerColor "ColorYellow";
			
			{
				//[_x, 0] call arjay_createDebugIndicator;
				_markerName = format["arjay_debugRouteMarker_%1_%2", _countMarkers, _countPositions];
				_marker = createMarker [_markerName, _x];
				_marker setMarkerAlpha 0.3;
				_marker setMarkerSize [1,1];
				_marker setMarkerType "hd_dot";	
				_marker setMarkerColor "ColorOrange";
				_countPositions = _countPositions + 1;
			} forEach _positions;
			
			_countMarkers = _countMarkers + 1;
			*/
		}
		else
		{
			[arjay_worldLocationPerimeters, _name, []] call Dictionary_fnc_set;
			['[arjay_worldLocationPerimeters, "%1", %2] call Dictionary_fnc_set;',_name, []] call arjay_dump;
		};	
	} forEach (arjay_worldLocations select 1);
	
};

/*
	Get Civilian Buildings from world building list
	Generate good parking spawn point positions for each building
*/
arjay_getCivilianBuildings = 
{
	private ["_vehicles", "_id", "_location", "_locationType", "_building", "_position", "_direction", "_minDistance", "_maxDistance", "_vehicleClass", "_data", "_goodSpawnPosition"];
		
	_vehicles = ["CIVILIAN_GROUND"] call arjay_getVehicles;

	{
		_id = _x select 0;
		_location = _x select 1;
		_locationType = _x select 2;
		_building = _x select 3;		
		_position = _x select 4;
		_direction = _x select 7;
		
		_minDistance = 2;
		_maxDistance = 30;
		_direction = _direction - 180;
		
		_vehicleClass = _vehicles select round (random ((count _vehicles) - 1));
		_data = [];
		
		if(_building in arjay_civilianBuildings) then
		{
			// get external vehicle spawn positions
			if(arjay_worldGenerateSpawnPositions) then
			{					
				_goodSpawnPosition = [_vehicleClass, _position, _direction, _minDistance, _maxDistance] call arjay_getGoodSpawnPosition;
				
				_data set [count _data, _id];
				_data set [count _data, _vehicleClass];
				_data set [count _data, _goodSpawnPosition select 0];
				_data set [count _data, _goodSpawnPosition select 1];
			};
		
			[arjay_agentCivilianBuildings, _id, _data] call Dictionary_fnc_set;
			['[arjay_agentCivilianBuildings, "%1", %2] call Dictionary_fnc_set;',_id, _data] call arjay_dump;
		};

	} forEach (arjay_worldBuildings select 1);
	
	[] call arjay_clearGoodSpawnVehicles;
};

/*
	Get Civilian Task Buildings from world building list
	Generate good object spawn point positions for each building if set
*/
arjay_getCivilianTaskBuildings = 
{
	{
		private ["_vehicles", "_id", "_location", "_locationType", "_class", "_position", "_building", "_minDistance", "_maxDistance", "_direction", "_vehicleClass", "_goodSpawnPosition", "_data"];
	
		_id = _x select 0;
		_location = _x select 1;
		_locationType = _x select 2;
		_class = _x select 3;		
		_position = _x select 4;
		_direction = _x select 7;
		_data = [];
		
		if(_class in arjay_civilianTaskBuildings) then
		{
			// get external vehicle spawn positions
			if(arjay_worldGenerateSpawnPositions) then
			{
				switch(_class) do
				{
					// spawn boats by piers
					case "Land_Pier_small_F":
					{						
						_minDistance = 2;
						_maxDistance = 30;
						_direction = _direction - 90;
						
						_vehicles = ["CIVILIAN_SEA"] call arjay_getVehicles;
						_vehicleClass = _vehicles select round (random ((count _vehicles) - 1));
					
						_goodSpawnPosition = [_vehicleClass, _position, _direction, _minDistance, _maxDistance, true] call arjay_getGoodSpawnPosition;
						
						_data set [count _data, _id];
						_data set [count _data, _vehicleClass];
						_data set [count _data, _goodSpawnPosition select 0];
						_data set [count _data, _goodSpawnPosition select 1];
					};
					// spawn boats by piers
					case "Land_Pier_F":
					{				
						_minDistance = 2;
						_maxDistance = 30;
						_direction = _direction - 90;
						
						_vehicles = ["CIVILIAN_SEA"] call arjay_getVehicles;
						_vehicleClass = _vehicles select round (random ((count _vehicles) - 1));
					
						_goodSpawnPosition = [_vehicleClass, _position, _direction, _minDistance, _maxDistance, true] call arjay_getGoodSpawnPosition;
			
						_data set [count _data, _id];
						_data set [count _data, _vehicleClass];
						_data set [count _data, _goodSpawnPosition select 0];
						_data set [count _data, _goodSpawnPosition select 1];
					};
					default
					{	
						_data set [count _data, _id];
						_data set [count _data, ""];
						_data set [count _data, []];
						_data set [count _data, 0];
					};
				};				
			};
		
			[arjay_agentCivilianTaskBuildings, _id, _data] call Dictionary_fnc_set;
			['[arjay_agentCivilianTaskBuildings, "%1", %2] call Dictionary_fnc_set;',_id, _data] call arjay_dump;
		};
		

	} forEach (arjay_worldBuildings select 1);
	
	[] call arjay_clearGoodSpawnVehicles;
};

/*
	Get Military East Buildings from world building list
	Generate good parking spawn point positions for each building
*/
arjay_getEastBuildings = 
{
	private ["_vehicles", "_id", "_location", "_locationType", "_building", "_position", "_direction", "_minDistance", "_maxDistance", "_vehicleClass", "_goodSpawnPosition", "_data"];
	
	_vehicles = ["EAST_GROUND"] call arjay_getVehicles;

	{
		_id = _x select 0;
		_location = _x select 1;
		_locationType = _x select 2;
		_building = _x select 3;		
		_position = _x select 4;
		_direction = _x select 7;
		
		_minDistance = 2;
		_maxDistance = 30;
		_direction = _direction - 180;
		
		_vehicleClass = _vehicles select round (random ((count _vehicles) - 1));
		_data = [];
		
		if(_building in arjay_militaryBuildings) then
		{
			// get external vehicle spawn positions
			if(arjay_worldGenerateSpawnPositions) then
			{					
				_goodSpawnPosition = [_vehicleClass, _position, _direction, _minDistance, _maxDistance] call arjay_getGoodSpawnPosition;
				
				_data set [count _data, _id];
				_data set [count _data, _vehicleClass];
				_data set [count _data, _goodSpawnPosition select 0];
				_data set [count _data, _goodSpawnPosition select 1];
			};
		
			[arjay_agentEastBuildings, _id, _data] call Dictionary_fnc_set;
			['[arjay_agentEastBuildings, "%1", %2] call Dictionary_fnc_set;',_id, _data] call arjay_dump;
		};

	} forEach (arjay_worldBuildings select 1);
	
	[] call arjay_clearGoodSpawnVehicles;
};

/*
	Get East Task Buildings from world building list
	Generate good object spawn point positions for each building if set
*/
arjay_getEastTaskBuildings = 
{
	{
		private ["_vehicles", "_id", "_location", "_locationType", "_class", "_position", "_building", "_minDistance", "_maxDistance", "_direction", "_vehicleClass", "_goodSpawnPosition", "_data"];
	
		_id = _x select 0;
		_location = _x select 1;
		_locationType = _x select 2;
		_class = _x select 3;		
		_position = _x select 4;
		_direction = _x select 7;
		_data = [];
		
		if(_class in arjay_militaryTaskBuildings) then
		{
			// get external vehicle spawn positions
			if(arjay_worldGenerateSpawnPositions) then
			{
				switch(_class) do
				{
					// spawn air units in hangars
					case "Land_TentHangar_V1_F":
					{						
						_minDistance = 2;
						_maxDistance = 30;
						_direction = _direction - 180;
						
						_vehicles = ["EAST_AIR"] call arjay_getVehicles;	
						_vehicleClass = _vehicles select round (random ((count _vehicles) - 1));
					
						_goodSpawnPosition = [_vehicleClass, _position, _direction, _minDistance, _maxDistance, false] call arjay_getGoodSpawnPosition;
						
						_data set [count _data, _id];
						_data set [count _data, _vehicleClass];
						_data set [count _data, _goodSpawnPosition select 0];
						_data set [count _data, _goodSpawnPosition select 1];
					};
					// spawn boats by piers
					case "Land_Pier_small_F":
					{						
						_minDistance = 2;
						_maxDistance = 30;
						_direction = _direction - 90;
						
						_vehicles = ["EAST_SEA"] call arjay_getVehicles;	
						_vehicleClass = _vehicles select round (random ((count _vehicles) - 1));
					
						_goodSpawnPosition = [_vehicleClass, _position, _direction, _minDistance, _maxDistance, true] call arjay_getGoodSpawnPosition;
						
						_data set [count _data, _id];
						_data set [count _data, _vehicleClass];
						_data set [count _data, _goodSpawnPosition select 0];
						_data set [count _data, _goodSpawnPosition select 1];
					};
					// spawn boats by piers
					case "Land_Pier_F":
					{				
						_minDistance = 2;
						_maxDistance = 30;
						_direction = _direction - 90;
						
						_vehicles = ["EAST_SEA"] call arjay_getVehicles;
						_vehicleClass = _vehicles select round (random ((count _vehicles) - 1));
					
						_goodSpawnPosition = [_vehicleClass, _position, _direction, _minDistance, _maxDistance, true] call arjay_getGoodSpawnPosition;
			
						_data set [count _data, _id];
						_data set [count _data, _vehicleClass];
						_data set [count _data, _goodSpawnPosition select 0];
						_data set [count _data, _goodSpawnPosition select 1];
					};
					default
					{	
						_data set [count _data, _id];
						_data set [count _data, ""];
						_data set [count _data, []];
						_data set [count _data, 0];
					};
				};				
			};
		
			[arjay_agentEastTaskBuildings, _id, _data] call Dictionary_fnc_set;
			['[arjay_agentEastTaskBuildings, "%1", %2] call Dictionary_fnc_set;',_id, _data] call arjay_dump;
		};
		

	} forEach (arjay_worldBuildings select 1);
	
	[] call arjay_clearGoodSpawnVehicles;
};

/*
	Get Military West Buildings from world building list
	Generate good parking spawn point positions for each building
*/
arjay_getWestBuildings = 
{
	private ["_vehicles", "_id", "_location", "_locationType", "_building", "_position", "_direction", "_minDistance", "_maxDistance", "_vehicleClass", "_goodSpawnPosition", "_data"];
		
	_vehicles = ["WEST_GROUND"] call arjay_getVehicles;

	{
		_id = _x select 0;
		_location = _x select 1;
		_locationType = _x select 2;
		_building = _x select 3;		
		_position = _x select 4;
		_direction = _x select 7;
		
		_minDistance = 2;
		_maxDistance = 30;
		_direction = _direction - 180;
		
		_vehicleClass = _vehicles select round (random ((count _vehicles) - 1));
		_data = [];
		
		if(_building in arjay_militaryBuildings) then
		{
			// get external vehicle spawn positions
			if(arjay_worldGenerateSpawnPositions) then
			{					
				_goodSpawnPosition = [_vehicleClass, _position, _direction, _minDistance, _maxDistance] call arjay_getGoodSpawnPosition;
				
				_data set [count _data, _id];
				_data set [count _data, _vehicleClass];
				_data set [count _data, _goodSpawnPosition select 0];
				_data set [count _data, _goodSpawnPosition select 1];
			};
		
			[arjay_agentWestBuildings, _id, _data] call Dictionary_fnc_set;
			['[arjay_agentWestBuildings, "%1", %2] call Dictionary_fnc_set;',_id, _data] call arjay_dump;
		};

	} forEach (arjay_worldBuildings select 1);
	
	[] call arjay_clearGoodSpawnVehicles;
};

/*
	Get West Task Buildings from world building list
	Generate good object spawn point positions for each building if set
*/
arjay_getWestTaskBuildings = 
{
	{
		private ["_vehicles", "_id", "_location", "_locationType", "_class", "_position", "_building", "_minDistance", "_maxDistance", "_direction", "_vehicleClass", "_goodSpawnPosition", "_data"];
	
		_id = _x select 0;
		_location = _x select 1;
		_locationType = _x select 2;
		_class = _x select 3;		
		_position = _x select 4;
		_direction = _x select 7;
		_data = [];
		
		if(_class in arjay_militaryTaskBuildings) then
		{
			// get external vehicle spawn positions
			if(arjay_worldGenerateSpawnPositions) then
			{
				switch(_class) do
				{
					// spawn air units in hangars
					case "Land_TentHangar_V1_F":
					{						
						_minDistance = 2;
						_maxDistance = 30;
						_direction = _direction - 180;
						
						_vehicles = ["WEST_AIR"] call arjay_getVehicles;	
						_vehicleClass = _vehicles select round (random ((count _vehicles) - 1));
					
						_goodSpawnPosition = [_vehicleClass, _position, _direction, _minDistance, _maxDistance, false] call arjay_getGoodSpawnPosition;
						
						_data set [count _data, _id];
						_data set [count _data, _vehicleClass];
						_data set [count _data, _goodSpawnPosition select 0];
						_data set [count _data, _goodSpawnPosition select 1];
					};
					// spawn boats by piers
					case "Land_Pier_small_F":
					{						
						_minDistance = 2;
						_maxDistance = 30;
						_direction = _direction - 90;
						
						_vehicles = ["WEST_SEA"] call arjay_getVehicles;	
						_vehicleClass = _vehicles select round (random ((count _vehicles) - 1));
					
						_goodSpawnPosition = [_vehicleClass, _position, _direction, _minDistance, _maxDistance, true] call arjay_getGoodSpawnPosition;
						
						_data set [count _data, _id];
						_data set [count _data, _vehicleClass];
						_data set [count _data, _goodSpawnPosition select 0];
						_data set [count _data, _goodSpawnPosition select 1];
					};
					// spawn boats by piers
					case "Land_Pier_F":
					{				
						_minDistance = 2;
						_maxDistance = 30;
						_direction = _direction - 90;
						
						_vehicles = ["WEST_SEA"] call arjay_getVehicles;
						_vehicleClass = _vehicles select round (random ((count _vehicles) - 1));
					
						_goodSpawnPosition = [_vehicleClass, _position, _direction, _minDistance, _maxDistance, true] call arjay_getGoodSpawnPosition;
			
						_data set [count _data, _id];
						_data set [count _data, _vehicleClass];
						_data set [count _data, _goodSpawnPosition select 0];
						_data set [count _data, _goodSpawnPosition select 1];
					};
					default
					{	
						_data set [count _data, _id];
						_data set [count _data, ""];
						_data set [count _data, []];
						_data set [count _data, 0];
					};
				};				
			};
		
			[arjay_agentWestTaskBuildings, _id, _data] call Dictionary_fnc_set;
			['[arjay_agentWestTaskBuildings, "%1", %2] call Dictionary_fnc_set;',_id, _data] call arjay_dump;
		};
		

	} forEach (arjay_worldBuildings select 1);
	
	[] call arjay_clearGoodSpawnVehicles;
};