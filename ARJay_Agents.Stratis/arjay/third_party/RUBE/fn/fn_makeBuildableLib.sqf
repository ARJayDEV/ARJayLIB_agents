/*
   Author:
    rübe
    
   Description:
    buildables function library 

    
   TODO:
   -----
   
    - markers (color, type, label) in progress and after beeing finished.
    - how to get the COIN-interface? (option shall not be always in the
      list of actions... activate per radio call, maybe?)
    - where do we put finished buildings?
    
    - SELL & REPAIR buildings.
    
*/



/*
	buildable globals
	- feel free to overwrite these after RUBE_init as desired
*/

// how much supplies someone can carry while building(!, no full load).
//  - the lower this value, the more walking back and forth... (slower)
//  - will be slightly randomized each time...
RUBE_makeBuildableCarryCapacity = 20; // kg

// ... and the time needed to "use" one supply
//  - again slightly randomized after each use
RUBE_makeBuildableSupplyDelay = 1.5; // s

// radius, defining the area in which the AI will auto
// take supplies lying around...
RUBE_makeBuildableAISupplyScanRadius = 100; // m



/*
	functions and callbacks
*/

// object name string [obj -> string]
RUBE_makeBuildableName = {
   (getText (configFile >> "CfgVehicles" >> (typeOf _this) >> "displayName"))
};

// clean up building site [ [arrow, (delete?)] -> void]
RUBE_makeBuildableCleanUp = {
	private ["_arrow", "_delete"];
	
	_arrow = _this select 0;
	_delete = false;
	if ((count _this) > 1) then
	{
		_delete = _this select 1;
	};
	
	// delete markers
	{
		deleteMarker _x;
	} forEach (_arrow getVariable "RUBE_BS_markers");
	
	// delete building site objects
	{
		deleteVehicle _x;
	} forEach (_arrow getVariable "RUBE_BS_objects");
	
	// delete structure
	if (_delete) then
	{
		deleteVehicle (_arrow getVariable "RUBE_BS_structure");
	};
	
	// remove actions
	{
		[_arrow, _x] call RUBE_removeAction;
	} forEach (_arrow getVariable "RUBE_BS_actions");	
	
	// delete arrow
	deleteVehicle _arrow;
};

/*
   drop/consume object/supplies, build callback:
   
      _this select 0: target (object) - the object which the action is assigned to 
      _this select 1: caller (object) - the unit that activated the action 
      _this select 2: action-id (integer) - ID of the activated action 
      _this select 3: arguments
*/
RUBE_makeBuildableStart = {
   private ["_buildingSiteObject", "_unit", "_suppliesObj"];
   
   _buildingSiteObject = _this select 0;
   _unit = _this select 1;
   //_suppliesObj = _unit getVariable "RUBE_attachObj";

   _unit doFSM ["RUBE\ai\doBuildStructure.fsm", (position _buildingSiteObject), _buildingSiteObject];
};


/*
	stop AI from building
*/
RUBE_makeBuildableAbortAI = {
	(_this select 0) setVariable ["RUBE_abortAction", true, true];	
};




/*
	abort construction/destroy building site
*/
RUBE_makeBuildableAbort = {
	private ["_workers"];
	_workers = (_this select 0) getVariable "RUBE_BS_workers";
	if (isnil "_workers") exitWith {};
	if ((typeName _workers) != "ARRAY") exitWith {};
	
	// cant delete aslong as there are still workers working on it...
	if ((count _workers) > 0) exitWith {};
	
	[
		(_this select 0),
		true
	] call RUBE_makeBuildableCleanUp;
};
