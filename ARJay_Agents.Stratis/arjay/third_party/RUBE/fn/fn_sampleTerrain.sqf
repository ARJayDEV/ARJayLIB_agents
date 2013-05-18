/*
   Author:
    rübe
    
   Description:
    samples the terrain at a given position with the use
    of a terrain-/environment-expression (see selectBestPlaces).
    
    The sampled value can't be interpreted with a 100% hit rate,
    but it works fine in most cases.
    
    -> Returned terrain types/labels can be:
       - sea         (v < -922))
       - coast       (v > -922 && v < 0)
       - meadow      (v > 0  && v < 50)
       - forest      (v > 50 && v < 200)
       - inhabited   (v > 200)
       
       - undefined   (v == 0)
       
       -> undefined is most likely "out-of-map"
       -> value of exactly 1 may be outOfMap too!
       -> value of exactly 110 is 100% forest (100 forest + 10 trees)  
       
       -> inhabited coast areas/harbours are a bit problematic, 
          e.g. inhabited may be identified as meadow due to the sea
          penalty, and sea (inside the harbour) may be reported as
          coast due to the houses bonus, etc..    
    
   Parameter(s):
    _this: sample position (2d or 3d position)
    
   Returns:
    array [type-string, sample-value]
*/

private ["_sample", "_sampleValue", "_sampleType"];

_sample = selectBestPlaces [
   _this, // sample position
   6, // radius
   "(1000 * houses) + (100 * forest) + (10 * trees) + (1 * meadow) - (1000 * sea)", // expression
   3, // precision
   1 // sourcesCount
];

if ((count _sample) < 1) exitWith
{
   ["undefined", 0]
};

_sampleValue = (_sample select 0) select 1;
_sampleType = "meadow";

switch (true) do
{
   case (_sampleValue > 200):  { _sampleType = "inhabited"; };
   case (_sampleValue > 50):   { _sampleType = "forest"; };
   case (_sampleValue < -992): { _sampleType = "sea"; };
   case (_sampleValue < 0):    { _sampleType = "coast"; };
   case (_sampleValue == 0):   { _sampleType = "undefined"; }; // out of map/end of world
};

// return sample
[_sampleType, _sampleValue]