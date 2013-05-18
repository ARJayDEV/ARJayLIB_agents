/*
   Author:
    rübe
    
   Description:
    returns the cell depth of a cell in a given grid
    (see fn_makeGrid.sqf)
    
   Parameter(s):
    _this select 0: cell x (int)
    _this select 1: cell y (int)
    _this select 2: grid-size x (int, number of cells and not max array index!)
    _this select 3: grid-size y (int, number of cells and not max array index!)
*/

(((_this select 0) min (((_this select 2) - 1) - (_this select 0))) min 
 ((_this select 1) min (((_this select 3) - 1) - (_this select 1))))

