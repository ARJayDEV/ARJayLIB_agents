/*
   Author:
    rübe
    
   Description:
    makes a vehicle/object droppable for draggable objects. Works on
    all(?) A2/OA trucks, pickups and tents/camotents.
    
    Extended AI actions:
     - unload: AI may unload _all_ cargo from a given droppable 
        right next to the droppable (player gets no action to see, 
        but may issue his AI to do so with radio 6-0-X)
       
     - transship from ... (1): again with radio 6-0-X you may first select 
        a droppable as source (load from ...), nothing happens yet, 
        
     - transship to (2): ... but now you may (again with radio 6-0-X) issue 
        your AI to unload _all_ cargo from that source to another 
        droppable (load to) 
        
        -> the loading source is stored on the group, so after one unit
           has set a droppable source, you may order all your units to 
           unload from the same source, and even to different target 
           droppables :)

    
   Notes: 
   
    - that vehicle has to work with RUBE_packVehicle which needs
      special configuration (droppable area/offset) for each vehicle.
               ... just in case things don't work as expected.
    
    - we use RUBE_rectanglePacker to fill the cargo-area, which means
      that the ORDER in which we pack/drop things DOES MATTER. Maybe 
      stuff would fit, if another object would be packed/dropped later... :)
      
    - also if dropping fails (not enough space left/at all), you simply
      will drop, what you're currently carrying, thereby celebrating
      your failure, hehe (TODO: maybe make an option to set a custom/global 
      code for this event, so we could play a say-sound or something funny)
        
    - if the droppable object gets killed, all attached object get detached
      and eventually destroyed too!
      
      -> detach and setVelocity on cargo-objects, triggerd by the killed
         event of the droppable unfortunatley doesn't work well...
         (crazy delay/stupid objects)
      
      
    * DONE: a car like datsun1_civil_1_open get's easily damaged (can't drive
      straight anymore) while unloading heavy cargo such as an ammocrate.
      Solution could be to make draggable aware of draging from cargo, if so
      then rotate player/or put him away or something...
       
       -> DONE, already much better... 
       -> TODO: though animations could be tweaked a bit, to better hide the
                forced setPos... :/

    * TODO: it's tricky (if not impossible) to unload from a closed-truck since
      we have no way to target the goods (and make the action available)...
      What now? Actions to unload on the truck? Then we have all actions twice...
      A single action on the truck to unload _all_ cargo? Maybe... :/
      
      - if unload _all_ cargo, then maybe leave control of the player, kick in
        cam script and do stuff like an AI... so in the end, the player will
        use AI to unload _all_ cargo... 
        
     -> DONE: droppables are unloadable by AI only now, and multiple units may
        be ordered to unload the same droppable, and also closed trucks work
        fine now... you just need some AI around (action won't show up for the
        player; but radio 0-6-X to let your AI unload everything)

    - To extend the list of droppable objects, you need to define a cargo-area
      and -offset for the new object (manually measured) in RUBE_packVehicle,
      thought this "cargo area list" might be refactored to yet another function
      later...

   Interface/Strings you might want to overwrite/localize:
    - `RUBE_STR_DropOntoAction`: "drop %1 onto %2"
    - `RUBE_STR_UnloadAllAction`: "unload %1"
    - `RUBE_STR_UnloadAllFromAction`: "transship from %1 ..."
    - `RUBE_STR_UnloadAllToAction`: "transship to %1"

   Scripted Action:
    - `[droppable/vehicle, unit-with-draggable] spawn RUBE_makeDroppableDrop` drops
      the object currently attached to the given unit onto the given droppable.
      
      OR alternativ syntax (to drop objects without dragging unit):
      
    - `[droppable/vehicle, [object-to-drop]] call RUBE_makeDroppableDrop` drops
      the given object (wrapped in an array!) onto the given droppable.
      
    - `[_veh, _unit] call RUBE_makeDroppableUnloadAll` will order (commandFSM) _unit 
      to  unload all cargo from _veh.

    - `[_unit, _source, _target] call RUBE_makeDroppableLoadFromTo` to make a unit
      unload all cargo from the source (in)to the target droppable. Objects that have
      no place left in target will simply be dropped/released where the unit is...
      
         TODO: put unpackable objects back or something? mhhh

   Parameter(s):
    _this select 0: vehicle with cargo-area (object)
    _this select 1: take back unpackable objects if used as source (AI only)? (optional, default = auto)
    _this select 2: generic name of a droppable object (string; optional, default = "object")
    
   Returns:
    void
*/

private ["_obj", "_killedId", "_droppableName", "_takeBackUnpackable"];

_obj = _this select 0;
_takeBackUnpackable = false;
if ((count _this) > 1) then
{
   _takeBackUnpackable = _this select 1;
} else 
{
   if ((typeOf _obj) in [
      "Camp", "MASH", "CampEast", "Land_tent_east", 
      "Land_CamoNet_NATO", "Land_CamoNet_EAST",
      "Land_CamoNetB_NATO", "Land_CamoNetB_EAST",
      "Land_CamoNetVar_NATO", "Land_CamoNetVar_EAST"
   ]) then
   {
      _takeBackUnpackable = true;
   };
};

_droppableName = "object";
if ((count _this) > 2) then
{
   _droppableName = _this select 2;
};

_obj setVariable ["RUBE_vehObjTakeBack", _takeBackUnpackable, true];
_obj setVariable ["RUBE_vehObjCargo", [], true];




// release objects if killed
_killedId = _obj addEventHandler ["killed", {
   private ["_obj", "_cargo", "_id"];
   _obj = _this select 0;
   _cargo = _obj getVariable "RUBE_vehObjCargo";
   _id = _obj getVariable "RUBE_ehKilledFR";
   
   {
      detach _x;

      if ((random 1.0) > 0.7) then
      {
         _x setDamage (random 1.0);
      } else
      {
         // full destruction of cargo
         _x setDamage 1.0;
      };
      
      // TODO: for one setVelocity is weird on some objects that have
      // never heard of newton/gravity yet... second it takes up to several
      // seconds until shit blows finally up... meeehhh :/
      //_x setVelocity [(random 2.01), (random 2.01), 10.05];    
   } forEach _cargo;
   
   _obj removeEventHandler ["killed", _id];
   _obj setVariable ["RUBE_ehKilledFR", nil, true];
   _obj setVariable ["RUBE_vehObjCargo", [], true];
}];

_obj setVariable ["RUBE_ehKilledFR", _killedId, true];


// make droppable
[
   ["object", _obj],
   ["title", format[RUBE_STR_DropOntoAction, _droppableName, (_obj call RUBE_makeDraggableName)]],
   ["hideOnUse", false],
   ["callback", RUBE_makeDroppableDrop], // (see fn_makeDraggableLib.sqf)
   ["condition", "([_this, ""RUBE_attachObj""] call RUBE_isObject)"]
] call RUBE_addAction;


// make fully unloadable (AI only)
[
   ["object", _obj],
   ["title", format[RUBE_STR_UnloadAllAction, (_obj call RUBE_makeDraggableName)]],
   ["hideOnUse", false],
   ["callback", RUBE_makeDroppableUnloadAll], // (see fn_makeDraggableLib.sqf)
   ["condition", "(count (_target getVariable ""RUBE_vehObjCargo"") > 0) && (_this != player)"]
] call RUBE_addAction;

// select as loading source (for AI only)
[
   ["object", _obj],
   ["title", format[RUBE_STR_UnloadAllFromAction, (_obj call RUBE_makeDraggableName)]],
   ["hideOnUse", false],
   ["callback", RUBE_makeDroppableUnloadAllFrom], // (see fn_makeDraggableLib.sqf)
   //["condition", "(count (_target getVariable ""RUBE_vehObjCargo"") > 0) && ((count (units (group _this))) > 0)"]
   ["condition", "(count (_target getVariable ""RUBE_vehObjCargo"") > 0) && (_this != player)"]
] call RUBE_addAction;

// select as loading target (AI only)
[
   ["object", _obj],
   ["title", format[RUBE_STR_UnloadAllToAction, (_obj call RUBE_makeDraggableName)]],
   ["hideOnUse", false],
   ["callback", RUBE_makeDroppableUnloadAllTo], // (see fn_makeDraggableLib.sqf)
   ["condition", "([_target, _this] call RUBE_makeDroppableCanUnloadTo) && (_this != player)"]
] call RUBE_addAction;