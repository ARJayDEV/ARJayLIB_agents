/*
   Author:
    rübe
    
   Description:
    calculates the area of a closed polygon. The polygon
    must not be self-intersecting or else...
    
    >> in case the given polygon is not closed, we close
       it temporarily anyway - or else this algorithm 
       wouldn't work.
    
   Parameter(s):
    _this: closed polygon (array of positions)
    
   Returns:
    scalar (m^2)
*/

private ["_n", "_wasntClosed", "_area", "_i"];

_n = count _this;

// we really need a closed polygon, so we check and close it
// manually if necessary...
if (!((((_this select 0) select 0) == ((_this select (_n - 1)) select 0)) &&
      (((_this select 0) select 1) == ((_this select (_n - 1)) select 1)))) then
{
   _wasntClosed = true;
   _this set [_n, (_this select 0)];
   _n = _n + 1;
};


// compute area
_area = 0;
for "_i" from 0 to (_n - 2) do
{
   _area = _area + (((_this select _i) select 0) * (((_this select (_i + 1))) select 1))
                 - (((_this select _i) select 1) * (((_this select (_i + 1))) select 0));
};

_area = abs (_area * 0.5);


// delete last point again if we closed the given polygon
// automatically...
if (_wasntClosed) then
{
   _this resize (_n - 1);
};


// return computed area
_area