/*
   Author:
    rübe
    
   Description:
    Polynomial interpolation using Neville's algorithm.
    
    (see http://en.wikipedia.org/wiki/Polynomial_interpolation
         http://en.wikipedia.org/wiki/Neville%27s_algorithm )
    
    WARNING: Use functions of higher order at your own risk.
             Really. If you don't know what polynomial 
             interpolation looks like, you're most probably 
             better off using bezier curves or something. 
             Or else the mother of oscillation will come and
             get you, bwahahaha!
             
    (see http://en.wikipedia.org/wiki/Runge%27s_phenomenon )
   
   
   Parameter(s):
    _this select 0: samples/points (array of [x_n, f(x_n)])
    _this select 1: value of independent variable (x_i)
       
   Returns:
    scalar, f(x_i)
*/

private ["_data", "_value", "_n", "_i", "_j", "_poly"];

_data  = _this select 0;
_value = _this select 1;

_n = count _data;

_poly = [];

{
   _poly set [(count _poly), (_x select 1)];
} forEach _data;

for "_j" from 1 to (_n - 1) do
{
   for [{_i = _n - 1}, {_i >= _j}, {_i = _i - 1}] do
   {
      _poly set [
         _i,
         (( 
            (  (_value - ((_data select (_i - _j)) select 0))
             * (_poly select (_i)))
            - 
            (  (_value - ((_data select (_i)) select 0)) 
             * (_poly select (_i - 1)))
          ) / (
            ((_data select (_i)) select 0)
            - 
            ((_data select (_i - _j)) select 0)
         ))
      ];
   };
};

// return interpolated value
(_poly select (_n - 1))