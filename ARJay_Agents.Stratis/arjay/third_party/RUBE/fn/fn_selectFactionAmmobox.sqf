/*
   Author:
    rübe
    
   Description:
    get the ammobox-class of a given faction and type
    
   Parameter(s):
    _this select 0: type (string)
                    in ["weapons", "ammunition", "launcher", 
                        "ordnance", "special", "vehicle"]
                    
    _this select 1: faction (string)
                    in ["USMC", "CDF", "RU", "INS", "GUE", "CIV"]
   
   Returns:
    string 
*/

private ["_type", "_faction", "_class"];

_type = _this select 0;
_faction = 0;
_class = ["", "", "", "", ""];

// faction index mapping
switch (_this select 1) do
{
   case "USMC": { _faction = 0; };
   case "CDF":  { _faction = 1; };
   case "RU":   { _faction = 2; };
   case "INS":  { _faction = 3; };
   case "GUE":  { _faction = 4; };
   case "CIV":  { _faction = 4; };
   // OA
   case "US":         { _faction = 5; };
   case "CZ":         { _faction = 6; };
   case "GER":        { _faction = 7; };
   case "TK":         { _faction = 8; };
   case "TK_INS":     { _faction = 9; };
   case "TK_GUE":     { _faction = 10; };
   case "UN":         { _faction = 11; };   
   case "BAF":         { _faction = 12; };  
};

switch (_type) do 
{
   case "weapons":    
   { 
      _class = [
         "USBasicWeaponsBox", "RUBasicWeaponsBox", "RUBasicWeaponsBox", "RUBasicWeaponsBox", "LocalBasicWeaponsBox",
         "USBasicWeapons_EP1", "CZBasicWeapons_EP1", "GERBasicWeapons_EP1", "TKBasicWeapons_EP1", "TKBasicWeapons_EP1", "TKBasicWeapons_EP1", "UNBasicWeapons_EP1",
         "BAF_BasicWeapons"
      ]; 
   };
   case "ammunition": 
   { 
      _class = [
         "USBasicAmmunitionBox", "RUBasicAmmunitionBox", "RUBasicAmmunitionBox", "RUBasicAmmunitionBox", "LocalBasicAmmunitionBox",
         "USBasicAmmunitionBox_EP1", "USBasicAmmunitionBox_EP1", "USBasicAmmunitionBox_EP1", "TKBasicAmmunitionBox_EP1", "TKBasicAmmunitionBox_EP1", "TKBasicAmmunitionBox_EP1", "UNBasicAmmunitionBox_EP1",
         "BAF_BasicAmmunitionBox"
      ]; 
   };
   case "launcher":   
   { 
      _class = [
         "USLaunchersBox", "RULaunchersBox", "RULaunchersBox", "RULaunchersBox", "RULaunchersBox",
         "USLaunchers_EP1", "TKLaunchers_EP1", "USLaunchers_EP1", "TKLaunchers_EP1", "TKLaunchers_EP1", "TKLaunchers_EP1", "TKLaunchers_EP1",
         "BAF_Launchers"
      ]; 
   };
   case "ordnance":  
   { 
      _class = [
         "USOrdnanceBox", "RUOrdnanceBox", "RUOrdnanceBox", "RUOrdnanceBox", "RUOrdnanceBox",
         "USOrdnanceBox_EP1", "TKOrdnanceBox_EP1", "USOrdnanceBox_EP1", "TKOrdnanceBox_EP1", "TKOrdnanceBox_EP1", "TKOrdnanceBox_EP1", "TKOrdnanceBox_EP1",
         "BAF_OrdnanceBox"
      ]; 
   };
   case "special":    
   { 
      _class = [
         "USSpecialWeaponsBox", "RUSpecialWeaponsBox", "RUSpecialWeaponsBox", "RUSpecialWeaponsBox", "SpecialWeaponsBox",
         "USSpecialWeapons_EP1", "TKSpecialWeapons_EP1", "USSpecialWeapons_EP1", "TKSpecialWeapons_EP1", "TKSpecialWeapons_EP1", "TKSpecialWeapons_EP1", "TKSpecialWeapons_EP1",
         "BAF_BasicWeapons"
      ]; 
   };
   case "vehicle":    
   { 
      _class = [
         "USVehicleBox", "RUVehicleBox", "RUVehicleBox", "RUVehicleBox", "RUVehicleBox",
         "USVehicleBox_EP1", "TKVehicleBox_EP1", "USVehicleBox_EP1", "TKVehicleBox_EP1", "TKVehicleBox_EP1", "TKVehicleBox_EP1", "TKVehicleBox_EP1",
         "BAF_VehicleBox"
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