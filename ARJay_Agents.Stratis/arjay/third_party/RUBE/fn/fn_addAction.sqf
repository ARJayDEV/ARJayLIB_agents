/*
   Author:
    rübe
    
   Description:
    addAction wrapper function with the main advantage that we're able
    to use code-blocks as callbacks instead of yet another sqs/sqf file.
    (we store the callbacks for later usage, while calling a delegator script
     that retrieves the callback and calls it...)
    
    -> use RUBE_removeAction instead of the command removeAction. While the 
       latter works too, it won't delete/clear up the callback-function that
       RUBE_addAction has put into some internal array... (though shouldn't
       be that bad either...)
    
   Parameter(s):
    _this: parameters (array of array [key (string), value (any)])
    
           - required:
           
             - "object" (object)
               - the object which the action is assigned to 
             - "title" (string/struct. text)
             - "callback" (code)
               - get's passed:
                  _this select 0: target (object) - the object which the action is assigned to 
                  _this select 1: caller (object) - the unit that activated the action 
                  _this select 2: action-id (integer) - ID of the activated action 
                  _this select 3: arguments
               
           - optional:
           
             - "arguments" (any)
             - "priority" (integer, default = 0)
             - "showWindow" (bool, default = false)
             - "hideOnUse" (bool, default = false)
             - "shortcut" (string)
               - one of the `key names`, 
                 see: http://community.bistudio.com/wiki/ArmA:_CfgDefaultKeysMapping
             - "condition" (string)
               - bound variables: 
                 - _target: unit to which action is attached to
                 - _this: caller/executing unit
      
   Example:
   
       _actionID = [
           ["object", player],
           ["title", "call action"],
           ["callback", { hint format["addAction call:\n%1", _this]; }]
       ] call RUBE_addAction;
       
       // ... and maybe at some later point:
       [player, _actionID] call RUBE_removeAction;
             
   Returns:
    actionID (integer)
*/

private ["_obj", "_title", "_callback", "_args", "_priority", "_showWindow", "_hideOnUse", "_shortcut", "_condition", "_callbacks", "_actionID"];

_obj = objNull;
_title = "";
_callback = {};
_args = [];
_priority = 0;
_showWindow = false;
_hideOnUse = false;
_shortcut = "";
_condition = "true";


// read parameters
{
   switch (_x select 0) do
   {
      case "object": { _obj = _x select 1; };
      case "title": { _title = _x select 1; };
      case "callback": { _callback = _x select 1; };
      case "arguments": { _args = _x select 1; };
      case "priority": { _priority = _x select 1; };
      case "showWindow": { _showWindow = _x select 1; };
      case "hideOnUse": { _hideOnUse = _x select 1; };
      case "shortcut": { _shortcut = _x select 1; };
      case "condition": { _condition = _x select 1; };      
   };
} forEach _this;

// register action callback

// add action
_actionID = _obj addAction [_title, "RUBE\fn\fn_addActionCall.sqf", _args, _priority, _showWindow, _hideOnUse, _shortcut, _condition];

if (_actionID < 0) exitWith { -1 };

// first let's check if the object in question already
// has a slot for it's action callbacks...
_callbacks = [];

{
   if ((_x select 0) == _obj) exitWith
   {
      _callbacks = _x select 1;
   };
} forEach RUBE_INTERN_ACTION_CALLBACKS;

// ... otherwise we register a new slot for it.
if ((count _callbacks) == 0) then
{
   RUBE_INTERN_ACTION_CALLBACKS set [(count RUBE_INTERN_ACTION_CALLBACKS), [_obj, _callbacks]];
};

// ... and finally let's save the callback...
_callbacks set [_actionID, _callback];

// return actionID
_actionID