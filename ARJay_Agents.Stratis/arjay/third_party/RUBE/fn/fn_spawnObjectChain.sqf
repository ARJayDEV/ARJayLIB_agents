/*
   Author:
    rübe
    
   Description:
    spawns an object-chain, defined by 2 to n points. 
    
    Perfect for fences, walls, mine-strips (given a large margin) 
    - whatever. 
    
    However this script is not suitable to lay alternating objects
    of unequal size. (such as powerlines-to-mast or pipe chains 
    with different pieces) Sorry.
    
    
    The lazy       use it with markers in the editor - may all the 
                   other jerks place their wall-pieces by hand...
                
    The clever     use it with dynamic input, whenever they need. 
                   Wanna have a sandbag-wall around those 3 closely 
    but random spawned warefare buildings that form a dynamic camp? 
    Do you need a prison? Right now, right over here? (dyn. prison 
    tip Nr. 34: don't close the chain, but make start- and end 
    position of the chain form a gap exactly that wide as the door-
    object you wanna use!)
    
    Don't underestimate the option to set a margin! Wanna spawn 5 
    tents, nicely lined up/equally spaced? There you go! :D
     
     - objects aren't measured but their dimensions are looked up with
       RUBE_getObjectDimensions, since boundingboxes are generally too
       generous for "chainy" placement and even worse, objects arent
       always centered, thus an offset has to be applied to them,
       boundingCenter my ass...  :|    hehe
       
       RUBE_getObjectDimensions is a  "lookup-library" where manually 
       measured data is kept. Thus you may need to measure your object 
       (e.g. addon) by yourself and extend RUBE_getObjectDimensions 
       accordingly... As A GENERAL RULE: make sure the chain object 
       you're going to use is listed there!
       
       -> the scripts detects the longer-side for the placement itself,
       though you may apply a negative margin if necessary. Besides, you
       may flip the orientation (inside/outside) which may be needed for
       some type of objects.
    
     - make sure the chain-defining positions are far-off each other,
       in case they are too near, you might end up with extreme 
       chain-edges/angles
       
     - this algorithm makes sure, that the given positions match perfectly
       the beginning/side of a chain-object by means of deforming the chain-
       line with the aid of a new joint-position. This joint-position can be
       either inside or outside, to make the chain either concave or convex 
       respectively:
       
       
                 joint point            
                  (convex)   
                      .
                      |
           .__________|__________._____________________________________.
      start point     m      2nd point              |              end point
                                                    .
                                               joint point
                                                (concave)   
                                                
      -> the chain will go from point to point over one joint point each defined 
         (or the perfect/direct) "line", which is the normal on the middle position of 
         this direct line Pn-P(n+1), raised as much as needed to make the chain-object
         match perfectly.
         
         Thus you get: 
         
          - "round" chains with convex,
          
                  .___x___.
                 /         \        (x = defined point
                /           \        . = joint point)
               x             x
          
          - "stair" chains with concave or
          
                   x
                  / \        
             x--./   \.__x
              \         /
               .       .
              /         \
             x           x
             
          - even random jointpoint selection for a more chaotic or natural look.
         
      -> to "close" the chain, start and end point must be equal. 
         Perfect match assured! ;)      
         
      -> you can easily get (closed) regular geometric shapes (pentagon, hexagon, 
         ...) - and their "star"-counterpart with concave mode - in two ways:
      
         1) get the chain objects length, take a multiple of that to get the
            needed distance, calculate the radius, adjust the step in a from 
            0 to 360 loop accordingly...
            
         2) take advantage of the joint-point, again a multiple of the chain 
            objects length, but this time directly for the radius, then finally
            double the step. E.g. a triangle (step=120) will form a hexagonish
            form with "convex" deformation-to-fit mode
    
      (bananas tip 48: have some fun with `Land_podlejzacka`)
    
   Parameter(s):
    _this select 0: chain object (class-string)
    _this select 1: start to end points (array of positions)
    _this select 2: chain margin (scalar, optional: default = 0)
    _this select 3: deformation-to-fit mode (string, optional: default = "convex")
                    - mode in ["convex", "concave", "random"];
                    -> note that this holds true only if the chain goes clockwise!
                       
    _this select 4: flip object 180 deg. (boolean, optional: default = false)
    _this select 5: top/outer align (boolean OR scalar, optional: default = false)
                    - y displacement of 1/2 obj-depth, usefull for non-
                      symetric or just wide/thick objects like 
                      `Land_fort_rampart` to get nice "corners"...
                      otherwise we have a middle-alignment which is
                      usually best for fences/walls.
                      
                    - true == top/outer alignment
                    - false == middle alignment
                    
                    - scalar => automatique threshold: anything with 
                      a depth larger than the given number (in m) 
                      gets top/outer alignment, anything narrower 
                      gets middle alignment.
    
   Returns:
    array of objects (guaranteed to be sorted, from start to end)
*/

private ["_objects", "_class", "_positions", "_margin", "_deformation", "_flip", "_topalign", "_deform", "_dimensions", "_size", "_length", "_depth", "_offset", "_rot", "_rotation", "_segments"];

_objects = [];
_class = _this select 0;
_positions = _this select 1;
_margin = 0;
if ((count _this) > 2) then
{
   _margin = _this select 2;
};
_deformation = "convex";
if ((count _this) > 3) then
{
   _deformation = _this select 3;
};

_flip = -1;
// flip inside/outside?
if ((count _this) > 4) then
{
   if (_this select 4) then
   {
      _flip = 1;
   };
};

_topalign = 0;


// private function
_deform = {
   _this
};
switch (_deformation) do
{
   case "concave":
   {
      _deform = {
         (_this * -1)
      };
   };
   case "random":
   {
      _deform = {
         if (50 call RUBE_chance) exitWith {
            (_this * -1)
         };
         _this
      };
   };
};

_dimensions = _class call RUBE_getObjectDimensions;
_size = _dimensions select 0;
_length = ((_size select 0) max (_size select 1));
_depth = ((_size select 0) min (_size select 1));
_offset = _dimensions select 1;

// we always take the longer side as the chain-defining one
_rot = 90;
if (_length != (_size select 0)) then
{
   _rot = 180;
};
_length = _length + _margin;

// top align of chains objects?
if ((count _this) > 5) then
{
   if ((typeName (_this select 5)) == "BOOL") then
   {
      // fixed outer alignment
      if (_this select 5) then
      {
         _topalign = (_depth * 0.5 * _flip);
      };
   } else 
   {
      // threshold decision
      if (_depth > (_this select 5)) then
      {
         _topalign = (_depth * 0.5 * _flip);
      };
   };
};

// final rotated offset array (we have to rotate the coord-system 
// 90 deg. if the objects x-side isn't the longer one! plus we may
// need to flip the offset another 180 deg. for inside/outside flip)
_rotation = [];
if (_rot == 90) then
{
   _rotation = [
      [
         ((_offset select 1) * _flip) - _topalign,
         (((_offset select 0) * _flip) + (_length * 0.5))
      ],
      [
         ((_offset select 1) * (_flip * -1)) + _topalign,
         (((_offset select 0) * (_flip * -1)) + (_length * 0.5))
      ]
   ];
} else {
   _rotation = [
      [
         ((_offset select 0) * _flip) + _topalign,
         (((_offset select 1) * _flip) + (_length * 0.5))
      ],
      [
         ((_offset select 0) * (_flip * -1)) - _topalign,
         (((_offset select 1) * (_flip * -1)) + (_length * 0.5))
      ]
   ];
};

// apply flip rotation
if (_flip == 1) then
{
   _rot = _rot + 180;
};


// explode segments 
_segments = [];

for "_i" from 1 to ((count _positions) - 1) do
{
   _segments = _segments + [
      [(_positions select (_i - 1)), (_positions select _i)]
   ];
};



// spawn chain objects
{
   private ["_objectsL", "_objectsR", "_start", "_end", "_mid", "_dir", "_dir2", "_a", "_c", "_n", "_delta", "_betaL", "_betaR", "_joint", "_v1", "_v2", "_posL", "_posR", "_objL", "_objR"];
   _objectsL = [];
   _objectsR = [];

   _start = _x select 0;
   _end = _x select 1;
   _mid = [_start, _end] call RUBE_midwayPosition;
   _dir = [_start, _mid] call BIS_fnc_dirTo;
   _dir2 = [_end, _mid] call BIS_fnc_dirTo;
   
   _a = _start distance _mid;
   _c = [_a, _length, "ceil"] call RUBE_roundTo;
   _n = floor (_c / _length);
   
   _delta = (acos (_a / _c)) call _deform;
   
   _betaL = _dir - _delta;
   _betaR = _dir2 + _delta;
   _joint = [_start, _c, _betaL] call BIS_fnc_relPos;
   
   _v1 = [[0,0,0], _length, _betaL] call BIS_fnc_relPos;
   _v2 = [[0,0,0], _length, _betaR] call BIS_fnc_relPos;

   // debug objects
   /*
   {
      _d = (_x select 0) createVehicle (_x select 1);
      _d setPos (_x select 1);
   } forEach [
      ["FlagCarrierGUE", _start],
      ["Land_Barrel_empty", _joint],
      ["FlagCarrierRU", _end]
   ];
   */

   for "_i" from 0 to (_n - 1) do
   {
      _posL = [
         [
            ((_start select 0) + ((_v1 select 0) * _i)),
            ((_start select 1) + ((_v1 select 1) * _i)),
            0
         ],
         (_rotation select 0),
         _betaL
      ] call RUBE_offsetPosition;
      
      _objL = createVehicle [_class, _posL, [], 0, "NONE"];
      _objL setDir (_betaL + _rot);
      _objL setPos _posL;
      
      _objectsL = _objectsL + [_objL];
      //
      _posR = [
         [
            ((_end select 0) + ((_v2 select 0) * _i)),
            ((_end select 1) + ((_v2 select 1) * _i)),
            0
         ],
         (_rotation select 1),
         _betaR
      ] call RUBE_offsetPosition;
      
      _objR = createVehicle [_class, _posR, [], 0, "NONE"];
      _objR setDir (_betaR + _rot + 180);
      _objR setPos _posR;     
         
      _objectsR = [_objR] + _objectsR;
   };
   
   _objects = _objects + (_objectsL + _objectsR);

} forEach _segments;



// return chain objects
_objects