/*
   Author:
    rübe
    
   Description:
    Returns the weekday of a given date.
    
    Algorithm (Sakamoto's method) taken from:
     http://www.faqs.org/faqs/calendars/faq/part1/index.html
     2.6. What day of the week was 2 August 1953?
   
   Parameter(s):
    _this: date (array, optional)
    
   Returns:
    integer, s.t. 0=sunday,
                  1=monday,
                  2=tuesday,
                  3=wednesday,
                  4=thursday,
                  5=friday,
                  6=saturday
*/

private ["_date", "_a", "_y", "_m"];

_date = date;

if ((typeName _this) == "ARRAY") then
{
   if ((count _this) > 2) then
   {
      _date = _this;
   };
};

_a = floor ((14 - (_date select 1)) / 12);
_y = (_date select 0) - _a;
_m = (_date select 1) + (12 * _a) - 2;

((    (_date select 2) 
    + _y 
    + (floor (_y / 4)) 
    - (floor (_y / 100))
    + (floor (_y / 400))
    + (floor ((31 * _m) / 12))
) % 7)