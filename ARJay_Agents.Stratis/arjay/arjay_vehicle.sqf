/*
	File: arjay_vehicle.sqf
	Author: ARJay
	Description: For dealing with vehicles
*/

/*
	Filter in use vehicles from array
*/
arjay_filterInUseVehicles = 
{
	private ["_vehicles", "_inUse"];
	
	_vehicles = _this select 0;
	
	{
		_inUse = _x getVariable ["arjay_agentInUse", false];
		if(_inUse) then { _vehicles = _vehicles - [_x]};
	} forEach _vehicles;
	
	_vehicles
};

/*
	Get vehicle positions
*/
arjay_getEmptyVehiclePositions = 
{		
	private ["_vehicle", "_count", "_positions"];
	
	_vehicle = _this select 0;
	
	_positions = [0,0,0,0];
	
	if (locked _vehicle != 2 && alive _vehicle) then
	{	
		_positions set [0, _vehicle emptyPositions "Driver"];
		_positions set [1, _vehicle emptyPositions "Gunner"];
		_positions set [2, _vehicle emptyPositions "Commander"];
		_positions set [3, _vehicle emptyPositions "Cargo"];
	};
	
	_positions
};

/*
	Any vehicle positions empty
*/
arjay_vehicleEmptyPositions = 
{		
	private ["_vehicle", "_positions", "_result"];
	
	_vehicle = _this select 0;
	
	_result = 0;
	
	_positions = [_vehicle] call arjay_getEmptyVehiclePositions;
	
	{
		_result = _result + _x;
	} forEach _positions;
	
	_result
	
};

/*
	Enough room in vehicle for whole group
*/
arjay_vehicleHasRoomForGroup = 
{
	private ["_group", "_vehicle", "_groupCount", "_positionCount", "_result"];
	
	_group = _this select 0;
	_vehicle = _this select 1;
	
	_result = false;
	_groupCount = count units _group;
	_positionCount = [_vehicle] call arjay_vehicleEmptyPositions;
	
	if(_groupCount <= _positionCount) then
	{
		_result = true;
	};
	
	_result
};

/*
	Assign group to vehicle
*/
arjay_assignGroupToVehicle = 
{
	private ["_group", "_vehicle", "_orderIn", "_positionCount", "_units", "_assignments", "_leader", "_gunners", "_cargos", "_unit"];
	
	_group = _this select 0;
	_vehicle = _this select 1;
	_orderIn = if(count _this > 2) then {_this select 2} else {true};
	
	_positionCount = [_vehicle] call arjay_getEmptyVehiclePositions;
	_units = units _group;
	_assignments = [];
	_assignments set [0, []];
	_assignments set [1, []];
	_assignments set [2, []];
	_assignments set [3, []];
	_gunners = [];
	_cargos = [];

	if(count _units > 1) then 
	{
		
		_leader = leader _group;
		_units = _units - [_leader];
		
		// assign the leader as commander or cargo or gunner
		if(_positionCount select 2 > 0) then 
		{
			_leader assignAsCommander _vehicle;
			if(_orderIn) then { [_leader] orderGetIn true; };
			_assignments set [2, [_leader]];
		} else
		{
			// if there are more than 2 people in the group
			if(count _units > 1) then
			{
				_leader assignAsCargo _vehicle;
				if(_orderIn) then { [_leader] orderGetIn true; };
				_cargos set [0, _leader];
			}
			else
			{
				// if there are gunner positions available
				if(_positionCount select 1 > 0) then
				{
					_leader assignAsGunner _vehicle;
					if(_orderIn) then { [_leader] orderGetIn true; };
					_gunners set [0, _leader];
				}
				else
				{
					_leader assignAsCargo _vehicle;
					if(_orderIn) then { [_leader] orderGetIn true; };
					_cargos set [0, _leader];
				};				
			};			
		};
		
		// assign a unit as the driver		
		if(_positionCount select 0 > 0) then
		{
			_unit = _units call BIS_fnc_arrayPop;
			_unit assignAsDriver _vehicle;
			if(_orderIn) then { [_unit] orderGetIn true; };
			_assignments set [0, [_unit]];
		};
		
		// assign gunners	
		for "_i" from 1 to (_positionCount select 1) do 
		{
			if(count _units > 0) then
			{				
				_unit = _units call BIS_fnc_arrayPop;
				_unit assignAsGunner _vehicle;
				if(_orderIn) then { [_unit] orderGetIn true; };
				_gunners set [count _gunners, _unit];
			};			
		};
		_assignments set [1, _gunners];
		
		// assign cargo
		{
			_x assignAsCargo _vehicle;			
			if(_orderIn) then { [_x] orderGetIn true; };	
			_cargos set [count _cargos, _x];
		} forEach _units;		
		_assignments set [3, _cargos];
	}
	else
	{
		_unit = _units select 0;	
		_unit assignAsDriver _vehicle;	
		if(_orderIn) then { [_unit] orderGetIn true; };	
		_assignments set [0, [_unit]];
	};
	
	_assignments
};

/*
	Force group to vehicle
*/
arjay_forceGroupToVehicle = 
{
	private ["_assignments", "_vehicle", "_driver", "_gunners", "_commander", "_cargo"];
	
	_assignments = _this select 0;
	_vehicle = _this select 1;
	
	// driver
	_driver = _assignments select 0;
	
	{
		_x moveInDriver _vehicle;
	} forEach _driver;
	
	// gunner
	_gunners = _assignments select 1;
	
	{
		_x moveInGunner _vehicle;
	} forEach _gunners;
	
	// commander
	_commander = _assignments select 2;
	
	{
		_x moveInCommander _vehicle;
	} forEach _commander;
	
	// cargo
	_cargo = _assignments select 3;
	
	{
		_x moveInCargo _vehicle;
	} forEach _cargo;
};

/*
	Group Mount
*/
arjay_groupMountVehicle = 
{
	private ["_assignments", "_vehicle", "_gunnersDismount", "_driver", "_gunners", "_commander", "_cargo"];
	
	_assignments = _this select 0;
	_vehicle = _this select 1;
		
	// driver
	_driver = _assignments select 0;	
	{
		[_x] orderGetIn true;
	} forEach _driver;
	
	// gunner
	_gunners = _assignments select 1;
	{
		[_x] orderGetIn true;
	} forEach _gunners;
	
	// commander
	_commander = _assignments select 2;
	
	{
		[_x] orderGetIn true;
	} forEach _commander;
	
	// cargo
	_cargo = _assignments select 3;
	
	{
		[_x] orderGetIn true;
	} forEach _cargo;
};

/*
	Group Dismount
*/
arjay_groupDismountVehicle = 
{
	private ["_assignments", "_vehicle", "_gunnersDismount", "_driver", "_gunners", "_commander", "_cargo"];
	
	_assignments = _this select 0;
	_vehicle = _this select 1;
	_gunnersDismount = if(count _this > 2) then {_this select 2} else {true};
	
	// driver
	_driver = _assignments select 0;	
	{
		//unassignVehicle _x;
		[_x] orderGetIn false;
	} forEach _driver;
	
	// gunner
	if(_gunnersDismount) then
	{
		_gunners = _assignments select 1;
		{
			//unassignVehicle _x;
			[_x] orderGetIn false;
		} forEach _gunners;
	};
	
	// commander
	_commander = _assignments select 2;
	
	{
		//unassignVehicle _x;
		[_x] orderGetIn false;
	} forEach _commander;
	
	// cargo
	_cargo = _assignments select 3;
	
	{
		//unassignVehicle _x;
		[_x] orderGetIn false;
	} forEach _cargo;
};

/*
	Is a group in a vehicle
*/
arjay_isGroupInVehicle = 
{
	private ["_group", "_vehicle", "_result"];
	
	_group = _this select 0;
	_vehicle = _this select 1;
	
	_result = true;
	
	{
		if!(_x in _vehicle) then
		{
			_result = false;
		};
	} forEach units _group;
	
	_result
};