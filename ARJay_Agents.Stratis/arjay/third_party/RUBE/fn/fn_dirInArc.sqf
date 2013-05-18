/*
   Author:
    rübe
    
   Description:
    checks wheter a given angle is in (or on the edge) a defined arc. 
    Unnormalized input directions are totally fine (such as negative 
    directions).
    
              |-- inside arc -->
                    (true)
                a   .        b
                  \####|####/
                   \###|###/       . outside (false)
                    \##|##/        
                     \#|#/
             ----------X----------
                       |
                       |

                       
   Parameter(s):
     _this select 0: angle to be checked (scalar)
     _this select 1: start angle of arc (scalar)
     _this select 2: end angle of arc (scalar)
     
       >>> arc is drawn clockwise, from start to end!
   
   Returns:
    boolean
*/

private ["_dir", "_arc0", "_arc1", "_inside"];

_dir  = (_this select 0) call RUBE_normalizeDirection;
_arc0 = (_this select 1) call RUBE_normalizeDirection;
_arc1 = (_this select 2) call RUBE_normalizeDirection;

// empty arc
if (_arc0 == _arc1) exitWith { false };
// on edge of arc
if ((_dir == _arc0) || (_dir == _arc1)) exitWith { true };

_inside = false;

if (_arc0 > _arc1) then
{
   switch (true) do
   {
      case (_dir == 0): { _inside = true; };
      case (_dir > _arc0): { _inside = true; };
      case (_dir < _arc1): { _inside = true; };
   };
} else {
   if ((_dir > _arc0) && (_dir < _arc1)) then
   {
      _inside = true;
   };
};

_inside