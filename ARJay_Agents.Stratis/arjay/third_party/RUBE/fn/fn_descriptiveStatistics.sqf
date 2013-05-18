/*
   Author:
    rübe
    
   Description:
    returns a bunch of measures (location and dispersion statistics) 
    to quantitatively describe a given set of samples.
    
   Note:
    you might wanna filter out zero-values (or outliers or ...) first, 
    maybe with RUBE_arrayFilter.
   
   Parameter(s):
    _this: samples (array of scalar)
    
      OR
      
    _this select 0: samples (array of scalar)
    _this select 1: known population measures (array, optional)
                    - [
                         0: population average/mean (scalar) OR false
                         1: population standard deviation (scalar) OR false
                    ]
    
   Returns:
    array: 
    [
      // 0: location statistics (central tendency)
      [
         0: average/mean
         1: median
         2: mode
      ],
      // 1: dispersion statistics
      [
         0: minimum
         1: maximum
         2: range
         3: variance*
         4: standard deviation*
         5: skewness*                  v > 0: |'''\____    v < 0: ____/'''|
         6: kurtosis                   y > 0: ___)'(___    y < 0: _(''''')_ 
      ]
    ]
    
    => the measures marked by a * are scalar - aslong as no known population
       measures are supplied. In case you pass known population measures,
       measures makred by a * are array [0: estimate, 1: population] where
       `estimate` is the measure based on the samples only and `population`
       is the exact measure (given you really know something about the 
       population)
*/

private ["_samples", "_sampleSize", "_populationAvg", "_populationSD", "_v", "_i",
         "_min", "_max", "_range", "_median", "_sum", "_sum2", "_psum",   
         "_zi", "_pzi", "_mode", "_modeN", "_currentMode", "_currentN", "_avg",
         "_variance", "_standardDeviation", "_skewness", "_skewnessC", "_kurtosis", 
         "_kurtosisC", "_mapMeasure"];

_samples = _this;
_sampleSize = count _samples;

_populationAvg = false;
_populationSD = false;

// check for "extended"/population parameters
if (_sampleSize == 2) then
{
   if (((typeName (_samples select 0)) == "ARRAY") &&
       ((typeName (_samples select 1)) == "ARRAY")) then
   {
      _samples = _this select 0;
      _sampleSize = count _samples;
      
      if ((count (_this select 1)) > 0) then
      {
         _populationAvg = (_this select 1) select 0;
      };
      
      if ((count (_this select 1)) > 1) then
      {
         _populationSD = (_this select 1) select 1;
      };
   };
};

// catch empty sample sets
if (_sampleSize == 0) exitWith 
{
   [
      // 0: location statistics (central tendency)
      [
         /* 0 */ 0, 
         /* 1 */ 0,
         /* 2 */ 0
      ],
      // 1: dispersion statistics
      [
         /* 0 */ 0, 
         /* 1 */ 0, 
         /* 2 */ 0,
         /* 3 */ 0,
         /* 4 */ 0,
         /* 5 */ 0,
         /* 6 */ 0
      ]
   ]
};

// catch sample sets with a single value
if (_sampleSize == 1) exitwith
{
   [
      // 0: location statistics (central tendency)
      [
         /* 0 */ (_samples select 0), 
         /* 1 */ (_samples select 0),
         /* 2 */ (_samples select 0)
      ],
      // 1: dispersion statistics
      [
         /* 0 */ (_samples select 0), 
         /* 1 */ (_samples select 0), 
         /* 2 */ 0,
         /* 3 */ 0,
         /* 4 */ 0,
         /* 5 */ 0,
         /* 6 */ 0
      ]
   ]
};



// sort samples, ascending
_samples = [_samples] call RUBE_shellSort;

// select min, max, _range and median
_min = _samples select 0;
_max = _samples select (_sampleSize -1);
_range = _max - _min;
_i = floor ((_sampleSize -1) * 0.5);
_median = _samples select _i;
if ((_sampleSize % 2) == 0) then
{
   _median = (_median + (_samples select (_i + 1))) * 0.5;
};

// calculate mode and average
_sum = _samples select 0;
_mode = _samples select 0;
_modeN = 1;
_currentMode = _samples select 0;
_currentN = 1;

for "_i" from 1 to (_sampleSize - 1) do
{
   _v = _samples select _i;
   
   // avg
   _sum = _sum + _v;
   
   // mode
   if (_currentMode == _v) then
   {
      _currentN = _currentN + 1;
   } else
   {
      _currentN = 1;
   };
   
   _currentMode = _v;
   
   if (_currentN >= _modeN) then
   {
      _mode = _currentMode;
      _modeN = _currentN;
   };
};

_avg = _sum / _sampleSize;

// calculate variance and standard deviation
_sum = 0;
_psum = 0;

if ((typeName _populationAvg) == "SCALAR") then
{
   for "_i" from 0 to (_sampleSize - 1) do
   {
      _sum = _sum + ((_samples select _i) - _avg)^2;
      _psum = _psum + ((_samples select _i) - _populationAvg)^2;
   };
} else
{
   for "_i" from 0 to (_sampleSize - 1) do
   {
      _sum = _sum + ((_samples select _i) - _avg)^2;
   };
};

// sample standard deviation
// - tends to overestimate the standard deviation
// - but a better, unbiased estimator for the variance
_variance = [
   ((1/(_sampleSize - 1)) * _sum), // estimate
   false                           // exact/population
];
_standardDeviation = [
   (sqrt (_variance select 0)),    // estimate
   false                           // exact/population
];

if ((typeName _populationAvg) == "SCALAR") then
{
   _variance set [1, ((1/_sampleSize) * _psum)];
   _standardDeviation set [1, (sqrt (_variance select 1))];
   
   if ((typeName _populationSD) != "SCALAR") then
   {
      _populationSD = _standardDeviation select 1;
   };
};

// in case we're given a population st. dev., but no population avg.
if (((typeName _populationSD) == "SCALAR") && ((typeName _populationAvg) != "SCALAR")) then 
{
   _populationAvg = _avg;
};



// calculate skewness and kurtosis
_sum = 0;
_psum = 0;
_sum2 = 0;

if ((typeName _populationSD) == "SCALAR") then
{

   if ( !( ((_standardDeviation select 0) == 0) || (_populationSD == 0) )) then
   {
      for "_i" from 0 to (_sampleSize - 1) do
      {
         _zi = ((_samples select _i) - _avg) / (_standardDeviation select 0);
         _pzi = ((_samples select _i) - _populationAvg) / _populationSD;
         
         // skewness
         _sum = _sum + (_zi)^3;
         _psum = _psum + (_pzi)^3;
         
         // kurtosis
         _sum2 = _sum2 + (_zi)^4;
      };
   };
} else
{
   if (!((_standardDeviation select 0) == 0)) then
   {
      for "_i" from 0 to (_sampleSize - 1) do
      {
         _zi = ((_samples select _i) - _avg) / (_standardDeviation select 0);

         // skewness
         _sum = _sum + (_zi)^3;
         
         // kurtosis
         _sum2 = _sum2 + (_zi)^4;
      };
   };
};

_kurtosisC = (1 / _sampleSize);
_skewnessC = _kurtosisC;

// should be a better estimate (only for sample skewness!)
if (_sampleSize > 2) then
{
   _skewnessC = (_sampleSize / ((_sampleSize - 1) * (_sampleSize - 2)));
};

_skewness = [
   (_skewnessC * _sum), 
   false
];

_kurtosis = (_kurtosisC * _sum2) - 3;

if ((typeName _populationSD) == "SCALAR") then
{
   _skewness set [1, (_kurtosisC * _psum)]; // population skewness!
};



// return "estimate" or ["estimate", "population"] if population measures are given
_mapMeasure = {
   if ((typeName (_this select 1)) != "SCALAR") exitWith
   {
      (_this select 0)
   };
   
   _this
};




// return
[
   // 0: location statistics (central tendency)
   [
      /* 0 */ _avg, 
      /* 1 */ _median,
      /* 2 */ _mode
   ],
   // 1: dispersion statistics
   [
      /* 0 */ _min, 
      /* 1 */ _max, 
      /* 2 */ _range,
      /* 3 */ (_variance call _mapMeasure),
      /* 4 */ (_standardDeviation call _mapMeasure),
      /* 5 */ (_skewness call _mapMeasure),            // v > 0: |'''\____    v < 0: ____/'''|
      /* 6 */ _kurtosis                                // y > 0: ___)'(___    y < 0: _(''''')_ 
   ]
]