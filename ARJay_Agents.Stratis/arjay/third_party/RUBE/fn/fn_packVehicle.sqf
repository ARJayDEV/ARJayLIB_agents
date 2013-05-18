/*
   Author:
    rübe
    
   Description:
    tries to pack objects onto a vehicle (attachTo)
    
    -> can be reapplied to load on object after another onto
       a vehicle; already packed objects are saved.

   Parameter(s):
    _this: parameters (array of array [key (string), value (any)])
    
           - required:
           
             - "vehicle" (object)
             - "objects" (array of objects or strings, mixed)
                - given an object:
                  - packed: objects gets moved and attached 
                  - not packed: objects stays where it is; nothing
                - given a string/class:
                  - packed: objects gets created, moved and attached
                  - not packed: no object gets created, nothing happens,
                                also: these won't show up as a result in 
                                the not-packed-objects! Only already existing
                                objects do.
                  
           - optional:
             
             - "draggable" (boolean; default = true)
               makes packed objects draggable, if they had to be newly created
               (so you need to pass class-strings for this...)
             
             - "supplies" (array [min, max] where min, max is scalar from 0 to 1; default = [0,0])
               auto set/fill supplies (supplies x capacity)
               only for newly created objects

   Returns:
    array
    
    - empty array if the packer didn't even start (error/shitty input)
    - an array: [
         0: packed-objects (array)
      ]
      if everything given could be packed
    - an array: [
         0: packed-objects (array)
         1: not-packed-objects (array)
      ]  
      
    ... so you can easily create various checks of the outcome by simply
    counting the returned array.

*/

/**************************************************************
 * READ PARAMETERS
 */
private ["_veh", "_newObjects", "_makeDraggable", "_spacing", "_autoSupplies"];

_veh = objNull;
_newObjects = [];
_makeDraggable = true;
_autoSupplies = [0,0];

_spacing = 0.05;

// read parameters
{
   switch (_x select 0) do
   {
      case "vehicle": { _veh = _x select 1; };
      case "objects": { _newObjects = _x select 1; };
      case "draggable": { _makeDraggable = _x select 1; };
      case "supplies": { _autoSupplies = _x select 1; };
   };
} forEach _this;


/**************************************************************
 * INIT
 */
private ["_vehCargoArea", "_vehCargoOffset", "_alreadyPackedObjects", "_packerPool", "_addToPackerPool", "_packNum", "_obj", "_class", "_dim", "_a", "_b", "_getObjectZOffset"];

// QUIT: no vehicle
if (isNull _veh) exitWith { [] };

// get defined cargo area for this vehicle (needs to be measured manually)
_vehPos = position _veh;
_vehDir = direction _veh;
_vehCargoArea = [];   // [x, y, height-of-cargo-floor]
_vehCargoOffset = [0, 0]; // [x, y] (area offset)


// single objects z-offset correction [TODO: maybe refactor]
// class-string => scalar
_getObjectZOffset = {
   private ["_z"];
   _z = 0;
   
   // TODO: not sure about this... attachTo is a bitch, that I know. :)
   //
   // mmkay, so looks like we need this (only for droppables) while
   // adding to RUBE_makeDraggableZOffset which is the same, but also
   // used for draggables... tricky shit :|
   //
   // so again: this offset here is only used when we put stuff on
   // a droppable (vehicle cargo), but not while dragging...
   switch (_this) do
   {
      case "Land_Sack_EP1": { _z = -0.25; };
      case "Land_Crates_EP1": { _z = -0.2; };
   };
   
   _z
};

// TODO: maybe refactor this to RUBE_getObjectCargoArea or something,
//       ... might be useful somewhere else... :)
switch (typeOf _veh) do
{
   // open trucks
   case "KamazOpen":           { _vehCargoArea = [2.25, 4.75, 0]; _vehCargoOffset = [0, -0.6]; };
   case "UralOpen_CDF":        { _vehCargoArea = [2.2, 3.9, 0];   _vehCargoOffset = [0.05, -1.15, 0]; };
   case "UralOpen_INS":        { _vehCargoArea = [2.2, 3.9, 0];   _vehCargoOffset = [0.05, -1.15, 0]; };
   case "UralCivil2":          { _vehCargoArea = [2.2, 3.9, 0];   _vehCargoOffset = [0.05, -1.15, 0]; };
   case "V3S_Gue":             { _vehCargoArea = [2.0, 3.8, 0];   _vehCargoOffset = [0, -0.9]; };
   case "V3S_Civ":             { _vehCargoArea = [2.0, 3.8, 0];   _vehCargoOffset = [0, -0.9]; };
   case "V3S_Open_TK_CIV_EP1": { _vehCargoArea = [2.05, 3.8, 0];  _vehCargoOffset = [0, -0.95, 0]; };
   case "V3S_Open_TK_EP1":     { _vehCargoArea = [2.05, 3.8, 0];  _vehCargoOffset = [0, -0.95, 0]; };
   
   // closed trucks 
   case "MTVR":                { _vehCargoArea = [2.0, 3.85, 0];  _vehCargoOffset = [0, -1.375, 0]; };
   case "MTVR_DES_EP1":        { _vehCargoArea = [2.0, 3.85, 0];  _vehCargoOffset = [0, -1.375, 0]; };
   case "Ural_CDF":            { _vehCargoArea = [2.2, 3.9, 0];   _vehCargoOffset = [0.05, -1.15, 0]; };
   case "Ural_INS":            { _vehCargoArea = [2.2, 3.9, 0];   _vehCargoOffset = [0.05, -1.15, 0]; };
   case "V3S_TK_EP1":          { _vehCargoArea = [2.05, 3.8, 0];  _vehCargoOffset = [0, -0.95, 0]; };
   case "V3S_TK_GUE_EP1":      { _vehCargoArea = [2.05, 3.8, 0];  _vehCargoOffset = [0, -0.95, 0]; };
   case "Ural_UN_EP1":         { _vehCargoArea = [2.2, 3.9, 0];   _vehCargoOffset = [0.05, -1.15, 0]; };
   case "Kamaz":               { _vehCargoArea = [2.3, 4.7, 0];   _vehCargoOffset = [0.05, -0.9, 0]; };
   case "Ural_TK_CIV_EP1":     { _vehCargoArea = [2.2, 3.9, 0];   _vehCargoOffset = [0.05, -1.15, 0]; };
   case "Ural_UN_EP1":         { _vehCargoArea = [2.2, 3.9, 0];   _vehCargoOffset = [0.05, -1.15, 0]; };

   
   // "salvage"/supply trucks
   case "WarfareSalvageTruck_USMC": { _vehCargoArea = [2.0, 3.85, 0];  _vehCargoOffset = [0, -1.375, 0]; };
   case "WarfareSalvageTruck_CDF":  { _vehCargoArea = [2.2, 3.9, 0];   _vehCargoOffset = [0.05, -1.15, 0]; };
   case "WarfareSalvageTruck_RU":   { _vehCargoArea = [2.25, 4.75, 0]; _vehCargoOffset = [0, -0.625, 0]; };
   case "WarfareSalvageTruck_INS":  { _vehCargoArea = [2.2, 3.9, 0];   _vehCargoOffset = [0.05, -1.15, 0]; };
   case "WarfareSalvageTruck_Gue":  { _vehCargoArea = [2.2, 3.9, 0];   _vehCargoOffset = [0.05, -1.15, 0]; };
   case "MtvrSupply_DES_EP1":       { _vehCargoArea = [2.0, 3.85, 0];  _vehCargoOffset = [0, -1.375, 0]; };
   case "UralSupply_TK_EP1":        { _vehCargoArea = [2.2, 3.9, 0];   _vehCargoOffset = [0.05, -1.15, 0]; };
   case "V3S_Supply_TK_GUE_EP1":    { _vehCargoArea = [2.0, 3.8, 0];   _vehCargoOffset = [0, -0.9, 0]; };
   
   // offroader/pickups
   case "Pickup_PK_GUE":            { _vehCargoArea = [1.55, 1.95, -0.65]; _vehCargoOffset = [0, -1.15, 0]; };
   case "Pickup_PK_INS":            { _vehCargoArea = [1.55, 1.95, -0.61]; _vehCargoOffset = [0, -1.15, 0]; };
   case "datsun1_civil_1_open":     { _vehCargoArea = [1.5, 2.0, -0.27];   _vehCargoOffset = [0.02, -1.33, 0]; };
   case "datsun1_civil_3_open":     { _vehCargoArea = [1.5, 2.0, -0.27];   _vehCargoOffset = [0.02, -1.33, 0]; };
   case "hilux1_civil_1_open":      { _vehCargoArea = [1.5, 1.85, -0.18];  _vehCargoOffset = [0.02, -1.45, 0]; };
   case "hilux1_civil_3_open":      { _vehCargoArea = [1.5, 1.85, -0.18];  _vehCargoOffset = [0.02, -1.45, 0]; };
   case "hilux1_civil_3_open_EP1":  { _vehCargoArea = [1.5, 1.85, -0.18];  _vehCargoOffset = [0.02, -1.45, 0]; };
   case "Offroad_DSHKM_Gue":        { _vehCargoArea = [1.55, 1.9, -0.57];  _vehCargoOffset = [-0.05, -1.2, 0]; };
   case "Offroad_DSHKM_INS":        { _vehCargoArea = [1.55, 1.9, -0.57];  _vehCargoOffset = [-0.05, -1.2, 0]; };
   case "Offroad_SPG9_Gue":         { _vehCargoArea = [1.55, 1.85, -0.12]; _vehCargoOffset = [-0.05, -1.27, 0]; };
   case "Offroad_DSHKM_TK_GUE_EP1": { _vehCargoArea = [1.5, 1.85, -0.43];  _vehCargoOffset = [-0.05, -1.22, 0]; };
   case "Offroad_SPG9_TK_GUE_EP1":  { _vehCargoArea = [1.5, 1.85, -0.11];  _vehCargoOffset = [-0.05, -1.22, 0]; };
   case "Pickup_PK_TK_GUE_EP1":     { _vehCargoArea = [1.55, 1.95, -0.55]; _vehCargoOffset = [0, -1.15, 0]; };   
   
   // tents
   case "Camp":                     { _vehCargoArea = [2.4, 4.3, -0.57];          _vehCargoOffset = [0, -0.7, 0]; };
   case "MASH":                     { _vehCargoArea = [2.4, 4.3, -0.57];          _vehCargoOffset = [0, -0.7, 0]; };
   case "CampEast":                 { _vehCargoArea = [4.99998, 7.04998, -0.84];  };
   case "Land_tent_east":           { _vehCargoArea = [8.25, 5.5, -1.31]; };
   // unfortunately camo nets aren't targetable, so no drop into action appears :(
   // might still be useful for AI (unloading from a truck into/under the camo tent...
   // -->> indeed: AI may easily drop their goods into them (they `see` the ACTION, so we may order/script them to)
   //  ->> though beware: the packer might struggle with too many objects (camo tents are quite big)
   case "Land_CamoNet_NATO":        { _vehCargoArea = [10.7, 5.2, -0.76];        _vehCargoOffset = [0, -1]; };
   case "Land_CamoNet_EAST":        { _vehCargoArea = [10.7, 5.2, -0.76];        _vehCargoOffset = [0, -1]; };
   case "Land_CamoNetB_NATO":       { _vehCargoArea = [11.1, 11.35, -1.57];      _vehCargoOffset = [0.65, 0, 0]; };
   case "Land_CamoNetB_EAST":       { _vehCargoArea = [11.1, 11.35, -1.57];      _vehCargoOffset = [0.65, 0, 0]; };
   case "Land_CamoNetVar_NATO":     { _vehCargoArea = [11.4, 6.9, -0.71]; };   
   case "Land_CamoNetVar_EAST":     { _vehCargoArea = [11.4, 6.9, -0.71]; };  
};

// QUIT: no cargo area defined
if ((count _vehCargoArea) == 0) exitWith { [] };


// get already packed objects
_alreadyPackedObjects = _veh getVariable "RUBE_vehObjCargo";
if (isnil "_alreadyPackedObjects") then
{
   _alreadyPackedObjects = [];
};

// build packer pool [x, y, class, obj|objNull]
_packerPool = [];

_addToPackerPool = {
   private ["_class", "_obj", "_dim", "_a", "_b"];
   
   _class = _this select 0;
   _obj = _this select 1;
   
   _dim = _class call RUBE_getObjectDimensions;
   // we add the offset nevertheless...
   _a = ((_dim select 0) select 0) + (abs ((_dim select 1) select 0));
   _b = ((_dim select 0) select 1) + (abs ((_dim select 1) select 1));
   
   _packerPool set [
      (count _packerPool), 
      [
         (_a min _b),         // 0: x
         (_a max _b),         // 1: y
         ((_a min _b) != _a), // 2: rotate? (bool)
         (_dim select 1),     // 3: offset
         _class,              // 4: class
         _obj                 // 5: obj OR objNull (for new ones)
      ]
   ];
};

// ... build packer pool: already existing/packed objects
{
   _class = typeOf _x;
   [_class, _x] call _addToPackerPool;
} forEach _alreadyPackedObjects;

// ... build packer pool: new objects
{
   _class = "";
   _obj = objNull;
   
   switch (typeName _x) do
   {
      case "OBJECT":
      {
         _class = typeOf _x;
         _obj = _x;

      };
      case "STRING":
      {
         _class = _x;
      };
   };
   
   if (_class != "") then
   {  
      [_class, _obj] call _addToPackerPool;
   };
} forEach _newObjects;

_packNum = count _packerPool;

// QUIT: nothing to pack
if (_packNum == 0) exitWith { [] };

// run packer (returns array of [index, pos-x, pos-y])
_packerResult = [
   _vehCargoArea,    // container size
   _packerPool,      // array of rectangle sizes (array of arrays [x, y])
   _spacing,             // margin/spacing (int)
   "center",         // returned reference-point of packed rectangles (string)
   [
      (_vehCargoOffset select 0), 
      (_vehCargoOffset select 1), 
      "center"
   ],                // position-offset/container position (array of [x, y] OR [x, y, ref-point])
   0                 // rotation/direction (number, optional)
] call RUBE_rectanglePacker;



// instantiate new, packed objects
// move existing, packed objects
private ["_returnPacked", "_returnNotPacked", "_poolIndex", "_handleUnpackedObject", "_pos", "_posX", "_posY", "_posZ", "_rotate", "_dir", "_offset", "_vec"];

_returnPacked = [];
_returnNotPacked = [];

_index = 0;
_poolIndex = 0; 

// _index => void
_handleUnpackedObject = {
   private ["_obj"];
   _obj = (_packerPool select _this) select 5;
   
   if (!(isNull _obj)) then
   {
      // only register already existing objects
      _returnNotPacked set [(count _returnNotPacked), _obj];
   };
};

{
   _index = _x select 0;
   
   // handle unpacked objects
   while {_poolIndex < _index} do
   {
      _poolIndex call _handleUnpackedObject;
      _poolIndex = _poolIndex + 1;
   };

   // handle packed objects
   _posX   = _x select 1;
   _posY   = _x select 2;
   _rotate = (_packerPool select _index) select 2;
   _offset = (_packerPool select _index) select 3;
   _class  = (_packerPool select _index) select 4;
   _obj    = (_packerPool select _index) select 5;
   _dir = 0; // BEWARE: attachTo directions are relative to the object, not to the world!
      
   if (_rotate) then 
   {
      _posX = _posX - (_offset select 0);
      _posY = _posY - (_offset select 1);
      
      _dir = _dir + 90;
   } else
   {
      _posX = _posX - (_offset select 1);
      _posY = _posY + (_offset select 0);
   };
   
   _posZ = (_vehCargoArea select 2) + (_class call _getObjectZOffset) + (_class call RUBE_makeDraggableZOffset);

   _pos = _veh modelToWorld [
      _posX,
      _posY,
      _posZ
   ];
   
   if (isNull _obj) then
   {
      // create and pack/attach new object
      _obj = createVehicle [_class, _pos, [], 0, "NONE"];
      if (_makeDraggable) then
      {
         [_obj] call RUBE_makeDraggable;
         [
            _obj, 
            ((_autoSupplies select 0) + (random ((_autoSupplies select 1) - (_autoSupplies select 0))))
         ] call RUBE_suppliesAllocate;
      };
   } else
   {
      // move and pack/attach existing object
   };
   
   // chances are, the object is already packed corectly! :)
   if ((_obj distance (_veh modelToWorld [_posX, _posY, _posZ])) > 0.1) then
   {
      _obj setDir _dir;
      _obj setPos _pos;

      detach _obj;

      // attach
      _obj attachTo [
         _veh,
         [
            _posX,
            _posY,
            _posZ
         ]
      ];
      
      _obj setDir _dir;
   };
   
   // register packed object
   _returnPacked set [(count _returnPacked), _obj];
   
   // end/iter
   _poolIndex = _poolIndex + 1;
} forEach _packerResult;

// handle unpacked objects (yes, some more, maybe... :)
while {_index < (_packNum - 1)} do
{
   _index call _handleUnpackedObject;
   _index = _index + 1;
};


// register/tag cargo objects
{
   _x setVariable ["RUBE_cargoObj", _veh, true];
   
   if (!(_x in _alreadyPackedObjects)) then
   {
      _alreadyPackedObjects set [(count _alreadyPackedObjects), _x];
   };
} forEach _returnPacked;

_veh setVariable ["RUBE_vehObjCargo", _alreadyPackedObjects, true];


// return result
if ((count _returnNotPacked) == 0) exitWith
{
   // result: everything could be packed
   [
      _returnPacked
   ]
};

// result: not every object could be packed
[
   _returnPacked,
   _returnNotPacked
]