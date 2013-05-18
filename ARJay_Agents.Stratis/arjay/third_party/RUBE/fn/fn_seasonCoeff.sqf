/*
   Author:
    rübe
    
   Description:
    Returns the season coefficient (in [0,1]) which is
    
      0.0: in winter        (on day ~354;   ~24.Dec)
     ~0.5: in spring/autumn (on day 80/264; ~20.Mar/~24.Sep)
      1.0: in summer        (on day 172;    ~21.Jun)
                            
                            \______________________________/
                              for the northern hemisphere;
                               vice versa for the southern
   
   Parameter(s):
    _this select 0: date (array) or day (integer)
    _this select 1: latitude, in degree (scalar in [-90,90])
                    - positive = northern hemisphere
                      (NOT like in Arma's config!) 
                      
                     -> undefined at exactly 0, but seasons
                        don't matter too much at the equator
                        anyway...
   
   Returns:
    scalar in [0,1]
*/

private ["_day", "_latitude", "_distance", "_c"];

_day = _this select 0;
_latitude = _this select 1;

if ((typeName _day) == "ARRAY") then
{
   _day = (((_this select 0) select 1) - 1) * 30 +
          ((_this select 0) select 2);
};

// distance to shortest day (on southern hemisphere)
_distance = abs (_day - 172);

if (_distance > 183) then
{
   _distance = 172 + (366 - _day);
};

_c = _distance / 183;

// northern hemisphere?
if (_latitude > 0) then
{
   _c = 1 - _c;
};

_c