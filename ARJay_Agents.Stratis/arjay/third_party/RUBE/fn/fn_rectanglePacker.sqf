/*
   Author: 
    rübe
   
   Description:
    solving the packing problem (2D) with a binary tree: we try to fill all given 
    rectangles into a given container (a rectangle too), by recursively dividing
    the available space into empty and filled regions.
    
   Illustration:
    
    1)                       2)
             A                          A
           /   \                     /     \
         B       .       ==>       B         C
        / \                       / \       / \
       1   .                     1   .     D   .
                                          / \
                                         2   .
   
    
    1)                       2)           
                                         C
    ______________                _______|_____
    |            |                |  .   |     |
    |            |             D _|______|     |                             
    |            |                |      |  .  |
    |            |                |   2  |     |
   _|____________|_ A    ==>     _|______|_____|_ A       y
    |        |   |                |        |   |
    |   1    | . |                |   1    | . |          ^
    |        |   |                |        |   |          |
    ---------|----                ---------|----          |--> x 
            B                            B           
                                     
    
    No rotation of the rectangles allowed/done and it's not guaranteed that all (or any) 
    rectangles will fit in the given container, so we may reject/ignore them. Also you 
    may wanna sort your rectangles (by area, height, ...) before passing it over here.
    Sorting is *crucial* for this algorithm. Best efficiency is quaranteed by sorting on
    max dimension of rectangles (width max height), and not the area, since a square is 
    less likely to be problematic than a very long one with the same area... 
    
     On sorting: the algorithm is pretty efficient if bigger rectangles are placed prior
    to smaller ones (which will fit in the gaps left). The other way around (first small,
    then bigger ones) the algorithm becomes inefficient/ugly pretty soon. Unsorted lists
    work pretty nice and result in a far more messy/chaotic result than sorted lists.
    
     ... in short:
      - sorted (decreasing order) -> efficient, looking quite steril/symmetric
      - sorted (increasing order) -> inefficient, may produce an ugly stair(!), 
                                     large rect's are likely to not fit anymore/anywhere... 
      - unsorted (really random!) -> pretty efficient, looking rather messy/chaotic
      
      -> never sort from small to big. If you create an unsorted list, make sure you don't
         accidentally `sort` it like this by your logic.. If unsure, you might wanna randomize 
         or sort your list first.
      
      -> if you have a large rect. pool and don't care if only a fraction will fit,
         efficiency (min. wasted space, not speed!) improves.

    Divide and conquer. Hell yeah!
    
    If you need to fill a rotated container at some location, just pass a position-offset
    and an angle along...
    
   PS: This is like the cheapest (but also a fast) solution for a very hard problem. If you
   wanna know more, just google for `packing problem`, `recursive rectangle packing` or
   `recursive partitioining` ... There are uncountable papers and different algorithms on 
   this subject.
   
     ... since this algorithm is intended for dynamically spawned object compositions, 
     efficiency (and thus predictability) was never the goal. But go on and implement 
     another algorithm like the `Recursive Five-block Algorithm`, the `L-Algorithm`, ...
   
   PPS: DO NOT try to search a spot for a hundred similar or equal sized objects... you'd
     kill to much precious cpu-cycles... rather consider a regular for x for y loop instead.
     This algorithm solves a harder problem, than returning grid positions. :/
      
     (something like filling a 12x20 meter field with 80 barrels and random offset would be 
       exactly such a case...) 
       
     If you expect something to be spawned - relying on this function - but nothing happens, 
     you might just have to wait another minute or two.. haha
    
     --> if you really need to pack a very big rectangle, you should split it into several
         smaller ones to run the packer multiple times, but with much smaller binary trees.
         Remember: divide and conquer! ;)
    
    
   Parameter(s):
    _this select 0: container size (array [x, y])
    _this select 1: array of rectangle sizes (array of arrays [x, y])
    _this select 2: margin/spacing (int)
                    ~1.5m feels ok for tight sidewalks
                    ~7m for a one-way street (which M1A1 can pass just fine)
    _this select 3: returned reference-point of packed rectangles (string)
                    - "topleft", "bottomleft", "center"
                    - default = "bottomleft"
    _this select 4: position-offset/container position (array of [x, y] OR [x, y, ref-point])
                    - ref-point = string "topleft", "bottomleft", "center"
                      - default = "bottomleft";
    _this select 5: rotation/direction (number, optional)
    
    
   Returns:
    array of packed rectangles (not incl. dropped rectangles -> we may get an empty array)
    
     - data-structure of packed rectangles: 
       array of [
          array-index-of-passed-objects (int), 
          pos-x (scalar),
          pos-y (scalar)
       ]
*/

private ["_container", "_mapRotation", "_mapReferencePoint",  "_rectangles", "_margin", "_margin2", "_offsetX", "_offsetY", "_vec", "_rotation", "_rotationNOR", "_pack", "_packed", "_p", "_i", "_pos", "_m"];

// node structure:
/*
   array of [
      0: x,            (number)
      1: y,            (number)
      2: width,        (number)
      3: height,       (number)                   [init]
      --------------------------------------------------                              
      4: left-node,    (array|null)            [runtime]
      5: right-node    (array|null)
      6: node-is-used  (boolean|null)
   ]
*/

// root node
_container = [
   0,
   0,
   ((_this select 0) select 0),
   ((_this select 0) select 1)
];


_rectangles = _this select 1;
_margin = _this select 2;
_margin2 = _margin * 0.5;

_rotation = 0;
if ((count _this) > 5) then 
{
   _rotation = _this select 5;
};
_rotationNOR = (360 - _rotation) % 360;


_offsetX = 0;
_offsetY = 0;
if ((count _this) > 4) then 
{
   _offsetX = (_this select 4) select 0;
   _offsetY = (_this select 4) select 1;
   if ((count (_this select 4)) > 2) then
   {
      switch ((_this select 4) select 2) do
      {
         case "topleft":
         {
            _vec = [
               [0, ((_container select 3) * -1)], 
               _rotationNOR
            ] call BIS_fnc_rotateVector2D;
            _offsetX = _offsetX + (_vec select 0);
            _offsetY = _offsetY + (_vec select 1);
         };
         case "center":
         {
            _vec = [
               [((_container select 2) * -0.5), ((_container select 3) * -0.5)], 
               _rotationNOR
            ] call BIS_fnc_rotateVector2D;
            _offsetX = _offsetX + (_vec select 0);
            _offsetY = _offsetY + (_vec select 1);
         };
      };
   };
};


// private function to map container rotation
_mapRotation = {
   _this
};
if (_rotation != 0) then
{
   _mapRotation = {
      ([_this, _rotationNOR] call BIS_fnc_rotateVector2D)
   };
};

// private function to map reference point of packed rectangles
_mapReferencePoint = {
   ([
      ((_this select 0) + _margin2), 
      ((_this select 1) + _margin2)
   ] call _mapRotation)
};
if ((count _this) > 3) then
{
   switch (_this select 3) do
   {
      case "topleft": 
      {
         _mapReferencePoint = {
            ([
               ((_this select 0) + _margin2),
               (((_this select 1) + (_this select 3)) - _margin2)
            ] call _mapRotation)
         };
      };
      case "center":  
      {
         _mapReferencePoint = {
            ([
               ((_this select 0) + ((_this select 2) * 0.5)),
               ((_this select 1) + ((_this select 3) * 0.5))
            ] call _mapRotation)
         };
      };
   };
};

// private function to clone/init a node
_cloneNode = {
   [
      (_this select 0),
      (_this select 1),
      (_this select 2),
      (_this select 3)
   ]
};

// private function to look (recursively) for a suitable position
/*
   Parameter(s):
    _this select 0: node (-structure)
    _this select 1: width
    _this select 2: height
   
   Returns:
    array [x, y] OR false 
*/
_pack = {
   private ["_node", "_width", "_height", "_return", "_leftNode"];
   _node = _this select 0;
   _width = _this select 1;
   _height = _this select 2;
   
   _return = false;
   
   // 1) search leaf
   // we go down the binary tree (first left, then right)   
   // until we have a leaf (node without children)
   if ((count _node) > 4) then
   {
      if ((count _node) > 6) then
      {
         _return = false;
      } else {
         _leftNode = [(_node select 4), _width, _height] call _pack;
         if ((typeName _leftNode) == "ARRAY") then 
         {
            _return = _leftNode;
         } else {
            _return = [(_node select 5), _width, _height] call _pack;
         };
      };
   // 2) check/process leaf
   } else {
      // already used or too big? -> return false
      if ( (_width  > (_node select 2)) || 
           (_height > (_node select 3)) ) exitWith
      {
         _return = false;
      };
      
      // _perfect_ fit? -> use/return gap reference point
      if ( (_width  == (_node select 2)) && 
           (_height == (_node select 3)) ) exitWith
      {
         // flag node as used!
         _node set [6, true];
         // return position
         _return = (_node call _mapReferencePoint);
      };
      
      // split/partition current node 
      _node set [4, (_node call _cloneNode)]; 
      _node set [5, (_node call _cloneNode)];
      
      // partition horizontal/vertical
      if ( ((_node select 2) - _width) > ((_node select 3) - _height) ) then
      {
         (_node select 4) set [2, _width];
         (_node select 5) set [0, ((_node select 0) + _width)];
         (_node select 5) set [2, ((_node select 2) - _width)];
      } else {
         (_node select 4) set [3, _height];
         (_node select 5) set [1, ((_node select 1) + _height)];
         (_node select 5) set [3, ((_node select 3) - _height)];
      };
      
      _return = [(_node select 4), _width, _height] call _pack;
   };
   
   _return
};


_packed = [];
_p = 0;

// process rectangles
for "_i" from 0 to ((count _rectangles) - 1) do
{
   _pos = [
      _container, 
      (((_rectangles select _i) select 0) + _margin),
      (((_rectangles select _i) select 1) + _margin)
   ] call _pack;
   if ((typeName _pos) == "ARRAY") then
   {
      _packed set [_p, 
         [   
            _i,
            ((_pos select 0) + _offsetX),
            ((_pos select 1) + _offsetY)
         ]
      ];
      _p = _p + 1;
   };
};

// return packed rectangles
_packed























