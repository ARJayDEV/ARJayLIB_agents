/*
   Author:
    rübe
    
   Description:
    returns a random world position. (not guaranteed to be anything in 
    particular like land or something. Thus you probably should verify
    the position by yourself according to whatever you need)
    
   Parameter(s):
    none/empty array
    
   Return(s):
    2d position
*/

private ["_world", "_center", "_radius", "_dir", "_rad"];

_world = configFile >> "CfgWorlds" >> worldName;
_center = [0,0,0];
_radius = getNumber(_world >> "safePositionRadius");

// verify radius
if (_radius < 500) then
{
   // random default radius in case cfgWorlds
   // hasn't been set up properly
   _radius = 5000;
} else 
{
   // we slightly enlarge the "safety" radius
   _radius = _radius * 1.15;
};

// fifty/fifty chance to pick either the centerPosition
// or the safePositionAnchor (if defined)
if (50 call RUBE_chance) then
{
   _center = getArray(_world >> "centerPosition");
} else
{
   _center = getArray(_world >> "safePositionAnchor");
   // we need to check if the armory-part of the world config
   // has been set up properly
   if (((typename _center) != "ARRAY") || 
       (((_center select 0) == 0) && ((_center select 1) == 0))) then
   {
      _center = getArray(_world >> "centerPosition");
   };
};

// let's pick a random position by taking a random direction
// and a random fraction of the radius, shall we :)
_dir = random 360;
_rad = _radius * (random 1.0);

// calculate and return 
([
   ((_center select 0) + ((cos _dir) * _rad)),
   ((_center select 1) + ((sin _dir) * _rad)),
   0
] call RUBE_getPosASL)