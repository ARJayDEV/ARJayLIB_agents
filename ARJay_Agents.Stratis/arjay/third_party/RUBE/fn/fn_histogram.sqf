/*
   Author:
    rübe
    
   Description:
    calculates (and `diag_log`-plots) a histogram of a set of 
    samples. THe interval get's calculated based on the desired 
    amount of range-groups/bars. Or calculate stuff on your own.
    
      Used for fast debug-plots, which is the main intention for
    this function. That's why the plot option is on per default.
    This, and because of reason. But feel free to feed your 
    dialogs with it or what ever you fancy.
    
   Parameter(s):
    _this: parameters (array of array [key (string), value (any)])
    
      - required:
        
        - "samples" (array of scalar)
        
      - optional:
         
         - "size" (integer > 0)
             amount of range-groups/bars, 
             default = 10
           
         - "plot" (boolean)
             plots the histogram with diag_log. Make sure to
             view the output with a monospaced font.
             default = true
           
         - "min" (scalar)
             default = auto: floor minimum
           
         - "max" (scalar)
             default = auto: ceil maximum
            
         - "interval" (scalar)
             default = auto: (_max - _min)/_size
    
   Returns:
    array
*/

private ["_samples", "_size", "_plot", "_min", "_max", "_interval"];

_samples = [];
_size = 10;
_plot = true;
_min = false;
_max = false;
_interval = false;

// read parameters
{
   switch (_x select 0) do
   {
      case "samples": { _samples = _x select 1; };
      case "size": { _size = _x select 1; };
      case "plot": { _plot = _x select 1; };
      case "min": { _min = _x select 1; };
      case "max": { _max = _x select 1; };
      case "interval": { _interval = _x select 1; };
   };
} forEach _this;

// abort if too stupid
if (_size == 0) exitWith { [] };

// calculate auto defaults
if ( ((typeName _min) == "SCALAR") &&
     ((typeName _max) == "SCALAR") && 
     ((typeName _interval) == "SCALAR")) then
{
   _size = (_max - _min) / _interval;
};

if ((typeName _min) == "BOOL") then
{
   _min = floor ([_samples] call RUBE_arrayMin);
};

if ((typeName _max) == "BOOL") then
{
   _max = ceil ([_samples] call RUBE_arrayMax);
};

if ((typeName _interval) == "BOOL") then
{
   _interval = (_max - _min) / _size;
};

// abort if too stupid
if (_interval == 0) exitWith { [] };


// calculate histogram
private ["_h", "_index"];

_h = [];

for "_i" from 0 to (_size - 1) do
{
   _h set [_i, 0];
};

for "_i" from 0 to ((count _samples) - 1) do
{
   _index = floor (((_samples select _i) - _min) / _interval);      
   _h set [_index, ((_h select _index) + 1)];
};

// plot histogram
if (_plot) then
{
   private ["_hit", "_hitSpacing", "_miss", "_maxH", 
            "_lineOffset", "_lineLength", "_line",
            "_m", "_i", "_j", "_v"];
   
   // configure histogram "symbols"
   _hit = "#######"; // symbol for bar
   _hitSpacing = count (toArray _hit);
   _miss = ["", _hitSpacing, " "] call RUBE_pad; // symbol for no-bar
   
   _maxH = [_h] call RUBE_arrayMax;
   _lineOffset = 0;
   _lineLength = 0;
   
   diag_log "";
   
   // plot bars
   for "_i" from 1 to _maxH do
   {
      _m = _maxH - _i + 1;  
      _line = format[
         " %1 ",
         ([_m, 3, "0", true] call RUBE_pad)
      ];
      
      if (_i == _maxH) then
      {
         _lineOffset = count (toArray _line);
      };
      
      for "_j" from 0 to ((count _h) - 1) do
      {
         if ((_h select _j) >= _m) then
         {
            _line = _line + _hit;
         } else
         {
            _line = _line + _miss;
         };
         
         _line = _line + " ";
      };
      
      if (_i == _maxH) then
      {
         _lineLength = count (toArray _line);
      };
      
      diag_log _line;
   };
   
   // plot axis
   _line = "";
   for "_i" from 1 to _lineLength do
   {
      _line = _line + "-";
   };
   
   // print hist. labels   
   _line = ["", _lineOffset, " "] call RUBE_pad;
   for "_i" from 0 to (_size - 1) do
   {
      _v = _min + (_i * _interval);
      // _hitSpacing
      _line = _line + format[
         "%1|",
          ([
            ([_v, 0.01] call RUBE_roundTo),
            _hitSpacing,
            " ",
            false
           ] call RUBE_pad)
      ];
   };
   diag_log _line;
   
   _line = (["", _lineOffset, " "] call RUBE_pad);
   
   diag_log "";
   diag_log format[
      "%1interval: %2, from %3 to %4",
      _line,
      _interval,
      _min,
      _max
   ];
   
   diag_log "";
};

// return histogram
_h