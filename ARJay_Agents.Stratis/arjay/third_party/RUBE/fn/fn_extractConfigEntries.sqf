/*
   Author:
    rübe
    
   Description:
    extracts config entries into an array with the use of custom
    selectors and a custom filter.
    
   Parameter(s):
    _this select 0: config/path (configFile/-Path)
    _this select 1: variables (array of strings/variable-names AND/OR 
                    code given the current class, returning any AND/OR
                    boolean to retrieve the current class itself (true) 
                    and the className (false))
    _this select 2: filter (function given the entry, returning boolean, 
                    optional)
   
   
   
   
   Example: (retrieves all CityCenters on the current island)
   
    // this will define the structure and contents of the arrays
    // we'll get back! (same order!)
    _cityCenterVariables = [
       false, // retrieve className
       true,  // retrieve the config itself
       "name", 
       "position", 
       // custom selector/manipulator:
       { 
         [
            (getNumber (_this >> "radiusA")), 
            (getNumber (_this >> "radiusB"))
         ] 
       },
       "type", 
       "speech",
       "neighbors",
       "demography"
    ];
    
    _cityCenterFilter = {
       if ((getText (_this >> "type")) in ["CityCenter"]) exitWith
       {
          true
       };
       false
    };
    
    _entries = [
       (configFile >> "CfgWorlds" >> worldName >> "Names"),
       _cityCenterVariables, 
       _cityCenterFilter
    ] call RUBE_extractConfigEntries;
    
    // (count _entries) == 46
    // (_entries select 0) returns:
    /-
       [
          "ACityC_Chernogorsk", 
          bin\config.bin/CfgWorlds/Chernarus/Names/ACityC_Chernogorsk, 
          "", 
          [6735.83,2626.6], 
          [100,100], 
          "CityCenter", 
          <null>, 
          ["ACityC_Prigorodki","ACityC_Balota","ACityC_Nadezhdino","ACityC_Mogilevka"], 
          ["CIV",1,"CIV_RU",0]
       ]
    -/
    
    
   Returns:
    array of config-entries with the desired variables in given order
*/

private ["_cfg", "_variables", "_filter", "_entries", "_extractValue", "_e"];

_cfg = _this select 0;
_variables = _this select 1;
_filter = { true };
_entries = [];

_extractValue = {
   if (isNumber _this) exitWith
   {
      (getNumber _this)
   };
   if (isText _this) exitWith
   {
      (getText _this)
   };
   if (isArray _this) exitWith
   {
      (getArray _this)
   };
   if (isClass _this) exitWith
   {
      private ["_c"];
      _c = [];
      for "_i" from 0 to ((count _this) - 1) do
      {
         _c = _c + [((_this select _i) call _extractValue)];
      };
      _c
   };
};

if ((count _this) > 2) then
{
   _filter = _this select 2;
};

for "_i" from 0 to ((count _cfg) - 1) do
{
   if ((_cfg select _i) call _filter) then
   {
      _e = [];
      {
         switch (typeName _x) do
         {
            // custom selector
            case "CODE":
            {
               _e = _e + [((_cfg select _i) call _x)];
            };
            // class selector/itself
            case "BOOL":
            {
               if (_x) then
               {
                  _e = _e + [(_cfg select _i)];
               } else {
                  _e = _e + [(configName (_cfg select _i))];
               };
            };
            // default selector
            default
            {
               _e = _e + [(((_cfg select _i) >> _x) call _extractValue)];
            };
         };
      } forEach _variables;
      
      _entries = _entries + [_e];
   };
};

_entries