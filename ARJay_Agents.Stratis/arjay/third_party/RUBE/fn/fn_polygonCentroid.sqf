/*
   Author:
    rübe
    
   Description:
    returns the centroid (geometric center) of a 2d polygon
    (non-self-intersecting closed). 
    The given vertices are assumed to be in order of their
    occurrence along the polygon's perimeter and 
    [x0,y0] == [xN, yN] (closed).
    
    >> in case the given polygon is not closed, we close
       it temporarily anyway - or else this algorithm 
       wouldn't work.

    
   Parameter(s):
    _this: closed polygon (array of positions)
    
   Returns:
    position 
*/

private ["_center", "_dA", "_n", "_wasntClosed", "_i", "_j", "_dt", "_dN"];

_center = [0,0,0];
_dA = 0;
_n = count _this;
_wasntClosed = false;

// we really need a closed polygon, so we check and close it
// manually if necessary...
if (!((((_this select 0) select 0) == ((_this select (_n - 1)) select 0)) &&
      (((_this select 0) select 1) == ((_this select (_n - 1)) select 1)))) then
{
   _wasntClosed = true;
   _this set [_n, (_this select 0)];
   _n = _n + 1;
};

for "_i" from 0 to (_n - 2) do
{
   _j = _i + 1;
   _dt = ((_this select _i) select 0) * ((_this select _j) select 1) -
         ((_this select _j) select 0) * ((_this select _i) select 1);
         
   _center set [0, ((_center select 0) + (
      (((_this select _i) select 0) + ((_this select _j) select 0)) * _dt
   ))];
   _center set [1, ((_center select 1) + (
      (((_this select _i) select 1) + ((_this select _j) select 1)) * _dt
   ))];
   
   _dA = _dA + _dt;
};

// delete last point again if we closed the given polygon
// automatically...
if (_wasntClosed) then
{
   _this resize (_n - 1);
};

_dN = 3 * _dA;

_center set [0, ((_center select 0) / _dN)];
_center set [1, ((_center select 1) / _dN)];

_center
