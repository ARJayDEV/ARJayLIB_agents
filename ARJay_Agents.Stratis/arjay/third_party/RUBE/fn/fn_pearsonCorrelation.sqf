/*
   Author:
    rübe
    
   Description:
    Given two equally large sets, this function computes their correlation 
    coefficient r, the significance level at which the null hypothesis of 
    zero correlation is disproved, and Fisher's z, whose value can be used 
    in further statistical tests.
    
    Algorithm from: Numerical Recipes in C
   
   Parameter(s):
      _this select 0: set X (array of scalar)          
      _this select 1: set Y (array of scalar)

   Returns:
    array [
             0: correlation coefficient
             1: significance level
             2: Fisher's z
          ]
   
*/

private ["_setX", "_setY", "_n", "_tiny", "_ax", "_ay", "_sxx", "_syy", "_sxy", 
         "_r", "_z", "_p"];

_setX = _this select 0;
_setY = _this select 1;

_n = count _setX;
_tiny = 1E-005; // smallest number in Arma

// fint the means
_ax = 0;
_ay = 0;

for "_i" from 0 to (_n - 1) do
{
   _ax = _ax + (_setX select _i);
   _ay = _ay + (_setY select _i);
};

_ax = _ax / _n;
_ay = _ay / _n;


// compute the correlation coefficient
_sxx = 0;
_syy = 0;
_sxy = 0;

for "_i" from 0 to (_n - 1) do
{
   _xt = (_setX select _i) - _ax;
   _yt = (_setY select _i) - _ay;
   
   _sxx = _sxx + (_xt * _xt);
   _syy = _syy + (_yt * _yt);
   _sxy = _sxy + (_xt * _yt);
};

_r = _sxy / (sqrt ((_sxx * _syy) + _tiny));

// Fisher's z transformation
_z = 0.5 * (ln ((1.0 + _r + _tiny) / (1.0 - _r + _tiny)));

_p = ((abs (_z * (sqrt (_n - 1.0)))) / 1.41421 ) call RUBE_erfcc;

//
[_r, _p, _z]