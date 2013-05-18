/*
   Author:
    rübe
    
   Description:
    spawns objects in a grid arrangement/alignment. You can
    specify corner, border/edge and cell/inside objects separately.
    
    - This is like the little brother of RUBE_makeGrid, simple but fast,
      without gridQuery (to address more specific grid positions).. If
      you need that (eg. to address middle-cells for entries/gaps) you
      know where to look...
      
   Parameter(s):
    _this select 0: grird position (array of [x, y] OR [x, y, ref-point])
                    - ref-point = string "topleft", "bottomleft", "center"
                      - default = "bottomleft";
                      
    _this select 1: orientation/direction (number)
    
    _this select 2: grid size (array [x, y, ("meters" || "cells")], default = "meters")
                    - 3rd value is optional:
                       - "cells" exact number of cells
                       - "meters" any number of cells that fits in the defined rect.
                    
    _this select 3: cell size (array of [x, y] in meters)
                    
    _this select 4: grid object-data/functions (array of (up to 3) object-arrays, object-class-strings OR functions)
                    - array length 1 -> used for all grid positions (cell, border and corner)
                    - array length 2 -> 1st for cell, 2nd for border and corner
                    - array length 3 -> 1st for cell, 2nd for border, 3rd for corner
                    
                    -> use empty strings or empty arrays to negate a given grid-position
    
    _this select 5: auto-rotate/manipulate object rotation for border and corner cells (boolean)
                    - optional, default = true;
    
      - Object data structure:
           array [
              object class (string),
              position offset (array),
              rotation (number),
              pitch (number, optional),
              bank (number, optional)
           ]
           
         OR
         
         object class (string)
   
      - Custom Function/Code get's passed:
           _this select 0: position (cell-center)
           _this select 1: direction (manipulated for border and edge cells!)
           _this select 2: cell-id (counting from 1 to n cells, starting topleft)
           _this select 3: cell-type:
                           0 = cell
                           1 = border top, 2 = right, 3 = bottom, 4 = left
                           5 = corner topleft, 6 = topright, 7 = bottomright, 8 = bottomleft
           _this select 4: cell-depth (0=corner/edge, inc. every step inwards, highest at the center)

                -> cell-id and/or cell-depth may be usefull for simple modulo op. 
                   to alternate between diff. objects
           
         -> must return an array of objects (thus may return more than one per cell)
    
   Returns:
    array of (spawned) objects
*/

private ["_position", "_pos", "_ref", "_direction", "_directionNOR", "_gridSize", "_gridX", "_gridY", "_gridUnit", "_cell", "_cellX", "_cellY", "_absX", "_absY", "_vecX", "_vecY", "_components", "_manipulateCellDir", "_i", "_x", "_y", "_mapCell", "_mapPosition", "_objects"];


_position = [
   ((_this select 0) select 0),
   ((_this select 0) select 1),
   0
];
_ref = "bottomleft";
if ((count (_this select 0)) > 2) then
{
   if ((typeName ((_this select 0) select 2)) == "STRING") then
   {
      _ref = (_this select 0) select 2;
   };
};

_direction = _this select 1;
_directionNOR = (360 - _direction) % 360;
_gridSize = _this select 2;
_gridUnit = "meters";
if ((count _gridSize) > 2) then
{
   _gridUnit = (_gridSize select 2);
};
_gridX = (_this select 2) select 0;
_gridY = (_this select 2) select 1;
_cellX = (_this select 3) select 0;
_cellY = (_this select 3) select 1;

if (_gridUnit == "meters") then
{
   _gridX = floor (_gridX / _cellX);
   _gridY = floor (_gridY / _cellY);
};

_absX = _gridX * _cellX;
_absY = _gridY * _cellY;

_vecX = [[_cellX, 0], _directionNOR] call BIS_fnc_rotateVector2D;
_vecY = [[0, _cellY], _directionNOR] call BIS_fnc_rotateVector2D;

/* 
_flag1 = "FlagCarrierRU" createVehicle _position;
_flag1 setPos _position;
*/

// map grid position according to given reference point
switch (_ref) do
{
   case "topleft":
   {
      _position = [
         _position,
         [
            0,
            (_absY * -1) + (_cellY * 0.5)
         ],
         _directionNOR,
         false
      ] call RUBE_gridOffsetPosition;
   };
   case "center":
   {
      _position = [
         _position,
         [
            (_absX * -0.5) + (_cellX * 0.5),
            (_absY * -0.5) + (_cellY * 0.5)
         ],
         _directionNOR,
         false
      ] call RUBE_gridOffsetPosition;
   };
};

/*
_flag2 = "FlagCarrierUSA" createVehicle _position;
_flag2 setPos _position;
*/

// init grid components [cell, border, corner]
_components = [
   ((_this select 4) select 0),
   ((_this select 4) select 0),
   ((_this select 4) select 0)
];
for "_i" from 1 to 2 do
{
   if ((count (_this select 4)) >= _i) then
   {
      _components set [_i, ((_this select 4) select _i)];
   };
};


// add a null vector for string-class-components 
// (so spawnObjects doesn't bug out)
for "_i" from 0 to 2 do
{
   if ((typeName (_components select _i)) == "STRING") then
   {
      if ((_components select _i) != "") then
      {
         _components set [_i, [(_components select _i), [0,0,0]]];
      };
   };
};



_manipulateCellDir = true;
if ((count _this) > 5) then
{
   _manipulateCellDir = _this select 5;
};

// private function to map a cell -> [component-id, direction-offset, cell-id, cell-type, cell-depth]
_mapCell = {
   private ["_x", "_y", "_xe", "_ye", "_id", "_dir", "_cellId", "_type", "_depth"];
   _x = _this select 0;
   _y = _this select 1;
   _xe = (_this select 2) - 1;
   _ye = (_this select 3) - 1;
   
   _id = 0;
   _dir = 0;
   _cellId = (_y * (_this select 2)) + (_x + 1);
   _type = 0;
   _depth = [_x, _y, _gridX, _gridY] call RUBE_gridCellDepth;
   
   // only corners/borders have a cell-depth of 0
   if (_depth == 0) then
   {
      // corners
      if (_x == 0 && _y == _ye)   exitWith { _id = 2; _type = 5; };
      if (_x == _xe && _y == _ye) exitWith { _id = 2; _type = 6; _dir = 90; };
      if (_x == _xe && _y == 0)   exitWith { _id = 2; _type = 7; _dir = 180; };
      if (_x == 0 && _y == 0)     exitWith { _id = 2; _type = 8; _dir = 270; };
      // borders
      if (_y == _ye) exitWith { _id = 1; _type = 1; };
      if (_x == _xe) exitWith { _id = 1; _type = 2; _dir = 90; };
      if (_y == 0)   exitWith { _id = 1; _type = 3; _dir = 180; };
      if (_x == 0)   exitWith { _id = 1; _type = 4; _dir = 270; };
   };
   
   if (!_manipulateCellDir) then
   {
      _dir = 0;
   };
   
   [_id, _dir, _cellId, _type, _depth]
};



// final objects
_objects = [];



for "_x" from 0 to (_gridX - 1) do
{
   for "_y" from 0 to (_gridY - 1) do
   {
      _cell = [_x, _y, _gridX, _gridY] call _mapCell;
      _pos = [_position, _x, _y, _vecX, _vecY] call RUBE_gridCellPosition;

		/*
		_flag3 = "FlagCarrierCDF" createVehicle _pos;
		_flag3 setPos _pos;
		*/
      
      switch (typeName (_components select (_cell select 0))) do
      {
         case "STRING":
         {
            if ((_components select (_cell select 0)) != "") then
            {
               {
               	_objects set [(count _objects), _x];
               } foreach ([
                  _pos, 
                  (_direction + (_cell select 1)),
                  [(_components select (_cell select 0))]
               ] call RUBE_spawnObjects);
            };       
         };
         case "ARRAY":
         {
            if ((count (_components select (_cell select 0))) > 0) then
            {
               {
               	_objects set [(count _objects), _x];
               } foreach ([
                  _pos, 
                  (_direction + (_cell select 1)),
                  [(_components select (_cell select 0))]
               ] call RUBE_spawnObjects);
            };       
         };
         case "CODE":
         {
            {
            	_objects set [(count _objects), _x];
            } foreach ([
               _position,
               (_cell select 1),
               (_cell select 2),
               (_cell select 3),
               (_cell select 4)
            ] call (_components select (_cell select 0)));
         };
      }
   };
};


// return objects
_objects