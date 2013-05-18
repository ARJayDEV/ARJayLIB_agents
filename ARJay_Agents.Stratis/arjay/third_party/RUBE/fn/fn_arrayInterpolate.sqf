/*
   Author:
    rübe
   
   Description:
    multidimensional, piecewise linear interpolation over an array of arrays, 
    where the first value is the reference point ("on the x-axis") and the 
    subsequent values represent the function's  result vector/values ("on the 
    y-axis").
    
   Parameter(s):
    _this select 0: array of arrays as in:
                    [
                       [x0, a1, a2, a3, a4, ..., am],
                       [x1, b1, b2, b3, b4, ..., bm],
                       ...
                       [xn, s1, s2, s3, s4, ..., sm]
                    ]
                      \___/ \________________________/
                        n               m
                       ref.   values to interpolate
                       
    _this select 1: xp, point/position (scalar, s.t. x0 <= xp <= xn)
    
   Result:
    [xp, i1, i2, i3, i4, ..., im], where the first value is the given point/position,
                                   s.t. the indicies will match the given ones.
*/

private ["_data", "_p", "_intervals", "_index", "_values", "_c", "_v"];

_data = _this select 0;
_p = _this select 1;

_intervals = count _data;
_index = -1;

// oh you funny... :/
if (_intervals == 0) exitWith { [] };

// this one is actually completely fine :)
if (_intervals == 1) exitWith { (_data select 0) };


_values = count (_data select 0) - 1;

if (_values < 1) exitWith { _data};


// search interval
for "_i" from 0 to (_intervals - 2) do
{
   if (_p < ((_data select (_i + 1)) select 0)) exitWith
   {
      _index = _i;
   };
};

if (_index < 0) exitWith { [] };

// coefficient for the deltas
_c = ( _p - ((_data select _index) select 0) ) / 
     ( ((_data select (_index + 1)) select 0) - ((_data select _index) select 0) );

// interpolate vector
_v = [_p];

for "_i" from 1 to _values do
{
   _v set [
      _i,
      ((_data select _index) select _i) + 
      (_c * ( ((_data select (_index + 1)) select _i) - 
              ((_data select _index) select _i) ))
   ];
};

_v