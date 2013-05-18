/*
   Author:
    rübe
    
   Description:
    draggables/droppables function library

*/

// object name string [obj -> string]
RUBE_makeDraggableName = {
	(getText (configFile >> "CfgVehicles" >> (typeOf _this) >> "displayName"))
};



// per object z-offset to correct wrong models (wrong ground/floor LODs or something..)
// class-string => scalar
RUBE_makeDraggableZOffset = {
	private ["_z"];
   _z = 0;
   
   switch (_this) do
   {
      // ammo crates
      case "AmmoCrates_NoInteractive_Medium":   { _z = 0.75; };
      case "AmmoCrates_NoInteractive_Small":    { _z = 0.55; };
      case "GERBasicWeapons_EP1":               { _z = 0.75; }; 
      case "USBasicAmmunitionBox":              { _z = -0.24; };
      case "USBasicAmmunitionBox_EP1":          { _z = -0.24; }; 
      case "USBasicWeaponsBox":                 { _z = 0.75; };
      case "USBasicWeapons_EP1":                { _z = 0.75; };
      case "USLaunchersBox":                    { _z = 0.55; };
      case "USLaunchers_EP1":                   { _z = 0.55; };  
      case "USOrdnanceBox":                     { _z = 0.55; };
      case "USOrdnanceBox_EP1":                 { _z = 0.55; };
      case "USSpecialWeaponsBox":               { _z = 0.75; };
      case "USSpecialWeapons_EP1":              { _z = 0.75; };
      case "RUBasicWeaponsBox":                 { _z = 0.3; };
      case "TKBasicWeapons_EP1":                { _z = 0.3; };
      case "RULaunchersBox":                    { _z = 0.2; };
      case "TKLaunchers_EP1":                   { _z = 0.2; };
      case "UNBasicAmmunitionBox_EP1":          { _z = 0.2; };
      case "GuerillaCacheBox":                  { _z = 0.15; };
      case "GuerillaCacheBox_EP1":              { _z = 0.15; };
      
      // objects/supplies
      case "Misc_cargo_cont_tiny":              { _z = 0.23; };
      case "Misc_cargo_cont_small2":            { _z = 0.39; };
      
      case "Misc_cargo_cont_net1":              { _z = 0.32; };
      case "Misc_cargo_cont_net2":              { _z = 0.32; };
      case "Misc_cargo_cont_net3":              { _z = 0.48; };
       
      case "Land_Ind_BoardsPack1":              { _z = 0.40; };
      case "Land_Ind_BoardsPack2":              { _z = 0.23; };
      
      case "Land_transport_crates_EP1":         { _z = 0.21; };
      case "Barrels":                           { _z = 0.16; };
      
      // static weapons
      case "2b14_82mm":                         { _z = 0.21; };
      case "2b14_82mm_CDF":                     { _z = 0.21; };
      case "2b14_82mm_GUE":                     { _z = 0.21; };
      case "2b14_82mm_INS":                     { _z = 0.21; };
      case "2b14_82mm_TK_EP1":                  { _z = 0.21; };
      case "2b14_82mm_TK_GUE_EP1":              { _z = 0.21; };
      case "2b14_82mm_TK_INS_EP1":              { _z = 0.21; };
      
      case "AGS_CDF":                           { _z = 0.67; };
      case "AGS_Ins":                           { _z = 0.67; };
      case "AGS_RU":                            { _z = 0.67; };
      case "AGS_TK_EP1":                        { _z = 0.67; };
      case "AGS_TK_INS_EP1":                    { _z = 0.67; };
      case "AGS_TK_GUE_EP1":                    { _z = 0.67; };
      case "AGS_UN_EP1":                        { _z = 0.67; };
      
      case "DSHKM_CDF":                         { _z = 1.11; };
      case "DSHKM_Gue":                         { _z = 1.11; };
      case "DSHKM_Ins":                         { _z = 1.11; };
      case "DSHKM_TK_GUE_EP1":                  { _z = 1.11; };
      case "DSHKM_TK_INS_EP1":                  { _z = 1.11; };
      
      case "DSHkM_Mini_TriPod":                 { _z = 0.54; };
      case "DSHkM_Mini_TriPod_CDF":             { _z = 0.54; };
      case "DSHkM_Mini_TriPod_TK_GUE_EP1":      { _z = 0.54; };
      case "DSHkM_Mini_TriPod_TK_INS_EP1":      { _z = 0.54; };
      
      case "Igla_AA_pod_East":                  { _z = 1.22; };
      case "Igla_AA_pod_TK_EP1":                { _z = 1.22; };
      
      case "KORD":                              { _z = 0.63; };
      case "KORD_TK_EP1":                       { _z = 0.63; };
      case "KORD_UN_EP1":                       { _z = 0.63; };
      
      case "KORD_high":                         { _z = 1.03; };
      case "KORD_high_TK_EP1":                  { _z = 1.03; };
      case "KORD_high_UN_EP1":                  { _z = 1.03; };
      
      case "M252":                              { _z = 0.28; };
      case "M252_US_EP1":                       { _z = 0.28; };
      
      case "M2HD_mini_TriPod":                  { _z = 0.49; };
      case "M2HD_mini_TriPod_US_EP1":           { _z = 0.49; };
      
      case "M2StaticMG":                        { _z = 0.67; };
      case "M2StaticMG_US_EP1":                 { _z = 0.67; };

      case "MK19_TriPod":                       { _z = 0.55; };
      case "MK19_TriPod_US_EP1":                { _z = 0.55; };
      
      case "Metis":                             { _z = 0.59; };
      case "Metis_TK_EP1":                      { _z = 0.59; };
      
      case "SPG9_CDF":                          { _z = -0.41; };
      case "SPG9_Gue":                          { _z = -0.41; };
      case "SPG9_Ins":                          { _z = -0.41; };
      case "SPG9_TK_GUE_EP1":                   { _z = -0.41; };
      case "SPG9_TK_INS_EP1":                   { _z = -0.41; };

      case "SearchLight":                       { _z = -0.39; };
      case "SearchLight_CDF":                   { _z = -0.39; };
      case "SearchLight_Gue":                   { _z = -0.39; };
      case "SearchLight_INS":                   { _z = -0.39; };
      case "SearchLight_RUS":                   { _z = -0.39; };
      case "SearchLight_TK_EP1":                { _z = -0.39; };
      case "SearchLight_TK_GUE_EP1":            { _z = -0.39; };
      case "SearchLight_TK_INS_EP1":            { _z = -0.39; };
      case "SearchLight_UN_EP1":                { _z = -0.39; };
      case "SearchLight_US_EP1":                { _z = -0.39; };
      
      case "Stinger_Pod":                       { _z = 0.78; };
      case "Stinger_Pod_US_EP1":                { _z = 0.78; };
      
      case "TOW_TriPod":                        { _z = 0.65; };
      case "TOW_TriPod_US_EP1":                 { _z = 0.65; };
      
      // boats
   	case "Zodiac": 									{ _z = 0.6; };
   	case "PBX": 										{ _z = 0.85; };
   	case "Smallboat_1":					 			{ _z = 0.85; };
   	case "Smallboat_1": 								{ _z = 0.85; };
   	case "RHIB":					 					{ _z = 2.95; };
   	case "RHIB2Turret": 								{ _z = 2.95; };
   	case "SeaFox": 									{ _z = 3.15; };
   	case "SeaFox_EP1": 								{ _z = 3.15; };
   };
   
   _z
};

// drop draggable (object object) onto droppable
//  the draggable object the unit is currently dragging
//  is saved on the unit in the variable "RUBE_attachObj"
// [droppable/vehicle, unit] => int
//
// alternative syntax (to drop without dragging unit):
// [droppable/vehicle, [object]] => int
//
// returns (count _result), so 0: nothing packed, n: n packed
RUBE_makeDroppableDrop = {
   /*
      _this select 0: target (object) - the object which the action is assigned to 
      _this select 1: caller (object) - the unit that activated the action 
      _this select 2: action-id (integer) - ID of the activated action 
      _this select 3: arguments      
   */
   private ["_veh", "_unit", "_obj", "_noUnit", "_n"];
   
   _veh = _this select 0;
   _unit = _this select 1;
   
   _obj = objNull;
   _noUnit = false;
   
   if ((typeName _unit) == "ARRAY") then
   {
      _obj = _unit select 0;
      _noUnit = true;
   } else
   {
      _obj = _unit getVariable "RUBE_attachObj";
   };
   
   if (isnil "_obj") exitWith {};
   if (isNull _obj) exitWith {};
   
   // stop dragging
   if (!_noUnit) then
   {
      _obj setVariable ["RUBE_forcedRelease", true, true];
      waitUntil{!([_obj, "RUBE_forcedRelease"] call RUBE_isTrue)};
   };

   // rectangle packer
   _result = [
      ["vehicle", _veh],
      ["objects", [_obj]]
   ] call RUBE_packVehicle;
   
   _n = count _result;

   /*
   switch (_n) do
   {
      case 0:
      {
         // error, nothing packed at all
      };
      case 1:
      {
         // full success, everything packed 
      };
      case 2:
      {
         // coudn't pack everything (...which is exactly nothing, 
         // since we passed only one new object to be packed)
      };
   };
   */

   // return (count _result)
   _n
};


// unloads all cargo from a droppable
// [droppable, unit] => void
RUBE_makeDroppableUnloadAll = {
   private ["_veh", "_unit"];
   
   _veh = _this select 0;
   _unit = _this select 1;
   
   //[_veh, _unit] execFSM "RUBE\ai\ai_unloadAllCargo.fsm";
   // we use lowlevel commandFSM so the unit is "occupied" while unloading..
   [_unit] commandFSM ["RUBE\ai\ai_unloadAllCargo.fsm", (position _veh), _veh];
};


// nicer from droppable to droppable function to be used by scripters
// [unit, droppable-source, droppable-target] => void
RUBE_makeDroppableLoadFromTo = {
   private ["_unit", "_src", "_tgt"];
   _unit = _this select 0;
   _src = _this select 1;
   _tgt = _this select 2;
   
   [_src, _unit] call RUBE_makeDroppableUnloadAllFrom;
   [_tgt, _unit] call RUBE_makeDroppableUnloadAllTo;
};


// selects/sets an unload source (so load to can be issued)
// [droppable, unit] => void
RUBE_makeDroppableUnloadAllFrom = {
   private ["_veh", "_unit", "_group"];
   
   _veh = _this select 0;
   _unit = _this select 1;
   _group = group _unit;
   // we save the same unload-source for the whole group
   
   _group setVariable ["RUBE_unloadSource", _veh, true];
   true
};


// selects/sets an unload target; (source needs to be set first)
// [droppable, unit] => void
RUBE_makeDroppableUnloadAllTo = {
   private ["_veh", "_unit", "_group", "_src", "_cargo"];
   
   _veh = _this select 0;
   _unit = _this select 1;
   _group = group _unit;
   
   _src = _group getVariable "RUBE_unloadSource";
   _cargo = _src getVariable "RUBE_vehObjCargo";
   
   if ((typeName _cargo) == "ARRAY") then
   {
      _unit setVariable ["RUBE_unloadTarget", _veh, true];
      [_unit] commandFSM ["RUBE\ai\ai_unloadAllCargo.fsm", (position _src), _src];
      
      // unload observer (deselect if the job is done)
      [_group, _cargo] spawn {
         private ["_group", "_src", "_cargo", "_t"];
         _group = _this select 0;
         _src = _group getVariable "RUBE_unloadSource";
         _cargo = _this select 1;
         
         _t = time;
         
         while {(_src == (_group getVariable "RUBE_unloadSource"))} do
         {
            if ((count _cargo) == 0) exitWith 
            {
               _group setVariable ["RUBE_unloadSource", nil, true];
            };
            if ((time - _t) > 360) exitWith {};
            sleep 3 + (random 2);
         };
      };
   };
};


// checks if a valid unload source has been selected
// [dropable, unit] => boolean
RUBE_makeDroppableCanUnloadTo = {
   private ["_veh", "_unit", "_group", "_src", "_cargo"];
   
   _veh = _this select 0;
   _unit = _this select 1;
   _group = group _unit;
   
   _src = _group getVariable "RUBE_unloadSource";
   if (isnil "_src") exitWith { false };
   
   _cargo = _src getVariable "RUBE_vehObjCargo";
   if (isnil "_cargo") exitWith { false };
   if ((typeName _cargo) != "ARRAY") exitWith { false };
   
   true
};


// attach object to unit
// randomizes the way (pos/rotation) an object gets attached to a unit 
// [_obj, _unit] => void
RUBE_makeDraggableAttach = {
   private [
      "_obj", "_unit", "_class", "_dist", "_dir", "_pos", "_droppable", "_cargo",
      "_matrix", "_a", "_b"
   ];
   
   _obj = _this select 0;
   _unit = _this select 1;
   _class = typeOf _obj;
   
   _dist = [
      _obj, 
      "RUBE_attachDist", 
      {
         private ["_dim", "_a", "_b", "_dist", "_weight"];
         _dist = 1;
         _dim = _class call RUBE_getObjectDimensions;
         
         _a = (((_dim select 0) select 0) min ((_dim select 0) select 1));
         _b = (((_dim select 0) select 0) max ((_dim select 0) select 1));
         
         // some pseudo-weight as factor will do... (used for particles)
         _weight = _a * _b;
         if (_weight > 1) then
         {
            _weight = 1 + (ln (_weight * 2));
         };
         
         // save object dimensions for later usage
         //_this setVariable ["RUBE_objectSize", (_dim select 0)];
         //_this setVariable ["RUBE_objectOffset", (_dim select 1)];
         _this setVariable ["RUBE_objectSizeMin", _a, true];
         _this setVariable ["RUBE_objectSizeMax", _b, true];
         _this setVariable ["RUBE_objectWeight", _weight, true];
         
         // we can't take the min-width if the differences are too large!
         // hmmm... yes we can :/
         /*
         if ((_a / _b) < 0.6) then
         {
            _dist = (_a + _b) * 0.78;
         } else
         {
            _dist = _a;
         };
         */
         _dist = _a;
         
         if (_dist < 1.3) then
         {
            _dist = 1.3;
         };
         
         _dist
      }
   ] call RUBE_initVariable;
   
   _a = ((_obj getVariable "RUBE_objectSizeMin") * 0.5) + 0.45;
   _b = _obj getVariable "RUBE_objectSizeMax";
   
   _matrix = [
      _obj, 
      "RUBE_attachMatrix", 
      // [0:x, 1:y, 2:z, 3:x-min, 4:x-max, 5:y-min, 6:y-max, 7:rotation]
      [
         // x, y, z
         ((_dist * (random 0.3)) - (_dist * (random 0.6))),
         _dist,
         (0.5 + (_class call RUBE_makeDraggableZOffset)),
         // x-min, x-max
         (_b * -0.61),
         (_b * 0.61),
         // y-min, y-max
         _a,
         (_a + ((1.24 +_b) * 0.5)),
         // rotation
         ((direction _obj) - (direction _unit))
      ] 
   ] call RUBE_initVariable;

   // make sure we remove that object from a droppable's list
   // in case it got packed previously...
   _droppable = _obj getVariable "RUBE_cargoObj";
   
   if ((typeName _droppable) == "OBJECT") then
   {
      if (!(isNull _droppable)) then
      {
         _cargo = _droppable getVariable "RUBE_vehObjCargo";
         if ((typeName _cargo) == "ARRAY") then
         {
            _cargo = _cargo - [_obj];
            _droppable setVariable ["RUBE_vehObjCargo", _cargo, true];
            
            // make sure we don't damage the droppable (probably a weak car, hehe)
            // while unloading...
            _dir = [_droppable, _unit] call BIS_fnc_dirTo;
            _pos = [_unit, (_dist + 0.3), _dir] call BIS_fnc_relPos;
            _unit playAction "crouch";
            
            _unit setPos _pos;
         };
         
         _obj setVariable ["RUBE_cargoObj", objNull, true];
      };
   };

   [_obj, _unit] call RUBE_makeDraggableAttachPosition;

   // precision functionality for players
   //  (SHIFT + mouseMoveing == rotation of object)
   //  (CTRL  + mouseMoveing == attachTo position offset of object; limited) 
   if (_unit == player) then
   {
      // RUBE_inputListeners
      private ["_inputListeners"];
      _inputListeners = [
         ([
            ["handlerName", "KeyDown"],
            ["code", {
               player setVariable ["RUBE_shift", ((_this select 1) select 2), true];
               player setVariable ["RUBE_ctrl", ((_this select 1) select 3), true];
               false
            }]
         ] call RUBE_addInputListener),
         ([
            ["handlerName", "KeyUp"],
            ["code", {
               player setVariable ["RUBE_shift", false, true];
               player setVariable ["RUBE_ctrl", false, true];
               false
            }]
         ] call RUBE_addInputListener),
         ([
            ["handlerName", "MouseMoving"],
            ["code", {
               private ["_obj", "_x", "_xs", "_y", "_ys", "_matrix", "_nx", "_ny", "_dir"];
               if ([player, "RUBE_ctrl"] call RUBE_isTrue) exitWith
               {
                  _obj = player getVariable "RUBE_attachObj";
                  _x = abs ((_this select 1) select 1);
                  _xs = 0.03;
                  if (((_this select 1) select 1) < 0) then { _xs = -0.03; };       
                  if (_x > 1) then { _x = 1 + (ln _x); };
                  
                  _y = abs ((_this select 1) select 2);
                  _ys = 0.05;
                  if (((_this select 1) select 2) < 0) then { _ys = -0.05; };
                  if (_y > 1) then { _y = 1 + (ln _y); };
                  
                  // [0:x, 1:y, 2:z, 3:x-min, 4:x-max, 5:y-min, 6:y-max, 7:rotation]
                  _matrix = _obj getVariable "RUBE_attachMatrix";
                  
                  _nx = ((_matrix select 0) + (_x * _xs));
                  if ((_nx > (_matrix select 3)) && (_nx < (_matrix select 4))) then
                  {
                     _matrix set [
                        0,
                        _nx
                     ];
                  };
                  
                  _ny = ((_matrix select 1) - (_y * _ys));
                  if ((_ny > (_matrix select 5)) && (_ny < (_matrix select 6))) then
                  {
                     _matrix set [
                        1,
                        _ny
                     ];
                  };
                  
                  [_obj, player] call RUBE_makeDraggableAttachPosition;
                  true
               };
               if ([player, "RUBE_shift"] call RUBE_isTrue) exitWith
               {
                  _obj = player getVariable "RUBE_attachObj";
                  _x = abs ((_this select 1) select 1);
                  _xs = 1;
                  if (((_this select 1) select 1) < 0) then { _xs = -1; };
                  if (_x > 1) then { _x = 1 + (ln (_x * 2)); };
                  
                  _x = _x * 1.3;
                                    
                  _matrix = _obj getVariable "RUBE_attachMatrix";
                  _matrix set [
                     7,
                     ((_matrix select 7) + (_x * _xs))
                  ];
                  
                  _dir = direction player;
                  
                  [_obj, player] call RUBE_makeDraggableAttachRotation;
                  
                  player setDir (_dir - (_x * _xs));
                  true
               };
               false
            }]
         ] call RUBE_addInputListener)
      ];
      
      player setVariable ["RUBE_inputListeners", _inputListeners, true];
   };
};

// attach or adjust attachment position
// [_obj, _unit] => void
RUBE_makeDraggableAttachPosition = {
   private ["_obj", "_unit", "_matrix"];
   
   _obj = _this select 0;
   _unit = _this select 1;
   
   _matrix = _obj getVariable "RUBE_attachMatrix";
   
   _obj attachTo [
      _unit,
      [
         (_matrix select 0), 
         (_matrix select 1),
         (_matrix select 2)
      ]
   ];

   _obj setDir (_matrix select 7);
   if ((random 1.0) > 0.82) then
   {
      _obj spawn RUBE_makeDraggableParticles;
   };
};

// adjust attachment rotation
// [_obj, _unit] => void
RUBE_makeDraggableAttachRotation = {
   private ["_obj", "_unit", "_matrix"];
   
   _obj = _this select 0;
   _unit = _this select 1;
   
   _matrix = _obj getVariable "RUBE_attachMatrix";
   
   _obj setDir (_matrix select 7);
   if ((random 1.0) > 0.89) then
   {
      _obj spawn RUBE_makeDraggableParticles;
   };
};


// object => void (spawn)
RUBE_makeDraggableParticles = {
   private ["_particles", "_maxParticles", "_i"];
   _particles = [];
   _maxParticles = floor (random (_this getVariable "RUBE_objectWeight"));
   for "_i" from 0 to _maxParticles do
   {
      {
         _particles set [(count _particles), _x];
      } forEach ([_this] call RUBE_PE_DragObj);
   };
   sleep (0.3 + (random 1.7));
   // delete particles
   {
      deleteVehicle _x;
      sleep 0.005;
   } forEach _particles;
};


/*
   start dragging object callback:
   
      _this select 0: target (object) - the object which the action is assigned to 
      _this select 1: caller (object) - the unit that activated the action 
      _this select 2: action-id (integer) - ID of the activated action 
      _this select 3: arguments
*/
RUBE_makeDraggableStart = {
   private ["_unit", "_obj", "_id", "_dim", "_veh", "_cargo"];
   
   _obj = _this select 0;
   _unit = _this select 1;  
   _id = _obj getVariable "RUBE_draggableId";  
   
   if ((count _this) > 2) then
   {
      _id = _this select 2;
   };
   
   // check that object (static weapon?) is not manned
   if ((count (crew _obj)) > 0) exitWith {};
   
   // a unit can only drag one object at a time...
   if (!(isNull (_unit getVariable "RUBE_attachObj"))) exitWith {};
   
   // remove drag action
   [_obj, _id] call RUBE_removeAction;

   // attach object
   [_obj, _unit] call RUBE_makeDraggableAttach;
   
   // lock (vehicle?)
   _obj lock true;

   // remove from cargo if obj was attached to a droppable vehicle
   if ([_obj, "RUBE_cargoObj"] call RUBE_isObject) then
   {
      _veh = _obj getVariable "RUBE_cargoObj";
      _cargo = _veh getVariable "RUBE_vehObjCargo";
      _cargo = _cargo - [_obj];
      _veh setVariable ["RUBE_vehObjCargo", _cargo, true];
      
      _obj setVariable ["RUBE_cargoObj", objNull, true];
   };

   // add release action
   _id = [
      ["object", _unit],
      ["title", format[RUBE_STR_ReleaseAction, (_obj call RUBE_makeDraggableName)]],
      ["hideOnUse", true],
      ["callback", RUBE_makeDraggableRelease],
      ["condition", "_this == _target"]
   ] call RUBE_addAction;
   
   // flag obj/unit...
   _obj setVariable ["RUBE_attachedTo", _unit, true];
   
   _unit setVariable ["RUBE_attachObj", _obj, true];
   _unit setVariable ["RUBE_attachId", _id, true];
   
   // ... start draggable observer (limit speed!)
   [_obj, _unit, _id] spawn 
   {
      private ["_obj", "_unit", "_id", "_particles", "_maxParticles", "_vel", "_limit", "_speed"];
      _obj = _this select 0;
      _unit = _this select 1;
      _id = _this select 2;
      _particles = [];
      _maxParticles = ceil (2 + (_obj getVariable "RUBE_objectWeight"));

      if (_unit != player) then
      {
         //_unit setUnitPos "Middle";    // DONT: units without main weapon will be blocked otherwise!
         _unit forceWalk true;
      };
      
      _unit forceSpeed 2.0;
      _unit action ["WEAPONONBACK", _unit];
      
      // dragging loop
      while {!(isNull (_unit getVariable "RUBE_attachObj"))} do
      {
         // forced release object (death or in a vehicle)
         if (!(alive _unit) || 
             (_unit != (vehicle _unit)) ||
             ([_obj, "RUBE_forcedRelease"] call RUBE_isTrue)
            ) exitWith 
         {
            [_unit, _unit, _id] spawn RUBE_makeDraggableRelease;
         };
         
         // slightly randomized speed limit (for natural breaks)
         _limit = 11 + (random 17);
         if ((random 1.0) > 0.5) then
         {
            _limit = _limit + 5;
         };
         
         // walking/dragging
         _speed = _unit call BIS_fnc_absSpeed;
         if (_speed > 1.0) then
         { 
            // particles
            if ((count _particles) < _maxParticles) then
            {
               {
                  _particles set [(count _particles), _x];
               } forEach ([_obj] call RUBE_PE_DragObj);
            };
            
            // force limit speed
            // :: the plan is that you may only drag stuff safely*
            //    while crouched and going backwards, pulling the 
            //    object. Go too fast (up/forward) and you might 
            //    injure yourself.
            if (_speed > _limit) then
            {
               _vel = velocity _unit;

               switch (true) do
               {
                  // stumble and forced release if we're way toooo fast, HAHAHA :)
                  case ((_speed * (0.54 + (random 0.3))) > _limit):
                  {
                     _unit switchMove "ActsPercMrunSlowWrflDf_TumbleOver";
                     sleep 0.3;
                     [_unit, _unit, _id] spawn RUBE_makeDraggableRelease;
                  };
                  // quick forced halt
                  default
                  {
                     _unit setVelocity [
                        (_vel select 0) * 0.5,
                        (_vel select 1) * 0.5,
                        (_vel select 2)
                     ];
                     _unit playAction "crouch";
                     // reattach/displace obj
                     //[_obj, _unit] call RUBE_makeDraggableAttach; 
                  };
               };
               
            };
            
            if ((random 1.0) > 0.67) then
            {
               deleteVehicle (_particles call BIS_fnc_arrayPop);
            };
         } else
         // stopped/paused
         {
            {
               deleteVehicle _x;
            } forEach _particles;
            _particles = [];
         };
         
         sleep 0.05;
      };
      
      _unit setUnitPos "AUTO";
      _unit forceWalk false;
      _unit forceSpeed -1;
            
      // clean up particles
      {
         deleteVehicle _x;
      } forEach _particles;         
   };
};


/*
   releases object: 
   
      _this select 0: target (object) - dragging unit to which the action is attached to
      _this select 1: caller (object) - the unit that activated the action (doesn't matter here since same as target)
      _this select 2: action-id (integer) - ID of the activated action 
      
      _this select 3: make-draggable again (boolean; optional. default = true)
*/
RUBE_makeDraggableRelease = {
   private ["_unit", "_obj", "_id", "_pos", "_matrix", "_atl", "_inputListeners", "_makeDraggableAgain"];

   _unit = _this select 0;
   _obj = _unit getVariable "RUBE_attachObj";
   _id = _unit getVariable "RUBE_attachId";
   
   if ((count _this) > 2) then
   {
      if ((_this select 2) >= 0) then
      {
         _id = _this select 2;
      };
   };
   _makeDraggableAgain = true;
   if ((count _this) > 3) then
   {
      if ((typeName (_this select 3)) == "BOOL") then
      {
         _makeDraggableAgain = _this select 3;
      };
   };
   
   [_unit, _id] call RUBE_removeAction;

   detach _obj;
   [_obj, 0, 0] call BIS_fnc_setPitchBank;
   _pos = position _obj;
   
   _atl = (getPosATL _obj) select 2;
   if (_atl < 0.1) then
   {
      // ground level
      _pos set [2,0];
      _obj setPos _pos;
   } else
   {
      // on upper surface
      //_matrix = _obj getVariable "RUBE_attachMatrix";
      _pos set [2, (_atl - 0.095)];
      // some neg. z-speed, so stuff falls down! yeah!
      //  -> this might be buggy for some objects (falling through the ground
      //     to disapear forever, it's still a lot better than objects put into 
      //     the air... :/
      _obj setVelocity [0,0,-0.001];
      //_obj setPosATL _pos; // not needed ^^
   };
   
   
   _unit setVariable ["RUBE_attachObj", objNull, true];
   
   _inputListeners = _unit getVariable "RUBE_inputListeners";
   if ((typeName _inputListeners) == "ARRAY") then
   {
      {
         _x call RUBE_removeInputListener;
      } forEach _inputListeners;
   };
   
   _obj setVariable ["RUBE_attachedTo", objNull, true];
   _obj setVariable ["RUBE_attachMatrix", nil, true];
   
   if ([_obj, "RUBE_forcedRelease"] call RUBE_isTrue) then
   {
      _obj setVariable ["RUBE_forcedRelease", nil, true];
   };
   
   // stall dust (particles)
   _obj spawn {
      private ["_particles", "_maxParticles", "_i"];
      _particles = [];
      _maxParticles = floor (1 + (random (_this getVariable "RUBE_objectWeight")));
      for "_i" from 0 to _maxParticles do
      {
         {
            _particles set [(count _particles), _x];
         } forEach ([_this] call RUBE_PE_DragObj);
      };
      sleep 1 + random 2;
      // delete particles
      {
         deleteVehicle _x;
         sleep 0.005;
      } forEach _particles;
   };
   
   // unlock
   _obj lock false;
   
   // make obj draggable again
   if (_makeDraggableAgain) then
   {
      [_obj] call RUBE_makeDraggable;
   };
};