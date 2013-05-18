/*
   Author:
    rübe
    
   Description:
    given a tent (as object!), this function returns an array of save position 
    and direction to spawn stuff in the size of .. say a table, an ammocrate or 
    the like.
    
    Guaranteed to return at least one position
    
   Parameter(s):
    _this: tent (object)
    
    OR
    
    _this select 0: tent (object)
    _this select 1: position type (string in ["table", "cargo", "sleep"])
                     select different position layouts
                    - reference objects:
                      - "table": FoldTable (~ 2.02 x 0.82)
                      - "cargo": Barrels   (~ 1.6 x 1.6)
                      - "sleep": sleeping soldier, laying on the floor
                    - default = "table"

   Returns:
    array of [position, direction]
*/

private ["_obj", "_class", "_posType", "_positions", "_pos"];

_obj = _this;
_posType = "table";

if ((typeName _this) == "ARRAY") then
{
   _obj = _this select 0;
   if ((count _this) > 1) then
   {
      _posType = _this select 1;
   };
};


_class = typeOf _obj;
_positions = [];

// convert same objects/different classes
switch (_class) do
{
   case "Camp": { _class = "MASH"; }; 
   case "MASH_EP1": { _class = "MASH"; };   
   case "CampEast_EP1": { _class = "CampEast"; };
};

// lookup positions
switch (_class) do
{
   case "CampEast":
   {
      switch (_posType) do
      {
         case "cargo":
         {
            _positions = [
               [[0, 2.75, 0], 0],
               [[1.9, 2.75, 0], 0],
               [[-1.9, 2.75, 0], 0],
               
               [[1.9, 0.8, 0], 90],
               [[-1.9, 0.8, 0], -90],
               
               [[1.9, -1.0, 0], 90],
               [[-1.9, -1.0, 0], -90],
               
               [[1.9, -2.8, 0], 90],
               [[-1.9, -2.8, 0], -90]
            ];
         };
         case "sleep":
         {
            _positions = [
               [[0.4, 2.7, 0], 90],
               [[-0.4, 2.7, 0], -90],
               
               [[0.4, 1.3, 0], 90],
               [[-0.4, 1.3, 0], -90],
               
               [[0.4, -0.1, 0], 90],
               [[-0.4, -0.1, 0], -90],
               
               [[0.4, -1.5, 0], 90],
               [[-0.4, -1.5, 0], -90],
               
               [[0.4, -2.9, 0], 90],
               [[-0.4, -2.9, 0], -90]
            ];
         };
         default
         {
            _positions = [
               [[0, 2.75, 0], 180],
               [[2.0, 1.0, 0], -90],
               [[-2.0, 1.0, 0], 90],
               [[2.0, -1.5, 0], -90],
               [[-2.0, -1.5, 0], 90]
            ];
         };
      };
   };
   case "Land_tent_east":
   {
      switch (_posType) do
      {
         case "cargo":
         {
            _positions = [
               [[2.9, -2.0, 0], 180],
               [[2.9, 2.0, 0], 0],
               
               [[0.9, -2.0, 0], 180],
               [[0.9, 2.0, 0], 0],
               
               [[-1.2, -2.0, 0], 180],
               [[-1.2, 2.0, 0], 0],
               
               [[-3.2, -2.0, 0], 180],
               [[-3.2, 2.0, 0], 0]
            ];
         };
         case "sleep":
         {
            _positions = [
               [[3.0, -0.4, 0], 180],
               [[3.0, 0.4, 0], 0],
               
               [[1.4, -0.4, 0], 180],
               [[1.4, 0.4, 0], 0],
               
               [[-0.2, -0.4, 0], 180],
               [[-0.2, 0.4, 0], 0],
               
               [[-1.7, -0.4, 0], 180],
               [[-1.7, 0.4, 0], 0],
               
               [[-3.3, -0.4, 0], 180],
               [[-3.3, 0.4, 0], 0]
            ];
         };
         default
         {
            _positions = [
               [[0, -2.3, 0], 0],
               [[0, 2.3, 0], 180],
               
               [[2.5, -2.3, 0], 0],
               [[2.5, 2.3, 0], 180],
               
               [[-2.5, -2.3, 0], 0],
               [[-2.5, 2.3, 0], 180]
            ];
         };
      };
   };
   case "MASH":
   {
      switch (_posType) do
      {
         case "cargo":
         {
            _positions = [
               [[1.5, -1.5, 0], 90],
               [[-0.35, -1.5, 0], -90],
               [[1.5, 0.75, 0], 90],
               [[-0.35, 0.75, 0], -90]
            ];
         };
         case "sleep":
         {
            _positions = [
               [[0.2, -2.2, 0], 90],
               [[1.0, -1.4, 0], -90],
               [[0.2, -0.6, 0], 90],
               [[1.0, 0.2, 0], -90],
               [[0.2, 1.0, 0], 90]
            ];
         };
         default
         {
            if ((random 1.0) > 0.5) then
            {
               _positions = [
                  [[0.45, -2.1, 0], 0],
                  [[1.7, 0.75, 0], -90],
                  [[-0.5, 0.75, 0], 90]
               ];
            } else
            {
               _positions = [
                  [[1.7, -1.5, 0], -90],
                  [[-0.5, -1.5, 0], 90],
                  [[1.7, 0.75, 0], -90],
                  [[-0.5, 0.75, 0], 90]
               ];
            };
         };
      };
   };
};

// map model to world positions
[_positions, {
   private ["_pos"];
   _pos = _obj modelToWorld (_this select 0);
   _pos set [2, 0];
   [
      _pos,
      ((direction _obj) + (_this select 1))
   ]
}] call RUBE_arrayMap;

// safety/default position
if ((count _positions) == 0) then
{
   _pos = _obj modelToWorld [(1 + (random 2)), (0.5 - (random 1)), 0];
   _pos set [2, 0];
   _positions set [0, [_p, (direction _tent)]];
};

// return positions
_positions