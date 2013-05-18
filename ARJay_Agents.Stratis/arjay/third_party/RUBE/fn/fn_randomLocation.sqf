/*
   Author:
    rübe
   
   Description:
    returns a random location from the current world.
    
   Parameter(s):
    _this: parameters (array of array [key (string), value (any)])
    
           - required:
           
             none.
             
           - optional:
           
             - "type" (string or array of strings)
                  names/location type(s) to pick from.
               - default = ["NameCityCapital", "NameCity", "NameVillage", "NameLocal"]
               
             - "selector" (array of [string|boolean|selector-code])
                  config information selector. See RUBE_extractConfigEntries
               for further information.
               
               
      btw. the config path to the names/locations is:
       (configFile >> "CfgWorlds" >> worldName >> "Names")
   
   Returns:
   an empty array in case of failure OR
   [
      0: location entry classname (string)
      1: location entry (config entry)
      2: location name; int./translated (string)
      3: location type (string)
      4: location position (2d position)
      5: location size (array [x-rad, y-rad])
      6: location angle (scalar)      
        
           ... or whatever is specified in your 
           custom information selector
   ]
*/

private ["_types", "_selector", "_filter", "_entries"];

_types = ["NameCityCapital", "NameCity", "NameVillage", "NameLocal"];

_selector = [
   false,
   true,
   "name", 
   "type",
   "position", 
   { [(getNumber (_this >> "radiusA")), (getNumber (_this >> "radiusB"))] },
   "angle"
];

_filter = {
   if ((getText (_this >> "type")) in _types) exitWith
   {
      true
   };
   false
};

// read parameters
{
   switch (_x select 0) do
   {
      case "selector": { _selector = _x select 1; };
      case "type": 
      { 
         if ((typeName (_x select 1)) == "ARRAY") then
         {
            _types = _x select 1;
         } else
         {
            _types = [(_x select 1)]; 
         };
      };
   };
} forEach _this;




// extract entries
_entries = [
   (configFile >> "CfgWorlds" >> worldName >> "Names"),
   _selector, 
   _filter
] call RUBE_extractConfigEntries;

// return a random one
if ((count _entries) == 0) exitWith
{
   []
};

(_entries call RUBE_randomSelect)