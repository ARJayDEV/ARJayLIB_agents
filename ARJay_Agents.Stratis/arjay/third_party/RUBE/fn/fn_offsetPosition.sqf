/*
   Author:
    rübe
    
   Description:
    applies a 2d vector defined per offset and direction to
    a given position.
    
   Parameter(s):
    _this select 0: origin (position)
    _this select 1: offset (2d-array [x,y])
    _this select 2: direction (scalar)
    
   Returns:
    position
*/

private ["_pos", "_offset", "_dir"];

_pos = _this select 0;
_offset = +_this select 1;
_offset set [0, ((_offset select 0) * -1)];
_offset set [1, ((_offset select 1) * -1)];
_dir = _this select 2;

[
   ( (_pos select 0) + ((cos _dir) * (_offset select 0) - (sin _dir) * (_offset select 1)) ),
   ( (_pos select 1) + ((sin _dir) * (_offset select 0) - (cos _dir) * (_offset select 1)) ),
   0
]
