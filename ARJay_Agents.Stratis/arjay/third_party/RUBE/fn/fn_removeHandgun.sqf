/*
  Author:
   rübe
   
  Description:
   removes the handgun(s) from the given unit(s).
  
  Parameters:
   _this: some unit(s) (object OR array of objects)
   
  Returns:
   void
*/

private ["_units"];

_units = _this;
if ((typeName _this) != "ARRAY") then
{
   _units = [_this];
};

for "_i" from 0 to ((count _units) - 1) do
{
   {
      if ((getNumber (configFile/"CfgWeapons"/_x/"type")) == 2) then
      {
         (_units select _i) removeWeapon _x;
      }; 
   } forEach (weapons (_units select _i));
};

true