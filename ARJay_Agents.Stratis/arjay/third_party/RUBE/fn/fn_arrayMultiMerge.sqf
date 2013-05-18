/*
   Author:
    rübe
    
   Descriptions:
    merges multi-dimensional arrays (we don't alter the original arrays)
    
   Parameter(s):
    _this select 0: array (array of arrays of any)
    _this select n: array (array of arrays of any)
    
   Returns:
    multi-dimensional array
    
   Example:
   
    _array1 = [
       [1, 1, 1],
       [2, 2, 2],
       []
    ];
    
    _array2 = [
       [1, 0, 0],
       [],
       [0, 0, 1]
    ];
    
    _result = [_array1, _array2] call RUBE_arrayMultiMerge;
    
    // _result:
    // [[1, 1, 1, 1, 0, 0],
    //  [2, 2, 2],
    //  [0, 0, 1]
    // ]
*/

private ["_array", "_arraySize", "_m", "_i"];

// we make a copy of the initial array
_array = +_this select 0;


for "_m" from 1 to ((count _this) - 1) do
{
   _arraySize = count (_array);
   
      for "_i" from 0 to ((count (_this select _m)) - 1) do
      {
         if (_arraySize > _i) then
         {
            _array set [_i, ((_array select _i) + ((_this select _m) select _i))];
         } else {
            _array set [_i, ((_this select _m) select _i)];
         };
      };
};

_array