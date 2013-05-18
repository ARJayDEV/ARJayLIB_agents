/*
   Author:
    rübe
    
   Description:
    Returns an approximation for the complementary error function erfc(x) with 
    fractional error everywhere less than, hm, somewhere around 1E-005 maybe.
                      ...shouldn't matter too much anyway for our purposes.
    
    Algorithm from: Numerical Recipes in C; numbers chopped off (and rounded up
    if needed) to match the precision of Arma's numbers.
    
   Parameter(s):
      _this: scalar
      
   Returns:
      scalar
*/
private ["_x", "_z", "_t", "_ans"];

_x = _this;

_z = abs _x;
_t = 1.0 / (1.0 + (0.5 * _z));

_ans = _t * (exp (
   (-1 * _z * _z) - 1.26551 + _t * (1.00002 + _t * (0.37409 + _t * (0.09678 +
   _t * (-0.18629 + _t * (0.27887 + _t * (-1.13520 + _t * (1.48852 +
   _t * (-0.82215 + _t * 0.17087))))))))
));

if (_x < 0.0) then
{
   _ans = 2.0 - _ans;
};

_ans