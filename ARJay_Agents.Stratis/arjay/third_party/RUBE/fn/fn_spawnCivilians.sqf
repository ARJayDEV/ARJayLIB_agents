/*
   Author:
    rübe
    
   Description:
    spawn civilians of a given number, type and side
    
   Parameter(s):
    _this: parameters (array of array [key (string), value (any)])
    
           - required:
             
             - "number" (int)
               number of spawned civilians 
               
             - "position" (position)

               
           - optional:
           
             - "radius" (scalar)
                 placement radius
                Default = 200;
           
             - "type" string
                 ethnic group. (you may have groups with multiple
                 types and exact proportion by chain-spawning them,
                 that is, passing the first created group to 
                 subsequent calls)
                types: ruralCR, urbanCR, ruralRU, urbanRU, TK
                Default: ruralCR
           
             - "sex" (int from 0.0 to 1.0)
                 proportion of male/female (NOT EXACT, it's a chance)
                0.0 = 100% male
                1.0 = 100% female
                Default = 0.67;
           
             - "side" (side)
                side of the civilian group. Make sure the
               side has a side center up and running.
               Default = Civilian
               
             - "faction" (string)
                 may be used instead of "side", taking the
                default side of the given faction.
               
             - "group" (group)
                group to join. If non is given, a new one
               will be created, if used "side" has no effect.
               
    
   Returns:
    group
*/

private ["_position", "_radius", "_adjustPos", "_number", "_side", "_faction", "_type", "_sex", "_group", "_positions", "_unit"];

_position = [0,0,0];
_radius = 200;
_adjustPos = 1.0;

_number = 0;
_side = Civilian;
_faction = "";
_type = "ruralCR";
_sex = 0.67;
_group = grpNull;

// read parameters
{
   switch (_x select 0) do
   {
      case "position": { _position = _x select 1; };
      case "radius": { _radius = _x select 1; };
      case "number": { _number = _x select 1; };
      case "type": { _type = _x select 1; };
      case "sex": { _sex = _x select 1; };
      case "side": { _side = _x select 1; };
      case "faction": { _faction = _x select 1; };
      case "group": { _group = _x select 1; };
   };
} forEach _this;

// check critical input
if (_number < 1) exitWith {
   _group
};


// create new group
if (isNull _group) then
{
   if (_faction != "") then
   {
      private ["_factionInfo"];
      _side = (_faction call RUBE_selectFactionInfo) select 0;
   };
   
   _group = createGroup _side;
   // initial waypoint for new groups
   [
      ["group", _group],
      ["type", "DISMISS"],
      ["behaviour", "SAFE"],
      ["speed", "LIMITED"]
   ] call RUBE_updateWaypoint;
};



// create pool
private ["_fillPool", "_civilians", "_prefix"];

// [prefix, male, female] => void
_fillPool = {
   private ["_male", "_female"];
   _male = [];
   _female = [];
   while {((count _civilians) < _number)} do
   {
      if ((random 1.0) < _sex) then
      {
         // female
         if ((count _female) == 0) then
         {
            _female = + (_this select 2)
         };
         _civilians set [
            (count _civilians), 
            format["%1%2", (_this select 0), (_female call RUBE_randomPop)]
         ];
      } else
      {
         // male
         if ((count _male) == 0) then
         {
            _male = + (_this select 1)
         };
         _civilians set [
            (count _civilians), 
            format["%1%2", (_this select 0), (_male call RUBE_randomPop)]
         ];
      };
   };
};


_civilians = [];

switch (true) do
{
   case (_type in ["TK"]):
   {
      [
         "",
         [
            "TK_CIV_Takistani01_EP1",
            "TK_CIV_Takistani02_EP1",
            "TK_CIV_Takistani03_EP1",
            "TK_CIV_Takistani04_EP1",
            "TK_CIV_Takistani05_EP1",
            "TK_CIV_Takistani06_EP1",
            "CIV_EuroMan02_EP1"
         ],
         [
            "TK_CIV_Woman01_EP1",
            "TK_CIV_Woman02_EP1",
            "TK_CIV_Woman03_EP1",
            "CIV_EuroWoman01_EP1",
            "CIV_EuroWoman02_EP1"
         ]
      ] call _fillPool;
   };
   case (_type in ["urbanCR", "urbanRU"]):
   {
      _prefix = "";
      if (_type in ["urbanRU"]) then { _prefix = "RU_"; };
      [
         _prefix,
         [
            "Assistant",
            "Citizen1",
            "Citizen2",
            "Citizen3",
            "Citizen4",
            "Functionary1",
            "Functionary2",
            "Profiteer1",
            "Profiteer2",
            "Profiteer3",
            "Profiteer4",
            "Rocker1",
            "Rocker2",
            "Rocker3",
            "Rocker4",
            "Worker1",
            "Worker2",
            "Worker3",
            "Worker4"
         ],
         [
            "Damsel1",
            "Damsel2",
            "Damsel3",
            "Damsel4",
            "Damsel5",
            "Hooker1",
            "Hooker2",
            "Hooker3",
            "Hooker4",
            "Hooker5",
            "Madam1",
            "Madam2",
            "Madam3",
            "Madam4",
            "Madam5",
            "Secretary1",
            "Secretary2",
            "Secretary3",
            "Secretary4",
            "Secretary5",
            "Sportswoman1",
            "Sportswoman2",
            "Sportswoman3",
            "Sportswoman4",
            "Sportswoman5"
         ]
      ] call _fillPool;
   };
   // "ruralCR", "ruralRU"
   default 
   {
      _prefix = "";
      if (_type in ["ruralRU"]) then { _prefix = "RU_"; };
      [
         _prefix,
         [
            "Villager1",
            "Villager2",
            "Villager3",
            "Villager4",
            "SchoolTeacher",
            "Woodlander1",
            "Woodlander2",
            "Woodlander3",
            "Woodlander4"
         ],
         [
            "Farmwife1",
            "Farmwife2",
            "Farmwife3",
            "Farmwife4",
            "Farmwife5",
            "HouseWife1",
            "HouseWife2",
            "HouseWife3",
            "HouseWife4",
            "HouseWife5",
            "WorkWoman1",
            "WorkWoman2",
            "WorkWoman3",
            "WorkWoman4",
            "WorkWoman5"
         ]
      ] call _fillPool;
   };
};

// search empty places to spawn them (or else they could end up on roof, ...)
// Also we don't wanna spawn them directly on a street..
_positions = [];
while {((count _positions) < _number)} do
{
   _positions = [
      ["position", _position],
      ["number", _number],
      ["range", [0, _radius]],
      ["objDistance", 1.5],
      ["roadDistance", 1.5],
      ["adjustPos", _adjustPos]
   ] call RUBE_randomCirclePositions;
   
   _radius = _radius * 1.15;
   _adjustPos = _adjustPos + 1.0;
};

// spawn those guys...
{
   _unit = _group createUnit [_x, (_positions call RUBE_randomPop), [], 0, "NONE"];
   // remove weapons (we might have used soldier models, hrhr)
   removeAllWeapons _unit;
} forEach _civilians;

// return group
_group