/*
   Author:
    rübe
    
   Description:
    returns true if the given object/class is male.
   
   Parameter(s):
    _this: object OR string

   Returns:
    boolean
*/

private ["_class", "_config", "_genericName"];

_class = _this;

if ((typeName _class) == "OBJECT") then
{
   _class = typeOf _this;
};

_config = (configFile >> "CfgVehicles" >> _class);
_genericName = (getText (_config >> "genericNames"));



// check if Women is in genericName
if (["Women", _genericName] call RUBE_inString) exitWith
{
   false
};

true