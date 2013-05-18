/*
   Author:
    rübe
   
   Description:
    takes a class string for a default/woodlandish object and tries 
    to return the desertish equivalent. The same object is returned
    in case no alternative could be found.
    
   Parameter(s):
    _this: object class (string)
    
   Returns:
    object class (string)
*/

private ["_class"];

_class = _this;

switch (_class) do
{
   case "Fort_Barricade": { _class = "Fort_Barricade_EP1"; };
   case "Fort_EnvelopeBig": { _class = "Fort_EnvelopeBig_EP1"; };
   case "Fort_EnvelopeSmall": { _class = "Fort_EnvelopeSmall_EP1"; };
   case "Land_Fort_Watchtower": { _class = "Land_Fort_Watchtower_EP1"; };
   case "Land_fort_artillery_nest": { _class = "Land_fort_artillery_nest_EP1"; };
   case "Land_fort_rampart": { _class = "Land_fort_rampart_EP1"; };
   case "Land_fortified_nest_big": { _class = "Land_fortified_nest_big_EP1"; };
   case "Land_fortified_nest_small": { _class = "Land_fortified_nest_small_EP1"; };
   
   case "CampEast": { _class = "CampEast_EP1"; };
   case "MASH": { _class = "MASH_EP1"; };
   
   case "Land_CamoNet_NATO": { _class = "Land_CamoNet_NATO_EP1"; };
   case "Land_CamoNet_EAST": { _class = "Land_CamoNet_EAST_EP1"; };
   case "Land_CamoNetB_NATO": { _class = "Land_CamoNetB_NATO_EP1"; };
   case "Land_CamoNetB_EAST": { _class = "Land_CamoNetB_EAST_EP1"; };
   case "Land_CamoNetVar_NATO": { _class = "Land_CamoNetVar_NATO_EP1"; };
   case "Land_CamoNetVar_EAST": { _class = "Land_CamoNetVar_EAST_EP1"; };
   
   case "PowGen_Big": { _class = "PowGen_Big_EP1"; };
   case "Land_Dirthump01": { _class = "Land_Dirthump01_EP1"; };
   case "Land_Dirthump02": { _class = "Land_Dirthump02_EP1"; };
   case "Land_Dirthump03": { _class = "Land_Dirthump03_EP1"; };
};

// return class
_class