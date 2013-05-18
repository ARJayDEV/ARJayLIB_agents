/*
  Author: 
   rübe
  
  Description:
   Controlled/limited randomization of a position. Only x and y coord. are randomized.
  
  Parameter(s):
  _this select 0: center position (position)
  _this select 1: minimum x/y distance from center position (Array with two numbers)
  _this select 2: maximum x/y distance from center position (Array with two numbers)
  
  Example:
  _centerPos = [100, 100, 0];
  _randomizedPos = [_centerPos, [10, 10], [100, 100]] call RUBE_randomizePos;
  => [112, 75, 0]
  
  Returns:
  position
*/

private ["_pos", "_min", "_max", "_newPos", "_diff"];
_pos = _this select 0;
_min = _this select 1;
_max = _this select 2;

// we need to copy(!) that array
_newPos = + _pos;

for "_i" from 0 to 1 do
{
   _diff = (_min select _i) + (random ((_max select _i) - (_min select _i)));
   if ((random 100) > 50) then 
   {
      _diff = _diff * -1;
   };
   _newPos set [_i, ((_pos select _i) + _diff)];
};

// return pos
_newPos