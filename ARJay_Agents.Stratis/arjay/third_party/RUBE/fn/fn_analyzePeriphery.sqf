/*
   Author:
    rübe
    
   Descriptions:
    retrieves information about the landform/physical features 
    inside the periphery of a given position, evaluating data 
    from RUBE_samplePeriphery.
    
    In case we're on a peak, most samples will refine to/follow
    valleys and we're missing all peaks lower than we are. Thus
    we kick in a backscan in this situation, gathering some more
    samples to make those peaks visible. If we are the peak, then 
    you may think of this like an act of self-awareness...
    
    btw. I'd suggest to force backscan anyway for better results.
    
    Illustration:
    
     1) forward scan:              2) backward scan
         (rays going outwards)         (rays coming to us)
         
                                           .
                \                          |
                |                          | 
                |                          |
                |                         \
         <------O------>                   O 
                |                        \  /\
                |                       /     \  
                |                      /       \ 
                /                     /         \
                                     .           .
                                        
   
   Anyway... we gather these points and make a very simple cluster
   "analysis" (single-scan based on distance threshold) to merge
   samples that "mean" the same spot.
   
   Based on the forward scan only (rays around and away from us), 
   we calculate the average gradient for each compass direction and
   we can classify/label the landform either as:
   
    - peak 
    - topSlope
    - middleSlope
    - bottomSlope
    - valley
    - plain
    
   Be aware though that these label cant be interpreted too literally.
   Eg. a peak may be a tiny hill or a really big mountain we're
   upon. Slopes just means, that there are higher and lower places
   around us; more higher places equals bottomSlop, more lower ones
   topSlop (assuming that we're pretty much on top already).
   Just keep in mind that these labels are of strategic value and may
   not equal the impressions/images you may have in mind. (e.g. you may
   need to check the ASL of returned peaks to get a better picture)
   
    - We return the distinctive positions separated as arrays of:
      - peaks (higher than we are)
      - peaks (lower than we are, can only be found with backward scans)
      - plains (equal height to our position)
      - valleys 
    
    - as long as position refinement is on for peaks and valleys, 
      these positions really are distinctive.
      
    - the positions are not further sorted (or filtered), for there 
      are too many usefull options (distance, height, ...). But feel 
      free to do so yourself. (e.g. filter on distance and/or rel. dir
      and then sort per height-ASL; or find the nearest peak, that has
      a good spot for an aa-site, ...)


   Have a look at the description in RUBE_samplePeriphery for more
   detailed information about the sampling process and the position-
   refinement method.
   

   Parameter(s):
    _this: parameters (array of array [key (string), value (any)])
    
           - required:
           
             - "position" (position)
             
           - optional:
           
             - "backScanMode" (int 0 - 2)
               0: never
               1: auto. (only for position on top of a peak)
               2: always
               - default = 1
               
               
           - optional (samplePeriphery settings):  
               
             - "gradientThreshold" (scalar)
               max. gradient below terrain is considered flat
               - default = 2.0
               
             - "sampleSpacing" (array of scalar)
               sample positions in m taken on each ray
               - default = [75, 250, 500]
               
             - "sampleRange" ([start (scalar), end (scalar)])
               - default = [0, 360]  
               
             - "sampleSector" (scalar)
               360 / N = number of sample-rays
               - default = 10 degree (36 sample-rays à count(sampleSpacing) samples)
               
             - "refine" (int 0 - 2)
               0: no sample refinement
               1: refine peak and valleys
               2: refine peaks only (faster if you aren't interessted in
                  valleys anyway)
               - default = 1
               
             - "refinementSector" (scalar)
               360 / N = number of refinement sample-rays, where
               the most extreme is followed further (peak/valley)
               - default = 60 degree (6 sample-rays à one sample)
               
             - "refinementDistance" (scalar)
               length of refinement sample-rays in m. (or how exact peaks/
               valleys can be pinpointed)
               - default = 10
               
             - "debug" (boolean)

   Returns:
    [_landform, _periphery, _mountains, _plains, _hilltops, _valleys] where:
    
     - 0: landform (string) 
       in ["peak", "topSlope", "middleSlope", "bottomSlope", "valley", "plain"]
       
     - 1: periphery (avg. gradient per compass direction) (array of scalar, N=7) 
       0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SW, 6=W, 7=NW
     
     - 2: mountains (sample-array) peaks higher than we are
     - 3: plains (sample-array) considered flat to us (~same height)
     - 4: hilltops (sample-array) peaks lower than we are
     - 5: valleys (sample-array) valleys, where the terrain starts to raise again
     
       where "sample-array" is:
       [
          0: position,
          1: terrain-sample [type, sample-value] (see RUBE_sampleTerrain)
             - type may be: "sea", "coast", "meadow", "forest", "inhabited" or "undefined"
       ]
*/

private ["_debug", "_position", "_height", "_backScanMode", "_landformThreshold", "_clusterThreshold", "_sampleSpacing", "_sampleRange", "_sampleSector", "_gradientThreshold", "_refinementMode", "_refinementSector", "_refinementDistance"];

_debug = false;

_position = [0,0,0];
_height = 0;

_backScanMode = 1;
_landformThreshold = 0.7; // % needed to dominate/label the landform
_clusterThreshold = 50; // max. distance in m to be in the same cluster

// samplePerihpery variables
_sampleSpacing = [150, 300, 600];
_sampleRange = [0, 360];
_sampleSector = 10;
_gradientThreshold = 2.0;
_refinementMode = 1;
_refinementSector = 60; 
_refinementDistance = 10;

// read parameters
{
   switch (_x select 0) do
   {
      case "position": { _position = _x select 1; };
      case "backScanMode": { _backScanMode = _x select 1; };
      case "debug": { _debug = _x select 1; };
      
      // samplePeriphery variables
      case "gradientThreshold": { _gradientThreshold = _x select 1; };
      case "sampleRange": { _sampleRange = _x select 1; };
      case "sampleSpacing": { _sampleSpacing = _x select 1; };
      case "sampleSector": { _sampleSector = _x select 1; };
      
      case "refine": { _refinementMode = _x select 1; };
      case "refinementSector": { _refinementSector = _x select 1; };
      case "refinementDistance": { _refinementDistance = _x select 1; };
   };
} forEach _this;


_height = (_position call RUBE_getPosASL) select 2;

private ["_mountains", "_hilltops", "_plains", "_valleys", "_samples", "_n", "_f", "_i", "_landform", "_lfPlains", "_lfMountains", "_lfValleys", "_periphery", "_triangleBackScan", "_squareBackScan", "_clusterInsert"];

_mountains = 0; // peaks higher than we are
_hilltops = 0;  // peaks lower than we are (only with backscanning)
_plains = 0;
_valleys = 0;

_samples = [
   ["position", _position],
   ["refine", _refinementMode],
   ["sampleSpacing", _sampleSpacing],
   ["sampleRange", _sampleRange],
   ["sampleSector", _sampleSector],
   ["gradientThreshold", _gradientThreshold],
   ["refinementSector", _refinementSector],
   ["refinementDistance", _refinementDistance]
] call RUBE_samplePeriphery;

_n = count _samples;
_f = 1;
if (_n > 0) then
{
   _f = 1 / _n;
};

for "_i" from 0 to (_n - 1) do
{
   switch (true) do
   {
      case (((_samples select _i) select 0) > 0):
      {
         _mountains = _mountains + 1;
      };
      case (((_samples select _i) select 0) < 0):
      {
         _valleys = _valleys + 1;
      };
      default
      {
         _plains = _plains + 1;
      };
   };
};

// landform (relative to sample center)
/*
   [
      <string> (peak, topSlope, middleSlope, bottomSlope, plain, valley)
      flat,             0 == rough; 1 == flat/plains 
      hilltops/upper,   0 == no hills, 1 == 100% hills
      valleys/lower     0 == no valleys, 1 == 100% valleys
   ]
*/
// [label, plainsValue, mountainsValue, valleysValue]
_landform = "";

_lfPlains = _plains * _f;
_lfMountains = _mountains * _f;
_lfValleys = _valleys * _f;

// landform label
switch (true) do
{
   case (_lfPlains > _landformThreshold): { _landform = "plain"; };
   case (_lfMountains > _landformThreshold): { _landform = "valley"; };
   case (_lfValleys > _landformThreshold): { _landform = "peak"; };
   default 
   { 
      if ( (abs (_lfMountains - _lfValleys)) > 0.2) then
      {
         if (_lfValleys > _lfMountains) then
         {
            _landform = "topSlope";
         } else {
            _landform = "bottomSlope";
         };
      } else {
         _landform = "middleSlope";
      };
   };
};


// periphery (from the pov of the sample center)
// we calculate the average gradient of a 1/8 compass direction,
// we take all samples inside a 90 degree angle (thus, overlapping
// by 45 degree)
// 0=N, 1=NE, 2=E, ... NW=7
_periphery = [[],[],[],[],[],[],[],[]];
{
   if (((_x select 2) >= 315) || ((_x select 2) <= 45)) then
   {
      (_periphery select 0) set [(count (_periphery select 0)), (_x select 1)];
   };
   if (((_x select 2) >= 0) && ((_x select 2) <= 90)) then
   {
      (_periphery select 1) set [(count (_periphery select 1)), (_x select 1)];
   };
   if (((_x select 2) >= 45) && ((_x select 2) <= 135)) then
   {
      (_periphery select 2) set [(count (_periphery select 2)), (_x select 1)];
   };
   if (((_x select 2) >= 90) && ((_x select 2) <= 180)) then
   {
      (_periphery select 3) set [(count (_periphery select 3)), (_x select 1)];
   };
   if (((_x select 2) >= 135) && ((_x select 2) <= 225)) then
   {
      (_periphery select 4) set [(count (_periphery select 4)), (_x select 1)];
   };
   if (((_x select 2) >= 180) && ((_x select 2) <= 270)) then
   {
      (_periphery select 5) set [(count (_periphery select 5)), (_x select 1)];
   };
   if (((_x select 2) >= 225) && ((_x select 2) <= 315)) then
   {
      (_periphery select 6) set [(count (_periphery select 6)), (_x select 1)];
   };
   if (((_x select 2) >= 270) || ((_x select 2) <= 0)) then
   {
      (_periphery select 7) set [(count (_periphery select 7)), (_x select 1)];
   };
} forEach _samples;

// calculate avg. gradient
[
   _periphery, 
   {
      if ((count _this) == 0) exitWith
      {
         0
      };
      ([_this] call RUBE_average)
   }
] call RUBE_arrayMap;



// we need to take another set of samples if we're on
// a hilltop, to get a better picture (backscanMode auto)
if ((_backScanMode == 1) && (_landform == "peak")) then
{
   _backScanMode = 2;
};


// equilateral triangle backscan
// 3 periphery scans à 180 degree (+ (540 degree / _sampleSector) rays)
_triangleBackScan = {
   private ["_c", "_a", "_a2", "_ha", "_hb"];
   
   _c = (_sampleSpacing select ((count _sampleSpacing) - 1)) * 3.3;
   _a = (cos 30) * _c;
   _a2 = _a * 0.5;
   _ha = (tan 30) * _a2;
   _hb = (_a2 * (sqrt 3)) - _ha;
   
   [
      [
         [
            (_position select 0),
            ((_position select 1) + _hb)
         ],
         [90, 270]
      ],
      [
         [
            ((_position select 0) - _a2),
            ((_position select 1) - _ha)
         ],
         [-30, 150]
      ],
      [
         [
            ((_position select 0) + _a2),
            ((_position select 1) - _ha)
         ],
         [-150, 30]
      ]
   ]
};

// square backscan 
// 4 periphery scans à 90 degree (+ (360 degree / _sampleSector) rays)
_squareBackScan = {
   private ["_c"];
   
   _c = (_sampleSpacing select ((count _sampleSpacing) - 1)) * 1.2;
   
   [
      [
         [
            ((_position select 0) - _c),
            ((_position select 1) + _c)
         ],
         [90, 180]
      ],
      [
         [
            ((_position select 0) + _c),
            ((_position select 1) + _c)
         ],
         [180, 270]
      ],
      [
         [
            ((_position select 0) + _c),
            ((_position select 1) - _c)
         ],
         [270, 360]
      ],
      [
         [
            ((_position select 0) - _c),
            ((_position select 1) - _c)
         ],
         [0, 90]
      ]
   ]
};

if (_backScanMode == 2) then
{  
   {
   
      {
         // plains from backscans are meaningless
         if ((_x select 0) != 0) then
         {
            _samples set [(count _samples), _x];
         };
      } forEach ([
         ["position", (_x select 0)],
         ["refine", _refinementMode],
         ["sampleSpacing", _sampleSpacing],
         ["sampleRange", (_x select 1)],
         ["sampleSector", _sampleSector],
         ["gradientThreshold", _gradientThreshold],
         ["refinementSector", _refinementSector],
         ["refinementDistance", _refinementDistance]
      ] call RUBE_samplePeriphery);
      
   } forEach ([] call _triangleBackScan);
   // _triangleBackScan / _squareBackScan 
};


// find clusters (single scan)
// [position, value]
_clusterInsert = {
   private ["_index", "_n", "_i"];
   _index = -1;
   _n = count (_this select 1);
   
   for "_i" from 0 to (_n - 1) do
   {
      if ((((_this select 0) select 3) distance 
           (((_this select 1) select _i) select 0)) < _clusterThreshold) exitWith
      {
         _index = _i;
         switch (true) do
         {
            case (((_this select 0) select 0) > 0):
            {
               if ( (((_this select 0) select 3) select 2) >
                    ((((_this select 1) select _i) select 0) select 2)) then
               {
                  ((_this select 1) select _i) set [0, ((_this select 0) select 3)];
               };
            };
            case (((_this select 0) select 0) < 0):
            {
               if ( (((_this select 0) select 3) select 2) <
                    ((((_this select 1) select _i) select 0) select 2)) then
               {
                  ((_this select 1) select _i) set [0, ((_this select 0) select 3)];
               };
            };
         };

      };
   };
   
   if (_index < 0) then
   {
      (_this select 1) set [_n, 
         [
            ((_this select 0) select 3), 
            (((_this select 0) select 3) call RUBE_sampleTerrain)
         ]
      ];
   };
};

_mountains = []; // peaks higher than we are
_hilltops = [];  // peaks lower than we are (only with backscanning)
_plains = [];
_valleys = [];

{
   switch (true) do
   {
      case ((_x select 0) > 0): 
      {
         if (((_x select 3) select 2) > _height) then
         {
            [_x, _mountains] call _clusterInsert;
         } else {
            [_x, _hilltops] call _clusterInsert;
         };
      };
      case ((_x select 0) < 0): 
      {
         [_x, _valleys] call _clusterInsert;
      };
      default 
      {
         [_x, _plains] call _clusterInsert;
      };
   };
   
   if (_debug) then
   {
      [
         ["position", (_x select 3)],
         ["type", "mil_dot"],
         ["color", "ColorWhite"],
         ["size", 0.3]
      ] call RUBE_mapDrawMarker;
      if ((count _x) > 4) then
      {
         [
            ["start", (_x select 3)],
            ["end", (_x select 4)],
            ["color", "ColorWhite"],
            ["size", 3]
         ] call RUBE_mapDrawLine;
         [
            ["position", (_x select 4)],
            ["type", "mil_dot"],
            ["color", "ColorWhite"],
            ["size", 0.6]
         ] call RUBE_mapDrawMarker;
      };
   };
   
} forEach _samples;


// return
[_landform, _periphery, _mountains, _plains, _hilltops, _valleys]