/*
   Author:
    rübe
    
   Description:
    Calculates the daylight hours at a given place (latitude) and 
    on a given date (day in year).
    
    
    Algorithm by: Food and Agriculture Organization of the United 
    Nations, http://www.fao.org/docrep/X0490E/x0490e07.htm

   
   Parameter(s):
    _this select 0: date (array) or day (integer)
    _this select 1: latitude, in degree (scalar in [-90,90])
                    - positive = northern hemisphere
                      (NOT like in Arma's config!) 
    
   Returns:
    scalar (in hours)
*/

private ["_day", "_latitude", "_solarDecimation", "_sunsetHourAngle", "_h"];

_day = _this select 0;
_latitude = _this select 1;

if ((typeName _day) == "ARRAY") then
{
   _day = (((_this select 0) select 1) - 1) * 30 +
          ((_this select 0) select 2);
};

// respect bounds
if (_latitude >= 90)  then { _latitude =  89.9; };
if (_latitude <= -90) then { _latitude = -89.9; };

// solar decimation
_solarDecimation = 0.409 * (sin (deg ( 
                      ( ((2 * pi) / 365) * _day) - 1.39
                   )));

// sunset hour angle
_sunsetHourAngle = rad (acos (
                      -(tan _latitude) * (tan (deg _solarDecimation))
                   ));

// calculate daylight hours
_h = (24/pi) * _sunsetHourAngle;

// catch -1.#IND
// TODO: is there really no other way?! "smaller than" doesn't catch it, typeName == "SCALAR" neither...
//   well, whatever... we don't call this function all that often anyway :P
if (format["%1", _h] == "-1.#IND") then
{
   _h = 0;
};

_h