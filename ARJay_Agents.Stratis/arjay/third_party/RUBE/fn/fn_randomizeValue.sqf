/*
   Author:
    rübe
    
   Description:
    randomizes a given value at a given max. amount, either 
    + or -
   
   Parameter(s):
    _this select 0: given value (number)
    _this select 1: max. random amount, applied +/- (number)
    
   Returns:
    number 
   
*/
private ["_value", "_diff"];

_value = _this select 0;
_diff = random (_this select 1);

if ((random 100) > 50) then { _diff = _diff * -1; };

// return value
(_value + _diff)