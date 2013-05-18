/*
   Author:
    rübe
   
   Description:
    one dimensional random walk generator to model the weather, 
    the wall street and everything.
    
    This one is bounded, and returns values in the range of 
    [-1,1], which is accomplished by two sines on two independent 
    1D walkers. That's why we need to keep track of these two 
    numbers to generate the next step.  
    
    -> By applying some custom functions to the walker data 
       structure, you can model even more sorts of random walkers. 
       Steadily change the walkers base and you get an unbounded 
       one with strong bias. Overall/in the long term increasing 
       stocks anyone? Yay! :)
       
       Though you have to do such things outside/ontop of this, 
       since the modification of walker-settings is regarded as 
       external effect... mostly because such changes could happen 
       punctual (on certain events such as the black friday) and 
       not periodic. There could be multiple reasons, so a single
       function wouldn't catch them all...
   
   Note:
    This thing has been designed with lots of subsequent iter-
    ations/simulation steps in mind... Thus the idea is to init 
    an array as described below once and pass that one (respectively
    a pointer to it) repeatedly to this function, which modifies that 
    same array, over and over. Or in short:
    
         parameters data structure == returned data structure
    
    If you need to keep the samples/history, just save the current
    "position" after each step somewhere else.
    
   
   Data Structure:

      [
         0: current position/value [READ ONLY]  (scalar),
         1: age; in simulation steps/iterations (integer),
         2: settings                            (array)
            [
               0: intensity (base)     (scalar),
               1: intensity (random)   (scalar),
               2: base                 (scalar), 
               3: multiplier           (scalar), 
               4: abs. range           (boolean)
            ],
         3: independent, unbounded 1D walkers   (array)
            [
               0: osc1                 (scalar), 
               1: osc2                 (scalar)
            ]
      ]


   Parameter(s):

    _this select 0: current position/value              (scalar)
    
                    - will be set, after the function has been 
                      called.
                      
                    - READ ONLY: doesn't affect the computation 
                      of the next value, only the indep. private 
                      walkers do.
                       
                       
    _this select 1: age; in simulation steps/iterations (integer)
                    
                    - gets incremented at each step, so we do not
                      have to keep randomWalkers `running in sync`.
                      Instead keep a global simulation time and
                      simulate a randomWalker n-times as needed
                      only on demand...
                      
    
    _this select 2: settings                            (array)
    
                    [
                       0: intensity (base)     (scalar),
                       1: intensity (random)   (scalar),
                       2: base                 (scalar), 
                       3: multiplier           (scalar), 
                       4: abs. range           (boolean)
                    ]
                    
                    - intensity: this is the step-size for the two
                      independent 1D walkers, from which we take 
                      the sin. So a very low value will get you a 
                      very slow and smooth movement, while a large 
                      one will produce more chaos, faster. Keep this
                      value near 0 (or a multiple of 360) and don't 
                      even think about setting this to a multiple of 
                      90. A value of 20 (degree!) is probably too much
                      already.
                      
                      Keep in mind that the "graph" (or what you
                      picture/expect to get) also depends heavily on
                      the number of simulation steps beeing taken.
                      For example a randomWalker with an age of only
                      40 (simulation steps) won't get you far with a 
                      small intensity value.
                      
                      -> think about continously changing this value
                         to model slower<->faster changes, depending
                         on some external effects.
                         
                      The random part is a maximum amount that get's
                      added to the base intensity for each step.
                      
                      -> You get a much more natural output with a small
                         random intensity amount - especially with an 
                         already large base intensity.
                      
                      -> try an intensity without base part; just keep 
                         in mind, that the average step-size now will 
                         only be half as big as with a base part only
                         intensity.
                    
                    - transform base: base amount/value of the walker.
                      Depending on whether the range is absolute or not,
                      this is the minimum (or maximum with inversed 
                      multiplier), respectively the expected value E(x).
                      
                        - for a uniform randomWalker: base = 0
                        
                        -> you can model a *biased* walker by applying 
                           some function to this value at each simulation 
                           step. E.g. you could increase the base value
                           at each step for an infinitely raising value.
                      
                    - transform multiplier: range/variable amount
                    
                        - for a uniform randomWalker: multiplier = 1
                     
                    - transform abs. range: 
                      Set to true:  range = [ 0,1] * transform multiplier
                      Set to false: range = [-1,1] * transform multiplier
                      
                        - for a uniform randomWalker: abs. range = false
                        
    
    _this select 3: independent, unbounded 1D walkers   (array)
                    
                    [
                       1: osc1           (scalar), 
                       2: osc2           (scalar)
                    ]
                    
                    - we use two independend, unbiased one-dimensional 
                      walkers osc1 and osc2 s.t. the output will be:
                      
                        output = ((sin osc1) + (sin osc2)) * 0.5
                        
                      This produces random interferences and thus our
                      bounded random walk on [-1,1].
                      
                    - You need to tweak these values to set the intial
                      position of your random walker. Since we're dealing
                      with the sum of two sines, one osc delivers +/- 0.5
                      at max, s.t.:
                      
                        - if osc1=0,  osc2=0     =>    output = 0
                             osc1=90, osc2=0     =>    output = 0.5
                             osc1=0,  osc2=-90   =>    output = -0.5
                             osc1=90, osc2=90    =>    output = 1
                             osc1=90, osc2=-90   =>    output = 0
                      

   Example call:
   
    % _intensity = 3.5;
    % _walk = [0, 0, [_intensity, 0, 1, false], [0, 0]];
    % _history = [0];
    %
    % for "_i" from 0 to 499 do
    % {
    %    _walk call RUBE_randomWalk;
    %    _history set [_i, (_walk select 0)];
    % };
    
     -> And now go model some stocks and configure higher values
        with lower intensity, but higher initial-value (added to
        every item in _history), while lower value stocks have
        low inital values, but higher intensity...
        
        -> adjust the intensity of your stocks later on... :)
        -> depending on whether you use the full [-1,1] range
           or only [0,1], that initial value is a minimum value,
           below which your stocks cant drop (and then you could
           adjust that value too, if needed later on).
        
     -> And maybe chop off/floor some digits, before you put them
        into your path/history.


   Returns:
    array (we modify the passed array -> read (array select 0)
*/

private ["_d", "_r", "_osc1", "_osc2", "_base", "_mul", "_abs"];

_d    = (_this select 2) select 0; // base intensity (movement delta or step size)
_r    = (_this select 2) select 1; // random intensity

if (_r > 0) then
{
   _d = _d + (random _r);
};

_base = (_this select 2) select 2; // base amount
_mul  = (_this select 2) select 3; // range multiplier
_abs  = (_this select 2) select 4; // abs. range

_osc1 = (_this select 3) select 0; // indep. walker/oscillator 1
_osc2 = (_this select 3) select 1; // indep. walker/oscillator 2

if ((random 1.0) >= 0.5) then
{
   _osc1 = _osc1 + _d;
} else
{
   _osc1 = _osc1 - _d;
};

if ((random 1.0) >= 0.5) then
{
   _osc2 = _osc2 + _d;
} else
{
   _osc2 = _osc2 - _d;
};

// remember independent 1D walkers
(_this select 3) set [0, _osc1];
(_this select 3) set [1, _osc2];

// save result: two sines on two independent 1D walkers
if (_abs) then
{
   _this set [0, _base + (_mul * (abs (0.5 * ((sin _osc1) + (sin _osc2)))))];
} else {
   _this set [0, _base + (_mul * (0.5 * ((sin _osc1) + (sin _osc2))))];
};

// increment age
_this set [1, ((_this select 1) + 1)];

_this