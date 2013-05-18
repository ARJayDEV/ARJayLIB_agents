/*
   Author:
    rübe
    
   Description:
    adds an offset to a grid-position (the grid can have any orientation, thus
    we need to do this with a (rotated) vector.
    
    THe z-axis of the origin will be ignored. If given, we treat the z-offset 
    as origin vector (z == z-offset). Otherwise z will be 0.
    
   Parameter(s):
    _this select 0: position (position)
    _this select 1: offset vector (array of [x, y(, z)])
    _this select 2: orientation/direction (number)
    _this select 3: normalize direction (boolean; option, default = true)
    
   Returns:
    position
    
   Notes:
    - requires BIS function library
    - used in/written for fn_spawnGridComposition.sqf
*/

private ["_origin", "_offset", "_alpha", "_normalize"];

_origin = _this select 0;
_offset = _this select 1;
if ((count _offset) < 3) then
{
   _offset set [2, 0];
};
_alpha = _this select 2;
_normalize = true;
if ((count _this) > 3) then
{
   _normalize = _this select 3;
};
if (_normalize) then
{
   _alpha = (360 - _alpha) % 360;
};

// offset vector
private ["_offsetVector"];
_offsetVector = [[(_offset select 0), (_offset select 1)], _alpha] call BIS_fnc_rotateVector2D;

// return transformed position
[
   ((_origin select 0) + (_offsetVector select 0)),
   ((_origin select 1) + (_offsetVector select 1)),
   (_offset select 2)
]
