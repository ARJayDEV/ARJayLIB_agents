/*
   Author:
    rübe
    
   Description:
    removes actions added with RUBE_addAction (deleting the
    stored action callback)
  
   Parameters:
    _this select 0: from object/unit (object)
    _this select 1: action-id (integer)
    
   Returns:
    void
*/   

private ["_actionID", "_callbacks", "_n"];

_actionID = _this select 1;

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

// trash old callback
(_callbacks) set [_actionID, {}];

// remove action
(_this select 0) removeAction _actionID;