/*
   Author:
    rübe
    
   Description:
    creates new AI HQs for the given sides (createCenter) and
    sets them to friends or foes as desired. Only use at 
    mission start.
    
    Make sure a side is given only once and also you shouldn't
    make any side be angry to the Civilian side for they will
    go totally mad at shit and stuff...
    
   Parameter(s):
    _this select 0: the one "side" (side or array of sides)
                     all sides in here will be friendly
    _this select 1: the other "side" (side or array of sides)
    _this select 2: switzerland (side or array of sides, optional)
                    - sides set to be neutral to each other are 
                      friendly, but with the lowest possible value 
                      of 0.6. Thus this relationship might change.
    
   Returns:
    void
*/

private ["_center", "_side", "_sides"];

// make sure we have arrays
[
   _this,
   {
      if ((typeName _this) == "ARRAY") exitWith
      {
         _this
      };
      [_this]
   }
] call RUBE_arrayMap;

// make sure we have a neutral-pool even if empty
if ((count _this) == 2) then
{
   _this set [2, []];
};

// create centers for all given sides
//createCenter sidelogic; // we already do this as first command to load BIS_fnc_lib ;)

{
   _sides = _x;
   {
      _center = createCenter _x;
   } forEach _sides;
} forEach _this;

// setup relationships
{
   _side = _x;
   // friendlies
   if ((count (_this select 0)) > 1) then
   {
      {
         _side setFriend [_x, 1.0];
      } forEach ((_this select 0) - [_side]);
   };
   // enemies
   {
      _side setFriend [_x, 0.0];
   } forEach (_this select 1);
   // switzerland
   {
      _side setFriend [_x, 0.6];
   } forEach (_this select 2);
} forEach (_this select 0);

{
   _side = _x;
   // friendlies
   if ((count (_this select 0)) > 1) then
   {
      {
         _side setFriend [_x, 1.0];
      } forEach ((_this select 1) - [_side]);
   };
   // enemies
   {
      _side setFriend [_x, 0.0];
   } forEach (_this select 0);
   // switzerland
   {
      _side setFriend [_x, 0.6];
   } forEach (_this select 2);
} forEach (_this select 1);

{
   // friendlies
   if ((count (_this select 0)) > 1) then
   {
      {
         _side setFriend [_x, 1.0];
      } forEach ((_this select 2) - [_side]);
   };
   // neutral
   {
      _side setFriend [_x, 0.6];
   } forEach (_this select 0);
   {
      _side setFriend [_x, 0.6];
   } forEach (_this select 1);
} forEach (_this select 2);