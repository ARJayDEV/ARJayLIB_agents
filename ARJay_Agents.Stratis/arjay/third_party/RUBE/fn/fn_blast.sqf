/*
   Author:
    rübe
    
   Description:
    destroys anything in a given (blast-)radius. Each bomb (optional)
    will be spawned where some object has been destroyed. We destroy
    the bomb itself too, creating a nice and long fire with heavy black
    smoke.
        
   Parameter(s):
    _this: parameters (array of array [key (string), value (any)])
    
           - required:
           
             - "position" (position)
             - "radius" (scalar in m)
             
           - optional:
           
             - "bombs" (int)
               - default = 0
               
             - "bombType" (string)
               - default = "Bomb"
           
             - "class" (string OR array of strings)
             - "!class" (string OR array of strings)
             
             - "kind" (string OR array of strings)
             - "!kind" (string OR array of strings)
             
             -> e.g. ["!kind", "Man"] 
                     for everything but men
                     
                or   ["kind", "AllVehicles"] and ["!kind", "Man"]  
                     for every vehicle
    
   Parameter(s):
    _this select 0: position (position)
    _this select 1: radius (scalar)
    _this select 2: restrict to class (string)
                    - optional (empty string to skip)
    _this select 3: restrict to kind (string)
                    - optional (empty string to skip)
                    
   Returns:
    number of destroyed objects (int)
*/

private ["_position", "_radius", "_bombs", "_bombType", "_bombDist", "_lastBomb", "_class", "_classNot", "_kind", "_kindNot"];

_position = [0,0];
_radius = 0;

_bombs = 0;
_bombType = "Bomb";
_bombDist = 5;
_lastBomb = [];
_class = [];
_classNot = [];
_kind = [];
_kindNot = [];

// read parameters
{
   switch (_x select 0) do
   {
      case "position": { _position = _x select 1 };
      case "radius": { _radius = _x select 1; };
      case "bombs": { _bombs = _x select 1; };
      case "bombType": { _bombType = _x select 1; };
      
      default 
      {
         private ["_var"];
         _var = [];
         
         switch (_x select 0) do
         {
            case "class": { _var = _class; };
            case "!class": { _var = _classNot; };
            case "kind": { _var = _kind; };
            case "!kind": { _var = _kindNot; };
         };
      
         switch (typeName (_x select 1)) do
         {
            case "STRING": 
            {
               if ((_x select 1) != "") then
               {
                  _var set [(count _var), (_x select 1)];
               };
            };
            case "ARRAY":
            {
               [_var, (_x select 1)] call RUBE_arrayAppend;
            };
         };
      };
   };
} forEach _this;


//_position set [2, ((_position select 2) - _radius)];
_position set [2, 0];

private ["_classTest", "_kindTest"];

_classTest = { true };
_kindTest = { true };

if (((count _class) + (count _classNot)) > 0) then
{
   _classTest = {
      private ["_c"];
      _c = typeOf _this;
      if (!(_c in _class)) exitWith { false };
      if (_c in _classNot) exitWith { false };
      true
   };
};

if ((count _kind) == 0) then
{
   //_kind = ["all"];
};

if ((count _kindNot) > 0) then
{
   _kindTest = {
      private ["_pass"];
      _pass = true;
      {
         if (_this isKindOf _x) exitWith
         {
            _pass = false;
         };
      } forEach _kindNot;
      
      _pass
   };
};


private ["_n", "_canBomb"];
_n = 0;

_canBomb = {
   if (_bombs == 0) exitWith { false };
   if ((count _lastBomb) == 0) exitWith { true };
   if ((_this distance _lastBomb) > _bombDist) exitWith { true };
   false
};

// destroy objects in radius
{
   if ((_x call _classTest) && (_x call _kindTest)) then
   {
      private ["_bomb", "_pos"];
      _pos = position _x;
      _x setDamage 1.0;
      _n = _n + 1;
      
      if (_pos call _canBomb) then
      {
         _bomb = createVehicle [_bombType, _pos, [], 0, "NONE"];
         _bomb setDamage 1.0;
         _bomb setPos [(_pos select 0), (_pos select 1), 0];
         
         _bombs = _bombs - 1;
         _lastBomb = +_pos;
      };
   };
} forEach (nearestObjects [_position, _kind, _radius]);

// return
_n