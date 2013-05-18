/*
   Author:
    rübe
    
   Description:
    get the vehicle/staticweapon-class of a given faction and type
    
   Parameter(s):
    _this select 0: type (string)
    
                    static weapons in: 
                    [
                       "static-mortar", "static-ags", "static-arty", 
                       "static-mg", "static-mg-mini", "static-at", 
                       "static-aa", "searchlight"
                    ]
                                        
                    vehicles in: 
                    [
                       "truck-closed", "truck-open", "truck-reammo", 
                       "truck-refuel", "truck-repair", "truck-salvage",
                    
                       "motorbike",
                       "mobile", "mobile-mg", "mobile-mortar", 
                       "mobile-at", "mobile-aa", "mobile-medic", 
                       "mobile-arty", "mobile-hq", 
                       
                       "mech-transport", "mech-assault"
                                  
                       "tank-heavy", "tank-light", "tank-aa",
                                  
                       "air-transport", "air-transport-heavy", "air-recon", "air-medic", 
                       "air-attack", "air-at", "air-aa", 
                       "air-bombard",
                       
                       "parachoute-big", "parachoute-medium",
                       "parachoute-small"
                    ]
                    
    _this select 1: faction (string)
                    in [
                       "USMC", "CDF", "RU", "INS", "GUE",
                       "US", "CZ", "GER", "TK", "TK_INS", "TK_GUE", "UN", "BAF"
                    ]
    
    _this select 2: camo selection/suffix (string)
                    - optional
                    - you may pass generic camo type keys:
                      - "mtp" (multi terrain pattern; default if available)
                      - "woodland" (next default if available)
                      - "desert"
                      or explicit suffix (such as "D", "W", ...)
*/

private ["_type", "_faction", "_class", "_suffix", "_formatClass"];

_type = _this select 0;
_faction = 0;
_class = [];
_suffix = "";

// faction index mapping
switch (_this select 1) do
{
   // A2
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
   case "BAF":         { _faction = 12; _suffix = "W"; };
};

// camo selection
if ((count _this) > 2) then
{
   switch (_faction) do
   {
      // BAF variants
      case 12: 
      {
         switch (_this select 2) do
         {
            case "mtp": { _suffix = "W"; };
            case "desert": { _suffix = "D"; };
            case "woodland": { _suffix = "W"; };
            default
            {
               _suffix = _this select 2;
            };
         };
      };
   };
};


// private function for suffix replacement
_formatClass = {
   if (_suffix == "") exitWith { _this };
   (format[_this, _suffix])
};


switch (_type) do {
   // static weapons 
   case "static-mortar":  
   { 
      _class = [
         "M252", "2b14_82mm_CDF", "2b14_82mm", "2b14_82mm_INS", "2b14_82mm_GUE",
         "M252_US_EP1", "M252_US_EP1", "M252_US_EP1", "2b14_82mm_TK_EP1", "2b14_82mm_TK_INS_EP1", "2b14_82mm_TK_GUE_EP1", "2b14_82mm_TK_GUE_EP1", 
         "M252"
      ]; 
   };
   case "static-ags":     
   { 
      _class = [
         "AGS_CDF", "AGS_CDF", "AGS_RU", "AGS_Ins", "AGS_RU",
         "AGS_UN_EP1", "AGS_UN_EP1", "AGS_UN_EP1", "AGS_TK_EP1", "AGS_TK_INS_EP1", "AGS_TK_GUE_EP1", "AGS_UN_EP1", 
         "BAF_GMG_Tripod_%1"
      ]; 
   };
   case "static-arty":    
   { 
      _class = [
         "M119", "D30_CDF", "D30_RU", "D30_Ins", "D30_RU",
         "M119_US_EP1", "M119_US_EP1", "M119_US_EP1", "D30_TK_EP1", "D30_TK_INS_EP1", "D30_TK_GUE_EP1", "D30_TK_GUE_EP1", 
         "M119"
      ]; 
   };
   case "static-mg":      
   { 
      _class = [
         "M2StaticMG", "DSHKM_CDF", "DSHKM_Ins", "DSHKM_Ins", "DSHKM_Gue",
         "M2StaticMG_US_EP1", "KORD_high_UN_EP1", "M2StaticMG_US_EP1", "KORD_high_TK_EP1", "DSHKM_TK_INS_EP1", "DSHKM_TK_GUE_EP1", "KORD_high_UN_EP1", 
         "BAF_L2A1_Tripod_%1"
      ]; 
   };
   case "static-mg-mini": 
   { 
      _class = [
         "M2HD_mini_TriPod", "DSHkM_Mini_TriPod_CDF", "KORD", "KORD", "DSHkM_Mini_TriPod",
         "M2HD_mini_TriPod_US_EP1", "KORD_UN_EP1", "M2HD_mini_TriPod_US_EP1", "KORD_TK_EP1", "DSHkM_Mini_TriPod_TK_INS_EP1", "DSHkM_Mini_TriPod_TK_GUE_EP1", "KORD_UN_EP1", 
         "BAF_GPMG_Minitripod_%1"
      ]; 
   };
   case "static-at":      
   { 
      _class = [
         "TOW_TriPod", "SPG9_CDF", "Metis", "SPG9_Ins", "SPG9_Gue",
         "TOW_TriPod_US_EP1", "Metis_TK_EP1", "TOW_TriPod_US_EP1", "Metis_TK_EP1", "SPG9_TK_INS_EP1", "SPG9_TK_GUE_EP1", "Metis_TK_EP1",
         "TOW_TriPod"
      ]; 
   };
   case "static-aa":      
   { 
      _class = [
         "Stinger_Pod", "ZU23_CDF", "Igla_AA_pod_East", "ZU23_Ins", "ZU23_Gue",
         "Stinger_Pod_US_EP1", "Igla_AA_pod_TK_EP1", "Stinger_Pod_US_EP1", "Igla_AA_pod_TK_EP1", "ZU23_TK_INS_EP1", "ZU23_TK_GUE_EP1", "ZU23_CDF", 
         "Stinger_Pod"
      ]; 
   };
   case "searchlight":   
   { 
      _class = [
         "SearchLight", "SearchLight_CDF", "SearchLight_RUS", "SearchLight_INS", "SearchLight_Gue",
         "SearchLight_US_EP1", "SearchLight_UN_EP1", "SearchLight_US_EP1", "SearchLight_TK_EP1", "SearchLight_TK_INS_EP1", "SearchLight_TK_GUE_EP1", "SearchLight_UN_EP1", 
         "SearchLight"
      ]; 
   };

   // wheeled/tracked 
   case "truck-closed": 
   { 
      _class = [
         "MTVR", "Ural_CDF", "Kamaz", "Ural_INS", "Ural_INS",
         "MTVR_DES_EP1", "MTVR_DES_EP1", "MTVR_DES_EP1", "V3S_TK_EP1", "V3S_TK_EP1", "V3S_TK_GUE_EP1", "Ural_UN_EP1", 
         "MTVR"
      ]; 
   };
   case "truck-open":   
   { 
      _class = [
         "UralOpen_CDF", "UralOpen_CDF", "KamazOpen", "UralOpen_INS", "UralCivil2",
         "UralOpen_CDF", "V3S_Open_TK_CIV_EP1", "V3S_Open_TK_CIV_EP1", "V3S_Open_TK_EP1", "V3S_Open_TK_CIV_EP1", "V3S_Open_TK_CIV_EP1", "UralOpen_CDF", 
         "UralOpen_CDF"
      ]; 
   };
   case "truck-reammo":
   { 
      _class = [
         "MtvrReammo", "UralReammo_CDF", "KamazReammo", "UralReammo_INS", "UralReammo_INS",
         "MtvrReammo_DES_EP1", "MtvrReammo_DES_EP1", "MtvrReammo_DES_EP1", "UralReammo_TK_EP1", "UralReammo_TK_EP1", "V3S_Reammo_TK_GUE_EP1", "UralReammo_CDF",
         "MtvrReammo"
      ]; 
   };
   case "truck-refuel": 
   { 
      _class = [
         "MtvrRefuel", "UralRefuel_CDF", "KamazRefuel", "UralRefuel_INS", "UralRefuel_INS",
         "MtvrRefuel_DES_EP1", "MtvrRefuel_DES_EP1", "MtvrRefuel_DES_EP1", "UralRefuel_TK_EP1", "UralRefuel_TK_EP1", "V3S_Refuel_TK_GUE_EP1", "UralRefuel_CDF",
         "MtvrRefuel"
      ]; 
   };
   case "truck-repair": 
   { 
      _class = [
         "MtvrRepair", "UralRepair_CDF", "KamazRepair", "UralRepair_INS", "UralRepair_INS",
         "MtvrRepair_DES_EP1", "MtvrRepair_DES_EP1", "MtvrRepair_DES_EP1", "UralRepair_TK_EP1", "UralRepair_TK_EP1", "V3S_Repair_TK_GUE_EP1", "UralRepair_CDF",
         "MtvrRepair"
      ]; 
   };
   case "truck-salvage": 
   { 
      _class = [
         "WarfareSalvageTruck_USMC", "WarfareSalvageTruck_CDF", "WarfareSalvageTruck_RU", "WarfareSalvageTruck_INS", "WarfareSalvageTruck_Gue",
         "MtvrSupply_DES_EP1", "MtvrSupply_DES_EP1", "MtvrSupply_DES_EP1", "UralSupply_TK_EP1", "UralSupply_TK_EP1", "V3S_Supply_TK_GUE_EP1", "WarfareSalvageTruck_CDF", 
         "WarfareSalvageTruck_USMC"
      ];
   };
   case "motorbike":
   {
      _class = [
         "M1030", "TT650_Civ", "TT650_Ins", "TT650_Ins", "TT650_Gue",
         "M1030_US_DES_EP1", "TT650_TK_CIV_EP1", "M1030_US_DES_EP1", "TT650_TK_EP1", "TT650_TK_CIV_EP1", "Old_moto_TK_Civ_EP1", "TT650_TK_CIV_EP1",
         "M1030"
      ];
   };
   case "mobile":         
   { 
      _class = [
         "HMMWV", "UAZ_CDF", "UAZ_RU", "UAZ_INS", "Pickup_PK_GUE",
         "HMMWV_DES_EP1", "HMMWV_DES_EP1", "HMMWV_DES_EP1", "UAZ_Unarmed_TK_EP1", "UAZ_Unarmed_TK_EP1", "UAZ_Unarmed_TK_CIV_EP1", "UAZ_Unarmed_UN_EP1",
         "BAF_Offroad_%1"
      ]; 
   };
   case "mech-transport": 
   { 
      _class = [
         "AAV", "BRDM2_CDF", "GAZ_Vodnik", "BRDM2_INS", "BRDM2_Gue",
         "M1126_ICV_M2_EP1", "M1126_ICV_M2_EP1", "M1126_ICV_M2_EP1", "BTR60_TK_EP1", "BTR40_TK_INS_EP1", "BTR40_TK_GUE_EP1", "M113_UN_EP1",
         "BAF_FV510_%1"
      ]; 
   };
   case "mech-assault": 
   { 
      _class = [
         "LAV25", "BMP2_CDF", "BMP3", "BMP2_INS", "BMP2_Gue",
         "M2A3_EP1", "M2A2_EP1", "M2A2_EP1", "BMP2_TK_EP1", "BTR40_MG_TK_INS_EP1", "BTR40_MG_TK_GUE_EP1", "BMP2_UN_EP1",
         "BAF_FV510_%1"
      ]; 
   };   
   case "mobile-mg":      
   { 
      _class = [
         "HMMWV_M2", "UAZ_MG_CDF", "GAZ_Vodnik", "UAZ_MG_INS", "Offroad_DSHKM_Gue",
         "HMMWV_M998_crows_M2_DES_EP1", "LandRover_Special_CZ_EP1", "HMMWV_M1151_M2_DES_EP1", "UAZ_MG_TK_EP1", "LandRover_MG_TK_INS_EP1", "Pickup_PK_TK_GUE_EP1", "M113_UN_EP1",
         "BAF_Jackal2_L2A1_%1"
      ]; 
   };
   case "mobile-mortar":  
   { 
      _class = [
         "HMMWV_MK19", "UAZ_AGS30_CDF", "UAZ_AGS30_RU", "UAZ_AGS30_INS", "UAZ_AGS30_RU",
         "HMMWV_M998_crows_MK19_DES_EP1", "LandRover_Special_CZ_EP1", "HMMWV_MK19_DES_EP1", "UAZ_AGS30_TK_EP1", "UAZ_AGS30_TK_EP1", "UAZ_AGS30_CDF", "UAZ_AGS30_CDF",
         "BAF_Jackal2_GMG_%1"
      ]; 
   };
   case "mobile-at":     
   { 
      _class = [
         "HMMWV_TOW", "BRDM2_ATGM_CDF", "BTR90", "UAZ_SPG9_INS", "Offroad_SPG9_Gue",
         "HMMWV_TOW_DES_EP1", "HMMWV_TOW_DES_EP1", "HMMWV_TOW_DES_EP1", "BRDM2_ATGM_TK_EP1", "LandRover_SPG9_TK_INS_EP1", "LandRover_SPG9_TK_INS_EP1", "BMP2_UN_EP1",
         "BAF_FV510_%1"
      ]; 
   };
   case "mobile-aa":      
   { 
      _class = [
         "HMMWV_Avenger", "Ural_ZU23_CDF", "GAZ_Vodnik_HMG", "Ural_ZU23_INS", "Ural_ZU23_Gue",
         "HMMWV_Avenger_DES_EP1", "HMMWV_Avenger_DES_EP1", "HMMWV_Avenger_DES_EP1", "Ural_ZU23_TK_EP1", "Ural_ZU23_TK_EP1", "Ural_ZU23_TK_GUE_EP1", "Ural_ZU23_CDF",
         "HMMWV_Avenger"
      ]; 
   };
   case "mobile-medic":   
   { 
      _class = [
         "HMMWV_Ambulance", "BMP2_Ambul_CDF", "GAZ_Vodnik_MedEvac", "BMP2_Ambul_INS", "GAZ_Vodnik_MedEvac",
         "M1133_MEV_EP1", "HMMWV_Ambulance_CZ_DES_EP1", "HMMWV_Ambulance_DES_EP1", "M113Ambul_TK_EP1", "BMP2_Ambul_INS", "GAZ_Vodnik_MedEvac", "M113Ambul_UN_EP1",
         "HMMWV_Ambulance"
      ]; 
   };
   case "mobile-arty":    
   { 
      _class = [
         "MLRS", "GRAD_CDF", "GRAD_RU", "GRAD_INS", "GRAD_RU",
         "MLRS_DES_EP1", "MLRS_DES_EP1", "MLRS_DES_EP1", "GRAD_TK_EP1", "GRAD_TK_EP1", "GRAD_TK_EP1", "GRAD_CDF",
         "MLRS"
      ]; 
   };
   case "mobile-hq":     
   {
      _class = [
         "LAV25_HQ", "BMP2_HQ_CDF", "BTR90_HQ", "BMP2_HQ_INS", "BRDM2_HQ_Gue",
         "M1130_CV_EP1", "M1130_CV_EP1", "M1130_CV_EP1", "BMP2_HQ_TK_EP1", "BMP2_HQ_TK_EP1", "BRDM2_HQ_TK_GUE_EP1", "BMP2_HQ_CDF",
         "BAF_Jackal2_L2A1_%1"
      ]; 
   };
   
   case "tank-heavy": 
   { 
      _class = [
         "M1A2_TUSK_MG", "T72_CDF", "T90", "T72_INS", "T72_Gue",
         "M1A2_US_TUSK_MG_EP1", "M1A2_US_TUSK_MG_EP1", "M1A2_US_TUSK_MG_EP1", "T72_TK_EP1", "T55_TK_EP1", "T55_TK_GUE_EP1", "T72_Gue",
         "M1A2_TUSK_MG"
      ]; 
   };
   case "tank-light": 
   { 
      _class = [
         "M1A1", "T72_CDF", "T72_RU", "T72_INS", "T34",
         "M1A1_US_DES_EP1", "M1A1_US_DES_EP1", "M1A1_US_DES_EP1", "T55_TK_EP1", "T34_TK_EP1", "T34_TK_GUE_EP1", "BMP2_UN_EP1",
         "M1A1"
      ]; 
   };
   case "tank-aa":    
   { 
      _class = [
         "2S6M_Tunguska", "ZSU_CDF", "ZSU_INS", "ZSU_INS", "ZSU_INS",
         "M6_EP1", "M6_EP1", "M6_EP1", "ZSU_TK_EP1", "ZSU_INS", "ZSU_CDF", "ZSU_CDF",
         "2S6M_Tunguska"
      ]; 
   };
   
   // air  
   case "air-transport": 
   { 
      _class = [
         "MH60S", "Mi17_CDF", "Mi17_rockets_RU", "Mi17_Ins", "Mi17_Ins",
         "UH60M_EP1", "Mi171Sh_CZ_EP1", "UH60M_EP1", "Mi17_TK_EP1", "Mi17_Ins", "UH1H_TK_GUE_EP1", "Mi17_UN_CDF_EP1",
         "BAF_Merlin_HC3_D"
      ]; 
   };
   case "air-transport-heavy": 
   { 
      _class = [
         "MV22", "Mi17_CDF", "Mi17_rockets_RU", "Mi17_Ins", "Mi17_Ins",
         "CH_47F_EP1", "Mi171Sh_CZ_EP1", "CH_47F_EP1", "Mi17_TK_EP1", "Mi17_Ins", "Mi17_Civilian", "Mi17_UN_CDF_EP1",
         "CH_47F_BAF"
      ]; 
   };
   
   case "air-recon":     
   { 
      _class = [
         "MQ9PredatorB", "Pchela1T", "Pchela1T", "Pchela1T", "Pchela1T",
         "MQ9PredatorB_US_EP1", "MQ9PredatorB_US_EP1", "MQ9PredatorB_US_EP1", "Pchela1T", "Pchela1T", "Pchela1T", "Pchela1T",
         "MQ9PredatorB"
      ]; 
   };
   case "air-medic":     
   { 
      _class = [
         "MH60S", "Mi17_medevac_CDF", "Mi17_medevac_RU", "Mi17_medevac_Ins", "Mi17_medevac_Ins",
         "UH60M_MEV_EP1", "UH60M_MEV_EP1", "UH60M_MEV_EP1", "Mi17_medevac_RU", "Mi17_medevac_Ins", "Mi17_medevac_CDF", "Mi17_UN_CDF_EP1",
         "UH60M_MEV_EP1"
      ]; 
   };
   case "air-attack":    
   { 
      _class = [
         "AH1Z", "Mi24_D", "Ka52", "Mi24_V", "Mi24_P",
         "AH64D_EP1", "Mi171Sh_rockets_CZ_EP1", "AH64D_EP1", "Mi24_D_TK_EP1", "Mi24_D_TK_EP1", "UH1H_TK_GUE_EP1", "Mi17_UN_CDF_EP1",
         "BAF_Apache_AH1_D"
      ]; 
   };
   case "air-at":        
   { 
      _class = [
         "A10", "Su25_CDF", "Su39", "Su25_Ins", "Su25_Ins",
         "A10_US_EP1", "A10_US_EP1", "A10_US_EP1", "L39_TK_EP1", "L39_TK_EP1", "Su25_CDF", "Su25_CDF",
         "AW159_Lynx_BAF"
      ]; 
   };
   case "air-aa":        
   { 
      _class = [
         "F35B", "Su25_CDF", "Su34", "Su25_Ins", "Su25_Ins",
         "A10_US_EP1", "A10_US_EP1", "A10_US_EP1", "Su25_TK_EP1", "Su25_Ins", "Su25_CDF", "Su25_CDF",
         "F35B"
      ]; 
   };
   case "air-bombard":   
   { 
      _class = [
         "AV8B", "Su25_CDF", "Su25_Ins", "Su25_Ins", "Su25_Ins",
         "A10_US_EP1", "A10_US_EP1", "A10_US_EP1", "Su25_TK_EP1", "Su25_Ins", "Su25_CDF", "Su25_CDF",
         "F35B"
      ]; 
   };
   
   // parachoutes
   case "parachoute-big": 
   { 
      _class = [
         "ParachuteBigWest", "ParachuteBigWest", "ParachuteBigEast", "ParachuteBigEast", "ParachuteBigEast",
         "ParachuteBigWest_EP1", "ParachuteBigWest_EP1", "ParachuteBigWest_EP1", "ParachuteBigEast_EP1", "ParachuteBigEast_EP1", "ParachuteBigEast_EP1", "ParachuteBigEast_EP1",
         "ParachuteBigWest"
      ]; 
   };
   case "parachoute-medium": 
   { 
      _class = [
         "ParachuteMediumWest", "ParachuteMediumWest", "ParachuteMediumEast", "ParachuteMediumEast", "ParachuteMediumEast",
         "ParachuteMediumWest_EP1", "ParachuteMediumWest_EP1", "ParachuteMediumWest_EP1", "ParachuteMediumEast_EP1", "ParachuteMediumEast_EP1", "ParachuteMediumEast_EP1", "ParachuteMediumEast_EP1",
         "ParachuteMediumWest"
      ]; 
   };
   case "parachoute-small": 
   { 
      _class = [
         "ParachuteWest", "ParachuteWest", "ParachuteEast", "ParachuteEast", "ParachuteG",
         "Parachute_US_EP1", "ParachuteWest", "ParachuteWest", "Parachute_TK_EP1", "TK_INS", "Parachute_TK_GUE_EP1", "ParachuteEast",
         "ParachuteWest"
      ]; 
   };
   
};


// failsafe (explicit class selection)
if (((count _class) - 1) < _faction) exitWith
{
   (_type call _formatClass)
};

// return class
((_class select _faction) call _formatClass)