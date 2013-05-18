/*
   Author:
    rübe
    
   Description:
    checks whether the given string refers to a magazine or not (.. and
    thus would require a `weaponholder` to be spawned in)
    
   Parameter(s):
    _this: magazine (string)
    
   Returns:
    boolean
    
   Requires:
    BIS function library OR BIS_fnc_classMagazine.sqf defined
*/

(isClass ([_this] call BIS_fnc_classMagazine))