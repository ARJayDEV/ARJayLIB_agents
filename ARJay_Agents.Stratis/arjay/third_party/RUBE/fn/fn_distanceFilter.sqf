/*
   Author:
    rübe
    
   Description:
    filters out positions/objects too near to each other
    according to a given distance, or their average
    bounding circle.
    
   Parameter(s):
    _this select 0: positions or objects (array)
    _this select 1: min. distance (scalar)
                    - optional. if none is given, the avg. bounding 
                      circle (a bit more) of the two objects will be 
                      used.
                      
                       PS. make sure you pass objects and not 
                      position if you do that!
   
   Returns:
    array
*/

private ["_filtered", "_list", "_minDist", "_toPosition", "_test", "_i", "_pass"];

_filtered = [];

_list = _this select 0;
_minDist = -1;
if ((count _this) > 1) then
{
   _minDist = _this select 1;
};

// return empty list
if ((count _list) == 0) exitWith
{
   _list
};

// any => position
_toPosition = {
   if ((typeName _this) == "ARRAY") exitWith
   {
      _this
   };
   
   (position _this)
};

// [p1, p2] => boolean
_test = {
   ((((_this select 0) call _toPosition) distance ((_this select 1) call _toPosition)) >= _minDist)
};
// bounding circle check?
if (_minDist < 0) then
{
   _test = {
      private ["_b1", "_b2", "_d"];
      _b1 = (_this select 0) call RUBE_boundingBoxSize;
      _b2 = (_this select 1) call RUBE_boundingBoxSize;
      _d = (((_b1 select 0) max (_b1 select 1)) + ((_b2 select 0) max (_b2 select 1))) * 0.65;
      
      (((_this select 0) distance (_this select 1)) >= _d)
   };
};

_filtered set [0, (_list select 0)];

for "_i" from 1 to ((count _list) - 1) do
{
   _pass = true;
   
   {
      if (!([(_list select _i), _x] call _test)) exitWith
      {
         _pass = false;
      };
   } forEach _filtered;
   
   if (_pass) then
   {
      _filtered set [(count _filtered), (_list select _i)];
   };
};



// return 
_filtered