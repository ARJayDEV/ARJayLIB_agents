/*
   Author:
    rübe
    
   Description:
    spawns a building site for the desired building. 
   
   Parameter(s):
    _this: parameters (array of array [key (string), value (any)])
    
           - required:
           
             - "class" (string)
                class of the object that shall be build
               
             - "position" (position)
             - "direction" (integer)
             - "cost" (scalar; higher than 1!)
             
          - optional:
          
          	- "markers" (boolean)
          	  whether map markers shall be drawn/mentioned during the
          	  building process; default = true
          	  
          	  
          TODO:	  
            - "(final?)-marker" something... filled rect? or some symbol?
            
            - color?
          
          	- "label" (string OR code)
          	  final marker/label; given a string, we take that one as is,
          	  given code, we pass it the built obj as _this and it should
          	  return string for the label

    
   Returns:
    
*/

private ["_class", "_position", "_direction", "_cost", "_createMarkers", "_obj"];

_class = "";
_position = [];
_direction = 0;
_cost = 0;
_createMarkers = true;

// read parameters
{
   switch (_x select 0) do
   {
      case "class": { _class = _x select 1; };
      case "position": { _position = _x select 1; };
      case "direction": { _direction = _x select 1; };
      case "cost": { _cost = _x select 1; };
      case "markers": { _createMarkers = _x select 1; };
   };
} forEach _this;

_obj = objNull;

if (_class == "") exitWith { _obj };
if (count(_position) < 3) exitWith { _obj };
if (_cost < 1) exitWith { _obj };

private [
   "_objDim", "_objSize", "_objOffset", "_objRadius", 
   "_objHeightFrom", "_objHeightTo", "_totalHeight", "_heightPerSupply"
];

// create building 
_obj = _class createVehicle [-10000, -10000, 10000];
if (isNull _obj) exitWith { _obj };

// retrieve building dimensions
_objDim = _class call RUBE_getObjectDimensions;
_objSize = _objDim select 0;
_objOffset = _objDim select 1;

_objRadius = [
	((_objSize select 0) min (_objSize select 1)),
	((_objSize select 0) max (_objSize select 1))
];

// we will burry and then raise the building to simulate the
// building process...
_objHeightFrom = (0.25 + ((_obj call RUBE_boundingBoxSize) select 2)) * -1.07;
_objHeightTo = _position select 2;

_totalHeight = _objHeightTo - _objHeightFrom;
_heightPerSupply = _totalHeight / _cost;

_obj setdir _direction; 
_obj setPos [
	(_position select 0),
	(_position select 1),
	_objHeightFrom
];

// adjust position if there's an offset...
if (((_objOffset select 0) != 0) || ((_objOffset select 1) != 0)) then
{
	_position = [
		_position, 
		[
			((_objOffset select 0) * -1),
			((_objOffset select 1) * -1)
		], 
		_direction
	] call RUBE_gridOffsetPosition;
};

// setup building site (~according to structure size)
private [
	"_buildingSitePosition", "_arrow", "_actions", "_markers", "_objects",
	"_cutter", "_ruin", "_ruins", "_flags", "_fence",
	"_c", "_n", "_s", "_x", "_y", "_o", "_fobjects"
];

_buildingSitePosition = _position;
_o = objNull;
_objects = [];

_cutter = "";
_flags = true;
_fence = false;
_ruin = 0; // 0:none, 1:small, 2:medium, 3:large
_ruins = [];

switch (true) do
{
	// very small building site
	case ((_objRadius select 0) < 3): 
	{
		_cutter = "ClutterCutter_small_2_EP1"; // [2.6, 2.6]
	};
	//  small building site
	case ((_objRadius select 0) < 4): 
	{
		_cutter = "ClutterCutter_small_EP1"; // [4.0, 4.0]
		_ruin = 1;
	};
	// medium/large building site
	default
	{
		if ((_objRadius select 0) > 15) then
		{
			_cutter = "ClutterCutter_EP1"; // [19.9, 19.9]
			_ruin = 3;
		} else
		{
			_cutter = "ClutterCutter_small_EP1"; // [4.0, 4.0]
			_ruin = 2;
		};
		
		_fence = true;
	};
};

// no flags if we have a fence
if (_fence) then
{
	_flags = false;
};

// spawn cutter
if (_cutter != "") then
{
	_o = _cutter createVehicle _position;
	_o setdir _direction;
	_objects set [(count _objects), _o];
};

// spawn (corner-)flags
if (_flags) then
{
	_x = ((_objSize select 0) * 0.5) + (_objOffset select 0);
	_y = ((_objSize select 1) * 0.5) + (_objOffset select 1);
	
	{
		_objects set [(count _objects), _x];
	} foreach ([
		_position,
		_direction,
		[
			["FlagCarrierSmall", [_x, _y, 0], (random 360)],
			["FlagCarrierSmall", [_x, (_y * -1), 0], (random 360)],
			["FlagCarrierSmall", [(_x * -1), _y, 0], (random 360)],
			["FlagCarrierSmall", [(_x * -1), (_y * -1), 0], (random 360)]
		]
	] call RUBE_spawnObjects);
};

// configure ruins (to represent building materials and stuff...)
switch (_ruin) do
{
	case 1: 
	{
		// small ruins
		_ruins = [
			"Land_Ind_Workshop01_box_ruins",
			"Land_Majak_ruins",
			"Land_Dum_m2_ruins"
		];
	};
	case 2: 
	{
		// medium ruins
		_ruins = [
			"Land_Dulni_bs_ruins",
			"Land_domek_rosa_ruins",
			"Land_Statek_kulna_ruins",
			"Land_Sara_domek_sedy_ruins",
			"Land_hut06_ruins"
		];
	};
	case 3: 
	{
		// large ruins
		_ruins = [
			"Land_Sara_domek_zluty_ruins",
			"Land_AFbarabizna_ruins",
			"Land_dum01_ruins",
			"Land_Sara_domek_hospoda_ruins",
			"Land_Sara_domek_podhradi_1_ruins",
			"Land_leseni2x_ruins",
			"Land_zalchata_ruins"
		];
	};
};

// tmp. disable ruins
//_ruins = [];

// spawn ruins
if ((count _ruins) > 0) then
{
	_o = (_ruins call RUBE_randomSelect) createVehicle _position;
	_o setPos [(_position select 0), (_position select 1), (-0.1 - (random 0.5))];
	//_o setdir _direction;
	_o setdir (random 360);
	
	_objects set [(count _objects), _o];
};

// fence building site
if (_fence) then
{
	_fobjects = [
		[
			(_position select 0),
			(_position select 1),
			"center"
		],
		_direction,
		[
			((_objSize select 0) + 6.75),
			((_objSize select 1) + 6.75)
		],
		[3.25, 3.25],
		[
			"",
			["Sign_tape_redwhite", [0, 0.5, 0], 0],
			["Sign_tape_redwhite", [0.57, -0.6, 0], -45]
		]
	] call RUBE_spawnObjectGrid;
	
	_c = count _fobjects;
	_n = floor (_c * (0.3 + (random 0.3)));
	_s = floor (random _c);
			
	// open fence by deleting some pieces again...
	for "_i" from 0 to _c do
	{
		_j = (_s + _i) % _c;
		if (_i < _n) then
		{
			// ...which is also a good spot for our action-arrow
			_buildingSitePosition = position (_fobjects select _j);
			deleteVehicle (_fobjects select _j);
		} else
		{
			_objects set [(count _objects), (_fobjects select _j)];
		};
	};
};


// create map marker
_markers = [];
if (_createMarkers) then
{
	// building site area
	_markers set [0, ([
		["position", _position],
		["direction", _direction],
		["type", "RECTANGLE"],
		["size", [(_objSize select 0) * 0.5, (_objSize select 1) * 0.5]],
		["color", "ColorBlue"],
		["brush", "BORDER"]
	] call RUBE_mapDrawMarker)];
	// progress label
	_markers set [1, ([
		["position", _position],
		["type", "mil_dot"],
		["size", 0.3],
		["color", "ColorYellow"],
		["text", format["0/%1", _cost]]
	] call RUBE_mapDrawMarker)];
};


// create building site action-arrow
_arrow = "Sign_arrow_down_large_EP1" createVehicle _buildingSitePosition;
_arrow setdir _direction;
_arrow setPos _buildingSitePosition;


// add actions
_actions = [
	// make buildable
	([
		["object", _arrow],
		["title", format[RUBE_STR_buildDropAction, (_obj call RUBE_makeBuildableName)]],
		["hideOnUse", false],
		["callback", RUBE_makeBuildableStart], // (see fn_makeBuildableLib.sqf)
		["condition", "true"]
	] call RUBE_addAction),
	// make abortable (destroy building site)
	([
		["object", _arrow],
		["title", format[RUBE_STR_buildAbortAction, (_obj call RUBE_makeBuildableName)]],
		["hideOnUse", true],
		["callback", RUBE_makeBuildableAbort], // (see fn_makeBuildableLib.sqf)
		["condition", "true"]
	] call RUBE_addAction)
];


// register building site
/*
	all we need for our building site is stored in our action-arrow object
*/
_arrow setVariable ["RUBE_BS_structure", _obj, true]; 
_arrow setVariable ["RUBE_BS_radius", (_objRadius select 0), true];
_arrow setVariable ["RUBE_BS_markers", _markers, true];
_arrow setVariable ["RUBE_BS_actions", _actions, true];
_arrow setVariable ["RUBE_BS_objects", _objects, true]; 

_arrow setVariable ["RUBE_BS_consumed", 0, true];
_arrow setVariable ["RUBE_BS_cost", _cost, true];
_arrow setVariable ["RUBE_BS_heightBase", _objHeightFrom, true];
_arrow setVariable ["RUBE_BS_height", _objHeightTo, true];
_arrow setVariable ["RUBE_BS_heightPerSupply", _heightPerSupply, true];

_arrow setVariable ["RUBE_BS_workers", [], true]; 