/*
   Author:
    rübe
    
   Description:
    creates and initializes a trigger
    
   Parameter(s):
    _this: parameters (array of array [key (string), value (any)])
    
           - required:
           
           - optional:
           
             // TRIGGER AREA //
           
             - "position" (position)
             
             - "area" (string in ["ELLIPSE", "RECTANGLE"])
                  form of the trigger area.
               Default = "ELLIPSE"
             
             - "radius" (scalar or [x (scalar), y (scalar)])
                  defines the size of the trigger area, either
               for an ellipse or a rectangle.
               
             - "direction" (scalar)
                  rotation of the trigger area.
               Default = 0.
             
             // TRIGGER TYPE //
             
             - "type" (string OR side OR [side, "GUARDED"])
                   sets the trigger type in [
                  "NONE", "EAST G", "WEST G", "GUER G", "SWITCH", "END[1-6]", "LOOSE", ("WIN")
               ] (G == guarded by)
               - sides are transformed to their corresponding guarded by string
               - default = "NONE"
               
             // TRIGGER ACTIVATION //
             
             - "activation" (array [by (string OR side OR [side, "SIDE" || "SEIZED"]), 
                                    type (string OR side OR [side, "DETECT"])])
                  defines the trigger activation.
                  
               - `by`, who activates the trigger; in [
                  "NONE", "EAST", "WEST", "GUER", "CIV", "LOGIC", "ANY", "ALPHA", "BRAVO", 
                  "CHARLIE", "DELTA", "ECHO", "FOXTROT", "GOLF", "HOTEL", "INDIA", "JULIET", 
                  "STATIC", "VEHICLE", "GROUP", "LEADER", "MEMBER", "WEST SEIZED", 
                  "EAST SEIZED" or "GUER SEIZED"
               ]
               
               - `type`, activaton condition; in [
                  "PRESENT", "NOT PRESENT", "WEST D", "EAST D", "GUER D" or "CIV D"
               ] (D == detect(-ing); read: WEST D => WEST is Detecting(!), not detected)
               - sides for `by` are transformed to their corresponding seized strings,
                 for `type` to their detected ones
             
             - "repeat" (boolean)
                  whether the activation may repeat or not.
               Default = false
               
             // TRIGGER STATEMENTS //
             
             - "condition" (string)
                  boolean statement 
               Default = "this"
               
             - "onActivation" (string)
                  code executed on triggers activation
             
             - "onDeactivation" (string)
                  code executed on triggers deactivation
             
             // TRIGGER TEXT //  
             
             - "text" (string)
                  sets a text/label for the trigger (e.g. used for radio triggers)
             
             // TRIGGER TIMEOUT //
             
             - "timeout" (array [min (scalar), mid (scalar), max (scalar), interruptable (boolean)]

   
   Returns:
    trigger (object)
*/

private ["_trigger", "_position", "_radius", "_direction", "_rectangle", "_type", "_activation", "_repeat", "_condition", "_onActivation", "_onDeactivation", "_timeout", "_text", "_sideToString"];

_position = [0,0,0];

_radius = 0;
_direction = 0;
_rectangle = false;

_type = "NONE";
_activation = [];
_repeat = false;

_condition = "this";
_onActivation = "";
_onDeactivation = "";

_timeout = [];
_text = "";


// read parameters
{
   switch (_x select 0) do
   {
      case "position": { _position = _x select 1; };
      case "radius": 
      { 
         if ((typeName (_x select 1)) == "ARRAY") then
         {
            _radius = _x select 1;
         } else
         {
            _radius = [(_x select 1), (_x select 1)];
         }; 
      };
      case "direction": { _direction = _x select 1; };
      case "area": 
      { 
         if ((_x select 1) in ["RECT", "RECTANGLE"]) then
         {
            _rectangle = true;
         };
      };
      case "type": { _type = _x select 1; };
      case "activation": { _activation = _x select 1; };
      case "repeat": { _repeat = _x select 1; };
      case "condition": { _condition = _x select 1; };
      case "onActivation": { _onActivation = _x select 1; };
      case "onDeactivation": { _onDeactivation = _x select 1; };
      case "timeout": { _timeout = _x select 1; };
      case "text": { _text = _x select 1; };
   };
} forEach _this;


// converts a SIDE into the corresponding key string
_sideToString = {
   (format["%1%2", (_this select 0), (_this select 1)])
};

// transform side related parameter strings
switch (typeName _type) do
{
   case "SIDE":
   {
      _type = [_type, " G"] call _sideToString;
   };
   case "ARRAY": 
   {
      _type = [(_type select 0), " G"] call _sideToString;
   };
};

switch (typeName (_activation select 0)) do
{
   case "SIDE":
   {
      _activation set [0, format["%1", (_activation select 0)]];
   };
   case "ARRAY": 
   {
      switch (((_activation select 0) select 1)) do
      {
         case "SEIZED":
         {
            _activation set [0, ([((_activation select 0) select 0), " SEIZED"] call _sideToString)];
         };
         default
         {
            _activation set [0, format["%1", ((_activation select 0) select 0)]];
         };
      };
   };
};

switch (typeName (_activation select 1)) do
{
   case "SIDE":
   {
      _activation set [1, ([(_activation select 1), " D"] call _sideToString)];
   };
   case "ARRAY": 
   {
      _activation set [1, ([((_activation select 1) select 0), " D"] call _sideToString)];
   };
};




// initialize trigger
_trigger = createTrigger ["EmptyDetector", _position];

// trigger area
if ((typeName _radius) == "ARRAY") then
{
   _trigger setTriggerArea [(_radius select 0), (_radius select 1), _direction, _rectangle];
};

// trigger type
if (_type != "NONE") then
{
   _trigger setTriggerType _type;
};

// trigger activation
if ((count _activation) > 1) then
{
   _trigger setTriggerActivation [(_activation select 0), (_activation select 1), _repeat];
};

// trigger statements
if ((_condition != "this") || (_onActivation != "") || (_onDeactivation != "")) then
{
   _trigger setTriggerStatements [_condition, _onActivation, _onDeactivation];
};

// trigger timeout
if ((count _timeout) > 3) then
{
   _trigger setTriggerTimeout _timeout;
};

// trigger label
if (_text != "") then
{
   _trigger setTriggerText _text;
};




// return trigger
_trigger