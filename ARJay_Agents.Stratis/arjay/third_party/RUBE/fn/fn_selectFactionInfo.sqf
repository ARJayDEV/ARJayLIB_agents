/*
   Author:
    rübe
    
   Description:
    returns information (markers, colors, and such) about a given faction.
    You might wanna set the RUBE_CFG_SIDE_[FACTION] variables initially
    to whatever your mission needs them to be... (TODO/TESTING/WIP)
    
   Parameter(s):
    _this: faction (string)
           in ["USMC", "CDF", "RU", "INS", "GUE"]

   Returns:
    array 
    [
       0: (default-)side
       1: color
       2: marker flag class
       3: full name
    ]
*/


if (isnil ("RUBE_CFG_SIDE_USMC")) then    { RUBE_CFG_SIDE_USMC = West; };
if (isnil ("RUBE_CFG_SIDE_CDF")) then     { RUBE_CFG_SIDE_CDF = West; };
if (isnil ("RUBE_CFG_SIDE_RU")) then      { RUBE_CFG_SIDE_RU = East; };
if (isnil ("RUBE_CFG_SIDE_INS")) then     { RUBE_CFG_SIDE_INS = East; };
if (isnil ("RUBE_CFG_SIDE_GUE")) then     { RUBE_CFG_SIDE_GUE = Resistance; };
if (isnil ("RUBE_CFG_SIDE_US")) then      { RUBE_CFG_SIDE_US = West; };
if (isnil ("RUBE_CFG_SIDE_CZ")) then      { RUBE_CFG_SIDE_CZ = West; };
if (isnil ("RUBE_CFG_SIDE_GER")) then     { RUBE_CFG_SIDE_GER = West; };
if (isnil ("RUBE_CFG_SIDE_TK")) then      { RUBE_CFG_SIDE_TK = East; };
if (isnil ("RUBE_CFG_SIDE_TK_INS")) then  { RUBE_CFG_SIDE_TK_INS = East; };
if (isnil ("RUBE_CFG_SIDE_TK_GUE")) then  { RUBE_CFG_SIDE_TK_GUE = Resistance; };
if (isnil ("RUBE_CFG_SIDE_UN")) then      { RUBE_CFG_SIDE_UN = Resistance; };
if (isnil ("RUBE_CFG_SIDE_BAF")) then     { RUBE_CFG_SIDE_BAF = West; };

private ["_info"];

_info = [];

switch (_this) do
{
   // A2
   case "USMC": {
      _info = [
         RUBE_CFG_SIDE_USMC,
         "ColorBlue",
         "Faction_US",
         "United States Marine Corps (USMC)"
      ];
   };
   case "CDF": {
      _info = [
         RUBE_CFG_SIDE_CDF,
         "ColorBlue",
         "Faction_CDF",
         "Chernarussian Defence Forces (CDF)"
      ];
   };
   case "RU": {
      _info = [
         RUBE_CFG_SIDE_RU,
         "ColorRed",
         "Faction_RU",
         "Russian Armed Forces (RU)"
      ];
   };
   case "INS": {
      _info = [
         RUBE_CFG_SIDE_INS,
         "ColorOrange",
         "Faction_INS",
         "Chernarussian Movement of the Red Star (ChDKZ)"
      ];
   };
   case "GUE": {
      _info = [
         RUBE_CFG_SIDE_GUE,
         "ColorBrown",
         "Faction_GUE",
         "National Party (NAPA)"
      ];
   };
   // OA
   case "US": {
      _info = [
         RUBE_CFG_SIDE_US,
         "ColorBlue",
         "Faction_USA_EP1",
         "United States Army (US)"
      ];
   };
   case "CZ": {
      _info = [
         RUBE_CFG_SIDE_CZ,
         "ColorBlue",
         "Faction_CzechRepublic_EP1",
         "601st Special Forces Group of the Army of the Czech Republic"
      ];
   };
   case "GER": {
      _info = [
         RUBE_CFG_SIDE_GER,
         "ColorYellow",
         "Faction_Germany_EP1",
         "Kommando Spezialkräfte (KSK)"
      ];
   };
   case "TK": {
      _info = [
         RUBE_CFG_SIDE_TK,
         "ColorRed",
         "Faction_TKA_EP1",
         "Takistani Army"
      ];
   };
   case "TK_INS": {
      _info = [
         RUBE_CFG_SIDE_TK_INS,
         "ColorOrange",
         "Faction_TKM_EP1",
         "Takistani Militia"
      ];
   };
   case "TK_GUE": {
      _info = [
         RUBE_CFG_SIDE_TK_GUE,
         "ColorKhaki",
         "Faction_TKG_EP1",
         "Takistanian local fighters"
      ];
   };
   case "UN": {
      _info = [
         RUBE_CFG_SIDE_UN,
         "ColorBlue",
         "Faction_UNO_EP1",
         "UNFORT (UN Forces Takistan)"
      ];
   };
   // DLC
   case "BAF": {
      _info = [
         RUBE_CFG_SIDE_BAF,
         "ColorBlue",
         "Faction_BritishArmedForces_BAF",
         "British Armed Forces (BAF)"
      ];
   };   
};

_info