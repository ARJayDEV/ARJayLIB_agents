/*
  File: arrayRandomSelect.sqf
  Author: rübe
  
  Description:
  Returns a random item from an array. Nice and simple. (just in case BIS_fnc_randomIndex feels too awkward, hehe)
  
  Parameter(s):
  _this: Array (array)
  
  Example:
  _array = [1, 2, 3, 4, 5];
  _item = _array call RUBE_arrayRandomSelect;
  => 3
  
  Returns:
  any
*/

// return random item
(_this select (floor (random (count _this))))

