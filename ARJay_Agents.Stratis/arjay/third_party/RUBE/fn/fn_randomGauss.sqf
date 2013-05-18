/*
   Author:
    rübe
    
   Description:
    Returns a standard, normally distributed (zero expectation, 
    unit variance) random number using the (polar) Box-Muller 
    transform.
    
    (see http://en.wikipedia.org/wiki/Box%E2%80%93Muller_transform
         http://en.wikipedia.org/wiki/Marsaglia_polar_method)
           
    
                                    .--.
                                   /    \
                                  /      \
                                 /        \
                                /          \
                               /            \
                              /              \
                            .-                -.
                         .--                    --.
                     .---                          ---.
                .----                                  ----.
       <--------____________________________________________-------->
          |      |      |      |      |      |      |      |      |
        -4s    -3s    -2s    -1s     my    +1s    +2s    +3s    +4s
       
                               [### 68.3% ###]  
                        [########## 95.5% ##########]    
                 [################# 99.7% #################]     
          [######################## 99.9% ########################]   
           
             
   Parameters:
    _this select 0: mean/expectation (optional, default = 0)
    _this select 1: standard deviation (optional, default = 1)
    _this select 2: limit range/bounds (optional, array of [min, max])
                    - if you're going to bound the range, you 
                      technically won't have a normal distribution
                      anymore. Just sayin'... :)
    
   Returns:
    scalar,  ( ]-4, 4[ for a normal distribution)
*/

private ["_mean", "_stdDev", "_gauss", "_bounds"];

_mean = 0;
_stdDev = 1;
_bounds = [];

if ((typeName _this) == "ARRAY") then
{
   if ((count _this) > 0) then
   {
      _mean = _this select 0;
   };
   
   if ((count _this) > 1) then
   {
      _stdDev = _this select 1;
   };
   
   if ((count _this) > 2) then
   {
      _bounds = _this select 2;
   };
};

// the polar form of the Box-Muller transform takes
// and maps two samples at a time, so we're going to 
// maintain a randomGauss-numbers buffer, to not waste
// any of those precious numbers :)
if (isnil "RUBE_randomGaussBUFFER") then
{
   RUBE_randomGaussBUFFER = [];
};


// generate new numbers?
if ((count RUBE_randomGaussBUFFER) == 0) then
{
   private ["_w", "_x1", "_x2"];
   _w = 1.0;
   
   while {_w >= 1.0} do
   {
      _x1 = (2.0 * (random 1.0)) - 1.0;
      _x2 = (2.0 * (random 1.0)) - 1.0;
      
      _w = (_x1 * _x1) + (_x2 * _x2);
   };
   
   _w = sqrt ((-2.0 * (ln _w)) / _w);
   
   RUBE_randomGaussBUFFER set [(count RUBE_randomGaussBUFFER), (_x1 * _w)];
   RUBE_randomGaussBUFFER set [(count RUBE_randomGaussBUFFER), (_x2 * _w)];
};

// pop number
_gauss = RUBE_randomGaussBUFFER call BIS_fnc_arrayPop;


// no standard normal distribution?
if (_stdDev != 1) then
{
   _gauss = _gauss * _stdDev;
};

if (_mean != 0) then
{
   _gauss = _gauss + _mean;
};

// limited range/bounds?
if ((count _bounds) > 0) then
{
   if (_gauss < (_bounds select 0)) then
   {
      _gauss = _bounds select 0;
   };
};

if ((count _bounds) > 1) then
{
   if (_gauss > (_bounds select 1)) then
   {
      _gauss = _bounds select 1;
   };
};

// return random gauss
_gauss