/*
   Author:
    rübe
    
   Description:
    returns the (shorter) arc/angle between to given angles.
    
    
              20° (a1)           320° (a1)
              \                   /
             /                     \     120°
            /   70°                 \
           /                         \           80° (a2)
          X---------> 90° (a2)        X---------/ 
    
    
   Parameter(s):
    _this select 0: angle 1 (scalar)
    _this select 1: angle 2 (scalar)
    
   Returns:
    scalar (0-180)
*/

private ["_diff"];

_diff = abs (((_this select 1) % 360) - ((_this select 0) % 360));

if (_diff > 180) then
{
   _diff = 360 - _diff;
};

_diff