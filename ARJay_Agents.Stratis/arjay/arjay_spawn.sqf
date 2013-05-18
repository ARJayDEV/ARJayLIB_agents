/*
	File: arjay_spawn.sqf
	Author: ARJay
	Description: Spawning objects
	props: Object direction and pitch http://www.kylania.com/ex/?p=21 AWESOME!
*/

arjay_goodSpawnVehicles = [];

/*
	Respawn
*/
arjay_respawn = 
{
	private ["_target", "_delayDestroy", "_delayCreate", "_position", "_direction"];
	
	_target = _this select 0;
	_delayDestroy = if(count _this > 1) then {_this select 1} else {3};
	_delayCreate = if(count _this > 2) then {_this select 2} else {2};
	_position = if(count _this > 3) then {_this select 3} else {getPosASL _target;};
	_direction = if(count _this > 4) then {_this select 4} else {getDir _target;};

	[_target, _delayDestroy, _delayCreate, _position, _direction] spawn 
	{	
		private ["_target", "_delayDestroy", "_delayCreate", "_type", "_position", "_direction", "_name"];
		
		_target = _this select 0;
		_delayDestroy = _this select 1;
		_delayCreate = _this select 2;
		_position = _this select 3;
		_direction = _this select 4;
		_type = typeOf _target;
		_name = vehicleVarName _target;
		
		sleep _delayDestroy;
		
		deleteVehicle _target;
		
		sleep _delayCreate;
		
		_target = _type createVehicle _position;
		_target setPosASL _position;
		_target setDir _dir;
		
		_target setVehicleVarName _name;
	};
};	

/*
	Random Location Spawn
	Spawns count items around randomly around target
	Optionally spawns items on a random timer
*/
arjay_randomLocationSpawn = 
{
	private ["_target", "_preset", "_count", "_distance", "_randomTiming", "_randomTimingMax", "_position", "_object"];
	
	_target = _this select 0;
	_preset = _this select 1;
	_count = if(count _this > 2) then {_this select 2} else {5};
	_distance = if(count _this > 3) then {_this select 3} else {100};
	_randomTiming = if(count _this > 4) then {_this select 4} else {false};
	_randomTimingMax = if(count _this > 5) then {_this select 5} else {10};
		
	for "_i" from 0 to _count-1 do
	{
		if(_randomTiming) then 
		{
			[_target, _preset, _distance] spawn {
			
				_target = _this select 0;
				_preset = _this select 1;
				_distance = _this select 2;
			
				sleep random 10;
				
				_object = [_target, _preset] call arjay_spawn;
				_position = [position _object, random _distance, random 360] call BIS_fnc_relPos;
				_object setPos _position;
			};			
		}
		else
		{
			_object = [_target, _preset] call arjay_spawn;
			_position = [position _object, random _distance, random 360] call BIS_fnc_relPos;
			_object setPos _position;
		};		
	};
	
	_object
};	

/*
	Spawn
*/
arjay_spawn = 
{
	private ["_target", "_preset", "_object"];
	
	_target = _this select 0;
	_preset = _this select 1;
			
	switch(_preset) do
	{			
		case "EXPLOSION_SMALL":
			{
				_object = "GrenadeHand" createVehicle ((_target) modelToWorld [0,0,1]);
				_object setVelocity [0,0,-10];
			};
		case "EXPLOSION_MEDIUM":
			{
				_object = "Sh_82mm_AMOS" createVehicle ((_target) modelToWorld [0,0,1]); 
				[_object,_target] call arjay_pointAt;
				_object setVelocity [0,0,-10];
			};
		case "EXPLOSION_LARGE":
			{
				_object = "Sh_120mm_AMOS_LG" createVehicle ((_target) modelToWorld [0,0,1]); 
				[_object,_target] call arjay_pointAt;
				_object setVelocity [0,0,-10];
			};
		case "BOMB_SMALL":
			{
				_object = "G_20mm_HE" createVehicle ((_target) modelToWorld [0,0,100]); 
				_object setVelocity [0,0,-10];
			};
		case "BOMB_MEDIUM":
			{
				_object = "Sh_82mm_AMOS" createVehicle ((_target) modelToWorld [0,0,100]); 
				[_object,_target] call arjay_pointAt;
				_object setVelocity [0,0,-10];
			};
		case "BOMB_LARGE":
			{
				_object = "Sh_120mm_AMOS_LG" createVehicle ((_target) modelToWorld [0,0,100]); 
				[_object,_target] call arjay_pointAt;
				_object setVelocity [0,0,-10];
			};
		case "MISSILE_STRIKE_SMALL":
			{
				_object = "M_NLAW_AT_F" createVehicle ((_target) modelToWorld [0,400,400]);
				[_object,_target] call arjay_pointAt;
			};
		case "MISSILE_STRIKE_MEDIUM":
			{
				_object = "M_Mo_82mm_AT_LG" createVehicle ((_target) modelToWorld [0,400,400]);
				[_object,_target] call arjay_pointAt;
			};
		case "MISSILE_STRIKE_LARGE":
			{
				_object = "M_Mo_120mm_AT_LG" createVehicle ((_target) modelToWorld [0,400,400]);
				[_object,_target] call arjay_pointAt;
			};
		case "FLARE_SMALL":
			{
				_object = "F_20mm_Red" createVehicle ((_target) modelToWorld [0,0,50]); 
				_object setVelocity [0,0,-10];
			};
		case "FLARE_LARGE":
			{
				_object = "F_40mm_Red" createVehicle ((_target) modelToWorld [0,0,50]); 
				_object setVelocity [0,0,-10];
			};
		case "SMOKE_SMALL":
			{
				_object = "G_40mm_Smoke" createVehicle ((_target) modelToWorld [0,0,100]); 
				[_object,_target] call arjay_pointAt;
				_object setVelocity [0,0,-10];
			};
		case "SMOKE_LARGE":
			{
				_object = "Smoke_120mm_AMOS_White" createVehicle ((_target) modelToWorld [0,0,100]); 
				[_object,_target] call arjay_pointAt;
				_object setVelocity [0,0,-10];
			};
		case "TEST":
			{
				_object = "Land_dp_smallTank_F" createVehicle ((_target) modelToWorld [0,0,0]); 
			};
	};	
	_object
};

/*
	Add ambient room light
*/
arjay_addAmbientRoomLight =
{
	private ["_target", "_colours", "_colour", "_brightness", "_light"];
	
	_target = _this select 0;
	
	_colours = [[255,217,66],[255,162,41],[221,219,206]];
	_colour = _colours select (random((count _colours)-1));
	_brightness = random 10 / 100;	
	
	_light = "#lightpoint" createVehicle getPos _target;
	
	if(isMultiplayer && !arjay_isMultiplayerHost) then
	{
		["arjay_clientCommandCreateRoomLight", [_target, _light, _brightness, _colour]] call arjay_broadcastClientCommand;
		//[arjay_players, "arjay_clientCommandCreateRoomLight", [_target, _light, _brightness, _colour]] call arjay_sendClientsCommand;
	}
	else
	{		
		_light setLightBrightness _brightness;
		_light setLightColor _colour;
		_light lightAttachObject [_target, [1,1,1]];
	};
	
	_light
};

/*
	Add ambient room music
*/
arjay_addAmbientRoomMusic = 
{
	private ["_target", "_musicSource"];
	
	_target = _this select 0;
		
	_musicSource = "RoadCone_L_F" createVehicle _position;
	_musicSource attachTo [_target,[1,1,1]];
	hideObject _musicSource;
	
	[_target, _musicSource] spawn
	{
		private ["_target", "_musicSource", "_tracksPlayed", "_totalTracks", "_trackName", "_trackDuration"];
		
		_target = _this select 0;
		_musicSource = _this select 1;
		_tracksPlayed = 1;
		_totalTracks = count (arjay_agentCivilianHouseTracks select 0);
		
		while { (alive _musicSource) } do 
		{			
			while { _tracksPlayed < _totalTracks } do
			{
				_trackName = format["Track%1", floor (1 + (random _totalTracks))];
				_trackDuration = [arjay_agentCivilianHouseTracks, _trackName] call Dictionary_fnc_get;
				
				if(isMultiplayer && !arjay_isMultiplayerHost) then
				{
					["arjay_clientCommandCreateRoomMusic", [_target, _musicSource, _trackName]] call arjay_broadcastClientCommand;
					//[arjay_players, "arjay_clientCommandCreateRoomMusic", [_target, _musicSource, _trackName]] call arjay_sendClientsCommand;
				}
				else
				{
					_musicSource say3d _trackName;
				};				
				
				sleep _trackDuration;
				
				_tracksPlayed = _tracksPlayed + 1;
							
				if not (alive _musicSource) exitWith {};
			};
			
			sleep 1;
		};
	};
	
	_musicSource
};

/*
	Creates a Unit
*/
arjay_createUnit = 
{	
	private ["_unitClass", "_unit", "_unitName", "_side", "_position", "_group"];
	
	_unitClass = _this select 0;
	_unitName = _this select 1;
	_side = _this select 2;
	_position = _this select 3;
	
	_group = createGroup _side;
	_unit = _group createUnit [_unitClass, _position, [], 0 , "NONE"];
	_unit setVehicleVarName _unitName;
	_unit setPos _position;
		
	_unit
};

/*
	Creates a Group for a passed leader
*/
arjay_createGroup = 
{	
	private ["_leader", "_groupCount", "_groupClasses", "_side", "_position", "_group", "_leaderName", "_unit", "_i"];
	
	_leader = _this select 0;
	_groupCount = _this select 1;
	_groupClasses = _this select 2;
	_side = _this select 3;
	_position = _this select 4;
	
	_group = group _leader;
	_leaderName = vehicleVarName _leader;
	
	for "_i" from 0 to (_groupCount-1) do 
	{
		_position = _position findEmptyPosition [2, 200];
		_unit = _group createUnit [(_groupClasses select _i), _position, [], 0 , "NONE"];
		_unit setVehicleVarName format["%1_g%2",_leaderName, _i];
		//_unit setPos _position;
	};	
};

/*
	Creates a Vehicle
*/
arjay_createVehicle = 
{	
	private ["_vehicleClass", "_vehicle", "_vehicleName", "_position", "_direction"];
	
	_vehicleClass = _this select 0;
	_vehicleName = _this select 1;
	_position = _this select 2;
	_direction = _this select 3;	
	_vehicle = createVehicle [_vehicleClass, _position, [], 0, "NONE"];
	_vehicle setPos _position;
	_vehicle setDir _direction;
	_vehicle setVehicleVarName _vehicleName;
	
	_vehicle
};

/*
	Creates a Weapon at a position
*/
arjay_createWeapon = 
{	
	private ["_position", "_direction", "_weaponClass", "_ammoClass", "_ammoCount", "_weapon"];
	
	_position = _this select 0;
	_direction = _this select 1;
	_weaponClass = _this select 2;
	_ammoClass = _this select 3;	
	_ammoCount = if(count _this > 4) then {_this select 4} else {2};
	
	_weapon = "groundWeaponHolder" createVehicle _position;
	_weapon addWeaponCargo [_weaponClass,1];
	_weapon addMagazineCargo [_ammoClass, _ammoCount];
	_weapon setPos _position;
	_weapon setDir _direction;
};

arjay_debugIndicators = ["Sign_Sphere100cm_F", "Sign_Sphere25cm_F", "Sign_Sphere10cm_F", "Sign_Pointer_Green_F", "Sign_Pointer_Blue_F", "Sign_Pointer_Pink_F", "Sign_Pointer_Yellow_F", "Sign_Pointer_Cyan_F"];

/*
	Position Indicator
*/
arjay_createDebugIndicator = 
{
	private ["_position", "_type", "_class", "_vehicle"];
	
	_position = _this select 0;
	_type = if(count _this > 1) then {_this select 1} else {0};
	
	_class = arjay_debugIndicators select _type;
	
	_vehicle = _class createVehicle _position;
	_vehicle setPos _position;
	
	_vehicle	
};

/*
	Sets a target objects 3D orientation to point at a target object
*/
arjay_pointAt = 
{
	private ["_source", "_target", "_relDirHor", "_relDirVer"];
	
	_source = _this select 0;
	_target = _this select 1;
	
	_relDirHor = [_source, _target] call BIS_fnc_DirTo;
	_source setDir _relDirHor;

	_relDirVer = asin ((((getPosASL _source) select 2) - ((getPosASL _target) select 2)) / (_target distance _source));
	_relDirVer = (_relDirVer * -1);
	[_source, _relDirVer, 0] call BIS_fnc_setPitchBank;
};

/*
	Gets an array of child classes of B_Soldier_base_F from the config files
*/
arjay_getUnits = 
{
	private ["_type", "_classType", "_config", "_count", "_units", "_item", "_class", "_ignoreClasses"];
	
	_type = _this select 0;
	
	switch(_type) do
	{
		case "WEST":
		{
			_classType = "B_Soldier_base_F";
			_ignoreClasses = ["B_Soldier_base_F", "B_Soldier_diver_base_F", "B_UAV_AI", "Underwear_F", "B_diver_F", "B_diver_TL_F", "B_diver_exp_F", "B_Helipilot_F"];
		};
		case "EAST":
		{
			_classType = "O_Soldier_base_F";
			_ignoreClasses = ["O_Soldier_base_F", "O_Soldier_diver_base_F", "O_UAV_AI", "I_UAV_AI", "O_diver_F", "O_diver_TL_F", "O_diver_exp_F", "O_Helipilot_F"];
		};
		case "CIV":
		{
			_classType = "C_man_1";
			_ignoreClasses = ["C_man_base_F"];
		};
	};

	_config = configFile >> "Cfgvehicles";
	_count = count _config;
	_units = [];
	for "_i" from 0 to (_count-1) do 
	{
		_item = _config select _i;		
		if (isClass _item) then 
		{
			_class = configName _item;
			if (_class isKindOf _classType) then 
			{
				_units set [count _units, _class];
			};
		};
	};
	
	_units = _units - _ignoreClasses;
	
	_units
};

/*
	Gets an array of child classes of O_Soldier_base_F from the config files
*/
arjay_getVehicles = 
{
	private ["_type", "_classType", "_side", "_config", "_count", "_vehicles", "_item", "_class"];

	_type = _this select 0;
	
	switch(_type) do
	{
		case "WEST_GROUND":
		{
			_classType = "Car";
			_side = 1;
		};
		case "WEST_SEA":
		{
			_classType = "Ship";
			_side = 1;
		};
		case "WEST_AIR":
		{
			_classType = "Air";
			_side = 1;
		};
		case "EAST_GROUND":
		{
			_classType = "Car";
			_side = 0;
		};
		case "EAST_SEA":
		{
			_classType = "Ship";
			_side = 0;
		};
		case "EAST_AIR":
		{
			_classType = "Air";
			_side = 0;
		};
		case "CIVILIAN_GROUND":
		{
			_classType = "Car";
			_side = 3;
		};
		case "CIVILIAN_SEA":
		{
			_classType = "Ship";
			_side = 3;
		};
		case "CIVILIAN_AIR":
		{
			_classType = "Air";
			_side = 3;
		};
	};
	
	_config = configFile >> "Cfgvehicles";
	_count = count _config;
	_vehicles = [];
	for "_i" from 0 to (_count-1) do 
	{
		_item = _config select _i;		
		if (isClass _item) then 
		{
			if (((getnumber (_item >> "scope")) == 2) && ((getnumber (_item >> "side")) == _side)) then
			{
				_class = configName _item;
				if (_class isKindOf _classType) then 
				{
					_vehicles set [count _vehicles, _class];
				};
			};
		};
	};
	
	_vehicles
};

/*
	Generate good spawn point positions for a position
	This is not meant to be run during play, its a labor intensive routine meant for generating positions for hard coded static world data
*/
arjay_getGoodSpawnPosition = 
{
	private ["_vehicleClass", "_position", "_direction", "_minDistance", "_maxDistance", "_onWater", "_parkingPosition", "_positionFound", "_attempt",
	"_badParkingPosition", "_testPosition", "_vehicle", "_time", "_endTime", "_isBad", "_damage", "_vehiclePos", "_road", "_nearRoads", "_roadConnectedTo", "_connectedRoad", "_vehiclePosIsWater"];

	_vehicleClass = _this select 0;
	_position = _this select 1;	
	_direction = _this select 2;
	_minDistance = if(count _this > 3) then {_this select 3} else {5};
	_maxDistance = if(count _this > 4) then {_this select 4} else {100};
	_onWater = if(count _this > 5) then {_this select 5} else {false};
	
	_parkingPosition = [];
	
	_positionFound = false;
	_attempt = 0;
	_badParkingPosition = "";
					
	// no valid position
	while{!(_positionFound)} do
	{
		_parkingPosition = [];
		
		// re attempt to find
		if(_attempt > 0) then
		{
			while{count _parkingPosition < 1} do
			{
				_minDistance = _minDistance + 1;
				_maxDistance = _maxDistance + 5;
				_testPosition = _position findEmptyPosition[_minDistance, _maxDistance, _vehicleClass];
				
				// position is different to last position and position is valid
				if(!(str _testPosition == _badParkingPosition) && count _testPosition > 1) then
				{
					_parkingPosition = _testPosition;
				};							
			};
		}
		else
		{
			while{ count _parkingPosition < 1 } do
			{
				_parkingPosition = _position findEmptyPosition[_minDistance, _maxDistance, _vehicleClass];
				_maxDistance = _maxDistance + 30;
			};
		};
		
		_vehicle = _vehicleClass createVehicle _parkingPosition;
		_vehicle setPos _parkingPosition;
		
		// get nearby road direction, align to that if found
		_nearRoads = _parkingPosition nearRoads 10;
		if(count _nearRoads > 0) then
		{
			_road = _nearRoads select 0;
			_roadConnectedTo = roadsConnectedTo _road;
			_connectedRoad = _roadConnectedTo select 0;
			_direction = [_road, _connectedRoad] call BIS_fnc_DirTo;
		};
		
		_vehicle setDir _direction;
		
		_time = time;
		_endTime = _time+10;
		_isBad = false;
		
		// spawn the vehicle at the position and wait for 5 seconds, if vehicle takes damage, mark position bad
		while {_time < _endTime} do
		{
			_time = time;
			_damage = getDammage _vehicle;
			
			if(_damage > 0) then
			{
				deleteVehicle _vehicle;
				_isBad = true;
				_badParkingPosition = str _parkingPosition;
			};
		};
		
		// if on water position is required and if position is not water mark position bad
		if(_onWater) then
		{
			_vehiclePos = getPos _vehicle;
			_vehiclePosIsWater = surfaceIsWater [_vehiclePos select 0, _vehiclePos select 1];
			if!(_vehiclePosIsWater) then
			{
				deleteVehicle _vehicle;
				_isBad = true;
				_badParkingPosition = str _parkingPosition;
			}
		};

		if!(_isBad) then
		{
			_positionFound = true;
		}
		else
		{
			_attempt = _attempt + 1;
		}				
	};
	
	arjay_goodSpawnVehicles set [count arjay_goodSpawnVehicles, _vehicle];
	
	[_parkingPosition, _direction]
};

/*
	Clear any created good spawn test vehicles
*/
arjay_clearGoodSpawnVehicles = 
{
	{
		deleteVehicle _x;
	} forEach arjay_goodSpawnVehicles;
	
	arjay_goodSpawnVehicles = [];
};