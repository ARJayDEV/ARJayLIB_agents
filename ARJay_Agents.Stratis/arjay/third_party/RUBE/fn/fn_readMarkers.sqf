/*
   Author:
    rübe
    
   Description:
    returns a list of valid/existing marker names OR
    runs the given code for each marker - if given.
    
   Parameter(s):
    _this select 0: marker-name as prefix (string or [string, int])
                    - given an array, the integer is taken as new starting
                      increment/suffix for the markers; default = 1   
    _this select 1: code  (code, optional)
                    - get's passed the marker-id-string as _this
    _this select 2: clear map (bool, optional; default = true)
                    - deletes markers after code has been run
    
   Returns:
    array of strings OR an empty array (code)
*/

private ["_name", "_i", "_code", "_cleanup", "_markerid", "_markers"];

_name = _this select 0;
_i = 1;
_code = false;
_cleanup = true;
_markers = [];

if ((typeName (_this select 0)) == "ARRAY") then
{
   _name = (_this select 0) select 0;
   _i = (_this select 0) select 1;
};

if ((count _this) > 1) then
{
   _code = _this select 1;
};

if ((count _this) > 2) then
{
   _cleanup = _this select 2;
};


_markerid = format["%1%2", _name, _i];

while {((getMarkerType _markerid) != "")} do
{
   if ((typeName _code) == "CODE") then
   {
      _markerid call _code;
      if (_cleanup) then
      {
         deleteMarker _markerid;
      };
   } else
   {
      _markers set [(count _markers), _markerid];
   };
   
   _i = _i + 1;
   _markerid = format["%1%2", _name, _i];
};

_markers