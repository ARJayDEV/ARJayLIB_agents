/*
   Author:
    rübe
    
   Description:
    closes doors from buildings in a given area.
    
   Parameter(s):
    _this select 0: position (position)
    _this select 1: radius (scalar, optional)
                    - default = 1000
    _this select 2: chance/"proportion" to close a door (scalar from 0.0 to 1.0, optional)
                    - default = 1.0
   
   Returns:
    void
*/

private ["_position", "_radius", "_chance"];

_position = _this select 0;
_radius = 1000;
_chance = 1.0;

if ((count _this) > 1) then
{
   _radius = _this select 1;
};

if ((count _this) > 2) then
{
   _chance = _this select 2;
};

// closeing doors
{
   for "_i" from 1 to 15 do
   {
      if ((random 1.0) < _chance) then
      {
         _x animate [format["dvere%1", _i], 1.0];
         _x animate [format["vrataL%1", _i], 1.0];
         _x animate [format["vrataR%1", _i], 1.0];
         if (_i > 9) then
         {
            _x animate [format["door_%1", _i], 1.0];
         } else
         {
            _x animate [format["door_0%1", _i], 1.0];
         };
      };
   };
} forEach (nearestObjects [_position, ["Buildings"], _radius]);