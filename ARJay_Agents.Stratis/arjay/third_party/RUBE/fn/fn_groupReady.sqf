/*
   Author:
    rübe
    
   Description:
    returns true if every unit of the given group is ready (unitReady)
    
   Parameter(s):
    _this: group (group)
   
   Returns:
    boolean
*/

private ["_ready"];

_ready = true;

{
   _ready = _ready && ((unitReady _x) || !(alive _x));
} forEach (units _this);

_ready