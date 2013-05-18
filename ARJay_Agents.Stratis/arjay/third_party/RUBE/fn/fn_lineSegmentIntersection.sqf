/*
   Auhtor:
    rübe
    
   Descriptions:
    returns the intersection point of two infinite lines defined 
    by two line segments (AB, CD). Thus the intersection point 
    doesn't has to sit _on_ either of the line segments (see 
    illustration below).
    
    Will return an empty array if no intersection point 
    may be determined (colinear line segments or else). 
   
   
          .C
           \
            \
             \
              \
               \
                . D
                 
                   
                   
    .---------.    -\-
    A         B     
                    ^
                    |
             intersection point
         
   
   
   Parameter(s):
    _this select 0: point A (2d array)
    _this select 1: point B (2d array)
    _this select 2: point C (2d array)
    _this select 3: point D (2d array)
    _this select 4: line AB is finite (boolean, optional: default = false)
                    set this to true to check if the infinite line
                    CD actually intersects the finite line AB.
    
   Returns:
    array (position OR empty array) 
*/

private ["_ax", "_ay", "_bx", "_by", "_cx", "_cy", "_dx", "_dy", "_onAB"];

_ax = (_this select 0) select 0;
_ay = (_this select 0) select 1;
_bx = (_this select 1) select 0;
_by = (_this select 1) select 1;
_cx = (_this select 2) select 0;
_cy = (_this select 2) select 1;
_dx = (_this select 3) select 0;
_dy = (_this select 3) select 1;

_onAB = false;
if ((count _this) > 4) then
{
   _onAB = true;
};

// reject zero-length line segments
if (((_ax == _bx) && (_ay == _by)) || ((_cx == _dx) && (_cy == _dy))) exitWith
{
   []
};


// 1) translate coordinate system so that point A is on the origin
_bx = _bx - _ax;
_by = _by - _ay;
_cx = _cx - _ax;
_cy = _cy - _ay;
_dx = _dx - _ax;
_dy = _dy - _ay;

private ["_ab", "_cos", "_sin", "_nx", "_point"];

// distance of line segment AB
_ab = sqrt (_bx * _bx + _by * _by);

// 2) rotate coordinate system so that point B is on the positive X axis
_cos = _bx / _ab;
_sin = _by / _ab;

_nx = _cx * _cos + _cy * _sin;
_cy = _cy * _cos - _cx * _sin;
_cx = _nx;

_nx = _dx * _cos + _dy * _sin;
_dy = _dy * _cos - _dx * _sin;
_dx = _nx;

// reject if the lines are parallel
if (_cy == _dy) exitWith
{
   []
};

// 3) find intersection point along AB/the x-axis
_point = _dx + (_cx - _dx) * _dy / (_dy - _cy);

// finite AB intersection needed?
if (_onAB && ((_point < 0) || (_point > _bx))) exitWith
{
   []
}; 

// 4) return intersection 
// (apply point to original coordinate system)
[
   (_ax + _point * _cos),
   (_ay + _point * _sin),
   0
]