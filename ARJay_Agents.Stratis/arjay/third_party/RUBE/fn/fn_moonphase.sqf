/*
   Author:
    rübe
    
   Description:
    calculates the moonphase on a given date, valid for 20th and 21th
    centuries, so perfect for our useage...
    based on:
    
     some Basic code by Roger W. Sinnot from Sky & Telescope magazine, 
     March 1985
    
     (see http://www.ben-daglish.net/moon.shtml)
    
    -> well, this does not correlate with ingame moonphases :(
       bleahhh :/
    
   Parameter(s):
    _this: date (array [year, month, day, ...] or as returned by `date`)
    
   Returns:
    integer 
    
    returns the phase day; 0 to 29, where 
      0 = new moon, 
     15 = full moon
*/

private ["_year", "_month", "_day"];

_year = _this select 0;
_month = _this select 1;
_day = _this select 2;


private ["_julianDayNumber"];

// [year, month, day] => julian day number
//  (TODO: make global function once used elsewhere!)
_julianDayNumber = {
   private [
      "_year", "_month", "_day",
      "_jy", "_jm", "_ja", "_jul"
   ];
   _year = _this select 0;
   _month = _this select 1;
   _day = _this select 2;
   
   if (_year < 0) then { _year = _year + 1; };
   
   _jy = _year;
   _jm = _month + 1;
   
   if (_month <= 2) then
   {
      _jy = _jy - 1;
      _jm = _jm + 12;
   };
   
   _jul = (floor (365.25 * _jy)) + (floor (30.6001 * _jm)) + _day + 1720995;
   
   if (_day + (31 * (_month + (12 * _year))) >= (15+31*(10+12*1582))) then
   {
      _ja = floor (0.01 * _jy);
      _jul = _jul + 2 - _ja + (floor (0.25 * _ja));
   };
   
   _jul
};

private ["_n", "_t", "_t2", "_as", "_am", "_xtra", "_i", "_j1", "_jd", "_armaErr"];

_n = floor (12.37 * (_year - 1900 + ((1.0 * _month - 0.5)/12)));
_t = _n / 1236.85;
_t2 = _t * _t;
_as = 359.2242 + 29.105356 * _n;
_am = 306.0253 + 385.816918 * _n + 0.010730 * _t2;
_xtra = 0.75933 + 1.53058868 * _n + ((0.0001178) - (0.000000155) * _t) * _t2;
_xtra = _xtra + (0.1734 - 0.000393 * _t) * (sin  _as) - 0.4068 * (sin _am);

_i = 0;
if (_xtra > 0) then
{
   _i = floor _xtra;
} else
{
   _i = ceil (_xtra - 1);
};

_armaErr = 0;//6;

_j1 = [_year, _month, _day] call _julianDayNumber;
_jd = (2415020 + 28 * _n) + _i;

((_j1 - _jd + 30 + _armaErr) % 30)