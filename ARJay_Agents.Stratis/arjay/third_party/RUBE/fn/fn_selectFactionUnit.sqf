/*
   Author:
    rübe
   
   Description:
    get the unit-class of a given faction and type 
    
     - only generic unit-types/no elite units (FR, MVD, Spetsnaz, ...)
     - slightly based on dslyecxi's guide (see http://ttp2.dslyecxi.com/)
     - some types are missing for some factions and replaced by some other 
       unit without loadout correction (such as engineer or lat... well, 
       actually many more with these new small factions from OA)
       
     >> check out RUBE_spawnFactionUnit to spawn a unit with loadout-correction
        and some skill manipulation...
    
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
                    
    _this select 2: camo selection/suffix (string)
                    - optional
                    - you may pass generic camo type keys:
                      - "mtp" (multi terrain pattern; default if available)
                      - "woodland"
                      - "desert"
                      or explicit suffix (such as "MTP", "DDPM", ...)
    
   Returns:
    class-string
*/

private ["_type", "_faction", "_class", "_suffix", "_formatClass", "_i"];

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
   case "BAF":        { _faction = 12; _suffix = "MTP"; };
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
            case "mtp": { _suffix = "MTP"; };
            case "desert": { _suffix = "DDPM"; };
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



switch (_type) do
{
   case "officer":   
   { 
      _class = [
         "USMC_Soldier_Officer", "CDF_Soldier_Officer", "RU_Soldier_Officer", "Ins_Commander", "GUE_Commander",
         "US_Soldier_Officer_EP1", "CZ_Soldier_Office_DES_EP1", "GER_Soldier_TL_EP1", "TK_Commander_EP1", "TK_INS_Warlord_EP1", 
         "TK_GUE_Warlord_EP1", "UN_CDF_Soldier_Officer_EP1", "BAF_Soldier_Officer_%1"
      ]; 
   };
   case "sl":        
   { 
      _class = [
         "USMC_Soldier_SL", "CDF_Soldier_TL", "RU_Soldier_SL", "Ins_Soldier_CO", "GUE_Soldier_CO",
         "US_Soldier_SL_EP1", "CZ_Soldier_SL_DES_EP1", "GER_Soldier_TL_EP1", "TK_Soldier_SL_EP1", "TK_INS_Soldier_TL_EP1", 
         "TK_GUE_Soldier_TL_EP1", "UN_CDF_Soldier_SL_EP1", "BAF_Soldier_SL_%1"
      ]; 
   };
   case "tl":        
   { 
      _class = 
      [
         "USMC_Soldier_TL", "CDF_Soldier_Militia", "RU_Soldier_TL", "Ins_Soldier_2", "GUE_Soldier_2",
         "US_Soldier_TL_EP1", "CZ_Special_Forces_TL_DES_EP1", "GER_Soldier_TL_EP1", "TK_Special_Forces_TL_EP1", "TK_INS_Soldier_TL_EP1",
         "TK_GUE_Soldier_TL_EP1", "UN_CDF_Soldier_SL_EP1", "BAF_Soldier_TL_%1"
      ]; 
   };
   case "ar":        
   { 
      _class = [
         "USMC_Soldier_AR", "CDF_Soldier_AR", "RU_Soldier_AR", "Ins_Soldier_AR", "GUE_Soldier_AR",
         "US_Soldier_AR_EP1", "CZ_Soldier_DES_EP1", "GER_Soldier_EP1", "TK_Soldier_AR_EP1", "TK_INS_Soldier_AR_EP1", 
         "TK_GUE_Soldier_AR_EP1", "UN_CDF_Soldier_EP1", "BAF_Soldier_AR_%1"
      ]; 
   };
   case "aar":       
   { 
      _class = [
         "USMC_Soldier", "CDF_Soldier", "RU_Soldier", "Ins_Soldier_1", "GUE_Soldier_3",
         "US_Soldier_AAR_EP1", "CZ_Soldier_B_DES_EP1", "GER_Soldier_EP1", "TK_Soldier_B_EP1", "TK_INS_Soldier_4_EP1", 
         "TK_GUE_Soldier_2_EP1", "UN_CDF_Soldier_B_EP1", "BAF_Soldier_AAR_%1"
      ]; 
   };
   case "r":         
   {
      // some randomization tricks for our basic units...
      _class = [
         (["USMC_Soldier", "USMC_Soldier", "USMC_Soldier", "USMC_Soldier2"] call RUBE_randomSelect),
         "CDF_Soldier",
         (["RU_Soldier", "RU_Soldier", "RU_Soldier", "RU_Soldier2"] call RUBE_randomSelect),
         (["Ins_Soldier_1", "Ins_Soldier_2"] call RUBE_randomSelect),
         (["GUE_Soldier_1", "GUE_Soldier_2", "GUE_Soldier_3"] call RUBE_randomSelect),
         (["US_Soldier_EP1", "US_Soldier_B_EP1"] call RUBE_randomSelect),
         (["CZ_Soldier_DES_EP1", "CZ_Soldier_B_DES_EP1"] call RUBE_randomSelect),
         "GER_Soldier_EP1",
         (["TK_Soldier_EP1", "TK_Soldier_B_EP1"] call RUBE_randomSelect),
         (["TK_INS_Soldier_EP1", "TK_INS_Soldier_4_EP1", "TK_INS_Soldier_3_EP1"] call RUBE_randomSelect),
         (["TK_GUE_Soldier_EP1", "TK_GUE_Soldier_2_EP1", "TK_GUE_Soldier_5_EP1", "TK_GUE_Soldier_3_EP1"] call RUBE_randomSelect),
         (["UN_CDF_Soldier_EP1", "UN_CDF_Soldier_B_EP1"] call RUBE_randomSelect),
         "BAF_Soldier_%1"
      ]; 
   };
   case "at":        
   { 
      _class = [
         "USMC_Soldier_AT", "CDF_Soldier_RPG", "RU_Soldier_AT", "Ins_Soldier_AT", "GUE_Soldier_AT",
         "US_Soldier_AT_EP1", "CZ_Soldier_AT_DES_EP1", "GER_Soldier_EP1", "TK_Soldier_AT_EP1", "TK_INS_Soldier_AT_EP1", 
         "TK_GUE_Soldier_AT_EP1", "UN_CDF_Soldier_AT_EP1", "BAF_Soldier_AT_%1"
      ]; 
   };
   case "aat":        
   { 
      _class = [
         "USMC_Soldier", "CDF_Soldier", "RU_Soldier", "Ins_Soldier_1", "GUE_Soldier_2",
         "US_Soldier_AAT_EP1", "CZ_Soldier_B_DES_EP1", "GER_Soldier_EP1", "TK_Soldier_AAT_EP1", "TK_INS_Soldier_AAT_EP1", 
         "TK_GUE_Soldier_AAT_EP1", "UN_CDF_Soldier_AAT_EP1", "BAF_Soldier_AAT_%1"
      ]; 
   };
   case "lat":       
   { 
      _class = [
         "USMC_Soldier_LAT", "CDF_Soldier_RPG", "RU_Soldier_LAT", "Ins_Soldier_AT", "GUE_Soldier_AT",
         "US_Soldier_LAT_EP1", "CZ_Soldier_AT_DES_EP1", "GER_Soldier_EP1", "TK_Soldier_LAT_EP1", "TK_INS_Soldier_AT_EP1", 
         "TK_GUE_Soldier_AT_EP1", "UN_CDF_Soldier_AT_EP1", "BAF_Soldier_AT_%1"
      ]; 
   };
   case "hat":       
   { 
      _class = [
         "USMC_Soldier_HAT", "CDF_Soldier_RPG", "RU_Soldier_HAT", "Ins_Soldier_AT", "GUE_Soldier_AT",
         "US_Soldier_HAT_EP1", "CZ_Soldier_AT_DES_EP1", "GER_Soldier_EP1", "TK_Soldier_HAT_EP1", "TK_INS_Soldier_AT_EP1", 
         "TK_GUE_Soldier_HAT_EP1", "UN_CDF_Soldier_AT_EP1", "BAF_Soldier_HAT_%1"
      ]; 
   };
   case "ahat":        
   { 
      _class = [
         "USMC_Soldier", "CDF_Soldier", "RU_Soldier", "Ins_Soldier_1", "GUE_Soldier_3",
         "US_Soldier_AHAT_EP1", "CZ_Soldier_B_DES_EP1", "GER_Soldier_EP1", "TK_Soldier_AAT_EP1", "TK_INS_Soldier_AAT_EP1", 
         "TK_GUE_Soldier_AAT_EP1", "UN_CDF_Soldier_AAT_EP1", "BAF_Soldier_AAT_%1"
      ]; 
   };
   case "aa":        
   { 
      _class = [
         "USMC_Soldier_AA", "CDF_Soldier_Strela", "RU_Soldier_AA", "Ins_Soldier_AA", "GUE_Soldier_AA",
         "US_Soldier_AA_EP1", "CZ_Soldier_DES_EP1", "GER_Soldier_EP1", "TK_Soldier_AA_EP1", "TK_INS_Soldier_AA_EP1", 
         "TK_GUE_Soldier_AA_EP1", "UN_CDF_Soldier_EP1", "BAF_Soldier_AA_%1"
      ]; 
   };
   case "crew":      
   { 
      _class = [
         "USMC_Soldier_Crew", "CDF_Soldier_Crew", "RU_Soldier_Crew", "Ins_Soldier_Crew", "GUE_Soldier_Crew",
         "US_Soldier_Crew_EP1", "CZ_Soldier_Pilot_EP1", "GER_Soldier_EP1", "TK_Soldier_Crew_EP1", "TK_INS_Soldier_3_EP1", 
         "TK_GUE_Soldier_5_EP1", "UN_CDF_Soldier_Crew_EP1", "BAF_crewman_%1"
      ]; 
   };
   case "engineer":  
   { 
      _class = [
         "USMC_SoldierS_Engineer", "CDF_Soldier_Engineer", "RU_Soldier", "Ins_Soldier_Sapper", "GUE_Soldier_Sab",
         "US_Soldier_Engineer_EP1", "CZ_Soldier_B_DES_EP1", "GER_Soldier_EP1", "TK_Soldier_Engineer_EP1", "TK_INS_Soldier_3_EP1", 
         "TK_GUE_Soldier_3_EP1", "UN_CDF_Soldier_EP1", "BAF_Soldier_EN_%1"
      ]; 
   };
   case "grenadier": 
   { 
      _class = [
         "USMC_Soldier_GL", "CDF_Soldier_GL", "RU_Soldier_GL", "Ins_Soldier_GL", "GUE_Soldier_GL",
         "US_Soldier_GL_EP1", "CZ_Special_Forces_GL_DES_EP1", "GER_Soldier_EP1", "TK_Soldier_GL_EP1", "TK_INS_Soldier_2_EP1", 
         "TK_GUE_Soldier_4_EP1", "UN_CDF_Soldier_B_EP1", "BAF_Soldier_GL_%1"
      ]; 
   };
   case "marksman":  
   { 
      _class = [
         "USMC_SoldierM_Marksman", "CDF_Soldier_Marksman", "RU_Soldier_Marksman", "Ins_Soldier_2", "GUE_Soldier_2",
         "US_Soldier_Marksman_EP1", "CZ_Special_Forces_Scout_DES_EP1", "GER_Soldier_EP1", "TK_Soldier_EP1", "TK_INS_Soldier_3_EP1", 
         "TK_GUE_Soldier_5_EP1", "UN_CDF_Soldier_EP1", "BAF_Soldier_Marksman_%1"
      ]; 
   };
   case "medic":     
   { 
      _class = [
         "USMC_Soldier_Medic", "CDF_Soldier_Medic", "RU_Soldier_Medic", "Ins_Soldier_Medic", "GUE_Soldier_Medic",
         "US_Soldier_Medic_EP1", "CZ_Soldier_medik_DES_EP1", "GER_Soldier_Medic_EP1", "TK_Soldier_Medic_EP1", "TK_INS_Bonesetter_EP1", 
         "TK_GUE_Bonesetter_EP1", "UN_CDF_Soldier_EP1", "BAF_Soldier_Medic_%1"
      ]; 
   };
   case "mg":        
   { 
      _class = [
         "USMC_Soldier_MG", "CDF_Soldier_MG", "RU_Soldier_MG", "Ins_Soldier_MG", "GUE_Soldier_MG",
         "US_Soldier_MG_EP1", "CZ_Soldier_MG_DES_EP1", "GER_Soldier_MG_EP1", "TK_Soldier_MG_EP1", "TK_INS_Soldier_MG_EP1", 
         "TK_GUE_Soldier_MG_EP1", "UN_CDF_Soldier_MG_EP1", "BAF_Soldier_MG_%1"
      ]; 
   };
   case "amg":        
   { 
      _class = [
         "USMC_Soldier", "CDF_Soldier", "RU_Soldier", "Ins_Soldier_1", "GUE_Soldier_2",
         "US_Soldier_AMG_EP1", "CZ_Soldier_AMG_DES_EP1", "GER_Soldier_EP1", "TK_Soldier_AMG_EP1", "TK_INS_Soldier_4_EP1", 
         "TK_GUE_Soldier_2_EP1", "UN_CDF_Soldier_AMG_EP1", "BAF_Soldier_AMG_%1"
      ]; 
   };
   case "pilot":     
   { 
      _class = [
         "USMC_Soldier_Pilot", "CDF_Soldier_Pilot", "RU_Soldier_Pilot", "Ins_Soldier_Pilot", "GUE_Soldier_Pilot",
         "US_Soldier_Pilot_EP1", "CZ_Soldier_Pilot_EP1", "GER_Soldier_EP1", "TK_Soldier_Pilot_EP1", "TK_INS_Soldier_EP1", 
         "TK_GUE_Soldier_2_EP1", "UN_CDF_Soldier_Pilot_EP1", "BAF_Pilot_%1"
      ]; 
   };
   case "saboteur":  
   { 
      _class = [
         "FR_Sapper", "CDF_Soldier_Engineer", "RUS_Soldier_Sab", "Ins_Soldier_Sab", "GUE_Soldier_Sab",
         "US_Soldier_Engineer_EP1", "CZ_Soldier_B_DES_EP1", "GER_Soldier_EP1", "TK_Special_Forces_EP1", "TK_INS_Soldier_4_EP1", 
         "TK_GUE_Soldier_3_EP1", "UN_CDF_Soldier_EP1", "BAF_Soldier_EN_%1"
      ]; 
   };
   case "spotter":   
   { 
      _class = [
         "USMC_SoldierS_Spotter", "CDF_Soldier_Spotter", "RU_Soldier_Spotter", "Ins_Soldier_Sniper", "GUE_Soldier_Scout",
         "US_Soldier_Spotter_EP1", "CZ_Soldier_Sniper_EP1", "GER_Soldier_Scout_EP1", "TK_Soldier_Spotter_EP1", "TK_INS_Soldier_Sniper_EP1",
         "TK_GUE_Soldier_Sniper_EP1", "UN_CDF_Soldier_EP1", "BAF_Soldier_spotter_%1"
      ]; 
   };
   case "sniper":    
   { 
      _class = [
         "USMC_SoldierS_Sniper", "CDF_Soldier_Sniper", "RU_Soldier_Sniper", "Ins_Soldier_Sniper", "GUE_Soldier_Sniper",
         "US_Soldier_Sniper_EP1", "CZ_Soldier_Sniper_EP1", "GER_Soldier_Scout_EP1", "TK_Soldier_Sniper_EP1", "TK_INS_Soldier_Sniper_EP1", 
         "TK_GUE_Soldier_Sniper_EP1", "UN_CDF_Soldier_EP1", "BAF_Soldier_Sniper_%1"
      ]; 
   };  
   case "heavysniper":    
   { 
      _class = [
         "USMC_SoldierS_SniperH", "CDF_Soldier_Sniper", "RU_Soldier_SniperH", "Ins_Soldier_Sniper", "GUE_Soldier_Scout",
         "US_Soldier_SniperH_EP1", "CZ_Soldier_Sniper_EP1", "GER_Soldier_Scout_EP1", "TK_Soldier_SniperH_EP1", "TK_INS_Soldier_Sniper_EP1", 
         "TK_GUE_Soldier_Sniper_EP1", "UN_CDF_Soldier_EP1", "BAF_Soldier_SniperH_%1"
      ]; 
   }; 
   
   case "worker":    
   { 
      _class = [
         "USMC_Soldier_Light", "CDF_Soldier_Light", "RU_Soldier_Light", "Ins_Worker2", "GUE_Worker2",
         "US_Soldier_Light_EP1", "CZ_Soldier_Light_DES_EP1", "GER_Soldier_EP1", "TK_Soldier_Crew_EP1", "TK_INS_Soldier_2_EP1", 
         "TK_GUE_Soldier_4_EP1", "UN_CDF_Soldier_Light_EP1", "BAF_Soldier_L_%1"
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