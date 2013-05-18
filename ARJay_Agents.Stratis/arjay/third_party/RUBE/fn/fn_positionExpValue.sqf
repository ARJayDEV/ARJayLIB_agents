/*
   Author:
    rübe
    
   Description:
    evaluates a cutsom expression (see selectBestPlaces) at a given
    position and returns the value.
    
   Parameter(s):
    _this select 0: position (position)
    _this select 1: expression (string)
                    - keywords (maybe not complete, but known to be working):
                      [
                         forest, trees, meadow, hills, houses, sea,
                         night, rain, windy, deadBody
                      ]
    _this select 2: sample radius (scalar)
                    - optional, default = 6
    _this select 3: sample precision (scalar)
                    - optional, default = 3
    
   Returns:
    scalar
*/

private ["_sample", "_radius", "_precision"];

_radius = 6;
if ((count _this) > 2) then
{
   _radius = _this select 2;
};

_precision = 3;
if ((count _this) > 3) then
{
   _precision = _this select 2;
};

_sample = selectBestPlaces [
   (_this select 0),
   _radius,
   (_this select 1),
   _precision,
   1
];

if ((count _sample) < 1) exitWith
{
   -1
};

// return value
((_sample select 0) select 1)
