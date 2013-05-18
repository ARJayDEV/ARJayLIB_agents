/*
   Author:
    rübe
    
   Description:
    distributes a given set of things (e.g. tasks/targets) equally 
    over a given number of "pots" (e.g. units/groups). In other words, 
    we take a list of things, and split it into N equal sublists.
    
   Example:
   
    input list: 
     [0, 1, 2, 3, 4, 5, 6, 7]
     
    number of pots: 
     3
     
    output:
     [
      [0, 3, 6],
      [1, 4, 7],
      [2, 5]
     ]
     
    
   Parameter(s):
    _this select 0: a list of anything (array)
    _this select 1: number of "pots" (integer)
    
   Return(s):
    an array of n arrays with things
*/

private ["_pots", "_i"];

_pots = [];

// only one pot... (or even less?!)
if ((_this select 1) < 1) exitWith
{
   (_this select 0)
};

// init pots
for "_i" from 0 to ((_this select 1) - 1) do
{
   _pots set [_i, []];
};

// no items
if ((count (_this select 0)) < 1) exitWith
{
   _pots
};

// fill pots
for "_i" from 0 to ((count (_this select 0)) - 1) do
{
   (_pots select (_i % (_this select 1))) set [
      (count (_pots select (_i % (_this select 1)))),
      ((_this select 0) select _i)
   ];
};

// return pots
_pots