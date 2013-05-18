/*
   Author:
    rübe
    
   Description:
    returns a filtered list, not touching the original one,
    by means of a custom filter. 
    
   Parameter(s):
    _this select 0: list (array)
    _this select 1: filter (code)
                    - the filter gets passed the current item
                    - the filter has to return boolean:
                      - true: keep
                      - false: discard
   
   Returns:
    array
*/

private ["_filtered", "_i"];

_filtered = [];
_i = 0;

{
   if (_x call (_this select 1)) then
   {
      _filtered set [_i, _x];
      _i = _i + 1;
   };
} forEach (_this select 0);

_filtered