/*
   Author:
    rübe
    
   Description:
    spawns the desired group from a faction. 
    
    The goal here is to give the factions some different nature. For example 
    a GUER group might be highly randomized, while a US or RU group is 
    standardized... and since we use RUBE_spawnFactionUnit, the units are 
    spawned with loadout-correction and some skill tweaking.
       Also note that we sometimes use vehicles from other sides/factions but 
    the spawnVehicle/-Crew and selectCrew have been adapted to always spawn 
    the crew from the correct faction.
       
    
    And as always: feel free to change or extend the list of 
                   available groups as you go.
    
   Parameter(s):
    _this: parameters (array of array [key (string), value (any)])
    
           - required:
           
             - "type" (string OR array [[vehicles], [unitclasses or [unitclass, rank]]])
                  Type/Name of the group to be spawned.
                  unitclass may be a token: "grunt" or "mixed" for a random type.
                  
               Available types:
                - infantery: ["pltHQ", "squad", "fireteam", "at", "assault", "aa", "mg", "sniper", "enigneer", "saboteur"]
                - motorized: ["motInf", "motInfExt", "motPatrol", "motAT", "mechInf", "mechRecon", "rescueTeam"]
                  - motInfExt has an extra jeep, so they're really mobile
                - armored:   ["tankPlatoon" (4x heavy tanks), "tankSection" (2x light tanks)]
                - air:       ["airAttackSquadron" (rotary), airATSquadron (fixed), airAASquadron (fixed)]
             
             - "faction" (string)
             
           - optional:
           
             - "group" (group)
                  Join an existing group instead of creating a 
               new one.
             
             - "position" (position)
             
             - "direction" (scalar)
             
             - "special" (unit-type (string) OR array of unit-types)
               - set's special units, such as the 4th men in every fireteam.
                 Use this to specialize fireteams (making them balanced, AT or AA)
                 - note that the 4th men in a fireteam is random per default
                 - this has an effect on "squad", "fireteam", "motInf" and "mechInf"
             
             - "moveInCargo" (boolean)
                  Tries to move given units into the cargo of the given vehicle(s).
               We put the first unassigned unit into the first vehicle with empty 
               cargo possitions. For more elaborate control, call spawnFunctionGroup
               multiple times, while passing the group along...
               Default = false.
   
   Returns:
    group
*/

private ["_type", "_faction", "_group", "_newGroup", "_position", "_direction", "_composite", "_vehicles", "_vehiclePosOffset", "_special", "_moveInCargo", "_customSelection", "_randomLeader", "_randomGrunt", "_randomMixed", "_randomRank", "_getSpecial", "_i"];

_type = "";
_faction = "GUE";
_group = grpNull;
_newGroup = false;
_position = [0,0,0];
_direction = random 360;
_composite = [];
_vehicles = [];
_vehiclePosOffset = 8;
_special = "";
_moveInCargo = false;

_customSelection = [];

// read parameters
{
   switch (_x select 0) do
   {
      case "type": { 
         if ((typeName (_x select 1)) == "ARRAY") then
         {
            _type = "custom";
            _customSelection = (_x select 1); 
         } else
         {
            _type = _x select 1;
         };
      };
      case "faction": { _faction = _x select 1; };
      case "group": { _group = _x select 1; };
      case "position": { _position = _x select 1; };
      case "direction": { _direction = _x select 1; };
      case "special": { _special = _x select 1; };
      case "moveInCargo": { _moveInCargo = _x select 1; };
   };
} forEach _this;


// init special
if ((typeName _special) != "ARRAY") then
{
   if (_special == "") then
   {
      _special = [];
   } else
   {
      _special = [_special];
   };
};


// create new group
if (isNull _group) then
{
   private ["_factionInfo"];
   _factionInfo = _faction call RUBE_selectFactionInfo;
   _group = createGroup (_factionInfo select 0);
   _newGroup = true;
};

// some private functions
_randomLeader = {
   (["sl", "tl"] call RUBE_randomSelect)
};

_randomGrunt = {
   (["r", "r", "lat", "lat", "grenadier", "marksman"] call RUBE_randomSelect)
};

_randomMixed = {
   (["r", "r", "r", "r", "r", "r", "r", "aar", "mg", "ar", "ar", "engineer", "saboteur",
     "aa", "at", "lat", "lat", "grenadier", "grenadier", "marksman", "medic"] call RUBE_randomSelect)
};

_randomRank = {
   (["PRIVATE", "PRIVATE", "PRIVATE", "CORPORAL", "CORPORAL", "SERGEANT"] call RUBE_randomSelect)
};

_getSpecial = {
   if ((count _special) == 0) exitWith
   {
      ([] call _randomGrunt)
   };
   
   (_special select (_this % (count _special)))
};

// map custom selection (replaceing random tokens)
if (_type == "custom") then
{
   [
      (_customSelection select 1),
      {
         if ((typeName _this) == "ARRAY") exitWith { _this };
         if (_this == "grunt") exitWith { ([] call _randomGrunt) };
         if (_this == "mixed") exitWith { ([] call _randomMixed) };
         _this
      }
   ] call RUBE_arrayMap;
};


switch (_type) do
{
   // INFANTERY //
   
   case "pltHQ":
   {
      switch (true) do
      {
         // guerilla and insurgent squads aren't that well organized
         case (_faction in ["GUE", "TK_GUE", "INS", "TK_INS"]):
         {
            _composite = [
               ["officer", "MAJOR"],
               [([] call _randomLeader), "CAPTAIN"],
               [([] call _randomLeader), "LIEUTENANT"]
            ];
            // plus up to 3 mixed units
            for "_i" from 0 to (floor (random 3)) do
            {
               _composite set [(count _composite), [([] call _randomMixed), ([] call _randomRank)]];
            };
         };
         default
         {
            _composite = [
               ["officer", "MAJOR"],
               [([] call _randomLeader), "CAPTAIN"],
               ["medic", "LIEUTENANT"],
               ["r", "CORPORAL"]
            ];
         };
      };
   };
   case "squad":
   {
      switch (true) do
      {
         // guerilla and insurgent squads aren't that well organized
         // so we don't have fireteams/that much teamleaders
         case (_faction in ["GUE", "TK_GUE", "INS", "TK_INS"]):
         {
            _composite = [
               [([] call _randomLeader), "LIEUTENANT"],
               ["ar", "SERGEANT"],
               ["medic", "PRIVATE"]
            ];
            // 10-14 units in a squad
            for "_i" from 0 to (6 + (floor (random 5))) do
            {
               if ((_i > 0) && ((_i % 3) == 0)) then
               {
                  _composite set [(count _composite), [(_i call _getSpecial), ([] call _randomRank)]];
               } else
               {
                  _composite set [(count _composite), [([] call _randomMixed), ([] call _randomRank)]];
               };
            };
         };
         default
         {
            _composite = [
               ["sl", "LIEUTENANT"],
               ["medic", "PRIVATE"]
            ];
            // plus 3 fireteams
            for "_i" from 0 to 2 do
            {
               _composite set [(count _composite), ["tl", "SERGEANT"]];
               _composite set [(count _composite), ["ar", "CORPORAL"]];
               _composite set [(count _composite), ["aar", "PRIVATE"]];
               _composite set [(count _composite), [(_i call _getSpecial), "PRIVATE"]];
            };
         };
      };
   };
   case "fireteam":
   {
      switch (true) do
      {
         // guerilla and insurgent squads aren't that well organized
         // so we don't have teamleaders
         case (_faction in ["GUE", "TK_GUE", "INS", "TK_INS"]):
         {
            // 4-5 units
            for "_i" from 0 to (3 + (floor (random 2))) do
            {
               if ((_i > 0) && ((_i % 3) == 0)) then
               {
                  _composite set [(count _composite), [(_i call _getSpecial), ([] call _randomRank)]];
               } else
               {
                  _composite set [(count _composite), [([] call _randomMixed), ([] call _randomRank)]];
               };
            };
         };
         default
         {
            _composite = [
               ["tl", "SERGEANT"],
               ["ar", "CORPORAL"],
               ["aar", "PRIVATE"],
               [(0 call _getSpecial), "PRIVATE"]
            ];
         };
      };
   };
   case "at":
   {
      switch (_faction) do
      {
         default
         {
            _composite = [
               ["hat", "SERGEANT"],
               ["ahat", "CORPORAL"]
            ];
         };
      };
   };
   case "assault":
   {
      switch (_faction) do
      {
         default
         {
            _composite = [
               ["at", "SERGEANT"],
               ["aat", "CORPORAL"]
            ];
         };
      };
   };
   case "aa":
   {
      switch (_faction) do
      {
         default
         {
            _composite = [
               ["aa", "SERGEANT"],
               ["aar", "CORPORAL"]
            ];
         };
      };
   };
   case "mg":
   {
      switch (_faction) do
      {
         default
         {
            _composite = [
               ["mg", "SERGEANT"],  
               ["amg", "CORPORAL"], 
               ["r", "CORPORAL"]
            ];
         };
      };
   };
   case "sniper":
   {
      switch (_faction) do
      {
         default
         {
            _composite = [
               ["sniper", "SERGEANT"],
               ["spotter", "CORPORAL"]
            ];
         };
      };
   };
   case "engineer":
   {
      switch (_faction) do
      {
         default
         {
            _composite = [
               ["engineer", "SERGEANT"],  
               ["engineer", "CORPORAL"], 
               ["engineer", "CORPORAL"],
               ["engineer", "CORPORAL"]
            ];
         };
      };
   };
   case "saboteur":
   {
      switch (_faction) do
      {
         default
         {
            _composite = [
               ["saboteur", "SERGEANT"],  
               ["saboteur", "CORPORAL"], 
               ["saboteur", "CORPORAL"],
               ["saboteur", "CORPORAL"]
            ];
         };
      };
   };
   
   // MOTORIZED //
   
   case "motInf":
   {
      switch (_faction) do
      {
         default
         {
            _vehicles = [
               (["mobile-mg", _faction] call RUBE_selectFactionVehicle),
               (["mobile-mortar", _faction] call RUBE_selectFactionVehicle)
            ];
            _composite = [
               ["tl", "SERGEANT"],
               ["ar", "CORPORAL"],
               ["at", "CORPORAL"],
               ["ar", "CORPORAL"],
               [(0 call _getSpecial), "PRIVATE"],
               [(1 call _getSpecial), "PRIVATE"]
            ];
         };
      };
   };
   
   case "motInfExt":
   {
      switch (_faction) do
      {
         default
         {
            _vehicles = [
               (["mobile-mg", _faction] call RUBE_selectFactionVehicle),
               (["mobile-mortar", _faction] call RUBE_selectFactionVehicle),
               (["mobile", _faction] call RUBE_selectFactionVehicle)
            ];
            _composite = [
               ["tl", "SERGEANT"],
               ["ar", "CORPORAL"],
               ["at", "CORPORAL"],
               ["ar", "CORPORAL"],
               [(0 call _getSpecial), "PRIVATE"],
               [(1 call _getSpecial), "PRIVATE"]
            ];
         };
      };
   };
   
   case "motPatrol":
   {
      switch (_faction) do
      {
         default
         {
            _vehicles = [
               (["mobile-mg", _faction] call RUBE_selectFactionVehicle),
               (["mobile-at", _faction] call RUBE_selectFactionVehicle)
            ];
            _composite = [
               ["tl", "SERGEANT"],
               [([] call _randomGrunt), "PRIVATE"]
            ];
         };
      };
   };
   
   case "motAT":
   {
      switch (_faction) do
      {
         default
         {
            _vehicles = [
               (["mobile-at", _faction] call RUBE_selectFactionVehicle),
               (["mobile-at", _faction] call RUBE_selectFactionVehicle)
            ];
            _composite = [
               ["tl", "SERGEANT"],
               ["ar", "PRIVATE"]
            ];
         };
      };
   };
   case "mechInf":
   {
      switch (true) do
      {
         // guer/ins special
         case (_faction in ["GUE", "TK_GUE", "INS", "TK_INS"]):
         {
            _vehicles = [
               (["mech-transport", _faction] call RUBE_selectFactionVehicle),
               (["mech-assault", _faction] call RUBE_selectFactionVehicle)
            ];
            _composite = [
               [([] call _randomLeader), "LIEUTENANT"],
               ["ar", "SERGEANT"],
               ["medic", "CORPORAL"]
            ];
            // 10-14 units in a squad
            for "_i" from 0 to (6 + (floor (random 5))) do
            {
               if ((_i > 0) && ((_i % 3) == 0)) then
               {
                  _composite set [(count _composite), [(_i call _getSpecial), ([] call _randomRank)]];
               } else
               {
                  _composite set [(count _composite), [([] call _randomMixed), ([] call _randomRank)]];
               };
            };
         };  
         // only one vehicle needed
         case (_faction in ["USMC"]):
         {
            _vehicles = [
               (["mech-transport", _faction] call RUBE_selectFactionVehicle)
            ];
            _composite = [
               ["sl", "LIEUTENANT"],
               ["medic", "SERGEANT"]
            ];
            // plus 3 fireteams
            for "_i" from 0 to 2 do
            {
               _composite set [(count _composite), ["tl", "SERGEANT"]];
               _composite set [(count _composite), ["ar", "CORPORAL"]];
               _composite set [(count _composite), ["aar", "PRIVATE"]];
               _composite set [(count _composite), [(_i call _getSpecial), "PRIVATE"]];
            };
         };  
         // default needs two vehicles  
         default
         {
            _vehicles = [
               (["mech-transport", _faction] call RUBE_selectFactionVehicle),
               (["mech-transport", _faction] call RUBE_selectFactionVehicle)
            ];
            _composite = [
               ["sl", "LIEUTENANT"],
               ["medic", "SERGEANT"]
            ];
            // plus 3 fireteams
            for "_i" from 0 to 2 do
            {
               _composite set [(count _composite), ["tl", "SERGEANT"]];
               _composite set [(count _composite), ["ar", "CORPORAL"]];
               _composite set [(count _composite), ["aar", "PRIVATE"]];
               _composite set [(count _composite), [(_i call _getSpecial), "PRIVATE"]];
            };
         };
      };  
   };  
   case "mechRecon":
   {
      switch (true) do
      {
         // guer mech vehicle might have less free positions...
         case (_faction in ["GUE", "TK_GUE", "INS", "TK_INS"]):
         {
            _vehicles = [
               (["mech-assault", _faction] call RUBE_selectFactionVehicle)
            ];
            _composite = [
               ["tl", "LIEUTENANT"],
               [([] call _randomGrunt), "SERGEANT"],
               [([] call _randomGrunt), "CORPORAL"],
               [([] call _randomGrunt), "PRIVATE"]
            ];
         };
         default
         {
            _vehicles = [
               (["mech-assault", _faction] call RUBE_selectFactionVehicle)
            ];
            _composite = [
               ["tl", "LIEUTENANT"],
               ["ar", "SERGEANT"],
               [([] call _randomGrunt), "SERGEANT"],
               [([] call _randomGrunt), "CORPORAL"],
               [([] call _randomGrunt), "CORPORAL"],
               [([] call _randomGrunt), "PRIVATE"]
            ];
         };
      };
   };
   
   case "rescueTeam":
   {
      switch (_faction) do
      {
         default
         {
            _vehicles = [
               (["mobile-mg", _faction] call RUBE_selectFactionVehicle),
               (["mobile-medic", _faction] call RUBE_selectFactionVehicle),
               (["mobile-medic", _faction] call RUBE_selectFactionVehicle)
            ];
            _composite = [
               ["tl", "LIEUTENANT"],
               ["ar", "SERGEANT"],
               ["medic", "CORPORAL"],
               ["medic", "CORPORAL"]
            ];
         };
      };
   };
   
   
   // ARMORED //
   
   case "tankPlatoon":
   {
      _vehiclePosOffset = 12;
      
      switch (_faction) do
      {
         default
         {
            _vehicles = [
               (["tank-heavy", _faction] call RUBE_selectFactionVehicle),
               (["tank-heavy", _faction] call RUBE_selectFactionVehicle),
               (["tank-heavy", _faction] call RUBE_selectFactionVehicle),
               (["tank-heavy", _faction] call RUBE_selectFactionVehicle)
            ];
         };
      };
   };
   
   case "tankSection":
   {
      _vehiclePosOffset = 12;
      
      switch (_faction) do
      {
         default
         {
            _vehicles = [
               (["tank-light", _faction] call RUBE_selectFactionVehicle),
               (["tank-light", _faction] call RUBE_selectFactionVehicle)
            ];
         };
      };
   };
   
   
   // AIR //
   //   adjust _vehiclePosOffset to prevent instant crashes! //
   
   case "airAttackSquadron":
   {
      _vehiclePosOffset = 40;
      
      switch (_faction) do
      {
         default
         {
            _vehicles = [
               (["air-attack", _faction] call RUBE_selectFactionVehicle),
               (["air-attack", _faction] call RUBE_selectFactionVehicle)
            ];
         };
      };
   };
   
   case "airATSquadron":
   {
      _vehiclePosOffset = 50;
      
      switch (_faction) do
      {
         default
         {
            _vehicles = [
               (["air-at", _faction] call RUBE_selectFactionVehicle),
               (["air-at", _faction] call RUBE_selectFactionVehicle)
            ];
         };
      };
   };
   
   case "airAASquadron":
   {
      _vehiclePosOffset = 50;
      
      switch (_faction) do
      {
         default
         {
            _vehicles = [
               (["air-aa", _faction] call RUBE_selectFactionVehicle),
               (["air-aa", _faction] call RUBE_selectFactionVehicle)
            ];
         };
      };
   };
   
   // custom selection
   case "custom":
   {
      _vehicles = [
         (_customSelection select 0),
         {
            ([_this, _faction] call RUBE_selectFactionVehicle)
         }
      ] call RUBE_arrayMap;
      
      _composite = [
         (_customSelection select 1),
         {
            if ((typeName _this) == "ARRAY") exitWith { _this };
            [_this, ([] call _randomRank)]
         }
      ] call RUBE_arrayMap;
      
      if ((count _vehicles) > 0) then
      {
         _vehiclePosOffset = 12;
      }; 
   };
};




// spawn composite
private ["_vehiclePositions", "_isVehicleLeader", "_spawnPos", "_veh", "_unit", "_units", "_n"];

// create extra vehicle positions so they won't
// injure infantery (or bounce) in case this
// function is run that fast that isFlatEmpty
// doesn't catch up.. (which is most likely at mission
// start).. but using spawn isn't an option, for the
// group we return has to be complete at that point...
_vehiclePositions = [];

_n = count _vehicles;
if (_n > 0) then
{
   private ["_start"];
   _start = (floor (_n * 0.5)) * _vehiclePosOffset;
   
   for "_i" from 0 to ((count _vehicles) - 1) do
   {
      _vehiclePositions set [_i, ([
         _position, 
         [(_start + (_i * _vehiclePosOffset)), _vehiclePosOffset, 0], 
         _direction
      ] call RUBE_gridOffsetPosition)];
   };
};

// void => boolean
_isVehicleLeader = {
   if ((count _composite) == 0) exitWith
   {
      true
   };
   if (((_composite select 0) select 0) in ["officer", "sl", "tl"]) exitWith
   {
      false
   };
   true
};

// [position, radius] ==> pos
_spawnPos = {
   private ["_pos"];
   _pos = (_this select 0) isFlatEmpty [
      (_this select 1),
      40.0,
      0.5,
      (_this select 1),
      0,
      false,
      objNull
   ];
   if ((count _pos) == 0) exitWith
   {
      _position
   };

   _pos
};

// ... units
_units = [];
_n = count _composite;
if (_n > 0) then
{
   for "_i" from 0 to (_n - 1) do
   {
      _unit = [((_composite select _i) select 0), _faction, _group, ([_position, 2] call _spawnPos)] call RUBE_spawnFactionUnit;
      _unit setRank ((_composite select _i) select 1);
      
      // register units in reversed order (so we may easily pop them again)
      _units set [((_n - 1) - _i), _unit];
   
      // make first unit leader for new groups
      if ((_i == 0) && _newGroup) then
      {
         _group selectLeader _unit;
      };
   };
};

// ... vehicles
_n = count _vehicles;
if (_n > 0) then
{
   for "_i" from 0 to (_n - 1) do
   {
      _veh = [
         ([(_vehiclePositions select _i), 6] call _spawnPos), 
         _direction, 
         (_vehicles select _i), 
         _group, 
         _faction
      ] call RUBE_spawnVehicle;
      
      if ((_i == 0) && _newGroup) then
      {
         if ([] call _isVehicleLeader) then
         {
            _group selectLeader (commander (_veh select 0));
         };
      };
      
      // cargo?
      if (_moveInCargo && ((count _units) > 0)) then
      {
         private ["_freeCargo", "_u"];
         _freeCargo = (_veh select 0) emptyPositions "Cargo";
         while {((_freeCargo > 0) && ((count _units) > 0))} do
         {
            _u = _units call BIS_fnc_arrayPop;
            _u assignAsCargo (_veh select 0);
            _u moveInCargo (_veh select 0);
            [_u] orderGetIn true;
            _freeCargo = _freeCargo - 1;
         };
      };
   };
};


// return group
_group