/*
   Author:
    rübe
    
   Description:
    checks an item against a list of items with a 
    custom function, returning true only if all
    checks are passed (or if the test cases array 
    is empty).
   
    Mul-ti-pass. Muuuul-ti-paaaaaas. 
     Get it? :D
       
   Parameter(s):
    _this select 0: test candidate/single item (any)
    _this select 1: test cases/list of items (array of any)
    _this select 2: the test (code)
                    - gets passed:
                      - _this select 0: single item
                      - _this select 1: a single item of the list
                    - has to return boolean
   
   Returns:
    boolean
*/

private ["_candidate", "_testcases", "_test", "_pass"];

_candidate = _this select 0;
_testcases = _this select 1;
_test = _this select 2;

_pass = true;

{
   if (!([_candidate, _x] call _test)) exitWith
   {
      _pass = false;
   };
} forEach _testcases;

_pass