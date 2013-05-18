/*
   Author:
    rübe
    
   Description:
    packs an area randomly with objects from a given pool of
    object classes.
    
   Parameter(s):
    _this select 0: position (position)
    _this select 1: area/size ([x, y])
    _this select 2: direction (direction)
    _this select 3: margin/spacing (scalar)
    _this select 4: object classes (array)
   
   nice object pools:
   
   - food:
    ["Land_Barrel_water", "Land_Barrel_sand", "Land_Barrel_empty", 
     "Misc_Backpackheap", "Fort_Crate_wood", "Misc_cargo_cont_net1", 
     "Misc_cargo_cont_net2", "Misc_cargo_cont_net3"]
     
   - building materials:
    ["Barrels", "Misc_concrete_High", "Misc_palletsfoiled", 
     "Misc_palletsfoiled_heap", "Paleta1", "Paleta2", "PowerGenerator"]
     
   - service/mech.:
    ["Barrel1", "Barrel4", "Barrel5", "Land_Pneu", "Misc_TyreHeap", 
     "Misc_cargo_cont_tiny", "Misc_cargo_cont_small2"]
    
   Returns:
    objects (array)
*/

private ["_position", "_size", "_direction", "_margin", "_classes", "_c", "_dimensions", "_dim", "_area", "_sum", "_pool", "_index", "_d", "_packed", "_objects", "_pos", "_dir"];

_position = +(_this select 0); // copy since we modify this
_size = _this select 1;
_direction = _this select 2;
_margin = _this select 3;
_classes = _this select 4;
_c = count _classes;

if (_c == 0) exitWith 
{
   []
};

_position set [2, "center"];

// init obj dimensions
_dimensions = [];

for "_i" from 0 to (_c - 1) do
{
   _dim = (_classes select _i) call RUBE_getObjectDimensions;
   _dimensions set [_i, [
      (((_dim select 0) select 0) + (abs ((_dim select 1) select 0))),
      (((_dim select 0) select 1) + (abs ((_dim select 1) select 1)))
   ]];
   (_dimensions select _i) set [
      2, 
      (((_dimensions select _i) select 0) * ((_dimensions select _i) select 1))
   ];
};


// build random object pool to fill the 
// given area.
_area = ((_size select 0) * (_size select 1)) * 1.5;
_sum = 0;
_pool = []; // [x, y, dir-offset, class]

while {(_sum < _area)} do
{
   _index = floor (random _c);
   _d = 0;
   if ((random 1.0) > 0.5) then
   {
      _d = 180;
   };
   if ((random 1.0) > 0.5) then
   {
      _pool set [(count _pool), [
         ((_dimensions select _index) select 0),
         ((_dimensions select _index) select 1),
         _d,
         (_classes select _index)
      ]];
   } else
   {
      _pool set [(count _pool), [
         ((_dimensions select _index) select 1),
         ((_dimensions select _index) select 0),
         _d + 90,
         (_classes select _index)
      ]];
   };
   
   _sum = _sum + ((_dimensions select _index) select 2);
};

// pack
_packed = [
   _size,
   _pool,
   _margin,
   "center",
   _position,
   _direction
] call RUBE_rectanglePacker;

// spawn
_objects = [];

{
   _pos = [(_x select 1), (_x select 2), 0];
   _dir = _direction + ((_pool select (_x select 0)) select 2);
   _index = count _objects;
   _objects set [
      _index, 
      (((_pool select (_x select 0)) select 3) createVehicle _pos)
   ];
   
   (_objects select _index) setDir _dir;
   (_objects select _index) setPos _pos;

} forEach _packed;

// return
_objects
