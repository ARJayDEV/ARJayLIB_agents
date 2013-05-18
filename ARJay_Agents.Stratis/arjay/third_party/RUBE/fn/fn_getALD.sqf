/*
   Author:
    rübe
    
   Description:
    returns the airline distance (ALD) between two objects 
    or (ASL-)positions. (also Euclidean distance or `distance
    as the crow flies`)
    
   Parameter(s):
    _this select 0: from (position OR object)
    _this select 1: to (position OR object)
    
   Returns
    scalar
*/

private ["_p1", "_p2"];

_p1 = _this select 0;
_p2 = _this select 1;

if ((typeName _p1) != "ARRAY") then
{
   _p1 = position _p1;
};
if ((typeName _p2) != "ARRAY") then
{
   _p2 = position _p2;
};

// return
(sqrt (((_p2 select 0) - (_p1 select 0))^2 + 
       ((_p2 select 1) - (_p1 select 1))^2))