/*
   Author:
    rübe
    
   Description:
    returns true if the given group is still alive.
    
   Parameter(s):
    _this: group (group)
    
   Returns:
    boolean
*/

if (isNull _this) exitWith
{
   false
};

({alive _x} count (units _this) > 0)