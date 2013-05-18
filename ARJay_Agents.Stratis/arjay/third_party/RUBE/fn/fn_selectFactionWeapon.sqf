/*
   Author:
    rübe
    
   Description:
    get the weapon-class of a given faction and type
    (we return western weapons for CDF!)
    
   Parameters:
    _this select 0: weapon-type (string)
                    in ["rifle", "rifle-scoped", "rifle-launcher", "rifle-silenced", 
                        "shotgun", "sniper", "mg", "pistol", "at-light", "at-heavy", 
                        "aa", "handgrenade"]
                    
    _this select 1: faction (string)
                    in ["USMC", "CDF", "RU", "INS", "GUE", "CIV"]
*/

private ["_type", "_faction", "_class"];

_type = _this select 0;
_faction = 0;
_class = ["", "", "", "", ""];

// faction index mapping
switch (_this select 1) do
{
   // A2
   case "USMC": { _faction = 0; };
   case "CDF":  { _faction = 1; };
   case "RU":   { _faction = 2; };
   case "INS":  { _faction = 3; };
   case "GUE":  { _faction = 4; };
   case "CIV":  { _faction = 5; };
   // OA
   case "US":         { _faction = 6; };
   case "CZ":         { _faction = 7; };
   case "GER":        { _faction = 8; };
   case "TK":         { _faction = 9; };
   case "TK_INS":     { _faction = 10; };
   case "TK_GUE":     { _faction = 11; };
   case "UN":         { _faction = 12; };
   case "BAF":         { _faction = 13; };
};

switch (_type) do 
{
   case "rifle":           
   { 
      _class = [
         "M4A1", "M16A2", "AK_107_kobra", "AK_74", "AK_47_M", "AK_47_S",
         "SCAR_L_STD_HOLO", "Sa58V_CCO_EP1", "G36a_camo", "FN_FAL", "FN_FAL", "AK_47_M", "AKS_74_kobra",
         "BAF_L85A2_RIS_Holo"
      ]; 
   };
   case "rifle-scoped":    
   { 
      _class = [
         "G36a", "M16A4_ACG", "AK_107_pso", "AKS_74_pso", "AKS_74_pso", "AKS_74_pso",
         "SCAR_L_STD_EGLM_RCO", "Sa58V_RCO_EP1", "G36_C_SD_camo", "AKS_74_pso", "AKS_74_pso", "AKS_74_pso", "AKS_74_pso",
         "BAF_L85A2_RIS_ACOG"
      ]; 
   };
   case "rifle-launcher":  
   { 
      _class = [
         "M16A4_ACG_GL", "M16A2GL", "AK_107_GL_pso", "AK_74_GL", "AK_74_GL", "AK_74_GL",
         "SCAR_L_CQC_EGLM_Holo", "M4A3_RCO_GL_EP1", "SCAR_L_STD_EGLM_RCO", "M16A2GL", "M16A2GL", "AK_74_GL", "AK_74_GL_kobra",
         "BAF_L85A2_UGL_Holo"
      ]; 
   };
   case "rifle-silenced":  
   { 
      _class = [
         "M4A1_AIM_SD_camo", "MP5SD", "bizon_silenced", "bizon_silenced", "bizon_silenced", "AKS_74_U",
         "SCAR_L_CQC_CCO_SD", "AKS_74_U", "G36_C_SD_camo", "AKS_74_U", "AKS_74_U", "AKS_74_U", "AKS_74_U",
         "MP5SD"
      ]; 
   };
   case "shotgun":         
   { 
      _class = [
         "M1014", "M1014", "Saiga12K", "Saiga12K", "Saiga12K", "Saiga12K",
         "M1014", "M1014", "M1014", "Saiga12K", "Saiga12K", "Saiga12K", "Saiga12K",
         "M1014"
      ]; 
   };
   case "sniper":          
   { 
      _class = [
         "M40A3", "M24", "SVD_CAMO", "SVD", "SVD", "Huntingrifle",
         "M110_TWS_EP1", "SVD_des_EP1", "M110_TWS_EP1", "SVD_des_EP1", "SVD", "SVD", "SVD",
         "BAF_LRR_scoped"
      ]; 
   };
   case "mg":              
   { 
      _class = [
         "Mk_48", "M240", "Pecheneg", "PK", "PK", "RPK_74",
         "m240_scoped_EP1", "M60A4_EP1", "MG36_camo", "PK", "PK", "PK", "PK",
         "BAF_L7A2_GPMG"
      ]; 
   };
   case "pistol":          
   { 
      _class = [
         "M9SD", "M9", "MakarovSD", "Makarov", "Makarov", "Colt1911",
         "Colt1911", "glock17_EP1", "glock17_EP1", "Sa61_EP1", "revolver_EP1", "revolver_EP1", "Makarov",
         "Colt1911"
      ]; 
   };
   case "at-light":        
   { 
      _class = [
         "SMAW", "M136", "RPG7V", "RPG7V", "RPG7V", "RPG7V",
         "MAAWS", "M47Launcher_EP1", "MAAWS", "RPG7V", "RPG7V", "RPG7V", "RPG7V",
         "BAF_NLAW_Launcher"
      ]; 
   };
   case "at-heavy":        
   { 
      _class = [
         "Javelin", "Javelin", "MetisLauncher", "MetisLauncher", "MetisLauncher", "MetisLauncher",
         "Javelin", "MetisLauncher", "Javelin", "MetisLauncher", "MetisLauncher", "MetisLauncher", "MetisLauncher",
         "Javelin"
      ]; 
   };
   case "aa":              
   { 
      _class = [
         "Stinger", "Stinger", "Igla", "Igla", "Strela", "Strela",
         "Stinger", "Igla", "Stinger", "Strela", "Strela", "Igla", "Igla",
         "Stinger"
      ]; 
   };
   case "handgrenade":     
   { 
      _class = [
         "HandGrenade_West", "HandGrenade", "HandGrenade_East", "HandGrenade_East", "HandGrenade", "HandGrenade",
         "HandGrenade_West", "HandGrenade", "HandGrenade", "HandGrenade", "HandGrenade", "HandGrenade", "HandGrenade",
         "BAF_L109A1_HE"
      ]; 
   };
};

// failsafe (explicit class selection)
if (((count _class) - 1) < _faction) exitWith
{
   _type
};

// return class
(_class select _faction)