/*
  Author:
   rübe
   
  Description:
   returns a random civilian car/vehicle (no bus, but incl. motor-/mountainbike and wrecks too!)
   
   - we manage a pool of classes to pop from, to maximize diversity of classes
  
  Parameter(s):
   -
   
  Returns:
   class/string
*/

// manage global pool
if (isnil "RUBE_CivCarPool") then { RUBE_CivCarPool = []; };

if ((count RUBE_CivCarPool) == 0) then {
   RUBE_CivCarPool = [
      "Lada1",
      "Lada2",
      "LadaLM",
      "M1030",
      "MMT_Civ",
      "Skoda",
      "SkodaBlue",
      "SkodaGreen",
      "SkodaRed",
      "TT650_Civ",
      "TT650_Gue",
      "UralCivil",
      "UralCivil2",
      "VWGolf",
      "car_hatchback",
      "car_sedan",
      "datsun1_civil_1_open",
      "datsun1_civil_2_covered",
      "datsun1_civil_3_open",
      "hilux1_civil_1_open",
      "hilux1_civil_2_covered",
      "hilux1_civil_3_open",
      "tractor",
      "LADAWreck",
      "SKODAWreck",
      "UralWreck",
      "hiluxWreck",
      "datsun01Wreck",
      "datsun02Wreck"
   ];
};

(RUBE_CivCarPool call RUBE_randomPop)