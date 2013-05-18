/*
  Author: 
   rübe
  
  Description:
   Returns a scaled bounding box
  
  Parameter(s):
  _this select 0: object (object)
  _this select 1: factor(s) (number or array-of-3-numbers/matrix)
  _this select 2: model (false) or world-coordinates (true) (boolean - optional, default = true)
  
  Returns:
  array of [min, max, center]
*/

private ["_obj", "_f", "_worldCoordinates"];

_obj = _this select 0;
_f = _this select 1;

if (typeName _f != "ARRAY") then
{
   _f = [_f, _f, _f];
};

_worldCoordinates = true;
if ((count _this) > 2) then { _worldCoordinates = _this select 2; };


private ["_box", "_ct", "_b1", "_b2", "_p1", "_p2"];

_box = boundingBox _obj;
_ct = boundingCenter _obj;

_b1 = (_box select 0);
_b2 = (_box select 1);

_box set [0, [((_b1 select 0) * (_f select 0)), ((_b1 select 1) * (_f select 1)), ((_b1 select 2) * (_f select 2))]];
_box set [1, [((_b2 select 0) * (_f select 0)), ((_b2 select 1) * (_f select 1)), ((_b2 select 2) * (_f select 2))]];

_p1 = (_box select 0);
_p2 = (_box select 1);

if (_worldCoordinates) then
{
  _p1 = _obj modelToWorld (_box select 0);
  _p2 = _obj modelToWorld (_box select 1);
  _ct = _obj modelToWorld _ct;
};


// return
[_p1, _p2, _ct]