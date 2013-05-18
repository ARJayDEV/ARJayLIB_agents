/*
   You're not supposed to call/execute this file directly.
   It's used by RUBE_addAction to handle the callback.
   
   _this select 0: target (object) - the object which the action is assigned to 
   _this select 1: caller (object) - the unit that activated the action 
   _this select 2: action-id (integer) - ID of the activated action 
   _this select 3: arguments
   
*/

private ["_actionID", "_callbacks", "_n"];

_actionID = _this select 2;

// retrieve objects action callbacks
_callbacks = [];
{
   if ((_x select 0) == (_this select 0)) exitWith
   {
      _callbacks = _x select 1;
   };
} forEach RUBE_INTERN_ACTION_CALLBACKS;

// out of bounds
_n = count _callbacks;
if (_n == 0) exitWith {};
if (_n < _actionID) exitWith {};

// call callback
_this call (_callbacks select _actionID);