/*
   Author:
    rübe
    
   Description:
    adds an input listener (keyboard/mouse input)
    (wrapper function for displayAddEventHandler)
   
   Parameter(s):
    _this: parameters (array of array [key (string), value (any)])
    
        - required:
        
          - "handlerName" (string)
            - ["keyDown", "KeyUp", "MouseMoving", "MouseHolding"]
            
              (see http://community.bistudio.com/wiki/User_Interface_Event_Handlers ,
                   http://community.bistudio.com/wiki/DIK_KeyCodes )
                   
                 - key gets passed:
                 -->
                  _DisplayOrDialogOrControl = _this select 0; // Display, Dialog , or Control
                  _DikCode=                   _this select 1; // integer
                  _shiftState =               _this select 2; // boolean
                  _ctrlState =                _this select 3; // boolean
                  _altState =                 _this select 4; // boolean
              
          - "code" (code)
            - code gets passed an array:
               0: input listener id,
               1: the original _this from the display Event Handler
            - return true/false indicating that the event has handled this event 
              fully or not and whether the engine should execute it's default 
              code or not afterwards. 
          
        - optional:
        
          - "display" (integer)
            - default: 46
            
   Returns:
    input listener ID (integer) OR -1 in case of failure
*/

private ["_displayID", "_handlerName", "_code"];

_displayID = 46;
_handlerName = "KeyDown";
_code = {};

// read parameters
{
   switch (_x select 0) do
   {
      case "code": { _code = _x select 1; };     
      case "display": { _displayID = _x select 1; };
      case "handlerName": { _handlerName = _x select 1; };
   };
} forEach _this;

// no display found
if (isNull (findDisplay _displayID)) exitWith 
{
   -1
};


private ["_ilID", "_ehID"];

// get intern input listener ID, first check if we can
// reuse an old one...
_ilID = -1;

if ((count RUBE_INTERN_INPUT_LISTENERS_FREE) > 0) then
{
   _ilID = RUBE_INTERN_INPUT_LISTENERS_FREE call BIS_fnc_arrayPop;
} else
{
   // new slot/id
   _ilID = count RUBE_INTERN_INPUT_LISTENERS;
};


// add displayEventHandler
_ehID = (findDisplay _displayID) displayAddEventHandler [
   _handlerName,
   format["([%1, _this] call RUBE_addInputListenerCall)", _ilID]
];

if (_ehID < 0) exitWith
{
   -1
};

// register input listener
RUBE_INTERN_INPUT_LISTENERS set [
   _ilID,
   [
      _displayID,
      _handlerName,
      _ehID,
      _code
   ]
];

// return input listener id
_ilID