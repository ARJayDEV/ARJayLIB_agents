/*
   Author:
    rübe
   
   Description:
    spawns a given list of objects at a given position
    
    -> weapons and magazines will be wrapped in a 
       weaponholder automatically!
       
       if you wanna put some ammo in the weapon, you need
       to pass a custom code, spawning/returning the loaded weapon
       by yourself
    
   Parameter(s):
    _this select 0: center position (position)
    _this select 1: direction (number)
    _this select 2: objects (array of [
                       objClass (string) OR spawn-function (code), 
                       positionOffset 3D(!) (array),
                       rotation (number, optional)
                       pitch (number, optional)
                       bank (number, optional
                    ]
                     
                     - the spawn-function gets [pos, dir] and must return
                       a single object
   
   Returns:
    array of spawned objects
    
   Notes:
    - requires BIS function library loaded OR BIS_fnc_rotateVector2D
      and BIS_fnc_setPitchBank defined
*/

private ["_position", "_direction", "_directionNOR", "_objects", "_vec", "_pos", "_n", "_obj", "_pitch", "_bank"];

_position = _this select 0;
_direction = _this select 1;
_directionNOR = (360 - _direction) % 360;

_objects = [];

{
   _vec = [[((_x select 1) select 0), ((_x select 1) select 1)], _directionNOR] call BIS_fnc_rotateVector2D;
   _pos = [
      ((_position select 0) + (_vec select 0)),
      ((_position select 1) + (_vec select 1)),
      ((_x select 1) select 2)
   ];
   // object, weapon or magazine class
   if ((typeName (_x select 0)) == "STRING") then
   {
      _n = 0;
      if ((_x select 0) call RUBE_isWeapon) then 
      { 
         _n = 1; 
      } else {
         if ((_x select 0) call RUBE_isMagazine) then { _n = 2; };
      };
      switch (_n) do
      {
         case 1:
         {
            _obj = createVehicle ["weaponholder", _pos, [], 0, "NONE"];
            _obj addWeaponCargo [(_x select 0), 1];
         };
         case 2:
         {
            _obj = createVehicle ["weaponholder", _pos, [], 0, "NONE"];
            _obj addMagazineCargo [(_x select 0), 1];
         };
         default
         {
            _obj = createVehicle [(_x select 0), _pos, [], 0, "NONE"];
         };
      };
   // code
   } else {
      _obj = [_pos, _direction] call (_x select 0);
   };
   
   if ((count _x) > 2) then
   {
      _obj setDir (_direction + (_x select 2));
   } else {
      _obj setDir _direction;
   };
   _obj setPos _pos;
   
   if ((count _x) > 3) then
   {
      _pitch = _x select 3;
      _bank = 0;
      if ((count _x) > 4) then
      {
         _bank = _x select 4;
      };
      [_obj, _pitch, _bank] call BIS_fnc_setPitchBank;
   };
   
   if (((_x select 1) select 2) != 0) then
   {
      // setPosATL: Sets the position of an object relative to the terrain. 
      _obj setPosATL _pos;
   };
   
   _objects = _objects + [_obj];
} forEach (_this select 2);

// return objects
_objects