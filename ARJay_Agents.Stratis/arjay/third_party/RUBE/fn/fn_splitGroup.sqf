/*
   Author:
    rübe
    
   Description:
    split a group/array of units into n (_split) sub-groups.
    array-of-array-of-units = [array-of-units, number-of-subgroups] call RUBE_splitGroup;
    
   Parameter(s):
    _this select 0: original group (group)
    _this select 1: number of desired new groups (int)
    
   Returns:
    array of new groups
*/
private ["_grp", "_split", "_leader", "_grunts", "_teams", "_n", "_i", "_t"];
_grp = _this select 0;
_split = _this select 1;

_leader = leader _grp;
_grunts = [];

// get soldiers under command (all except leader)
{
   if (_x != _leader) then
   {
      _grunts = _grunts + [_x];
   };
} forEach (units _grp);

// create teams
_teams = [];
for [{_i=0}, {_i<_split}, {_i=_i+1}] do
{
   _teams = _teams + [[]];
};

_n = count _grunts;

// fill teams
for [{_i=0}, {_i<_n}, {_i=_i+1}] do
{
   _t = _i % _split;
   //_teams[_t] = _teams[_t] + [(_grunts select _i)];
   _teams set [_t, ((_teams select _t) + [(_grunts select _i)])];
};

// return teams
_teams