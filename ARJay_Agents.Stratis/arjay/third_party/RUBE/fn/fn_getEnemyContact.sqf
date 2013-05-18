/*
   Author:
    rübe
    
   Description:
    returns a list of enemy targets a group has made contact with.
    
   Parameter(s):
    _this: group (group)
    
    OR 
        
    _this select 0: group (group)
    _this select 1: range (scalar)
                    - optional, default = 1000
    _this select 2: cost threshold (scalar)
                       the sum of all targets subjective costs has to
                    reach this value befor any contact gets reported at
                    all. Note that sums might be HUGE numbers (e+006 and bigger)
                    - optional, default = 0
                    
   Returns:
    an empty array for no contacts OR
    [
       0: sum of contact costs
       1: contacts (array of contacts)
          - "contact" is what nearTargets returns, which is an array:
            [
               0: position (percieved/inaccurate!)
               1: type (percieved)
               2: side (percieved)
               3: subjective cost (positive for enemies, the more important/dangerous the higher)
               4: object
               5: position accuracy
            ]
       2: distance from leader to the nearest target (scalar)
       3: highest target(s) knownsAbout about a single unit from the group (scalar)
       4: men:   array of indices for contacts of type "man"
       5: cars:  array of indices for contacts of type "car"
       6: tanks: array of indices for contacts of type "tank"
       7: air:   array of indices for contacts of type "air"
       8: other: array of indices for contacts of type "other"
                 (such as motorcycles, ships, static weapons, ...)
    ]
    
    ^^ the indices of 4-8 are refering to the contacts returned in 1. So you may
    easily check, if some kind of contact has been made (tanks? only men? etc..)
*/

private ["_group", "_range", "_threshold", "_leader", "_units", "_side", "_targets", "_sum", "_beenSpotted", "_ka", "_ntDistance", "_dist", "_contact", "_kindOfMan", "_kindOfCar", "_kindOfTank", "_kindOfAir", "_kindOfOther", "_index"];

_group = grpNull;
_range = 1000;
_threshold = 0;

if ((typeName _this) == "ARRAY") then
{
   _group = _this select 0;
   if ((count _this) > 1) then
   {
      _range = _this select 1;
   };
   if ((count _this) > 2) then
   {
      _threshold = _this select 2;
   };
} else 
{
   _group = _this;
};


// make sure we have a group in case a unit
// got passed...
if ((typeName _group) != "GROUP") then
{
   _group = group _group;
};



_leader = leader _group;
_units = units _group;
_side = side _leader;
_targets = _leader nearTargets _range;
_sum = 0;
_beenSpotted = 0;
_ntDistance = 999999;
_contact = [];

_kindOfMan = [];
_kindOfCar = [];
_kindOfTank = [];
_kindOfAir = [];
_kindOfOther = [];

{
   // different side?
   if ((_x select 2) != _side) then
   {
      // not unknown!
      if (format["%1", (_x select 2)] != "UNKNOWN") then
      {
         // hostile side?
         if ((_side getFriend (_x select 2)) < 0.6) then
         {
            _sum = _sum + (_x select 3);
            _index = count _contact;
            _contact set [_index, _x];
            
            // distance
            _dist = (_x select 4) distance _leader;
            if (_dist < _ntDistance) then
            {
               _ntDistance = _dist;
            };
            
            // has anyone been spotted by these guys?
            for "_i" from 0 to ((count _units) - 1) do
            {
               _ka = (_x select 4) knowsAbout (_units select _i);
               if (_ka > _beenSpotted) then
               {
                  _beenSpotted = _ka;
               };
            };
            
            // register kind of contact
            switch (true) do
            {
               case (((_x select 4) isKindOf "Man")):  { _kindOfMan set [(count _kindOfMan), _index]; };
               case (((_x select 4) isKindOf "Car")):  { _kindOfCar set [(count _kindOfCar), _index]; };
               case (((_x select 4) isKindOf "Tank")): { _kindOfTank set [(count _kindOfTank), _index]; };
               case (((_x select 4) isKindOf "Air")):  { _kindOfAir set [(count _kindOfAir), _index]; };
               default
               {
                  _kindOfOther set [(count _kindOfOther), _index];
               };
            };
         };
      };
   };
} forEach _targets;

// no contacts made
if ((count _contact) == 0) exitWith
{
   []
};

// threshold not exceeded?
if (_sum < _threshold) exitWith
{
   []
};


// return enemy contact
[
   _sum,
   _contact,
   _ntDistance,
   _beenSpotted,
   _kindOfMan,
   _kindOfCar,
   _kindOfTank,
   _kindOfAir,
   _kindOfOther
]