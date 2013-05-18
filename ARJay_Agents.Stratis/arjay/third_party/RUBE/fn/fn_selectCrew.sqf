/*
   Author:
    rübe
    
   Description:
    returns an appropriate crew type for a given vehicle 
    and faction(!).
    
   Parameter(s):
    _this select 0: vehicle config entry (config)
    _this select 1: faction (string)
    
   Returns:
    crew unit class (string)
*/

private ["_cfg", "_faction", "_getRole", "_type"];

_cfg = _this select 0;
_faction = _this select 1;

// tries to extract the crew role (regular unit, crew, pilot)
// from the given configs crew class
_getRole = {
   private ["_role"];
   _role = "r";

   switch (true) do
   {
      case (["Pilot", _this] call RUBE_inString):
      {
         _role = "pilot";
      };
      case (["Crew", _this] call RUBE_inString):
      {
         _role = "crew";
      };
   };
   _role
};

_type = (getText (_cfg >> "crew")) call _getRole;

// return crew from the correct faction
([_type, _faction] call RUBE_selectFactionUnit)