/*
   Author:
    rübe
    
   Description:
    returns an objects size based on its bounding box
    
   Parameter(s):
    _this: object
    
   Returns:
    array [x, y, z]
*/

private ["_box"];

_box = boundingBox _this;

[
   (abs (((_box select 1) select 0) - ((_box select 0) select 0))),
   (abs (((_box select 1) select 1) - ((_box select 0) select 1))),
   (abs (((_box select 1) select 2) - ((_box select 0) select 2)))
]
