/*
   Author
    rübe
    
   Description:
    wrapper-function for getPosASL (which only takes objects at this point)
    
    takes a 2d-position, places a "probe"-object there, retrieves 
    and returns the ASL position
    
    - the "probe"-object get's created once at initialization of
      the RUBE function library.
   
   Parameter(s):
    _this: position
    
   Returns:
    position ASL
*/
/*
----------------------------------------------------------------------------
  PROBE_OBJ hack is finally not needed anymore, yay!
  DEPRECATED(!) since OA 1.55 and the introduction of getTerrainHeightASL
----------------------------------------------------------------------------
*/
/*
private ["_probe"];

RUBE_PROBE_OBJ setPos [(_this select 0), (_this select 1)];
_probe = getPosASL RUBE_PROBE_OBJ;

[
   (_this select 0),
   (_this select 1),
   (_probe select 2)
]
*/

[
   (_this select 0),
   (_this select 1),
   (getTerrainHeightASL _this)
]