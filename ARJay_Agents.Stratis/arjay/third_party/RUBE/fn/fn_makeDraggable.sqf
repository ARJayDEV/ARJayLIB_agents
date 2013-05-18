/*
   Author:
    rübe
    
   Description:
    makes an object draggable by player or AI.
   
   Notes:
   
     - your intended to drag/pull crouched and backwards. This
       is the only way to safely do this; otherwise you might get
       injured (not scripted)
       
     - only one object can be dragged at a time
      
     - you can't walk too fast/upright while dragging and will be
       force-crouched/stopped if you do (slightly randomly) and
       also you'll reposition (reattach) the object (this may injure
       you) to simulate a mistake (stumbling/letting go/drop the object).
       
       Same applies to AI if dragging. Also dragging AI may injure
       or even kill you, if they push the dragged object into you!
       
       ^^ all nice features, if you ask me :D
       
     - objects (most of all vehicles) may be droppable 
       (see RUBE_makeDroppable) which means you put the object you're
       currently dragging into/onto the droppable object. The object 
       get's detached from you and attached to the droppable object, 
       or if there is no more space left, you simply release the object
       
       Once dropped, you may again drag that object.
       
     - _draggableObject setVariable ["RUBE_forcedRelease", true, true]; 
       will force the object to be released (and made draggable again).
    
   Interface/Strings you might want to overwrite/localize:
    - `RUBE_STR_DragAction`: "drag %1"
    - `RUBE_STR_ReleaseAction`: "release %1"

   Scripted Action:
    - `[object, unit] call RUBE_makeDraggableStart` attaches object
      to the unit.
      
    - `[unit] call RUBE_makeDraggableRelease` detaches the object
      from the unit 

   Parameter(s):
    _this select 0: draggable object (object)
    
   Returns:
    void
*/

private ["_obj", "_actionId"];

_obj = _this select 0;

_actionId = [
   ["object", _obj],
   ["title", format[RUBE_STR_DragAction, (_obj call RUBE_makeDraggableName)]],
   ["hideOnUse", true],
   ["callback", RUBE_makeDraggableStart],
   ["condition", "!([_this, ""RUBE_attachObj""] call RUBE_isObject) && ((count (crew _target)) == 0)"]
] call RUBE_addAction;

_obj setVariable ["RUBE_draggableId", _actionId, true];