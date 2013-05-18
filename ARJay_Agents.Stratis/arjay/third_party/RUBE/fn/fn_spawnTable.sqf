/*
   Author:
    rübe
    
   Description:
    spawns a table with item(s) on top of it.
    
    notes:
     - items will be oriented automatically in natural direction 
       (desk-> items-> <-chair). Some objects need to be flipped,
       and are internally stored in _autoFlipItems. Feel free to
       extend this list as needed.
       
     - ^^ same for chairs and _autoFlipChairs respectively.
     
     - Weapons and ammo gets wrapped automatically in a weapon-
       holder, but BEWARE:
       You will run into a problem, if you'd like to spawn weapon
       and ammo, where both classes are named the same (e.g. Javelin),
       since both are interpreted as a weapon. 
       (TODO: some nifty workaround without too much hassle/flags)
       
     - stock table classes: FoldTable, SmallTable, Desk
     - stock chair classes: FoldChair, FoldChair_with_Cargo, WoodChair
    
   Parameter(s):
    _this: parameters (array of array [key (string), value (any)])
    
    - required:
    
      - "position" (position)
      
      - "direction" (direction)
    
    - optional:
      
      - "table" (class-string)
        - default = "FoldTable"
        
      - "zerror" (scalar)
        - items z = (table z - zerror)
        - default = 0.02
        
      - "chair" (class-string)
        - default = none
      
      - "items" (class-string OR array of class-strings)
        - default = none
        
      - "enableSimulation" (boolean)
        - if disabled, only non-weapon/ammo will be 
          affected, so these items will stay functional
        - default = true
    
   Returns:
    array of objects 
    - first is guaranteed to be the table,
    - second is the chair if given
    - the rest are the spawned items
*/

private ["_objects", "_enableSimulation", "_position", "_direction", "_table", "_chair", "_flipChair", "_items", "_numItems", "_tableZError", "_autoFlipItems", "_autoFlipChairs"];

_objects = [];
_enableSimulation = true;

_position = [0,0,0];
_direction = 0;
_table = "FoldTable";
_chair = "";
_flipChair = 180;
_items = [];
_numItems = 0;
_tableZError = 0.02;
_autoFlipItems = [
   "Notebook",
   "SmallTV"
];
_autoFlipChairs = [
   "FoldChair_with_Cargo"
];

// read parameters
{
   switch (_x select 0) do
   {
      case "position": { _position = _x select 1; };
      case "direction": { _direction = _x select 1; };
      case "table": { _table = _x select 1; };
      case "chair": { _chair = _x select 1; };
      case "items": {
         if ((typeName (_x select 1)) == "ARRAY") then
         {
            _items = _x select 1;
         } else {
            _items = [(_x select 1)];
         };
      };
      case "enableSimulation": { _enableSimulation = _x select 1; };
   };
} forEach _this;

_numItems = count _items;

private ["_createItem", "_autoFlip", "_keepInPlace", "_tableSize", "_pos", "_dir", "_i", "_t", "_x", "_x0", "_x1", "_y", "_z"];

_createItem = {
   private ["_weaponHolder", "_item"];
   _weaponHolder = 0;
   switch (true) do
   {
      case (_this call RUBE_isWeapon):   { _weaponHolder = 1; };
      case (_this call RUBE_isMagazine): { _weaponHolder = 2; };
   };
   
   if (_weaponHolder > 0) exitWith
   {
      _item = createVehicle ["weaponholder", [0,0,0], [], 0, "NONE"];
      if (_weaponHolder == 1) then
      {
         if (_this == "Javelin") then
         {
            _item addMagazineCargo ["Javelin", 1];
         };
         _item addWeaponCargo [_this, 1];
      } else {
         _item addMagazineCargo [_this, 1];
      };
      
      _item
   };
   
   _item = createVehicle [_this, [0,0,0], [], 0, "NONE"];
   
   if (!_enableSimulation) then
   {
      _item enableSimulation false;
   };
   
   _item
};

_autoFlip = {
   if (_this in _autoFlipItems) exitWith
   {
      0
   };
   
   180
};

// in case objects fall over (e.g. suitcases tend to), we
// put them back on the table once! (though this doesn't
// work too well, since bouncy objects tend to drift off 
// anyway :/)
_keepInPlace = {
   private ["_pos0", "_pos1", "_dir", "_up"];
   
   _pos0 = _this select 1;
   sleep 5;
   _pos1 = position (_this select 0);
   while {((abs ((_pos1 select 0) - (_pos0 select 0))) > 0.01)} do
   {
      sleep 2;
      _pos0 = +_pos1;
      _pos1 = position (_this select 0);
   };
   
   _dir = vectorDir (_this select 0);
   _up = vectorUp (_this select 0);
   
   (_this select 0) setPos (_this select 1);
   (_this select 0) setVectorDirAndUp [_dir, _up];
   (_this select 0) setVelocity [0, 0, 0];
};

// the table
_objects set [0, (createVehicle [_table, _position, [], 0, "NONE"])];
(_objects select 0) setDir _direction;
(_objects select 0) setPos _position;

_tableSize = (_objects select 0) call RUBE_boundingBoxSize;

if (!_enableSimulation) then
{
   (_objects select 0) enableSimulation false;
};


// the chair (optional)
if (_chair != "") then
{
   private ["_chairSize"];
   _objects set [1, (createVehicle [_chair, [0,0,0], [], 0, "NONE"])];
   
   _chairSize = (_objects select 1) call RUBE_boundingBoxSize;
   
   _x = [0, ((_tableSize select 0) * 0.3)] call RUBE_randomizeValue;
   _y = ((_tableSize select 1) * 0.5) + ((_chairSize select 1) * 0.51) + (random 0.1);
   
   _pos = (_objects select 0) modelToWorld [_x, _y, 0];
   _pos set [2, 0];
   (_objects select 1) setPos _pos;
   
   if (_chair in _autoFlipChairs) then
   {
      _flipChair = _flipChair - 180;
   };
   
   _dir = ([(_objects select 1), (_objects select 0)] call BIS_fnc_dirTo) - _flipChair;
   _dir = [_dir, 12] call RUBE_randomizeValue;
   
   (_objects select 1) setDir _dir;
   (_objects select 1) setPos _pos;
   
   if (!_enableSimulation) then
   {
      (_objects select 1) enableSimulation false;
   };
};



// the items (optional)
_i = count _objects;
switch (true) do {
   // single item
   case (_numItems == 1):
   {
      _objects set [_i, ((_items select 0) call _createItem)];
      
      _x = [0, ((_tableSize select 0) * 0.15)] call RUBE_randomizeValue;
      _y = [((_tableSize select 1) * -0.1), ((_tableSize select 1) * 0.2)] call RUBE_randomizeValue;
      
      _pos = (_objects select 0) modelToWorld [_x, _y, 0];
      _pos set [2, ((_tableSize select 2) - _tableZError)];
      
      _dir = [((direction (_objects select 0)) - ((_items select 0) call _autoFlip)), 15] call RUBE_randomizeValue;
      
      (_objects select _i) setDir _dir;
      (_objects select _i) setPos _pos;
      
      [(_objects select _i), _pos] spawn _keepInPlace; //--**--//
   };
   // even number of items
   case ((_numItems > 0) && ((_numItems % 2) == 0)):
   {
      private ["_j", "_jE"];
      _t = 0;
      _jE = _numItems * 2;
      _x0 = (_tableSize select 0) * -0.5;
      _x1 = (_tableSize select 0) / _jE;
      
      for [{_j=1}, {_j<_jE}, {_j=_j+2}] do
      {
         _objects set [_i, ((_items select _t) call _createItem)];
         
         _x = _x0 + (_j * _x1);
         _y = [((_tableSize select 1) * -0.1), ((_tableSize select 1) * 0.2)] call RUBE_randomizeValue;
         
         _pos = (_objects select 0) modelToWorld [_x, _y, 0];
         _pos set [2, ((_tableSize select 2) - _tableZError)];
         _dir = [((direction (_objects select 0)) - ((_items select _t) call _autoFlip)), 15] call RUBE_randomizeValue;
         
         (_objects select _i) setDir _dir;
         (_objects select _i) setPos _pos;
         
         [(_objects select _i), _pos] spawn _keepInPlace; //--**--//
         
         _i = _i + 1;
         _t = _t + 1;
      };
      
   };
   // odd number of items
   case (_numItems > 0):
   {
      private ["_j", "_jE"];
      _t = 0;
      _jE = _numItems + 1;
      _x0 = (_tableSize select 0) * -0.5;
      _x1 = (_tableSize select 0) / _jE;
      
      for [{_j=1}, {_j<_jE}, {_j=_j+1}] do
      {
         _objects set [_i, ((_items select _t) call _createItem)];
         
         _x = _x0 + (_j * _x1);
         _y = [((_tableSize select 1) * -0.1), ((_tableSize select 1) * 0.2)] call RUBE_randomizeValue;
         
         _pos = (_objects select 0) modelToWorld [_x, _y, 0];
         _pos set [2, ((_tableSize select 2) - _tableZError)];
         _dir = [((direction (_objects select 0)) - ((_items select _t) call _autoFlip)), 15] call RUBE_randomizeValue;
         
         (_objects select _i) setDir _dir;
         (_objects select _i) setPos _pos;
         
         [(_objects select _i), _pos] spawn _keepInPlace; //--**--//
         
         _i = _i + 1;
         _t = _t + 1;
      };
   };
};



// return objects
_objects