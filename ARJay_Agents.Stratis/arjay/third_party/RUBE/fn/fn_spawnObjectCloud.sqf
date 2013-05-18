/*
  Author: rübe
  
  Description:
  Spawns random objects from a given object-type-pool, placing them randomly near each other with regards to the objects bounding box.
  
  Parameter(s):
  _this select 0: position of the first object (position)
  _this select 1: array of object-types to be randomly spawned from (string OR array-of-strings)
  _this select 2: number of objects to be spawned 
  _this select 3: x/yspacing multiplier. (number OR array-of-two-numbers) 
                  - Optional. (obj bounding-box * multiplier) 
  _this select 4: sink/height multiplier. (number)
                  - Optional. Sinks/raises the object randomly (sinkMul * random 1; default = 0)
                    To sink an object randomly a little, set a little negative number here.
  _this select 5: random slopping (number from 0 to 1)
                  - Optional. The higher the number, the better the chance the object falls (eg. barrels)
  
  Returns:
  array-of-objects (returns all spawned objects)
*/
private ["_pos", "_objects", "_numObjects", "_res", "_distMulMin", "_distMulMax", "_sinkMul", "_slopeMul", "_slopeConst"];
_pos = _this select 0;
_objects = _this select 1;
if ((typeName _objects) != "ARRAY") then
{
   _objects = [(_this select 1)];
};
_numObjects = _this select 2;
_res = [];

// optional spacing multipliers
_distMulMin = 1;
_distMulMax = 1;
if ((count _this) > 3) then
{
   if ((typeName (_this select 3)) == "ARRAY") then
   {
      _distMulMin = (_this select 3) select 0;
      _distMulMax = (_this select 3) select 1;
   } else {
      _distMulMin = _this select 3;
      _distMulMax = _this select 3;
   };
};

// optional: sink multiplier
_sinkMul = 0;
if ((count _this) > 4) then
{
   _sinkMul = _this select 4;  
};

// optional: slope multiplier
_slopeMul = 0;
_slopeConst = 0;
if ((count _this) > 5) then
{
   _slopeMul = _this select 5; 
   _slopeConst = _slopeMul - (_slopeMul * _slopeMul);
    
};

private ["_previousType", "_x", "_y", "_type", "_obj", "_up", "_nv", "_j", "_r", "_box", "_boxP1", "_boxP2"];

_previousType = "";
_x = 0;
_y = 0;

// spawn the objects
for "_i" from 1 to _numObjects do
{
   _type = _objects call RUBE_randomSelect;
   _obj = createVehicle [_type, _pos, [], 0, "NONE"];
   _res = _res + [_obj];
   
   _obj setPos [(_pos select 0), (_pos select 1), (_sinkMul * (random 1))];
   _obj setDir (random 360);
   
   if (_slopeMul > 0) then
   {
      _up = vectorUp _obj;
      _nv = [0, 0, 0];

      _j = 0;
      {
         _r = (_slopeConst + random 1) * _slopeMul;
         if ((random 100) > 50) then 
         { 
            _r = _r * -1; 
         };
         _nv set [_j, tan ((_up select _j) + _r)];
         _j = _j + 1;
      } forEach _up;
      
      _obj setVectorUp _nv;
   };
   
   // we don't have to do this, if we spawn the same obj again
   if (_previousType != _type) then
   {
      _previousType = _type;
      
      _box = boundingBox _obj;
      _boxP1 = _obj modelToWorld (_box select 0);
      _boxP2 = _obj modelToWorld (_box select 1);
   
      _x = abs ((_boxP1 select 0) - (_boxP2 select 0));
      _y = abs ((_boxP1 select 1) - (_boxP2 select 1));
   };
   
   // calculate next pos
   _pos = [_pos, [(_x * _distMulMin), (_y * _distMulMin)], [(_x * _distMulMax), (_y * _distMulMax)]] call RUBE_randomizePos;
};

//
_res
