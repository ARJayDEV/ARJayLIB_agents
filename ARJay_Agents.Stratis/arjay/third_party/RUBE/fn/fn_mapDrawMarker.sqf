/*
   Author:
    rübe
    
   Description:
    creates a marker on the map
   
   Parameter(s):
    _this: parameters (array of array [key (string), value (any)])
    
           - required:
             - "position" (position)
             - "type" ("ELLIPSE", "RECTANGLE" or ICON-string)
             
           - optional:
             - "id" (unique marker string, default = RUBE_generateID)
             - "direction" (scalar)
             - "color" (string, default = Default)
             - "text" (string, default = "")
             - "size" (scalar or array [scalar, scalar], default = 1)
             - "brush" (string, default = SOLID)
                ["SOLID", "HORIZONTAL", "VERTICAL", "GRID", "FDIAGONAL", 
                 "BDIAGONAL", "DIAGGRID", "CROSS", "BORDER"]
             - "alpha" (scalar from 0.0 to 1.0, default = false)
           
    
   Example:
    _marker = [
       ["position", _pos],
       ["type", "FireMission"],
       ["color", "ColorRed"],
       ["text", "random"]
    ] call RUBE_mapDrawMarker; 
   
   Returns:
    marker
*/

private ["_id", "_mrk", "_pos", "_dir", "_color", "_text", "_size", "_shape", "_type", "_brush", "_alpha"];

_id = "";
_mrk = "";
_pos = [0,0,0];
_dir = 0;
_color = "Default";
_text = "";
_size = [];
_shape = "RECTANGLE";
_type = "";
_brush = "SOLID";
_alpha = false;


// read parameters
{
   switch (_x select 0) do
   {
      case "id":    
      { 
         if ((typeName (_x select 1)) == "STRING") then
         {
            _id = _x select 1; 
         };
      };
      case "position":
      {
         _pos = _x select 1;
      };
      case "direction":
      {
         _dir = _x select 1;
      };
      case "color":
      {
         _color = _x select 1;
      };
      case "text":
      {
         _text = _x select 1;
      };
      case "size":
      {
         if ((typeName (_x select 1)) == "ARRAY") then
         {
            _size = _x select 1;
         } else {
            _size = [(_x select 1), (_x select 1)];
         };
      };
      // this may be a geometric area (_shape) or an icon (_type)
      case "type":
      {
         switch (_x select 1) do
         {
            case "RECTANGLE":
            {
               _shape = "RECTANGLE";
            };
            case "ELLIPSE":
            {
               _shape = "ELLIPSE";
            };
            default
            {
               _shape = "ICON";
               _type = (_x select 1);
            };
         };
      };
      case "brush":
      {
         _brush = _x select 1;
      };
      case "alpha":
      {
         _alpha = _x select 1;
      };
   };
} forEach _this;

// create marker
if (_id == "") then
{
   _id = [] call RUBE_createMarkerID;
};
_mrk = createMarker [_id, _pos];

// define marker
_mrk setMarkerDir _dir;
_mrk setMarkerPos _pos;
_mrk setMarkerColor _color;
if ((count _size) > 0) then
{
   _mrk setMarkerSize _size;
};
if (_text != "") then
{
   _mrk setMarkerText _text;
};

if (_type == "") then
{
   _mrk setMarkerShape _shape;
   _mrk setMarkerBrush _brush;
} else {
   _mrk setMarkerShape "ICON";
   _mrk setMarkerType _type;
};

if ((typeName _alpha) == "SCALAR") then
{
   _mrk setMarkerAlpha _alpha;
};

// return marker
_mrk