/*
  Author:
   rübe
  
  Description:
   returns a random civilian class. 
   
    - only generic classes are returned, thus no priest, no policeman, 
      no doctor or other "special" civilians
    - we manage a pool of classes to pop from, to maximize diversity of classes
   
  Parameter(s):
   _this select 0: sex ("male", "female" or chance/number (0-100: male < n < female))
                   - optional, default = 50
   _this select 1: ethnic group ("CR", "RU" or chance/number (0-100: Chernarussian < n < Russian)
                   - optional, default = 78 (more chernarussian citizens)
   _this select 2: citizen type ("rural", "urban" or chance/number (0-100: rural < n < urban))
                   - optional, default = 66 (more rural citizens)
  
  Returns:
   class/string
*/

private ["_sex", "_ethnicity", "_type", "_class"];

// manage global pool
if (isnil "RUBE_CivPool_MR") then { RUBE_CivPool_MR = []; };
if (isnil "RUBE_CivPool_MU") then { RUBE_CivPool_MU = []; };
if (isnil "RUBE_CivPool_FR") then { RUBE_CivPool_FR = []; };
if (isnil "RUBE_CivPool_FU") then { RUBE_CivPool_FU = []; };

if ((count RUBE_CivPool_MR) == 0) then {
   RUBE_CivPool_MR = [
      "Villager1",
      "Villager2",
      "Villager3",
      "Villager4",
      "SchoolTeacher",
      "Woodlander1",
      "Woodlander2",
      "Woodlander3",
      "Woodlander4"
   ];
};
if ((count RUBE_CivPool_MU) == 0) then {
   RUBE_CivPool_MU = [
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
   ];
};
if ((count RUBE_CivPool_FR) == 0) then {
   RUBE_CivPool_FR = [
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
   ];
};
if ((count RUBE_CivPool_FU) == 0) then {
   RUBE_CivPool_FU = [
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
   ];
};

// parse parameters
_sex = 50;
_ethnicity = 78;
_type = 66;
_class = "";

if ((count _this) > 0) then { _sex = _this select 0; };
if ((count _this) > 1) then { _ethnicity = _this select 1; };
if ((count _this) > 2) then { _type = _this select 2; };

if ((typeName _sex) != "STRING") then
{
   if ((random 100) < _sex) then { _sex = "male"; } else { _sex = "female"; };
};
if ((typeName _ethnicity) != "STRING") then
{
   if ((random 100) < _ethnicity) then { _ethnicity = "CR"; } else { _ethnicity = "RU"; };
};
if ((typeName _type) != "STRING") then
{
   if ((random 100) < _type) then { _type = "rural"; } else { _type = "urban"; };
};

switch (true) do {
   case (_sex == "female" && _type == "rural"): { _class = RUBE_CivPool_FR call RUBE_randomPop; };
   case (_sex == "female" && _type == "urban"): { _class = RUBE_CivPool_FU call RUBE_randomPop; };
   case (_sex == "male"   && _type == "rural"): { _class = RUBE_CivPool_MR call RUBE_randomPop; };
   default                                      { _class = RUBE_CivPool_MU call RUBE_randomPop; };
};

if (_ethnicity == "RU") then
{
   _class = format ["RU_%1", _class];
};

_class
