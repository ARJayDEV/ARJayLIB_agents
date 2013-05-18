/*
   Author:
    rübe
    
   Description:
    get the building-class of a given faction and type
    
     - CZ, GER and TK_INS have no warefare buildings.
    
   Parameter(s):
    _this select 0: type (string)
                    in ["smallTent", "tent", "camoNet1", "camoNet2", "camoNet3",
                        "flag", "gateIndL", "gateIndR",
                        "depot", "barrier5x", "barrier10x", "barrier10xTall",
                        "hq", "aaRadar", "artyRadar", "barracks", 
                        "fieldHospital", "lightFactory", "heavyFactory", 
                        "aircraftFactory", "uavTerminal", "servicepoint"]
                    
    _this select 1: faction (string)
                    in ["USMC", "CDF", "RU", "INS", "GUE"]
 
   Returns:
    class (string)
*/

private ["_type", "_faction", "_mapGenericBuildings", "_class"];

_type = _this select 0;
_faction = 0;
_class = [];

// faction index mapping
switch (_this select 1) do
{
   case "USMC": { _faction = 0; };
   case "CDF":  { _faction = 1; };
   case "RU":   { _faction = 2; };
   case "INS":  { _faction = 3; };
   case "GUE":  { _faction = 4; };
   // OA
   case "US":         { _faction = 5; };
   case "CZ":         { _faction = 6; };
   case "GER":        { _faction = 7; };
   case "TK":         { _faction = 8; };
   case "TK_INS":     { _faction = 9; };
   case "TK_GUE":     { _faction = 10; };
   case "UN":         { _faction = 11; };
   // DLC
   case "BAF":         { _faction = 12; };
};

// private function to replace empty strings with 
// generic buildings (mostly warefare buildings)
_mapGenericBuildings = {
   private ["_generic"];
   _generic = _this;
   if (_generic != "") exitWith { _this };
   switch (_type) do
   {
      case "hq": { _generic = "WarfareBDepot"; };
      case "aaRadar": { _generic = "76n6ClamShell"; };
      case "artyRadar": { _generic = "76n6ClamShell"; };
      case "barracks": { _generic = "Land_Barrack2"; };
      case "fieldHospital": { _generic = "MASH"; };
      case "lightFactory": { _generic = "Land_A_FuelStation_Build"; };
      case "heavyFactory": { _generic = "Land_Ind_Garage01"; };
      case "aircraftFactory": { _generic = "Land_Vysilac_FM"; };
      case "uavTerminal": { _generic = "Land_Antenna"; };
      case "servicepoint": { _generic = "WarfareBCamp"; };
   };
   
   _generic
};

switch (_type) do {
   case "smallTent": { 
      _class = [
         "ACamp", "Land_A_tent", "Land_A_tent", "Land_A_tent", "Land_A_tent",
         "ACamp", "Land_A_tent", "ACamp", "Land_A_tent", "Land_A_tent", "Land_A_tent", "Land_A_tent",
         "ACamp"
      ]; 
   };
   case "tent": { 
      _class = [
         "Camp", "CampEast", "Land_tent_east", "Land_tent_east", "CampEast",
         "Camp", "CampEast", "CampEast", "Land_tent_east", "Land_tent_east", "CampEast", "CampEast",
         "CampEast"
      ]; 
   };
   case "camoNet1": { 
      _class = [
         "Land_CamoNet_NATO", "Land_CamoNet_NATO", "Land_CamoNet_EAST", "Land_CamoNet_EAST", "Land_CamoNet_EAST",
         "Land_CamoNet_NATO", "Land_CamoNet_NATO", "Land_CamoNet_NATO", "Land_CamoNet_EAST", "Land_CamoNet_EAST", "Land_CamoNet_EAST", "Land_CamoNet_NATO",
         "Land_CamoNet_NATO"
      ]; 
   }; 
   case "camoNet2": { 
      _class = [
         "Land_CamoNetB_NATO", "Land_CamoNetB_NATO", "Land_CamoNetB_EAST", "Land_CamoNetB_EAST", "Land_CamoNetB_EAST",
         "Land_CamoNetB_NATO", "Land_CamoNetB_NATO", "Land_CamoNetB_NATO", "Land_CamoNetB_EAST", "Land_CamoNetB_EAST", "Land_CamoNetB_EAST", "Land_CamoNetB_NATO",
         "Land_CamoNetB_NATO"
      ]; 
   };
   case "camoNet3": { 
      _class = [
         "Land_CamoNetVar_NATO", "Land_CamoNetVar_NATO", "Land_CamoNetVar_EAST", "Land_CamoNetVar_EAST", "Land_CamoNetVar_EAST",
         "Land_CamoNetVar_NATO", "Land_CamoNetVar_NATO", "Land_CamoNetVar_NATO", "Land_CamoNetVar_EAST", "Land_CamoNetVar_EAST", "Land_CamoNetVar_EAST", "Land_CamoNetVar_NATO",
         "Land_CamoNetVar_NATO"
      ]; 
   };
   case "flag": { 
      _class = [
         "FlagCarrierUSA", "FlagCarrierCDF", "FlagCarrierRU", "FlagCarrierINS", "FlagCarrierGUE",
         "FlagCarrierUSArmy_EP1", "FlagCarrierCzechRepublic_EP1", "FlagCarrierGermany_EP1", "FlagCarrierTakistanKingdom_EP1", "FlagCarrierTKMilitia_EP1", "FlagCarrierTakistan_EP1", "FlagCarrierUNO_EP1",
         "FlagCarrierBAF"
      ]; 
   };
   
   case "gateIndL": { 
      _class = [
         "Land_Wall_Gate_Ind2B_L", "Land_Wall_Gate_Ind2B_L", "Land_Wall_Gate_Ind2A_L", "Land_Wall_Gate_Ind2A_L", "Land_Wall_Gate_Ind2A_L",
         "Land_Wall_Gate_Ind2B_L", "Land_Wall_Gate_Ind2B_L", "Land_Wall_Gate_Ind2B_L", "Land_Wall_Gate_Ind2A_L", "Land_Wall_Gate_Ind2A_L", "Land_Wall_Gate_Ind2A_L", "Land_Wall_Gate_Ind2B_L",
         "Land_Wall_Gate_Ind2B_L"
      ]; 
   };
   
   case "gateIndR": { 
      _class = [
         "Land_Wall_Gate_Ind2B_R", "Land_Wall_Gate_Ind2B_R", "Land_Wall_Gate_Ind2A_R", "Land_Wall_Gate_Ind2A_R", "Land_Wall_Gate_Ind2A_R",
         "Land_Wall_Gate_Ind2B_R", "Land_Wall_Gate_Ind2B_R", "Land_Wall_Gate_Ind2B_R", "Land_Wall_Gate_Ind2A_R", "Land_Wall_Gate_Ind2A_R", "Land_Wall_Gate_Ind2A_R", "Land_Wall_Gate_Ind2B_R",
         "Land_Wall_Gate_Ind2B_R"
      ]; 
   };   
   
   case "depot": { 
      _class = [
         "WarfareBDepot", "WarfareBDepot", "WarfareBDepot", "WarfareBDepot", "WarfareBDepot",
         "WarfareBDepot", "WarfareBDepot", "WarfareBDepot", "WarfareBDepot", "WarfareBDepot", "WarfareBDepot", "WarfareBDepot",
         "WarfareBDepot"
      ]; 
   };
   case "barrier5x": { 
      _class = [
         "USMC_WarfareBBarrier5x", "CDF_WarfareBBarrier5x", "RU_WarfareBBarrier5x", "INS_WarfareBBarrier5x", "GUE_WarfareBBarrier5x",
         "USMC_WarfareBBarrier5x", "USMC_WarfareBBarrier5x", "USMC_WarfareBBarrier5x", "RU_WarfareBBarrier5x", "INS_WarfareBBarrier5x", "GUE_WarfareBBarrier5x", "CDF_WarfareBBarrier5x",
         "USMC_WarfareBBarrier5x"
      ]; 
   }; 
   case "barrier10x": { 
      _class = [
         "USMC_WarfareBBarrier10x", "CDF_WarfareBBarrier10x", "RU_WarfareBBarrier10x", "INS_WarfareBBarrier10x", "GUE_WarfareBBarrier10x",
         "USMC_WarfareBBarrier10x", "USMC_WarfareBBarrier10x", "USMC_WarfareBBarrier10x", "RU_WarfareBBarrier10x", "INS_WarfareBBarrier10x", "GUE_WarfareBBarrier10x", "CDF_WarfareBBarrier10x",
         "USMC_WarfareBBarrier10x"
      ]; 
   }; 
   case "barrier10xTall": { 
      _class = [
         "USMC_WarfareBBarrier10xTall", "CDF_WarfareBBarrier10xTall", "RU_WarfareBBarrier10xTall", "INS_WarfareBBarrier10xTall", "GUE_WarfareBBarrier10xTall",
         "USMC_WarfareBBarrier10xTall", "USMC_WarfareBBarrier10xTall", "USMC_WarfareBBarrier10xTall", "RU_WarfareBBarrier10xTall", "INS_WarfareBBarrier10xTall", "GUE_WarfareBBarrier10xTall", "CDF_WarfareBBarrier10xTall",
         "USMC_WarfareBBarrier10xTall"
      ]; 
   }; 
   case "hq": { 
      _class = [
         "LAV25_HQ_unfolded", "BMP2_HQ_CDF_unfolded", "BTR90_HQ_unfolded", "BMP2_HQ_INS_unfolded", "BRDM2_HQ_Gue_unfolded",
         "M1130_HQ_unfolded_EP1", "", "", "BMP2_HQ_TK_unfolded_EP1", "", "BRDM2_HQ_TK_GUE_unfolded_EP1", "",
         ""
      ]; 
   };
   case "aaRadar": { 
      _class = [
         "USMC_WarfareBAntiAirRadar", "CDF_WarfareBAntiAirRadar", "RU_WarfareBAntiAirRadar", "INS_WarfareBAntiAirRadar", "GUE_WarfareBAntiAirRadar",
         "US_WarfareBAntiAirRadar_EP1", "", "", "TK_WarfareBAntiAirRadar_EP1", "", "TK_GUE_WarfareBAntiAirRadar_EP1", "",
         ""
      ]; 
   };
   case "artyRadar": { 
      _class = [
         "USMC_WarfareBArtilleryRadar", "CDF_WarfareBArtilleryRadar", "RU_WarfareBArtilleryRadar", "Ins_WarfareBArtilleryRadar", "Gue_WarfareBArtilleryRadar",
         "US_WarfareBArtilleryRadar_EP1", "", "", "TK_WarfareBArtilleryRadar_EP1", "", "TK_GUE_WarfareBArtilleryRadar_EP1", "",
         ""
      ]; 
   };   
   case "barracks": { 
      _class = [
         "USMC_WarfareBBarracks", "CDF_WarfareBBarracks", "RU_WarfareBBarracks", "Ins_WarfareBBarracks", "Gue_WarfareBBarracks",
         "US_WarfareBBarracks_EP1", "", "", "TK_WarfareBBarracks_EP1", "", "TK_GUE_WarfareBBarracks_EP1", "",
         ""
      ]; 
   };
   case "fieldHospital": { 
      _class = [
         "USMC_WarfareBFieldhHospital", "CDF_WarfareBFieldhHospital", "RU_WarfareBFieldhHospital", "INS_WarfareBFieldhHospital", "GUE_WarfareBFieldhHospital",
         "US_WarfareBFieldhHospital_EP1", "", "", "TK_WarfareBFieldhHospital_EP1", "", "TK_GUE_WarfareBFieldhHospital_EP1", "",
         ""
      ]; 
   };
   case "lightFactory": { 
      _class = [
         "USMC_WarfareBLightFactory", "CDF_WarfareBLightFactory", "RU_WarfareBLightFactory", "Ins_WarfareBLightFactory", "Gue_WarfareBLightFactory",
         "US_WarfareBLightFactory_EP1", "", "", "TK_WarfareBLightFactory_EP1", "", "TK_GUE_WarfareBLightFactory_EP1", "",
         ""
      ]; 
   };
   case "heavyFactory": { 
      _class = [
         "USMC_WarfareBHeavyFactory", "CDF_WarfareBHeavyFactory", "RU_WarfareBHeavyFactory", "Ins_WarfareBHeavyFactory", "Gue_WarfareBHeavyFactory",
         "US_WarfareBHeavyFactory_EP1", "", "", "TK_WarfareBHeavyFactory_EP1", "", "TK_GUE_WarfareBHeavyFactory_EP1", "",
         ""
      ]; 
   };
   case "aircraftFactory": {
      _class = [
         "USMC_WarfareBAircraftFactory", "WarfareBAircraftFactory_CDF", "RU_WarfareBAircraftFactory", "WarfareBAircraftFactory_Ins", "WarfareBAircraftFactory_Gue",
         "US_WarfareBAircraftFactory_EP1", "", "", "TK_WarfareBAircraftFactory_EP1", "", "TK_GUE_WarfareBAircraftFactory_EP1", "",
         ""
      ]; 
   };
   case "uavTerminal": { 
      _class = [
         "USMC_WarfareBUAVterminal", "CDF_WarfareBUAVterminal", "RU_WarfareBUAVterminal", "INS_WarfareBUAVterminal", "GUE_WarfareBUAVterminal",
         "US_WarfareBUAVterminal_EP1", "", "", "TK_WarfareBUAVterminal_EP1", "", "TK_GUE_WarfareBUAVterminal_EP1", "",
         ""
      ]; 
   };
   case "servicepoint": { 
      _class = [
         "USMC_WarfareBVehicleServicePoint", "CDF_WarfareBVehicleServicePoint", "RU_WarfareBVehicleServicePoint", "INS_WarfareBVehicleServicePoint", "GUE_WarfareBVehicleServicePoint",
         "US_WarfareBVehicleServicePoint_EP1", "", "", "TK_WarfareBVehicleServicePoint_EP1", "", "TK_GUE_WarfareBVehicleServicePoint_EP1", "",
         ""
      ]; 
   };
};

// failsafe (explicit class selection)
if (((count _class) - 1) < _faction) exitWith
{
   _type
};

// return class
((_class select _faction) call _mapGenericBuildings)