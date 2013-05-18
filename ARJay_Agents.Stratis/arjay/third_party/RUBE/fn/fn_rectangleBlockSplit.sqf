/*
   Author:
    rübe
   
   Description:
    splits a rectangle/container recursively and randomly into smaller ones  
    by placing a given (defined) rectangle into a larger one...
    
    The idea here is to place one major building at a prominent place (C) and
    split the rest of the available space into random rectangles, which are
    to be filled with random objects.
    
    The relative position of (C) may be: topleft, topmiddle, topright, 
    bottomright, bottommiddle or bottomleft if the initial random position
    would cause a rectangle smaller than the given min. rect. size. Otherwise
    it will be placed more or less in the center.
    
        _________________________            _______________________
        |     |      |           |           |       |       .     |
        |  1  |  2   |     3     |           |   C   |   1   .  2  |
    y2 _|_____|______|___________|           |       |       .     |
        |     |      |           |       y2 _|_______|_____________|
        |  4  |  C   |     5     |   OR      |       |   .         |   OR ...
    y1 _|_____|______|___________|           |   3   |   .    6    |
        |     |  7   |     .     |           |.......| 5 ..........|
        |  6  |......|  9  . 10  |           |       |   .         |       y
        |     |  8   |     .     |           |   4   |   .    7    |       
        |_____|______|___________|           |_______|_____________|       ^
              |      |                               |                     |
             x1      x2                             x1                     |--> x 
    
    ... where C is the given (and defined) rectangle. Thus C can end up either at
    a side or in the center (most likely misaligned).
    
    A rectangle get's split if a side of a rect exceeds a given max, by a given 
    chance or not at all if both sides of the rect. are smaller than a given min.
    
   Parameter(s):
    _this select 0: container size (array [x, y])
    _this select 1: rectangle size (C) (array [x, y])
    _this select 2: returned reference-point of rectangles (string)
                    - "topleft", "bottomleft", "center"
                    - default = "bottomleft"
    _this select 3: position-offset/container position (array of [x, y] OR [x, y, ref-point])
                    - ref-point = string "topleft", "bottomleft", "center"
                      - default = "bottomleft";
    _this select 4: rotation/direction (number, optional)
    _this select 5: margin/spacing (number, optional)
    _this select 6: min. size of a rect. side, inhibiting a further split (number, optional)
                    - default = 3m
    _this select 7: max. size of a rect. side, forcing a split  (number, optional)
                    - default = 0 -> (no max size)
    _this select 8: chance for a split (number from 0-100, optional)
                    - default 66.6
    
   Return(s):
    array of arrays [
       [pos-x, pos-y],
       [width, height]
    ]
    
    where the first array is the inital splitting rectangle (C), followed by a
    random number of splitted rectangles, all together filling the container rectangle.
    
*/

private ["_contX", "_contY", "_midX", "_midY", "_rectSize", "_rotation", "_rotationNOR", "_offsetX", "_offsetY", "_margin", "_margin2", "_rectMin", "_rectMin2", "_rectMax", "_splitChance", "_mapRotation", "_mapReferencePoint", "_split", "_x1", "_x2", "_y1", "_y2", "_placement", "_rest", "_rectangles", "_h2", "_h3", "_w2", "_w3"];

_contX = (_this select 0) select 0;
_contY = (_this select 0) select 1;
_midX = _contX * 0.5;
_midY = _contY * 0.5;
_rectSize = _this select 1;

_rotation = 0;
if ((count _this) > 4) then 
{
   _rotation = _this select 4;
};
_rotationNOR = (360 - _rotation) % 360;

_offsetX = 0;
_offsetY = 0;

if ((count _this) > 3) then 
{
   _offsetX = (_this select 3) select 0;
   _offsetY = (_this select 3) select 1;
   if ((count (_this select 3)) > 2) then
   {
      private ["_vec"];
      switch ((_this select 3) select 2) do
      {
         case "topleft":
         {
            _vec = [
               [0, (_contY * -1)], 
               _rotationNOR
            ] call BIS_fnc_rotateVector2D;
            _offsetX = _offsetX + (_vec select 0);
            _offsetY = _offsetY + (_vec select 1);
         };
         case "center":
         {
            _vec = [
               [(_contX * -0.5), (_contY * -0.5)], 
               _rotationNOR
            ] call BIS_fnc_rotateVector2D;
            _offsetX = _offsetX + (_vec select 0);
            _offsetY = _offsetY + (_vec select 1);
         };
      };
   };
};

_margin = 0;
_margin2 = 0;
if ((count _this) > 5) then
{
   _margin = _this select 5;
   _margin2 = _margin * 0.5;
   _rectSize set [0, ((_rectSize select 0) + _margin)];
   _rectSize set [1, ((_rectSize select 1) + _margin)];
};

_rectMin = 3;
if ((count _this) > 6) then
{
   _rectMin = _this select 6;
};
_rectMin2 = _rectMin * 2;
_rectMax = 0;
if ((count _this) > 7) then
{
   _rectMax = _this select 7;
};
_splitChance = 66.6;
if ((count _this) > 8) then
{
   _splitChance = _this select 8;
};

// private function to map container rotation and offset
_mapRotation = {
   [
      ((_this select 0) + _offsetX),
      ((_this select 1) + _offsetY)
   ]
};
if (_rotation != 0) then
{
   _mapRotation = {
      private ["_p"];
      _p = [_this, _rotationNOR] call BIS_fnc_rotateVector2D;
      [
         ((_p select 0) + _offsetX),
         ((_p select 1) + _offsetY)
      ]
   };
};

// private function to map reference point of rectangles
_mapReferencePoint = {
   ([
      (_this select 0), 
      (_this select 1)
   ] call _mapRotation)
};
if ((count _this) > 2) then
{
   switch (_this select 2) do
   {
      case "topleft": 
      {
         _mapReferencePoint = {
            ([
               (_this select 0),
               ((_this select 1) + (_this select 3))
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



// private function to split rectangles
/*
   Returns:
    array of arrays [x, y, width, height]
*/
_split = {
   private ["_x", "_y", "_width", "_height", "_return", "_m", "_x1", "_y1", "_xE", "_yE"];
   _x = _this select 0;
   _y = _this select 1;
   _width = _this select 2;
   _height = _this select 3;

   _return = [];
   
   // further split allowed?
   if (((_width - _margin) > _rectMin2) || ((_height - _margin) > _rectMin2)) then
   {
      // chance/forced split
      if ( ((_rectMax > 0) && ((_width > _rectMax) || (_height > _rectMax))) ||
           (_splitChance call RUBE_chance)) then
      {
         // split
         if (_width > _height) then
         {
            // vertical split   |_|_|
            _xE = _x + _width;
            _x1 = [(_x + _rectMin2), (_xE - _rectMin2)] call RUBE_randomBetween;
            _return = ([_x, _y, (_x1 - _x - _margin2), _height] call _split) + 
                      ([(_x1 + _margin2), _y, (_xE - _x1 - _margin2), _height] call _split);
         } else {
            // horizontal split |---|
            _yE = _y + _height;
            _y1 = [(_y + _rectMin2), (_yE - _rectMin2)] call RUBE_randomBetween;
            _return = ([_x, _y, _width, (_y1 - _y - _margin2)] call _split) +
                      ([_x, (_y1 + _margin2), _width, (_yE - _y1 - _margin2)] call _split);
         };
      };
   };
   
   // no further split -> return
   if ((count _return) == 0) then
   {
      _return = [
         [
            ([_x, _y, _width, _height] call _mapReferencePoint),
            [_width, _height]
         ]
      ];
   };
      
   _return
};

// get random (C)-rect. position
_x1 = [0, _contX] call RUBE_randomBetween;
_y1 = [0, _contY] call RUBE_randomBetween;
_x2 = 0;
_y2 = 0;

_placement = "center";
if (_x1 < _rectMin) then
{
   if (_y1 < _midY) then
   {
      _placement = "bottomleft";
   } else {
      _placement = "topleft";
   };
};
if ((_contX - (_x1 + (_rectSize select 0))) < _rectMin) then
{
   if (_y1 < _midY) then
   {
      _placement = "bottomright";
   } else {
      _placement = "topright";
   };
};
if ((_y1 < _rectMin) && 
    (_placement == "center")) then
{
   _placement = "bottommiddle";
};
if (((_contY - (_y1 + (_rectSize select 1))) < _rectMin) && 
    (_placement == "center")) then
{
   _placement = "topmiddle";
};


// adjust (C)-rect. placement and get `rest` rectangles
_rest = [];
switch (_placement) do 
{
   case "center": 
   {
      _x2 = _x1 + (_rectSize select 0);
      _y2 = _y1 + (_rectSize select 1);
      
      _w2 = _x2 - _x1;
      _w3 = _contX - _x2;
      _h2 = _y2 - _y1;
      _h3 = _contY - _y2;
      
      _rest = [
         [  0, _y2, _x1, _h3],
         [_x1, _y2, _w2, _h3],
         [_x2, _y2, _w3, _h3],
         [  0, _y1, _x1, _h2],
         [_x2, _y1, _w3, _h2],
         [  0,   0, _x1, _y1],
         [_x1,   0, _w2, _y1],
         [_x2,   0, _w3, _y1]
      ];
   };
   case "topleft": 
   {
      _x1 = 0;
      _x2 = _rectSize select 0;
      _y2 = _contY;
      _y1 = _y2 - (_rectSize select 1);
      
      _w2 = _contX - _x2;
      _h2 = _y2 - _y1;
      
      _rest = [
         [_x2, _y1, _w2, _h2],
         [  0,   0, _x2, _y1],
         [_x2,   0, _w2, _y1]
      ];      
   };
   case "topmiddle": 
   {
      _x2 = _x1 + (_rectSize select 0);
      _y2 = _contY;
      _y1 = _y2 - (_rectSize select 1);
      
      _w2 = _x2 - _x1;
      _w3 = _contX - _x2;
      _h2 = _y2 - _y1;
      
      _rest = [
         [  0, _y1, _x1, _h2],
         [_x2, _y1, _w3, _h2],
         [  0,   0, _x1, _y1],
         [_x1,   0, _w2, _y1],
         [_x2,   0, _w3, _y1]
      ];
   };
   case "topright": 
   {
      _x2 = _contX;
      _x1 = _x2 - (_rectSize select 0);
      _y2 = _contY;
      _y1 = _y2 - (_rectSize select 1);
      
      _w2 = _x2 - _x1;
      _h2 = _y2 - _y1;
      
      _rest = [
         [  0, _y1, _x1, _h2],
         [  0,   0, _x1, _y1],
         [_x1,   0, _w2, _y1]
      ];
   };
   case "bottomright": 
   {
      _x2 = _contX;
      _x1 = _x2 - (_rectSize select 0);
      _y1 = 0;
      _y2 = _rectSize select 1;
      
      _w2 = _x2 - _x1;
      _h2 = _contY - _y2;
      
      _rest = [
         [  0, _y2, _x1, _h2],
         [_x1, _y2, _w2, _h2],
         [  0,   0, _x1, _y2]
      ];
   };
   case "bottommiddle": 
   {
      _x2 = _x1 + (_rectSize select 0);
      _y1 = 0;
      _y2 = _rectSize select 1;
      
      _w2 = _x2 - _x1;
      _w3 = _contX - _x2;
      _h2 = _contY - _y2;
      
      _rest = [
         [  0, _y2, _x1, _h2],
         [_x1, _y2, _w2, _h2],
         [_x2, _y2, _w3, _h2],
         [  0,   0, _x1, _y2],
         [_x2,   0, _w3, _y2]
      ];
   };
   case "bottomleft": 
   {
      _x1 = 0;
      _x2 = _rectSize select 0;
      _y1 = 0;
      _y2 = _rectSize select 1;
      
      _w2 = _contX - _x2;
      _h2 = _contY - _y2;
      
      _rest = [
         [  0, _y2, _x2, _h2],
         [_x2, _y2, _w2, _h2],
         [_x2,   0, _w2, _y2]
      ];
   };
};

// apply rect. margin
if (_margin > 0) then
{
   {
      _x set [0, ((_x select 0) + _margin2)];
      _x set [1, ((_x select 1) + _margin2)];
      _x set [2, ((_x select 2) - _margin)];
      _x set [3, ((_x select 3) - _margin)];
   } forEach _rest;
};

// insert (C) rect... 
_rectangles = [
   [
      ([(_x1 + _margin2), (_y1 + _margin2), ((_rectSize select 0) - _margin), ((_rectSize select 1) - _margin)] call _mapReferencePoint),
      [((_rectSize select 0) - _margin), ((_rectSize select 1) - _margin)]
   ]
];

// ...and recursively split the rest
{
   _rectangles = _rectangles + (_x call _split);
} forEach _rest;

// return rectangles
_rectangles







