/*
   Author:
    rübe

   Description:
    Calculates B(asis)-splines using de Boor's algorithm.
    Unless you pass your own knot-vector, we generate one
    for clamped, uniformly spaced knots.
    
    It uses O(n2) operations. Notice that the running time 
    of the algorithm depends only on degree n and not on 
    the number of points p.
    
    "Simplified, potentially faster variants of the de Boor 
     algorithm have been created but they suffer from 
     comparatively lower stability."
    
    (see http://en.wikipedia.org/wiki/De_Boor_algorithm )
    
   Note:
    -> while this algorithm is efficient in theory, all the
       recursion (or calls to _deBoor; even if it returns 
       zero a lot in case you use a lot of control points) 
       aren't managed that well by ArmA's engine.
       
       - TODO: implement something faster, for (2 <= k <=4) only.

   Parameter(s):
    _this: parameters (array of array [key (string), value (any)])
    
      - required:
      
         - "points" (array)
           - control points (or de Boor points)
           - array of scalar OR
             array of array's of scalar (such as an array of 
             positions)
           - minimum amount required: degree
         
         - "value" (scalar in [0,1])
           - input values will be mapped automatically to the 
             "knot's" or blend-functions range of [0,n-k+2]
             -- unless you don't pass along your own knot-vector...
      
      - optional:
      
         - "degree" (integer >= 2, default = 3)
           - 2: linear
           - 3: quadratic
           - 4: cubic 
           - n: I wouldn't really recommend higher degrees
      
         - "knots" (array of scalar)
           - knots m = n + k + 1, where n = amount of control points
             and k = degree
           - default: clamped, uniformly spaced knots 
           - mess with the knots at your own risk
    
   Returns:
    scalar OR array of scalar
*/

private ["_value", "_k", "_points", "_knots", "_n", "_m", "_lastEndPoint", "_dim", "_deBoor", "_s"];

_value = 0;

_k = 3;        // degree of basis functions
_points = [];  // set of (n + 1) control/de Boor points            
_knots = [];   // knot vector; set of (m + 1) knots

// read parameters
{
   switch (_x select 0) do
   {
      case "value": { _value = _x select 1; };
      case "degree": { _k = _x select 1; };
      case "points": { _points = _x select 1; };
      case "knots": { _knots = _x select 1; };
   };
} forEach _this;

_n = (count _points) - 1; // #control points
_m = _n + _k + 1; // #knots

/*
   we need to include the right endpoint into the support
   of the rightmost nontrivial N_{i,1}
   
   see: Carl de Boor, `B(asic)-Spline Basics`, S.15.
*/
_lastEndPoint = (_value >= 1);


// dimension of the given control points
_dim = 0;
if ((typeName (_points select 0)) == "ARRAY") then
{
   _dim = count (_points select 0);
};


// clamped, uniformly spaced knots
if ((count _knots) == 0) then
{
   // map input value range ([0,1]) to the range of the 
   // blending function ([0,n-k+2])
   _value = _value * (_n - _k + 2);

   for "_i" from 0 to (_m - 1) do
   {
      switch (true) do
      {
         case (_i < _k):  { _knots set [_i, 0]; };
         case (_i <= _n): { _knots set [_i, (_i - _k + 1)]; };
         default          { _knots set [_i, (_n - _k + 2)]; };
      };
   };
};

/*
if (_value == 0) then
{
   diag_log format["fn_bspline [k: %1, n: %2, m:%3]", _k, _n, _m];
   diag_log format[" - knots: %1", _knots];
};
*/


// de Boor's recursive blending function; N_{n,k}
// [n,k] => scalar
_deBoor = {
   private ["_v", "_n", "_k"];
   
   _v = 0;
   _n = _this select 0;
   _k = _this select 1;
   
   if (_k == 1) then
   {
      // N_{n,1}
      if (((_knots select _n) <= _value) && 
          (_value < (_knots select (_n + 1)))) then
      {
         _v = 1;
      } else
      {
         // we need to support the right endpoint too!
         if (_lastEndPoint && (_value == (_knots select (_n + 1)))) then
         {
            _v = 1;
         };
      };
      // else _v = 0;
   } else
   {
      // N_{n,k}
      private ["_a", "_b"];
      
      // we need to check for zero denominators; v/0 := 0
      _a = ((_knots select (_n + _k - 1)) == (_knots select _n)); 
      _b = ((_knots select (_n + _k)) == (_knots select (_n + 1)));
      
      switch (true) do
      {
         case (_a && _b):
         {
            // _v = 0;
         };
         case (_a):
         {
            _v =   ((_knots select (_n + _k)) - _value) 
                 / ((_knots select (_n + _k)) - (_knots select (_n + 1)))
                 * ([(_n+1), (_k-1)] call _deBoor);
         };
         case (_b):
         {
            _v =   (_value - (_knots select _n))
                 / ((_knots select (_n + _k - 1)) - (_knots select _n))
                 * ([_n, (_k-1)] call _deBoor);
         };
         default
         {
            _v = (  ((_knots select (_n + _k)) - _value) 
                  / ((_knots select (_n + _k)) - (_knots select (_n + 1)))
                  * ([(_n+1), (_k-1)] call _deBoor)
                 ) +
                 (  (_value - (_knots select _n))
                  / ((_knots select (_n + _k - 1)) - (_knots select _n))
                  * ([_n, (_k-1)] call _deBoor));
         };
      };
   };
      
   _v
};

_s = 0;

if (_dim == 0) then
{
   // scalar control points
   for "_i" from 0 to _n do
   {
      _s = _s + ((_points select _i) * ([_i, _k] call _deBoor));
   };
} else
{
   // multi-dim. (or positional) control points
   private ["_b"];
   
   _s = [];
   
   for "_j" from 0 to (_dim - 1) do
   {
      _s set [_j, 0];
   };
   
   for "_i" from 0 to _n do
   {
      _b = [_i, _k] call _deBoor;
      
      if (_b > 0) then
      {
         for "_j" from 0 to (_dim - 1) do
         {
            _s set [
               _j, 
               ((_s select _j) + (((_points select _i) select _j) * _b))
            ];
         };
      };
   };
};

_s