/*
   Author:
    rübe

   Description:
    Calculates bézier curves. Functions of higher order are supported 
    (up to a degree of 20; 21 control points), though these are expensive, 
    so think about patching together lower order curves or try some
    B-splines or something...
   
    (see http://en.wikipedia.org/wiki/B%C3%A9zier_curve )
   
   Parameter(s):
    _this select 0: control points (array)
                    - array of scalar OR
                      array of array's of scalar (such as
                      an array of positions)
                    - up to 21 control points
                      
    _this select 1: position/function input value (scalar)
                    - a bezier curve is defined on the
                      interval [0,1].

   Returns:
    scalar OR array of scalar (point on the curve )
*/

private ["_points", "_value", "_n", "_m", "_dim", "_pascal", "_c", "_ci"];

_points = _this select 0;
_value = _this select 1;

_n = count _points;
_m = _n - 1;

_dim = 0;
if ((typeName (_points select 0)) == "ARRAY") then
{
   _dim = count (_points select 0);
};


// pascal's triangle; hardcoded since we do not wanna
// calculate binomial coefficients on the fly and we
// aren't going to use _that_ many points for our curves
// anyway...
/*
   TODO: maybe expand the table and make RUBE_binomial global,
         including a private fallback-function to calculate 
         more if really needed...
         
   TODO: And then..., this is already more than wasteful;
         we better implement b-splines or something :)
*/
_pascal = [
/*  0 */ [1],
/*  1 */ [1,1],
/*  2 */ [1,2,1],
/*  3 */ [1,3,3,1],
/*  4 */ [1,4,6,4,1],
/*  5 */ [1,5,10,10,5,1],
/*  6 */ [1,6,15,20,15,6,1],
/*  7 */ [1,7,21,35,35,21,7,1],
/*  8 */ [1,8,28,56,70,56,28,8,1],
/*  9 */ [1,9,36,84,126,126,84,36,9,1],
/* 10 */ [1,10,45,120,210,252,210,120,45,10,1],
/* 11 */ [1,11,55,165,330,462,462,330,165,55,11,1],
/* 12 */ [1,12,66,220,495,792,924,792,495,220,66,12,1],
/* 13 */ [1,13,78,286,715,1287,1716,1716,1287,715,286,78,13,1],
/* 14 */ [1,14,91,364,1001,2002,3003,3432,3003,2002,1001,364,91,14,1],
/* 15 */ [1,15,105,455,1365,3003,5005,6435,6435,5005,3003,1365,455,105,15,1],
/* 16 */ [1,16,120,560,1820,4368,8008,11440,12870,11440,8008,4368,1820,560,120,16,1],
/* 17 */ [1,17,136,680,2380,6188,12376,19448,24310,24310,19448,12376,6188,2380,680,136,17,1],
/* 18 */ [1,18,153,816,3060,8568,18564,31824,43758,48620,43758,31824,18564,8568,3060,816,153,18,1],
/* 19 */ [1,19,171,969,3876,11628,27132,50388,75582,92378,92378,75582,50388,27132,11628,3876,969,171,19,1],
/* 20 */ [1,20,190,1140,4845,15504,38760,77520,125970,167960,184756,167960,125970,77520,38760,15504,4845,1140,190,20,1]
];

// binomial coefficients aren't tabulated for that many points!
if (_m > (count _pascal)) exitWith
{
   // so... whatever. :)
   (_points select 0)
};



_c = 0;

if (_dim == 0) then
{
   // scalar control points
   for "_i" from 0 to _m do
   {
      _c = _c + ((_points select _i)  
               * (1 - _value)^(_m - _i)  
               * ((_pascal select _m) select _i)  
               * (_value ^ _i));
   };
} else
{
   // multi-dim. (or positional) control points
   _c = [];
   
   for "_j" from 0 to (_dim - 1) do
   {
      _ci = 0;
      
      for "_i" from 0 to _m do
      {
         _ci = _ci + (((_points select _i) select _j)  
                    * (1 - _value)^(_m - _i)  
                    * ((_pascal select _m) select _i)  
                    * (_value ^ _i));
      };
      
      _c set [
         _j,
         _ci
      ];
   };
};

_c