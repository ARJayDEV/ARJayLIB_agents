/*
   Author:
    rübe
    
   Description:
    spawns the desired unit(-class/role) from a faction, with loadout-
    correction and adjusted skill(-set).
    
   Parameter(s):
    _this select 0: unit type (string)
                    in [
                       "officer", "sl", "tl", "ar", "aar", "r", "at", "aat", 
                       "lat", "hat", "ahat", "aa", "crew", "engineer", 
                       "grenadier", "marksman", "medic", "mg", "amg", 
                       "pilot", "saboteur", "spotter", "sniper", "heavysniper",
                       "worker"
                    ]
        
    _this select 1: faction (string)
                    in [
                       "USMC", "CDF", "RU", "INS", "GUE",
                       "US", "CZ", "GER", "TK", "TK_INS", "TK_GUE", "UN", "BAF"
                    ]
    
    _this select 2: group the unit should join (group)
    _this select 3: position (position, optional)
                    
   Returns:
    created unit (object)
*/

private ["_role", "_faction", "_class", "_group", "_position", "_unit", "_skillValue"];

_role = _this select 0;
_faction = _this select 1;
_class = [_role, _faction] call RUBE_selectFactionUnit;
_group = _this select 2;
_position = [0,0,0];
if ((count _this) > 3) then
{
   _position = _this select 3;
};

// create unit
_unit = _group createUnit [_class, _position, [], 0, "FORM"];

// private function to randomize skillset
_skillValue = {
   private ["_r"];
   // random part based on faction
   // the lower the random part, the better or
   // more consistent soldiers are trained
   _r = 0.5;
   
   switch (_faction) do
   {
      case "GER": { _r = 0.10; };
      case "CZ": { _r = 0.11; };
      case "BAF": { _r = 0.12; };
      case "USMC": { _r = 0.14; };
      case "US": { _r = 0.15; };
      case "RU": { _r = 0.17; };
      case "CDF": { _r = 0.25; };
      case "UN": { _r = 0.28; };
      case "TK": { _r = 0.34; };
   };
   
   ((_this * (1 - _r)) + (random (_this * _r)))
};

// set general skill (at least 0.2, at most 0.7)
_unit setSkill ((0.4 call _skillValue) + ((random 0.3) call _skillValue));

// set special skill and rank based on role
switch (_role) do
{
   case "officer":
   {
      _unit setSkill ["commanding", (1 call _skillValue)];
      _unit setSkill ["courage", (0.7 call _skillValue)];
      _unit setRank "MAJOR";
   };
   case "sl":
   {
      _unit setSkill ["commanding", (0.9 call _skillValue)];
      _unit setSkill ["courage", (0.8 call _skillValue)];
      _unit setRank "CAPTAIN";
   };
   case "tl":
   {
      _unit setSkill ["commanding", (0.8 call _skillValue)];
      _unit setSkill ["courage", (0.9 call _skillValue)];
      _unit setRank "LIEUTENANT";
   };
   case "medic":
   {
      _unit setSkill ["endurance", (0.8 call _skillValue)];
      _unit setSkill ["courage", (1 call _skillValue)];
      _unit setRank (["PRIVATE", "PRIVATE", "CORPORAL"] call RUBE_randomSelect);
   };
   case "marksman":
   {
      _unit setSkill ["aimingAccuracy", (0.78 call _skillValue)];
      _unit setSkill ["aimingShake", (0.72 call _skillValue)];
      _unit setSkill ["spotTime", (0.79 call _skillValue)];
      _unit setSkill ["spotDistance", (0.81 call _skillValue)];
      _unit setRank (["PRIVATE", "PRIVATE", "CORPORAL"] call RUBE_randomSelect);
   };
   case "spotter":
   {
      _unit setSkill ["spotTime", (1 call _skillValue)];
      _unit setSkill ["spotDistance", (1 call _skillValue)];
      _unit setRank (["PRIVATE", "PRIVATE", "CORPORAL"] call RUBE_randomSelect);
   };
   case "sniper":
   {
      _unit setSkill ["aimingAccuracy", (1 call _skillValue)];
      _unit setSkill ["aimingShake", (1 call _skillValue)];
      _unit setSkill ["spotTime", (0.78 call _skillValue)];
      _unit setSkill ["spotDistance", (0.92 call _skillValue)];
      _unit setRank (["PRIVATE", "PRIVATE", "CORPORAL"] call RUBE_randomSelect);
   };
   case "heavysniper":
   {
      _unit setSkill ["aimingAccuracy", (1 call _skillValue)];
      _unit setSkill ["aimingShake", (1 call _skillValue)];
      _unit setSkill ["spotTime", (0.72 call _skillValue)];
      _unit setSkill ["spotDistance", (0.91 call _skillValue)];
      _unit setRank (["PRIVATE", "PRIVATE", "CORPORAL"] call RUBE_randomSelect);
   };
   default
   {
      _unit setRank (["PRIVATE", "PRIVATE", "CORPORAL"] call RUBE_randomSelect);
   };
};


// fix units loadout
// feel free to make any changes you feel are necessary

// ... by roles, regardless what faction
switch (_role) do
{
   case "worker": { [_unit, [], []] call RUBE_setLoadout; };
};

// ... by faction
switch (_faction) do
{
   case "USMC": {};
   case "CDF": 
   {
      switch (_role) do
      {
         case "saboteur": 
         {
            [_unit, ["AK_74"], [["30Rnd_545x39_AK", 6], ["PipeBomb", 3]]] call RUBE_setLoadout;
         };
         case "heavysniper": 
         {
            [_unit, ["KSVK"], [["5Rnd_127x108_KSVK", 9], ["SmokeShell", 2]]] call RUBE_setLoadout;
         };
      };
   };
   case "RU": 
   {
      switch (_role) do
      {
         case "engineer": 
         {
            [_unit, ["AK_107_kobra"], [["30Rnd_545x39_AK", 6], ["Mine", 2], ["HandGrenade", 1], ["SmokeShell", 1]]] call RUBE_setLoadout;
         };
      };
   };
   case "INS": 
   {
      switch (_role) do
      {
         case "sl": 
         {
            [_unit, ["AK_107_GL_pso", "Binocular"], [["30Rnd_545x39_AK", 6], ["1Rnd_HE_GP25", 6], ["FlareWhite_GP25", 1], ["FlareRed_GP25", 1], ["SmokeShell", 2], ["SmokeShellRed", 1], ["SmokeShellGreen", 1]]] call RUBE_setLoadout;
         };
         case "tl": 
         {
            [_unit, ["AK_107_GL_pso", "Binocular"], [["30Rnd_545x39_AK", 6], ["1Rnd_HE_GP25", 6], ["FlareWhite_GP25", 1], ["FlareRed_GP25", 1], ["SmokeShell", 2], ["SmokeShellRed", 1], ["SmokeShellGreen", 1]]] call RUBE_setLoadout;
         };
         case "marksman": 
         {
            [_unit, ["AK_107_pso"], [["30Rnd_545x39_AK", 6], ["HandGrenade", 4], ["SmokeShell", 2]]] call RUBE_setLoadout;
         };
         case "engineer": 
         {
            [_unit, ["AK_107_kobra"], [["30Rnd_545x39_AK", 6], ["Mine", 2], ["HandGrenade", 1], ["SmokeShell", 1]]] call RUBE_setLoadout;
         };
         case "saboteur": 
         {
            [_unit, ["AK_107_kobra"], [["30Rnd_545x39_AK", 6], ["PipeBomb", 3]]] call RUBE_setLoadout;
         };
         case "spotter": 
         {
            [_unit, ["AK_107_kobra"], [["30Rnd_545x39_AK", 6], ["HandGrenade", 2], ["SmokeShell", 1], ["SmokeShellRed", 1]]] call RUBE_setLoadout;
         };
         case "heavysniper": 
         {
            [_unit, ["KSVK"], [["5Rnd_127x108_KSVK", 9], ["SmokeShell", 2]]] call RUBE_setLoadout;
         };
      };
   };
   case "GUE": 
   {
      switch (_role) do
      {
         case "sl": 
         {
            [_unit, ["AKS_74_pso", "Binocular"], [["30Rnd_545x39_AK", 6], ["SmokeShell", 2], ["SmokeShellRed", 1], ["SmokeShellGreen", 1]]] call RUBE_setLoadout;
         };
         case "tl": 
         {
            [_unit, ["AKS_74_pso", "Binocular"], [["30Rnd_545x39_AK", 6], ["SmokeShell", 2], ["SmokeShellRed", 1], ["SmokeShellGreen", 1]]] call RUBE_setLoadout;
         };
         case "marksman": 
         {
            [_unit, ["AKS_74_pso"], [["30Rnd_545x39_AK", 6], ["HandGrenade", 4], ["SmokeShell", 2]]] call RUBE_setLoadout;
         };
         case "engineer": 
         {
            [_unit, ["AK_47_M"], [["30Rnd_762x39_AK47", 6], ["Mine", 2], ["HandGrenade", 1], ["SmokeShell", 1]]] call RUBE_setLoadout;
         };
         case "saboteur": 
         {
            [_unit, ["AK_47_M"], [["30Rnd_762x39_AK47", 6], ["PipeBomb", 3]]] call RUBE_setLoadout;
         };
         case "heavysniper": 
         {
            [_unit, ["KSVK"], [["5Rnd_127x108_KSVK", 9], ["SmokeShell", 2]]] call RUBE_setLoadout;
         };
      };
   };
   case "US": 
   {
      switch (_role) do
      {
         case "saboteur": 
         {
            [_unit, ["M4A3_CCO_EP1"], [["30Rnd_556x45_Stanag", 6], ["PipeBomb", 3]]] call RUBE_setLoadout;
         };
      };
   };
   case "CZ": 
   {
      switch (_role) do
      {
         case "aa": 
         {
            [_unit, ["Sa58V_CCO_EP1", "Igla"], [["30Rnd_762x39_SA58", 6], ["Igla", 1]]] call RUBE_setLoadout;
         };
         case "ar": 
         {
            [_unit, ["m240_scoped_EP1"], [["100Rnd_762x51_M240", 5], ["HandGrenade", 2]]] call RUBE_setLoadout;
         };
         case "hat": 
         {
            [_unit, ["Sa58V_CCO_EP1", "MetisLauncher"], [["30Rnd_762x39_SA58", 6], ["AT13", 1]]] call RUBE_setLoadout;
         };
         case "engineer": 
         {
            [_unit, ["Sa58V_CCO_EP1"], [["30Rnd_762x39_SA58", 6], ["Mine", 2], ["HandGrenade", 1], ["SmokeShell", 1]]] call RUBE_setLoadout;
         };
         case "saboteur": 
         {
            [_unit, ["Sa58V_CCO_EP1"], [["30Rnd_762x39_SA58", 6], ["PipeBomb", 3]]] call RUBE_setLoadout;
         };
         case "spotter": 
         {
            [_unit, ["Sa58V_CCO_EP1"], [["30Rnd_762x39_SA58", 6], ["HandGrenade", 2], ["SmokeShell", 1], ["SmokeShellRed", 1]]] call RUBE_setLoadout;
         };
         case "heavysniper": 
         {
            [_unit, ["KSVK"], [["5Rnd_127x108_KSVK", 9], ["SmokeShell", 2]]] call RUBE_setLoadout;
         };
      };
   };
   case "GER":
   {
      switch (_role) do
      {
         case "grenadier": 
         {
            [_unit, ["SCAR_L_STD_EGLM_RCO"], [["30Rnd_556x45_Stanag", 6], ["1Rnd_HE_M203", 8], ["HandGrenade", 4]]] call RUBE_setLoadout;
         };
         case "lat": 
         {
            [_unit, ["G36C_camo", "M136"], [["30Rnd_556x45_G36", 6], ["M136", 1]]] call RUBE_setLoadout;
         };
         case "at": 
         {
            [_unit, ["G36C_camo", "MAAWS"], [["30Rnd_556x45_G36", 6], ["MAAWS_HEAT", 1], ["MAAWS_HEDP", 2]]] call RUBE_setLoadout;
         };
         case "hat": 
         {
            [_unit, ["G36C_camo", "Javelin"], [["30Rnd_556x45_G36", 6], ["Javelin", 1]]] call RUBE_setLoadout;
         };
         case "aa": 
         {
            [_unit, ["G36A_camo", "Stinger"], [["30Rnd_556x45_G36", 6], ["Stinger", 1]]] call RUBE_setLoadout;
         };
         case "ar": 
         {
            [_unit, ["m240_scoped_EP1"], [["100Rnd_762x51_M240", 5], ["HandGrenade", 2]]] call RUBE_setLoadout;
         };
         case "marksman": 
         {
            [_unit, ["M110_NVG_EP1"], [["20Rnd_762x51_B_SCAR", 6], ["HandGrenade", 4], ["SmokeShell", 2]]] call RUBE_setLoadout;
         };
         case "engineer": 
         {
            [_unit, ["G36C_camo"], [["30Rnd_556x45_G36", 6], ["Mine", 2], ["HandGrenade", 1], ["SmokeShell", 1]]] call RUBE_setLoadout;
         };
         case "saboteur": 
         {
            [_unit, ["G36A_camo"], [["30Rnd_556x45_G36", 6], ["PipeBomb", 3]]] call RUBE_setLoadout;
         };
         case "sniper": 
         {
            [_unit, ["M110_TWS_EP1", "glock17_EP1"], [["20Rnd_762x51_B_SCAR", 10], ["17Rnd_9x19_glock17", 8], ["HandGrenade", 2]]] call RUBE_setLoadout;
         };
         case "heavysniper": 
         {
            [_unit, ["m107_TWS_EP1", "glock17_EP1"], [["10Rnd_127x99_m107", 10], ["17Rnd_9x19_glock17", 8], ["HandGrenade", 2]]] call RUBE_setLoadout;
         };
      };
   };
   case "TK": 
   {
      switch (_role) do
      {
         case "marksman": 
         {
            [_unit, ["AKS_74_pso"], [["30Rnd_545x39_AK", 6], ["HandGrenade", 4], ["SmokeShell", 2]]] call RUBE_setLoadout;
         };
         case "saboteur": 
         {
            [_unit, ["AKS_74_kobra"], [["30Rnd_545x39_AK", 6], ["PipeBomb", 3]]] call RUBE_setLoadout;
         };
      };
   };
   case "TK_INS": 
   {
      switch (_role) do
      {
         case "grenadier": 
         {
            [_unit, ["M16A2GL"], [["30Rnd_556x45_Stanag", 6], ["1Rnd_HE_M203", 8], ["HandGrenade", 4]]] call RUBE_setLoadout;
         };
         case "marksman": 
         {
            [_unit, ["SVD"], [["10Rnd_762x54_SVD", 8], ["HandGrenade", 2], ["SmokeShell", 2]]] call RUBE_setLoadout;
         };
         case "engineer": 
         {
            [_unit, ["M4A1"], [["30Rnd_556x45_Stanag", 6], ["Mine", 2], ["HandGrenade", 1], ["SmokeShell", 1]]] call RUBE_setLoadout;
         };
         case "saboteur": 
         {
            [_unit, ["AKS_74_kobra"], [["30Rnd_545x39_AK", 6], ["PipeBomb", 3]]] call RUBE_setLoadout;
         };
         case "spotter": 
         {
            [_unit, ["AKS_74_pso"], [["30Rnd_545x39_AK", 6], ["HandGrenade", 2], ["SmokeShell", 1], ["SmokeShellRed", 1]]] call RUBE_setLoadout;
         };
         case "heavysniper": 
         {
            [_unit, ["KSVK"], [["5Rnd_127x108_KSVK", 9], ["SmokeShell", 2]]] call RUBE_setLoadout;
         };
      };
   };
   case "TK_GUE": 
   {
      switch (_role) do
      {
         case "grenadier": 
         {
            [_unit, ["AK_74_GL"], [["30Rnd_545x39_AK", 6], ["1Rnd_HE_GP25", 8], ["HandGrenade", 4]]] call RUBE_setLoadout;
         };
         case "marksman": 
         {
            [_unit, ["AKS_74_pso"], [["30Rnd_545x39_AK", 6], ["HandGrenade", 4], ["SmokeShell", 2]]] call RUBE_setLoadout;
         };
         case "engineer": 
         {
            [_unit, ["LeeEnfield"], [["10x_303", 6], ["Mine", 2], ["HandGrenade", 1], ["SmokeShell", 1]]] call RUBE_setLoadout;
         };
         case "saboteur": 
         {
            [_unit, ["M16A2"], [["30Rnd_556x45_Stanag", 6], ["PipeBomb", 3]]] call RUBE_setLoadout;
         };
         case "spotter": 
         {
            [_unit, ["AKS_74_pso"], [["30Rnd_545x39_AK", 6], ["HandGrenade", 2], ["SmokeShell", 1], ["SmokeShellRed", 1]]] call RUBE_setLoadout;
         };
         case "heavysniper": 
         {
            [_unit, ["KSVK"], [["5Rnd_127x108_KSVK", 9], ["SmokeShell", 2]]] call RUBE_setLoadout;
         };
      };
   };
   case "UN": 
   {
      switch (_role) do
      {
         case "grenadier": 
         {
            [_unit, ["AK_74_GL_kobra"], [["30Rnd_545x39_AK", 6], ["1Rnd_HE_GP25", 8], ["HandGrenade", 4]]] call RUBE_setLoadout;
         };
         case "lat": 
         {
            [_unit, ["AKS_74_kobra", "M136"], [["30Rnd_545x39_AK", 6], ["M136", 1]]] call RUBE_setLoadout;
         };
         case "hat": 
         {
            [_unit, ["AKS_74_kobra", "MetisLauncher"], [["30Rnd_545x39_AK", 6], ["AT13", 1]]] call RUBE_setLoadout;
         };
         case "aa": 
         {
            [_unit, ["AKS_74_kobra", "Igla"], [["30Rnd_545x39_AK", 6], ["Igla", 1]]] call RUBE_setLoadout;
         };
         case "ar": 
         {
            [_unit, ["Pecheneg"], [["100Rnd_762x54_PK", 5], ["HandGrenade", 2]]] call RUBE_setLoadout;
         };
         case "marksman": 
         {
            [_unit, ["AKS_74_pso"], [["30Rnd_545x39_AK", 6], ["HandGrenade", 4], ["SmokeShell", 2]]] call RUBE_setLoadout;
         };
         case "engineer": 
         {
            [_unit, ["AKS_74_kobra"], [["30Rnd_545x39_AK", 6], ["Mine", 2], ["HandGrenade", 1], ["SmokeShell", 1]]] call RUBE_setLoadout;
         };
         case "saboteur": 
         {
            [_unit, ["AKS_74_kobra"], [["30Rnd_545x39_AK", 6], ["PipeBomb", 3]]] call RUBE_setLoadout;
         };
         case "sniper": 
         {
            [_unit, ["SVD", "Makarov"], [["10Rnd_762x54_SVD", 10], ["8Rnd_9x18_Makarov", 8], ["HandGrenade", 2]]] call RUBE_setLoadout;
         };
         case "spotter": 
         {
            [_unit, ["AKS_74_kobra"], [["30Rnd_545x39_AK", 6], ["HandGrenade", 2], ["SmokeShell", 1], ["SmokeShellRed", 1]]] call RUBE_setLoadout;
         };
         case "heavysniper": 
         {
            [_unit, ["KSVK"], [["5Rnd_127x108_KSVK", 9], ["SmokeShell", 2]]] call RUBE_setLoadout;
         };
      };
   };
   case "BAF": 
   {
      switch (_role) do
      {
         case "saboteur": 
         {
            [_unit, ["BAF_L85A2_RIS_SUSAT"], [["30Rnd_556x45_Stanag", 6], ["PipeBomb", 3]]] call RUBE_setLoadout;
         };
      };
   };
};


if (RUBE_HACK_REMOVE_HANDGUNS) then
{
   _unit call RUBE_removeHandgun;
};

// return unit
_unit