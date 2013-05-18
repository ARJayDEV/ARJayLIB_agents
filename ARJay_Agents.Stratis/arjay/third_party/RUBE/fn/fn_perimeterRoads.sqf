/*
   Author:
    rübe
    
   Description:
    searchs and returns roads around a given position.
    
   Parameter(s):
    _this: parameters (array of array [key (string), value (any)])
    
           - required:
           
             - "position" (position)
             
           - optional:
           
             - "radius" (scalar)
               - default = 500
               
             - "deviance" (scalar from 0.0 to 1.0)  
               distance deviance for sample position
               - default = 0.2
               
             - "sector" (array [start, end])
               - default =  [0, 360]
               
             - "step" (scalar in degree)
               - default = 12
               
             - "minDistance" (scalar)
               - default = 100
               
             - "sideRadius" (scalar)
               radius for isFlatEmpty-check for side positions
               - default = 3.5;
               
             - "maxGradient" (scalar)
               for side positions
               - default = 0.31
               
   Returns:
    array of [road-object, outwards/away-direction, sidePositions] OR
    empty array
*/

private ["_center", "_radius", "_deviance", "_sector", "_step", "_minDistance", "_sideRadius", "_maxGradient"];

_center = [0,0,0];
_radius = 500;
_deviance = 0.2; // dist. deviance
_sector = [0, 360];
_step = 12;
_minDistance = 100;
_sideRadius = 3.5;
_maxGradient = 0.31;

// read parameters
{
   switch (_x select 0) do
   {
      case "position": { _center = _x select 1; };
      case "radius": { _radius = _x select 1; };
      case "deviance": { _deviance = _x select 1; };
      case "sector": { _sector = _x select 1; };
      case "step": { _step = _x select 1; };
      case "minDistance": { _minDistance = _x select 1; };
      case "sideRadius": { _sideRadius = _x select 1; };
      case "maxGradient": { _maxGradient = _x select 1; };
   };
} forEach _this;


if ((typeName _center) != "ARRAY") then
{
   _center = position _center;
};


private ["_getRelDir", "_getSidePositions", "_roads", "_sampleRadius", "_arc", "_start", "_i", "_pos", "_sample", "_filtered", "_passed", "_obj"];

_getRelDir = {
   private ["_obj", "_dir", "_rel"];
   _obj = _this;
   _dir = direction _this;
   _rel = ([_center, _obj] call BIS_fnc_dirTo) call RUBE_normalizeDirection;
   
   if ([_dir, (_rel - 90), (_rel + 90)] call RUBE_dirInArc) exitWith
   {
      _dir
   };
   
   (_dir - 180)
};

_getSidePositions = {
   private ["_obj", "_dir", "_box", "_dx", "_sidePositions", "_p"];
   _obj = _this;
   _dir = direction _obj;
   _box = _this call RUBE_boundingBoxSize;
   _dx = (((_box select 0) min (_box select 1)) * 0.5) + (_sideRadius * 0.5) + 0.25;
   
   _sidePositions = [];
   {
      _p = [(_x select 0), (_x select 1), 0];
      _p = _p isFlatEmpty [
         _sideRadius,
         0.5,
         _maxGradient,
         _sideRadius,
         0,
         false,
         objNull
      ];
      if ((count _p) > 0) then
      {
         _sidePositions set [(count _sidePositions), _p];
      };
   } forEach [
      ([_obj, _dx, (_dir + 90)] call BIS_fnc_relPos),
      ([_obj, _dx, (_dir - 90)] call BIS_fnc_relPos)
   ];
   
   
   _sidePositions
};






// search roads
_roads = [];

_sampleRadius = _radius * (sin (_step * 0.5));
_arc = (_sector select 1) - (_sector select 0);
_start = _sector select 0;
_i = 0;

if (_arc == 360) then
{
   _start = random 360;
};

while {(_i < _arc)} do
{
   _pos = [_center, (_radius * ((1.0 - _deviance) + (random (_deviance * 2)))), ((_start + _i) % 360)] call BIS_fnc_relPos;
   _pos set [2, 0];
   _sample = [
      (_pos nearRoads _sampleRadius),
      {
         if (!(_this call RUBE_WORLD_isRoad)) exitWith { false };
         private ["_box", "_dx"];
         _box = _this call RUBE_boundingBoxSize;
         _dx = (((_box select 0) min (_box select 1)) * 0.5) + _sideRadius;
         if ((count ((position _this) isFlatEmpty [_dx, 0, _maxGradient, _dx, 0, false, _this])) == 0) exitWith { false };
         true
      }
   ] call RUBE_arrayFilter;
   if ((count _sample) > 0) then
   {
      _roads set [(count _roads), (_sample call RUBE_randomSelect)];
   };
   _i = _i + _step;
};

// filter roads
_filtered = [];

{
   _passed = true;
   _obj = _x;
   {
      if ((_x distance _obj) < _minDistance) exitWith 
      {
         _passed = false;
      };
   } forEach _filtered;
   if (_passed) then
   {
      _filtered set [(count _filtered), _obj];
   };
} forEach _roads;


// map roads (add direction)
_filtered = [
   _filtered,
   {
      [_this, (_this call _getRelDir), (_this call _getSidePositions)]
   }
] call RUBE_arrayMap;


// return roads
_filtered