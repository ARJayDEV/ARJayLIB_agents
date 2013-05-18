/*
   Auhtor:
    rübe
    
   Description:
    returns the convex hull (or the set of perimeter points) 
    of a given list of objects, considering the 4 extrapolated 
    points of the given object (or position) by the aid of the 
    bounding box (or RUBE_getObjectDimensions). 
    
    Of course you may just pass an array of position, thus we
    apply the convex hull search/filter directly, bypassing
    the extrapolation.
    
    Application example: to spawn a wall, a fence or sandbags 
    around n given objects that form an entity (a camp, strong-
    point.. whatever) with RUBE_spawnObjectChain.
    
       Btw. in case you do so, you may consider increasing the
       spacing according to the chain's object size (which pushes 
       all points on the hull apart from each other) and maybe 
       even filter out points too close to each other directly to 
       avoid crazy edges in the resulting chain from 
       RUBE_spawnObjectChain (or similar) that form if two 
       following points in the chain are too close to each other.
    
    - implemented algorithm: 
    
      Graham Scan (or `3-coin algorithm`) by R. L. Graham in 1972
      which takes O(n log n) time.
      
       1) find an extremal point p0 (e.g. point with lowest y)
       2) sorting the remaining n-1 points radially with p0 as the origin 
       3) iterate through the points, three at a time, rejecting points
          that form a right-turn (backtracking)
    
    - not yet implemented optimization:
      - if you're gonna find the convex hull of very large N, consider
        implementing a `Quick Elimination` first:
        
         1) choose 4 points on the convex hull
         2) eliminate any points inside this quadrilateral since these
            can NOT be on the convex hull. 
            
         -> this can eliminate almost all points in linear time!
    
   Illustration:
   
   - convex hull from objects:         - convex hull from points:
                                                         
                                                        
         x___x                             x__________x 
         |   |       .__x                 /  .         \
         .___.       .__|                x         .    \
                      .______x            \   .          \
      x_.      O      |      |             \      O  . <- x -> (+/- spacing)
      | |    .____.   .______x              \            /
      x_.    |    |                          \ .    .   /
             |    |                           \        /
             x____x                            x______x
                                
                          
                           . = point not on the convex hull
                           x = point on the convex hull   
                           O = convex hull's centroid (only calculated
                               if spacing is applied)
             
    - where the rectangles are the bounding boxes* of the given
      objects and the points are the perimeter points.
      
      * or RUBE_getObjectDimensions (tightly measured size and offset)

   Parameter(s):
    _this select 0: objects (array of objects OR 
                             array of [object, class-string] OR
                             array of [position, direction, class-string] OR
                             array of positions)
                    -> given objects, we use the bounding box,
                    -> given objects/class, we use 
                       RUBE_getObjectDimensions
                    -> given a position/dir/class, we use 
                       RUBE_getObjectDimensions
                    -> given a list of positions only, we do 
                       consider these points directly without
                       any extrapolation
                       
    _this select 1: spacing (scalar; optinal, default = 0m)
                    -> like a convex hull border, effectively
                       pushing all points outside (or inside) by the 
                       given amount and the direction centroid->point.
                       
                       >> you'll get appealing results, as long as the 
                          convex hull isn't forming a triangle (h=3).
                          
    _this select 2: minimal distance between convex hull points aka
                    minimal face-length of the resulting polygon 
                    (scalar; optional, default = 0m)
                    
                    -> We may merge two points (B and C) on the convex 
                       hull by finding the intersection point of the 
                       two line segments AB and CD. Thus the convex hull
                       segment A-B-C-D may be reduced to A-P-D, where P
                       is this new intersection point, keeping the convex
                       hull intact (previously enclosed area will still be
                       inside the reduced convex hull).
                       
                    -> this step is done after spacing is applied.
                    
                    -> we don't reduce a convex hull with 4 or less points,
                       even if the face-length is below the given min. value.

   Returns:
    array of positions (the convex hull; simple closed polygonal chain,
    thus [0] == [n-1])
*/

private ["_points", "_spacing", "_minDistance", "_n"];

_points = [];
_spacing = 0;
_minDistance = 0;

if ((count _this) > 1) then
{
   _spacing = _this select 1;
};

if ((count _this) > 2) then
{
   _minDistance = _this select 2;
};

// empty list?
if ((count (_this select 0)) == 0) exitWith 
{
   []
};

private ["_extrapolate"];

// 1 pos/object -> 4 positions
_extrapolate = {
   private ["_pos", "_dir", "_x", "_y", "_offset"];
   _pos = _this select 0;
   _dir = _this select 1;
   _x = ((_this select 2) select 0) * 0.5;
   _y = ((_this select 2) select 0) * 0.5;
   _offset = _this select 3;
   
   // apply offset
   if (((_offset select 0) != 0) || ((_offset select 1) != 0)) then
   {
      _pos = [_pos, _offset, _dir] call RUBE_offsetPosition;
   };

   // return the four positions
   [
      ([_pos, [(_x * -1), _y], _dir] call RUBE_gridOffsetPosition),
      ([_pos, [_x, _y], _dir] call RUBE_gridOffsetPosition),
      ([_pos, [_x, (_y * -1)], _dir] call RUBE_gridOffsetPosition),
      ([_pos, [(_x * -1), (_y * -1)], _dir] call RUBE_gridOffsetPosition)
   ]
};

if ((typeName ((_this select 0) select 0)) == "OBJECT") then
{
   // objects & bounding box
   private ["_box"];
   {
      _box = _x call RUBE_boundingBoxSize;
      _points = _points + ([
         (position _x),
         (direction _x),
         _box,
         (boundingCenter _x)
      ] call _extrapolate);
   } forEach (_this select 0);
} else {
   switch (typeName (((_this select 0) select 0) select 0)) do
   {
      case "OBJECT":
      {
         // object & class (getObjectDimensions)
         private ["_dim"];
         {
            _dim = (_x select 1) call RUBE_getObjectDimensions;
            _points = _points + ([
               (position (_x select 0)),
               (direction (_x select 0)),
               (_dim select 0),
               (_dim select 1)
            ] call _extrapolate);
         } forEach (_this select 0);
      };
      case "ARRAY":
      {
         // position, direction & class (getObjectDimensions) 
         private ["_dim"];
         {
            _dim = (_x select 2) call RUBE_getObjectDimensions;
            _points = _points + ([
               (_x select 0),
               (_x select 1),
               (_dim select 0),
               (_dim select 1)
            ] call _extrapolate);
         } forEach (_this select 0);
      };
      case "SCALAR":
      {
         // positions as points (no extrapolation needed)
         _points = +(_this select 0);
      };
   };
};

_n = count _points;

// no or too few points (to form a polygon)?
if (_n < 3) exitWith 
{
   []
};

/*
{
   [
      ["position", _x],
      ["type", "mil_dot"],
      ["color", "ColorGreen"]
   ] call RUBE_mapDrawMarker;
} forEach _points;
*/


private ["_theta", "_convexity"];


// point1, point2 => scalar between 0 and 360
//  returns NOT the angle made by p1 and p2 with 
//  the horizontal but which has the same order 
//  properties as the true angle (easier to compute) 
_theta = {
   private ["_theta", "_dx", "_dy"];
   
   _theta = 0;
   
   _dx = ((_this select 1) select 0) - ((_this select 0) select 0);
   _dy = ((_this select 1) select 1) - ((_this select 0) select 1);
   
   if ((_dx == 0) && (_dy == 0)) then
   {
      _theta = 0;
   } else {
      _theta = _dy / ((abs _dx) + (abs _dy));
   };
   
   if (_dx < 0) then
   {
      _theta = 2 - _theta;
   } else {
      if (_dy < 0) then
      {
         _theta = 4 + _theta;
      };
   };

   (_theta * 90)
};


// p0, p1, p2 => scalar, where
//  _convexity < 0  == clockwise
//  _convexity == 0 == collinear
//  _convexity > 0  == counter-clockwise
_convexity = {
   ( 
      (((_this select 1) select 0) - ((_this select 0) select 0)) *
      (((_this select 2) select 1) - ((_this select 0) select 1)) -
      (((_this select 1) select 1) - ((_this select 0) select 1)) *
      (((_this select 2) select 0) - ((_this select 0) select 0))
   )
};





/****************************************************** 
 * graham scan
 */

// 1) finds the extremal or lowest (and left-most) point
// and puts/swaps it to the front
for "_i" from 1 to ((count _points) - 1) do
{
   if ((((_points select _i) select 1) < ((_points select 0) select 1)) || 
       ((((_points select _i) select 1) == ((_points select 0) select 1)) && 
        (((_points select _i) select 0) < ((_points select 0) select 0)))) then
   {
      [_points, 0, _i] call RUBE_arraySwap;
   };
};

// 2) sort by theta
_points = [_points, {
   ([(_points select 0), _this] call _theta)
}] call RUBE_shellSort;


// 3) graham scan
private ["_convexHull", "_m"];
_convexHull = [
   (_points select 0),
   (_points select 1)
];

_m = 2;
for "_i" from 2 to _n do
{
   // backtracking, eliminating right turns and
   // straight lines (collinear)
   while {(([
               (_points select _m), 
               (_points select (_m - 1)), 
               (_points select _i)
            ] call _convexity) >= 0)} do
   {
      _convexHull call BIS_fnc_arrayPop;
      _m = _m - 1;
   };
   //_convexHull = _convexHull + [(_points select _m)];
   _convexHull set [(count _convexHull), (_points select _m)];
   _m = _m + 1;
   [_points, _m, _i] call RUBE_arraySwap;
};



// apply spacing
if (_spacing != 0) then
{
   private ["_center"];
   _center = _convexHull call RUBE_polygonCentroid;

   [
      _convexHull, 
      {
         ([
            _this,
            _spacing,
            ([_center, _this] call BIS_fnc_dirTo)
         ] call BIS_fnc_relPos)
      }
   ] call RUBE_arrayMap;
};


private ["_relHullPos", "_reduceConvexHull"];

// relative access to points on the convex hull
// [_index, _shift] => _index
_relHullPos = {
   private ["_index", "_shift", "_n", "_pos"];
   _index = _this select 0;
   _shift = _this select 1;
   _n = count _convexHull;
   
   _pos = _index + _shift;
   
   if (_pos < 0) exitWith
   {
      (_n + _pos)
   };
   
   if (_pos >= _n) exitWith
   {
      (_pos % _n)
   };
   
   _pos
};

// recursively reducing the convex hull by
// merging two points into a new one
_reduceConvexHull = {
   private ["_n", "_i", "_j", "_d"];
   _n = count _convexHull;
   
   if (_n < 5) exitWith
   {
      true
   };
   
   for [{_i = 0}, {_i < _n}, {_i = _i + 1}] do
   {
      _j = [_i, 1] call _relHullPos;
      _d = (_convexHull select _i) distance (_convexHull select _j);
      if (_d < _minDistance) exitWith
      {
         private ["_newPoint", "_newHull", "_a1", "_a2", "_m", "_k"];
         // merge point _i and _i + 1 into new point
         _newPoint = [
            (_convexHull select ([_i, -1] call _relHullPos)),
            (_convexHull select _i),
            (_convexHull select _j),
            (_convexHull select ([_i, 2] call _relHullPos))
         ] call RUBE_lineSegmentIntersection;
         
         // alter convex hull
         _newHull = [];
         _a1 = _i min _j; // will be overwritten with the new point
         _a2 = _i max _j; // will be dropped
         _m = 0;
         
         for [{_k = 0}, {_k < _n}, {_k = _k + 1}] do
         {
            if (_k != _a2) then
            {
               if (_k == _a1) then
               {
                  _newHull set [_m, _newPoint];
               } else {
                  _newHull set [_m, (_convexHull select _k)];
               };
               _m = _m + 1;
            };
         };
         
         _convexHull = _newHull;
         
         // run again until the convex hull coudn't be
         // reduced any further...
         nul = [] call _reduceConvexHull;
      };
   };
   
   true
};

// apply minDistance
if (_minDistance != 0) then
{
   nul = [] call _reduceConvexHull;
};


// close hull/polygon
_convexHull = _convexHull + [(_convexHull select 0)];

// return convex hull
_convexHull