/*
   Author:
    rübe
    
   Description:
    removes an input listener (keyboard/mouse input)
    (wrapper function for displayRemoveEventHandler)
   
   Parameter(s):
    _this: input listener ID (integer)
    
   Returns:
    void
*/

private ["_n", "_inputListener"];

_n = count RUBE_INTERN_INPUT_LISTENERS;
if (_n < _this) exitWith {};

_inputListener = RUBE_INTERN_INPUT_LISTENERS select _this;

// no display found
if (isNull (findDisplay (_inputListener select 0))) exitWith 
{
   -1
};

// remove displayEventHandler
(findDisplay (_inputListener select 0)) displayRemoveEventHandler [
   (_inputListener select 1),
   (_inputListener select 2)
];

// trash/free input listener (we reuse discarded slots...)
RUBE_INTERN_INPUT_LISTENERS set [_this, [-1, "", -1, {}]];
RUBE_INTERN_INPUT_LISTENERS_FREE set [(count RUBE_INTERN_INPUT_LISTENERS_FREE), _this];