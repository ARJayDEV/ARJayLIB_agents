/*
   Author:
    rübe
    
   Description:
    supplies definitions and function library

   used variables on supply-objects:
    - RUBE_supplies (amount)
    - RUBE_capacity (max. supplies)
*/

RUBE_suppliesUnit = "kg";

// capacity table for supply objects
//  (feel free to modify this table as needed, better yet; copy the definition 
//   here and overwrite RUBE_suppliesGetCapacity after you loaded the RUBE
//   library, so you can use future version of the RUBE library while your
//   changes to this table will be still intact...)
RUBE_suppliesGetCapacity = {
	private ["_capacity"];
	
	_capacity = 0;
	
	switch (_this) do
	{
		// TINY: sacks, bags, ...
		case "Land_Sack_EP1": 					{ _capacity = 10; };
		case "Land_Bag_EP1": 					{ _capacity = 20; };
		case "Land_Canister_EP1": 				{ _capacity = 20; };
		case "Land_Crates_EP1": 				{ _capacity = 30; };
		case "Land_Wicker_basket_EP1": 		{ _capacity = 35; };
		
		// MEDIUM: barrels, ...
		//case "Land_Barrel_empty": 				{ _capacity = 0; };
		case "Land_Barrel_sand": 				{ _capacity = 100; };
		//case "Land_Barrel_water": 				{ _capacity = 0; };
		case "Barrel1": 							{ _capacity = 159; };
		case "Barrel4": 							{ _capacity = 159; };
		case "Barrel5": 							{ _capacity = 159; };
		
		// BIG: crates, ...	
		case "Fort_Crate_wood": 				{ _capacity = 195; };
		case "Land_Reservoir_EP1": 			{ _capacity = 200; };
		case "Land_Crates_stack_EP1": 		{ _capacity = 260; };
		case "Barrels": 							{ _capacity = 636; };
		case "Land_transport_crates_EP1": 	{ _capacity = 850; };
		case "Misc_cargo_cont_tiny": 			{ _capacity = 1005; };
		case "Misc_cargo_cont_net1": 			{ _capacity = 1005; };
		case "Misc_cargo_cont_net2": 			{ _capacity = 2005; };
		case "Misc_cargo_cont_net3": 			{ _capacity = 3005; };
		case "Misc_cargo_cont_small": 		{ _capacity = 4005; };
		case "Misc_cargo_cont_small2": 		{ _capacity = 5005; };
	};
	
	_capacity
};


/*
	allocate supplies to an object 
	 (init, can only be run once on a given object)
*/
// [obj, (s-factor)] => void
RUBE_suppliesAllocate = {
	private ["_obj", "_supplies", "_capacity"];
	
	_obj = _this select 0;
	_supplies = _obj getVariable "RUBE_suppliesId";
	
	// supplies already allocated 
	if (!(isnil "_supplies")) exitWith {};
	
	if ((count _this) > 1) then
	{
		_supplies = _this select 1;
	} else
	{
		_supplies = 1.0;	
	};
	
	_capacity = (typeOf _obj) call RUBE_suppliesGetCapacity;
	if (_capacity > 0) then
	{
		_obj setVariable ["RUBE_capacity", _capacity, true];
		_obj setVariable ["RUBE_supplies", (floor (_capacity * _supplies)), true];
	};
	
	// attach supply actions
	_obj setVariable [
		"RUBE_suppliesId",
		([
			["object", _obj],
			["title", format[RUBE_STR_suppliesInspect, (_obj call RUBE_makeDraggableName)]],
			["hideOnUse", false],
			["callback", {
            _this execVM "RUBE\dialogs\dlg_suppliesInspect.sqf";
            true
			}],
			["condition", "((_this distance _target) < 3)"]
		] call RUBE_addAction),
		true
	];
};
