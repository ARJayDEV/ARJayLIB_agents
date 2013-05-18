/*
   Author:
    rübe
    
   Description:
    generic implementation of the insertion sorting algorithm (that's one 
    of the simplest there is). The original list does NOT get altered.
    
    This sorting algorithm is very sensitive to the initial ordering of 
    the given list and thus only efficient for small/mostly-sorted 
    lists (we swap only adjacent elements!). Use another one for 
    large/totally unsorted lists. (e.g. RUBE_shellSort)
    
    >> Sedgewick says: "In short, insertion sort is the method of choice
       for `almost sorted` files with few inversions: for such files, it
       will outperform even the sophisticated methods [...]" 
       
       (e.g. if you have an already sorted list and you wanna add some 
       more to it...)
    
     - best case: O(n)
     - worst case: O(n^2)
    
   Parameter(s):
    _this select 0: the list to be sorted (array of any)
    _this select 1: sort value selector/calculator (string or code; optional)
                    - gets passed a list item, must return scalar
                    - if a string gets passed, we compile it first
                    
                    -> if the list does not consist of numbers but a complex 
                       data structure (like arrays), you may pass a simple
                       function, that accesses (or calculates) the "value" 
                       in this structure the list will be sorted on.
                       
                    -> to simply invert the sort order, pass {_this * -1} as
                       second parameter (for numbers).
                       
                       default sorting order is ASCENDING
               
   Example(s):
   
    // 1) sorting numbers

    _numbers = [8, 12, 1, 7, 8, 5];
    _sortedNumbers = [_numbers] call RUBE_insertSort
    
    // result: [1, 5, 7, 8, 8, 12]
    
    
    // 2) sorting data structures, calculating comp.-value
    //    and save the result in the given data structure too!

    _players = [
       // player, points, kills, killed
       [player1, 650, 5, 12],
       [player2, 40, 45, 27],
       [player3, 500, 19, 2],
       [player4, 370, 9, 1]
    ];
    // sort function
    _calculatePlayerTable = {
       private ["_points", "_kills", "_killed", "_score"];
       _points = _this select 1;
       _kills = _this select 2;
       _killed = _this select 3;
   
       _score = ((_points + (_kills * 5) - (_killed * 10)) * -1);
       _this set [4, (abs _score)];
   
       _score
    };
    _sortedPlayers = [_list, _calculatePlayerTable] call RUBE_insertSort;
    
    // result: [[player3, ..., 575], [player1, ..., 555], [player4, ..., 405], [player2, ..., 5]]
      
                       
   Returns:
    sorted list
*/

private ["_list", "_selectSortValue", "_item", "_i", "_j"];

_list = +(_this select 0);
_selectSortValue = { _this };

if ((count _this) > 1) then
{
   if ((typeName (_this select 1)) == "CODE") then
   {
      _selectSortValue = _this select 1;
   } else {
      _selectSortValue = compile (_this select 1);
   };
};

// insert sort
for "_i" from 1 to ((count _list) - 1) do
{
   _item = +(_list select _i);
   _j = 0;
   for [{_j = _i}, {_j > 0}, {_j = _j - 1}] do
   {
      if (((_list select (_j - 1)) call _selectSortValue) < (_item call _selectSortValue)) exitWith {};
      _list set [_j, (_list select (_j - 1))];
   };
   _list set [_j, _item];
};

_list