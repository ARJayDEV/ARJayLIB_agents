/*
   Author:
    rübe
    
   Description:
    returns the 2d cell-position (center) from a grid.
    (see fn_makeGrid.sqf)
    
   Parameter(s):
    _this select 0: origin position (cell 0/0) (position)
    _this select 1: cell x (int)
    _this select 2: cell y (int)
    _this select 3: offset/vector x-axis (2d array)
    _this select 4: offset/vector y-axis (2d array)
    
   Returns:
    position
*/

[
   // x-axis: pX + (cX * VXx) + (cY * vYx) 
   (((_this select 0) select 0) + ((_this select 1) * ((_this select 3) select 0)) 
                                + ((_this select 2) * ((_this select 4) select 0))),
   // y-axis: pY + (cX * VXy) + (cY * vYy)                             
   (((_this select 0) select 1) + ((_this select 1) * ((_this select 3) select 1)) 
                                + ((_this select 2) * ((_this select 4) select 1))),
   // z-axis                             
   0
]