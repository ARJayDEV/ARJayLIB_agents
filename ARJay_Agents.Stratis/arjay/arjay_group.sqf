/*
	File: arjay_group.sqf
	Author: ARJay
	Description: Utility methods for groups
*/

/*
	Create a group type
*/
arjay_getGroupType = 
{
	private ["_preset", "_side", "_unitCount", "_leaderClass", "_unitClasses"];
	
	_preset = _this select 0;
	_side = _this select 1;
	
	switch(_preset) do
	{
		case "PILOT":
		{
			_unitCount = 1;
			switch(_side) do
			{
				case "EAST": { 
					_leaderClass = "O_Helipilot_F";
					_unitClasses = ["O_Helipilot_F"];					
				};
				case "WEST": { 
					_leaderClass = "B_Helipilot_F";
					_unitClasses = ["B_Helipilot_F"];
				};
			};
		};
		case "DIVER":
		{
			_unitCount = 2;
			switch(_side) do
			{
				case "EAST": { 
					_leaderClass = "O_diver_TL_F";
					_unitClasses = ["O_diver_F", "O_diver_exp_F"];					
				};
				case "WEST": { 
					_leaderClass = "B_diver_TL_F";
					_unitClasses = ["B_diver_F", "B_diver_exp_F"];
				};
			};
		};
		case "FIRETEAM":
		{
			_unitCount = 3;
			switch(_side) do
			{
				case "EAST": {
					_leaderClass = "O_Soldier_SL_F";
					_unitClasses = ["O_Soldier_F", "O_Soldier_AR_F", "O_Soldier_GL_F"];
				};
				case "WEST": {
					_leaderClass = "B_Soldier_SL_F";
					_unitClasses = ["B_Soldier_F", "B_Soldier_AR_F", "B_Soldier_GL_F"];
				};
			};
		};
		case "ENGINEER_TEAM":
		{
			_unitCount = 3;
			switch(_side) do
			{
				case "EAST": { 
					_leaderClass = "O_Soldier_SL_F";
					_unitClasses = ["O_soldier_repair_F", "O_soldier_exp_F", "O_soldier_exp_F"];
				};
				case "WEST": { 
					_leaderClass = "B_Soldier_SL_F";
					_unitClasses = ["B_soldier_repair_F", "B_soldier_exp_F", "B_soldier_exp_F"];
				};
			};
		};
		case "SQUAD":
		{
			_unitCount = 9;
			switch(_side) do
			{
				case "EAST": { 
					_leaderClass = "O_Soldier_TL_F";
					_unitClasses = [
					"O_Soldier_SL_F", "O_Soldier_SL_F", "O_medic_F", "O_Soldier_AR_F", "O_Soldier_AR_F", "O_Soldier_F", "O_Soldier_F", "O_Soldier_F", "O_Soldier_F"
					]; 
				};
				case "WEST": { 
					_leaderClass = "B_Soldier_TL_F";
					_unitClasses = [
					"B_Soldier_SL_F", "B_Soldier_SL_F", "B_medic_F", "B_Soldier_AR_F", "B_Soldier_AR_F", "B_Soldier_F", "B_Soldier_F", "B_Soldier_F", "B_Soldier_F"
					]; 
				};
			};
		};
		case "WEAPONS_SQUAD":
		{
			_unitCount = 9;
			switch(_side) do
			{
				case "EAST": { 
					_leaderClass = "O_Soldier_TL_F";
					_unitClasses = [
					"O_Soldier_SL_F", "O_Soldier_SL_F", "O_medic_F", "O_Soldier_AR_F", "O_Soldier_AR_F", "O_Soldier_F", "O_soldier_M_F", "O_Soldier_LAT_F", "O_Soldier_LAT_F"
					]; 
				};
				case "WEST": { 
					_leaderClass = "B_Soldier_TL_F";
					_unitClasses = [
					"B_Soldier_SL_F", "B_Soldier_SL_F", "B_medic_F", "B_Soldier_AR_F", "B_Soldier_AR_F", "B_Soldier_F", "B_soldier_M_F", "B_Soldier_LAT_F", "B_Soldier_LAT_F"
					]; 
				};
			};
		};
		case "PLATOON":
		{
			_unitCount = 29;
			switch(_side) do
			{
				case "EAST": { 
					_leaderClass = "O_Soldier_TL_F";
					_unitClasses = [
					"O_Soldier_SL_F", "O_Soldier_SL_F", "O_Soldier_SL_F", "O_Soldier_SL_F", "O_medic_F", "O_medic_F", "O_Soldier_AR_F", "O_Soldier_AR_F", "O_Soldier_AR_F", "O_Soldier_AR_F",
					"O_Soldier_F", "O_Soldier_F", "O_Soldier_F", "O_Soldier_F", "O_Soldier_F", "O_Soldier_F", "O_Soldier_F", "O_Soldier_F", "O_Soldier_F", "O_Soldier_F", "O_Soldier_F", "O_Soldier_F", "O_Soldier_F", "O_Soldier_F", "O_Soldier_F",
					"O_Soldier_LAT_F", "O_Soldier_LAT_F", "O_soldier_M_F", "O_soldier_M_F"
					]; 
				};
				case "WEST": { 
					_leaderClass = "B_Soldier_TL_F";
					_unitClasses = [
					"B_Soldier_SL_F", "B_Soldier_SL_F", "B_Soldier_SL_F", "B_Soldier_SL_F", "B_medic_F", "B_medic_F", "B_Soldier_AR_F", "B_Soldier_AR_F", "B_Soldier_AR_F", "B_Soldier_AR_F",
					"B_Soldier_F", "B_Soldier_F", "B_Soldier_F", "B_Soldier_F", "B_Soldier_F", "B_Soldier_F", "B_Soldier_F", "B_Soldier_F", "B_Soldier_F", "B_Soldier_F", "B_Soldier_F", "B_Soldier_F", "B_Soldier_F", "B_Soldier_F", "B_Soldier_F",
					"B_Soldier_LAT_F", "B_Soldier_LAT_F", "B_soldier_M_F", "B_soldier_M_F"
					]; 
				};
			};
		};
	};
	
	[_leaderClass, _unitCount, _unitClasses]
};

/*
	Return the number of alive units in a group
*/
arjay_countGroupAlive =
{
	private ["_group", "_count"];
	
	_group = _this select 0;
	
	_count = 0;	
	
	{
		if(alive _x) then {
			_count = _count + 1;
		};
	} forEach units _group;
	
	_count
};

/*
	Return the first alive group member
*/
arjay_getAliveGroupMember =
{
	private ["_group", "_unit"];
	
	_group = _this select 0;
	
	{
		if(alive _x) exitWith {
			_unit = _x;
		};
	} forEach units _group;
	
	_unit
};

/*
	Return if the group is all at unitReady state
*/
arjay_isGroupReady =
{
	private ["_group", "_result"];
	
	_group = _this select 0;
	
	_result = true;
	
	{
		if!(unitReady _x) then
		{
			_result = false;
		};
	} forEach units _group;
	
	_result
};