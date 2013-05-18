/*
   Author:
    rübe
    
   Description:
    updates/overwrites the last waypoint and makes sure it's the
    current one now. (RUBE AI never manages real lists of waypoints,
    so the waypoint or `task` may be updated at any time by any
    source.)

   Parameter(s):
    _this: parameters (array of array [key (string), value (any)])
    
           - required:
           
             - "group" (group)
             
             
           - optional:
                if there is no default value noted, the corresponding command
             won't be called. So while the description is cleared if not stated 
             otherwise, the behaviour won't be overwritten with anything...
           
             - "position" (position)
             
             - "radius" (scalar)
                  has no effect if the position is not (re-)set.
               - default = 0
           
             - "type" (string in ["MOVE", "DESTROY", "GETIN", "SAD", "JOIN", "LEADER", 
                       "GETOUT", "CYCLE", "LOAD", "UNLOAD", "TR UNLOAD", "HOLD", "SENTRY", 
                       "GUARD", "TALK", "SCRIPTED", "SUPPORT", "GETIN NEAREST", "DISMISS", 
                       "AND" or "OR"])
           
             - "formation" (string in ["NO CHANGE", "COLUMN", "STAG COLUMN", "WEDGE", 
                            "ECH LEFT", "ECH RIGHT", "VEE", "LINE", "FILE", "DIAMOND"])
           
             - "behaviour" (string in ["UNCHANGED", "CARELESS", "SAFE", 
                            "AWARE", "COMBAT", "STEALTH"])
                            
             - "combatMode" (string in ["BLUE" (never fire), "GREEN" (hold fire/defend only, 
                             "WHITE" (hold fire/engage at will), "YELLOW" (fire at will), 
                             "RED" (fire/engage at will)])
             
             - "speed" (string in ["UNCHANGED", "LIMITED", "NORMAL", "FULL"])
             
             - "completionRadius" (scalar)
             
             - "timeout" (array [min (scalar), mid (scalar), max (scalar)])
             
             - "description" (string)
                  description shown in the HUD while the waypoint is active
               - default = ""
                  
             - "attachVehicle" (vehicle)
               - default = objNull
             
             - "attachObject" (object)
               - default = objNull
               
   Returns:
    waypoint (or empty array if anything fails)
*/

private ["_group", "_position", "_radius", "_type", "_formation", "_behaviour", "_combatMode", "_speed",  "_completionRadius", "_timeout", "_description", "_attachVehicle", "_attachObject", "_waypoints", "_waypoint"];

_group = grpNull;
_position = [];
_radius = 0;
_type = "";
_formation = "";
_behaviour = "";
_combatMode = "";
_speed = "";
_completionRadius = -1;
_timeout = [];
_description = "";
_attachVehicle = objNull;
_attachObject = objNull;

// read parameters
{
   switch (_x select 0) do
   {
      case "group": { _group = _x select 1; };
      case "position": { _position = _x select 1; };
      case "radius": { _radius = _x select 1; };
      case "type": { _type = _x select 1; };
      case "formation": { _formation = _x select 1; };
      case "behaviour": { _behaviour = _x select 1; };
      case "combatMode": { _combatMode = _x select 1; };
      case "speed": { _speed = _x select 1; };
      case "completionRadius": { _completionRadius = _x select 1; };
      case "timeout": { _timeout = _x select 1; };
      case "description": { _description = _x select 1; };
      case "attachVehicle": { _attachVehicle = _x select 1; };
      case "attachObject": { _attachObject = _x select 1; };
   };
} forEach _this;

/*
   - TODO: setWaypointHousePosition; 
      - whats the default/null value? 0? -1?
      - do we need to delete and recreate the waypoint?
      
   - TODO: maybe implement setWaypointStatements with 
     condition "true" and an empty statement as default
     values..
*/



// retrieve last (and probably the only) waypoint
_waypoints = waypoints _group;
if ((count _waypoints) == 0) exitWith 
{
   []
};


_waypoint = _waypoints select ((count _waypoints) - 1);

if ((count _position) > 0) then
{
   _waypoint setWaypointPosition [_position, _radius];
};

if (_type != "") then
{
   _waypoint setWaypointType _type;
};

if (_formation != "") then
{
   _waypoint setWaypointFormation _formation;
};

if (_behaviour != "") then
{
   _waypoint setWaypointBehaviour _behaviour;
};

if (_combatMode != "") then
{
   _waypoint setWaypointCombatMode _combatMode;
};

if (_speed != "") then
{
   _waypoint setWaypointSpeed _speed;
};

if (_completionRadius >= 0) then
{
   _waypoint setWaypointCompletionRadius _completionRadius;
};

if ((count _timeout) == 3) then
{
   _waypoint setWaypointTimeout _timeout;
};

// the description gets cleared per default
_waypoint setWaypointDescription _description;


if (isNull _attachVehicle) then
{
   // clear attached vehicle if needed
   if (!(isNull (waypointAttachedVehicle _waypoint))) then
   {
      _waypoint waypointAttachVehicle _attachVehicle;
   };
} else 
{
   _waypoint waypointAttachVehicle _attachVehicle;
};

if (isNull _attachObject) then
{
   // clear attached object if needed
   if (!(isNull (waypointAttachedObject _waypoint))) then
   {
      _waypoint waypointAttachObject _attachObject;
   };
} else 
{
   _waypoint waypointAttachObject _attachObject;
};




// set current and return waypoint
_group setCurrentWaypoint _waypoint;

_waypoint