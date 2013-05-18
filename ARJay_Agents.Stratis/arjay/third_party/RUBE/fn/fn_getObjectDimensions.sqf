/*
   Author:
    rübe
   
   Description:
    returns the objects size/area (2D) and a position-offset to center it,
    relying on a set of measurments instead of the bounding box (which
    requires an object to be passed to it)
    
    -> only some objects will return a 3D size (such as tables and some walls)
       Feel free to complete as needed.
       
    -> measurements are taken generally as tight as possible, 
       without any spacing...
       
    -> failsafe: incase the demanded object isn't listed, we temp. create
       it to take the boundingBox/-Center and delete it again...
    
   Parameter(s):
    _this: object class (string)
    
   Returns:
    array of [
      [x, y, (z)], 
      [offset-x, offset-y, offset-z]
    ]
    
   Notes:
    - on bounding boxes: since we can't rely on the object's bounding boxes, 
    we had to measure the available objects manually. So you should ensure
    that the objects in question are indeed listed below before you use
    this function.
    
    - on measurment: we tried to take the area as tight as possible. Any
    desired margin has to be added later...
    
    - feel free to extend the list below (for editor upgrade objects or 
    arrowhead... whatever)
    
*/

private ["_objSize", "_objOffset", "_obj", "_box", "_center"];

_objSize   = [0, 0];
_objOffset = [0, 0, 0];

switch (_this) do 
{ 
   // objects
   case "Barrels":                        { _objSize = [1.6, 1.6]; };
   case "HeliH":                          { _objSize = [12.5, 12.5]; };
   case "HeliHCivil":                     { _objSize = [12.5, 12.5]; };
   case "HeliHRescue":                    { _objSize = [12.5, 12.5]; };
   case "Land_Ind_BoardsPack1":           { _objSize = [1.5, 3]; };
   case "Land_Ind_BoardsPack2":           { _objSize = [1.5, 3]; };
   case "Land_Ind_Timbers":               { _objSize = [3, 9]; _objOffset = [-0.25, 4.55, 0]; };
   case "Land_Toilet":                    { _objSize = [1.5, 1.5]; };
   case "Misc_palletsfoiled":             { _objSize = [1.6, 1.6]; };
   case "Misc_palletsfoiled_heap":        { _objSize = [3.1, 4.6]; _objOffset = [-0.75, 0, 0]; };
   case "Misc_concrete_High":             { _objSize = [2.44, 3.37]; };
   case "Misc_TyreHeap":                  { _objSize = [3.3, 2.5]; };
   case "PowerGenerator":                 { _objSize = [0.93, 2.2]; };
   case "Axe_woodblock":                  { _objSize = [1.21, 0.43]; };
   case "Barrel1":                        { _objSize = [0.623, 0.623]; };
   case "Barrel4":                        { _objSize = [0.623, 0.623]; };
   case "Barrel5":                        { _objSize = [0.623, 0.623]; };
   case "Land_Barrel_empty":              { _objSize = [0.537, 0.537]; };
   case "Land_Barrel_sand":               { _objSize = [0.537, 0.537]; };
   case "Land_Barrel_water":              { _objSize = [0.537, 0.537]; };
   case "Land_Campfire":                  { _objSize = [1.6, 1.6]; };
   case "Land_Campfire_burning":          { _objSize = [1.6, 1.6]; };
   case "Land_Fire":                      { _objSize = [0.9, 0.9]; };
   case "Land_Fire_burning":              { _objSize = [0.9, 0.9]; };
   case "Land_Fire_barrel":               { _objSize = [0.623, 0.623]; };
   case "Land_Fire_barrel_burning":       { _objSize = [0.623, 0.623]; };
   case "Land_Ind_TankSmall":             { _objSize = [6.0, 2.5]; };
   case "Land_Ind_TankSmall2":            { _objSize = [6.0, 2.5]; };
   case "Land_Misc_Scaffolding":          { _objSize = [4.2, 12.0]; _objOffset = [0.8, -0.2, 0]; };
   case "Notice_board":                   { _objSize = [1.1, 0.7]; };
   case "Paleta1":                        { _objSize = [1.5, 1.5]; _objOffset = [-0.4, -0.35, 0]; };
   case "Paleta2":                        { _objSize = [1.45, 1.7]; _objOffset = [-0.2, -1.0, 0]; };
   case "Pile_of_wood":                   { _objSize = [0.7, 2.8]; _objOffset = [0.1, 1.4, 0]; };
   case "Satelit":                        { _objSize = [1.3, 1.8]; };
   case "Land_CncBlock":                  { _objSize = [2.6, 0.364]; };
   case "Land_CncBlock_D":                { _objSize = [2.615, 0.36]; };
   case "Land_CncBlock_Stripes":          { _objSize = [2.6, 0.364]; };
   case "Haystack":                       { _objSize = [18, 6]; };
   case "Fence_Ind":                      { _objSize = [3.0, 0.525]; };
   case "Fence_Ind_long":                 { _objSize = [9.0, 0.385]; _objOffset = [-3, 0, 0]; };
   case "Fence_corrugated_plate":         { _objSize = [4.0, 0.1, 1.9]; };
   case "Garbage_can":                    { _objSize = [0.62, 0.62]; _objOffset = [0.34, 0, 0]; };
   case "Garbage_container":              { _objSize = [1.2, 1.48]; _objOffset = [0, -0.75, 0]; };
   case "Haystack_small":                 { _objSize = [1.53, 1.58]; };
   case "Land_Hlidac_budka":              { _objSize = [6.5, 3.5]; };
   case "Land_Misc_Cargo2E":              { _objSize = [2.5, 6.25]; _objOffset = [0, 0.1, 0]; };
   case "Land_Misc_GContainer_Big":       { _objSize = [6.35, 3.18]; };
   case "Land_Misc_deerstand":            { _objSize = [3.6, 3.6]; _objOffset = [0.3, 0, 0]; };
   case "Land_Pneu":                      { _objSize = [1.1, 1.1]; };
   case "Land_Shed_wooden":               { _objSize = [4.8, 3.4]; _objOffset = [-2.4, 0, 0]; };
   case "Land_psi_bouda":                 { _objSize = [1.3, 1.1]; _objOffset = [-0.1, 0.1, 0]; };
   case "Sr_border":                      { _objSize = [3.4, 5.8]; };
   case "ZavoraAnim":                     { _objSize = [9.3, 0.4]; _objOffset = [3.25, 0, 0]; };

   // military
   case "ACamp":                          { _objSize = [2.9, 3.1]; };
   case "Barrack2":                       { _objSize = [6, 12]; };
   case "Camp":                           { _objSize = [6.5, 7.5]; _objOffset = [1, 0, 0]; };
   case "CampEast":                       { _objSize = [10.5, 12.75]; };
   case "Land_A_tent":                    { _objSize = [2.7, 4.8]; };
   case "Land_Antenna":                   { _objSize = [5.75, 4.5]; };
   case "Land_BarGate2":                  { _objSize = [3.73, 0.2]; _objOffset = [0.01, 0, 0]; };
   case "Land_CamoNetB_EAST":             { _objSize = [16, 16]; };
   case "Land_CamoNetB_NATO":             { _objSize = [16, 16]; };
   case "Land_CamoNetVar_EAST":           { _objSize = [14.5, 9]; };
   case "Land_CamoNetVar_NATO":           { _objSize = [14.5, 9]; };
   case "Land_CamoNet_EAST":              { _objSize = [14.5, 8.4]; };
   case "Land_CamoNet_NATO":              { _objSize = [14.5, 8.4]; };
   case "Land_GuardShed":                 { _objSize = [2.8, 2.1]; };
   case "Land_tent_east":                 { _objSize = [13, 8]; };
   case "MASH":                           { _objSize = [6.5, 7.5]; _objOffset = [1, 0, 0]; };
   case "Misc_Backpackheap":              { _objSize = [1.75, 1.75]; };
   case "Misc_Cargo1B_military":          { _objSize = [2.7, 6.6]; };
   case "Misc_Cargo1Bo_military":         { _objSize = [3.6, 10]; };
   case "Misc_cargo_cont_net1":           { _objSize = [1.6, 1.8]; };
   case "Misc_cargo_cont_net2":           { _objSize = [3.65, 3.65]; _objOffset = [-1, -1, 0]; };
   case "Misc_cargo_cont_net3":           { _objSize = [3.36, 4.96]; _objOffset = [0.8, 0, 0]; };
   case "Misc_cargo_cont_small":          { _objSize = [2.48, 2.75]; };
   case "Misc_cargo_cont_small2":         { _objSize = [1.91, 2.14]; };
   case "Misc_cargo_cont_tiny":           { _objSize = [1.72, 1.72]; };
   case "PowGen_Big":                     { _objSize = [4, 9.15]; };
   
   // fortification
   case "Fort_Crate_wood":                { _objSize = [1.0, 1.0]; };
   case "Land_HBarrier1":                 { _objSize = [1.3, 1.62]; };
   case "Land_HBarrier3":                 { _objSize = [3.55, 1.8]; _objOffset = [-1.07, 0, 0]; };
   case "Land_HBarrier5":                 { _objSize = [5.6, 1.8]; _objOffset = [-2.25, 0, 0]; };  
   case "Land_HBarrier_large":            { _objSize = [8.4, 2.25]; _objOffset = [0, -0.1, 0]; };
   case "Fort_RazorWire":                 { _objSize = [8.46, 2.1]; _objOffset = [-1.5, 0, 0]; };
   case "Hedgehog":                       { _objSize = [1.95, 1.85]; };
   case "Hhedgehog_concrete":             { _objSize = [9.12, 2.21]; };
   case "Hhedgehog_concreteBig":          { _objSize = [8.55, 3.33]; };
   case "Land_BagFenceLong":              { _objSize = [3.00, 0.5]; };
   case "Land_BagFenceShort":             { _objSize = [1.78, 0.47]; };
   case "Land_fort_bagfence_long":        { _objSize = [3.0, 1.0]; };
   case "Land_fort_bagfence_corner":      { _objSize = [3.1, 3.1]; _objOffset = [-0.213, -0.655]; };
   case "Fort_Barricade":                 { _objSize = [11, 3.0]; };
   case "Fort_EnvelopeBig":               { _objSize = [6.4, 1.5]; _objOffset = [0, -0.4, 0]; };
   case "Fort_EnvelopeSmall":             { _objSize = [2.6, 3.2]; };
   case "Fort_Nest_M240":                 { _objSize = [3.6, 3.6]; _objOffset = [0.6, 0.2, 0]; };
   case "Land_Fort_Watchtower":           { _objSize = [6.0, 9.6]; _objOffset = [0, -0.7, 0]; };
   case "Land_fort_artillery_nest":       { _objSize = [16, 11]; _objOffset = [0, 3, 0]; };
   case "Land_fort_rampart":              { _objSize = [9.89, 3.4]; _objOffset = [0, 1.4, 0]; };
   case "Land_fort_bagfence_round":       { _objSize = [6.0, 2.6]; _objOffset = [0, 1.1, 0]; };
   case "Land_fortified_nest_big":        { _objSize = [8.9, 9.2]; _objOffset = [-0.4, -2.15, 0]; };
   case "Land_fortified_nest_small":      { _objSize = [4.2, 4]; _objOffset = [-0.55, -0.35, 0]; };
   
   // static weapons
   case "D30_RU":                         { _objSize = [7.4, 8.0, 2.5]; };
   case "D30_Ins":                        { _objSize = [7.4, 8.0, 2.5]; };
   case "D30_CDF":                        { _objSize = [7.4, 8.0, 2.5]; };
   case "M119":                           { _objSize = [4.5, 8.0, 2.5]; };
   
   case "2b14_82mm":                      { _objSize = [0.55, 0.9]; _objOffset = [-0.05, -0.25]; };
   case "2b14_82mm_CDF":                  { _objSize = [0.55, 0.9]; _objOffset = [-0.05, -0.25]; };
   case "2b14_82mm_GUE":                  { _objSize = [0.55, 0.9]; _objOffset = [-0.05, -0.25]; };
   case "2b14_82mm_INS":                  { _objSize = [0.55, 0.9]; _objOffset = [-0.05, -0.25]; };
   case "2b14_82mm_TK_EP1":               { _objSize = [0.55, 0.9]; _objOffset = [-0.05, -0.25]; };
   case "2b14_82mm_TK_GUE_EP1":           { _objSize = [0.55, 0.9]; _objOffset = [-0.05, -0.25]; };
   case "2b14_82mm_TK_INS_EP1":           { _objSize = [0.55, 0.9]; _objOffset = [-0.05, -0.25]; };
   
   case "AGS_CDF":                        { _objSize = [0.75, 1.3]; _objOffset = [0, 0.15]; };
   case "AGS_Ins":                        { _objSize = [0.75, 1.3]; _objOffset = [0, 0.15]; };
   case "AGS_RU":                         { _objSize = [0.75, 1.3]; _objOffset = [0, 0.15]; };
   case "AGS_TK_EP1":                     { _objSize = [0.75, 1.3]; _objOffset = [0, 0.15]; };
   case "AGS_TK_INS_EP1":                 { _objSize = [0.75, 1.3]; _objOffset = [0, 0.15]; };
   case "AGS_TK_GUE_EP1":                 { _objSize = [0.75, 1.3]; _objOffset = [0, 0.15]; };
   case "AGS_UN_EP1":                     { _objSize = [0.75, 1.3]; _objOffset = [0, 0.15]; };
   
   case "DSHKM_CDF":                      { _objSize = [0.8, 1.55]; _objOffset = [0, -0.15]; };
   case "DSHKM_Gue":                      { _objSize = [0.8, 1.55]; _objOffset = [0, -0.15]; };
   case "DSHKM_Ins":                      { _objSize = [0.8, 1.55]; _objOffset = [0, -0.15]; };
   case "DSHKM_TK_GUE_EP1":               { _objSize = [0.8, 1.55]; _objOffset = [0, -0.15]; };
   case "DSHKM_TK_INS_EP1":               { _objSize = [0.8, 1.55]; _objOffset = [0, -0.15]; };
   
   case "DSHkM_Mini_TriPod":              { _objSize = [0.7, 1.55]; _objOffset = [0, 0.15]; };
   case "DSHkM_Mini_TriPod_CDF":          { _objSize = [0.7, 1.55]; _objOffset = [0, 0.15]; };
   case "DSHkM_Mini_TriPod_TK_GUE_EP1":   { _objSize = [0.7, 1.55]; _objOffset = [0, 0.15]; };
   case "DSHkM_Mini_TriPod_TK_INS_EP1":   { _objSize = [0.7, 1.55]; _objOffset = [0, 0.15]; };
   
   case "Igla_AA_pod_East":               { _objSize = [1.5, 1.8]; _objOffset = [0, 0.1]; };
   case "Igla_AA_pod_TK_EP1":             { _objSize = [1.5, 1.8]; _objOffset = [0, 0.1]; };
   
   case "KORD":                           { _objSize = [1.05, 2.4]; _objOffset = [0, -0.05]; };
   case "KORD_TK_EP1":                    { _objSize = [1.05, 2.4]; _objOffset = [0, -0.05]; };
   case "KORD_UN_EP1":                    { _objSize = [1.05, 2.4]; _objOffset = [0, -0.05]; };
   
   case "KORD_high":                      { _objSize = [1.15, 2.35]; _objOffset = [0, -0.25]; };
   case "KORD_high_TK_EP1":               { _objSize = [1.15, 2.35]; _objOffset = [0, -0.25]; };
   case "KORD_high_UN_EP1":               { _objSize = [1.15, 2.35]; _objOffset = [0, -0.25]; };
   
   case "M252":                           { _objSize = [0.8, 1.1]; _objOffset = [-0.1, -0.3]; };
   case "M252_US_EP1":                    { _objSize = [0.8, 1.1]; _objOffset = [-0.1, -0.3]; };
   
   case "M2HD_mini_TriPod":               { _objSize = [1.15, 1.8]; _objOffset = [0, -0.25]; };
   case "M2HD_mini_TriPod_US_EP1":        { _objSize = [1.15, 1.8]; _objOffset = [0, -0.25]; };
   
   case "M2StaticMG":                     { _objSize = [1.15, 1.85]; _objOffset = [0, -0.2]; };
   case "M2StaticMG_US_EP1":              { _objSize = [1.15, 1.85]; _objOffset = [0, -0.2]; };

   case "MK19_TriPod":                    { _objSize = [1.15, 1.35]; _objOffset = [0, 0.3]; };
   case "MK19_TriPod_US_EP1":             { _objSize = [1.15, 1.35]; _objOffset = [0, 0.3]; };
   
   case "Metis":                          { _objSize = [0.4, 1]; _objOffset = [0, 0.05]; };
   case "Metis_TK_EP1":                   { _objSize = [0.4, 1]; _objOffset = [0, 0.05]; };
   
   case "SPG9_CDF":                       { _objSize = [0.6, 2.05]; };
   case "SPG9_Gue":                       { _objSize = [0.6, 2.05]; };
   case "SPG9_Ins":                       { _objSize = [0.6, 2.05]; };
   case "SPG9_TK_GUE_EP1":                { _objSize = [0.6, 2.05]; };
   case "SPG9_TK_INS_EP1":                { _objSize = [0.6, 2.05]; };

   case "SearchLight":                    { _objSize = [1.15, 1.25]; _objOffset = [0, 0.05]; };
   case "SearchLight_CDF":                { _objSize = [1.15, 1.25]; _objOffset = [0, 0.05]; };
   case "SearchLight_Gue":                { _objSize = [1.15, 1.25]; _objOffset = [0, 0.05]; };
   case "SearchLight_INS":                { _objSize = [1.15, 1.25]; _objOffset = [0, 0.05]; };
   case "SearchLight_RUS":                { _objSize = [1.15, 1.25]; _objOffset = [0, 0.05]; };
   case "SearchLight_TK_EP1":             { _objSize = [1.15, 1.25]; _objOffset = [0, 0.05]; };
   case "SearchLight_TK_GUE_EP1":         { _objSize = [1.15, 1.25]; _objOffset = [0, 0.05]; };
   case "SearchLight_TK_INS_EP1":         { _objSize = [1.15, 1.25]; _objOffset = [0, 0.05]; };
   case "SearchLight_UN_EP1":             { _objSize = [1.15, 1.25]; _objOffset = [0, 0.05]; };
   case "SearchLight_US_EP1":             { _objSize = [1.15, 1.25]; _objOffset = [0, 0.05]; };
   
   case "Stinger_Pod":                    { _objSize = [3.1, 2.7]; _objOffset = [0, 0.65]; };
   case "Stinger_Pod_US_EP1":             { _objSize = [3.1, 2.7]; _objOffset = [0, 0.65]; };
   
   case "TOW_TriPod":                     { _objSize = [1.7, 1.6]; _objOffset = [0, 0.05]; };
   case "TOW_TriPod_US_EP1":              { _objSize = [1.7, 1.6]; _objOffset = [0, 0.05]; };
   
   // boats
   case "Fishing_Boat":                   { _objSize = [4.65, 13.95]; _objOffset = [-2.42, -0.2, 0]; };
   case "PBX":                            { _objSize = [2.2, 4.05]; _objOffset = [0, 0, 0]; };
   case "RHIB":                           { _objSize = [3.1, 9.3]; _objOffset = [1.41, -0.55, 0]; };
   case "RHIB2Turret":                    { _objSize = [3.1, 9.35]; _objOffset = [1.41, -0.55, 0]; };
   case "SeaFox":                         { _objSize = [3.45, 9.08]; _objOffset = [0.9, -0.11, 0]; };
   case "SeaFox_EP1":                     { _objSize = [3.45, 9.08]; _objOffset = [0.9, -0.11, 0]; };
   case "Smallboat_1":                    { _objSize = [2.25, 6.04]; _objOffset = [0, 0.2, 0]; };
   case "Smallboat_2":                    { _objSize = [2.25, 6.04]; _objOffset = [0, 0.2, 0]; };
   case "Zodiac":                         { _objSize = [1.83, 4.81]; _objOffset = [0.014, -0.018, 0]; };   
   
   // furniture
   case "Desk":                           { _objSize = [1.81, 0.86, 0.815]; };
   case "FoldChair":                      { _objSize = [0.57, 0.59]; };
   case "FoldTable":                      { _objSize = [2.02, 0.82, 0.79]; };
   case "Park_bench1":                    { _objSize = [1.82, 0.46]; };
   case "Park_bench2":                    { _objSize = [1.8, 0.969]; };
   case "Park_bench2_noRoad":             { _objSize = [1.8, 0.788]; };
   case "SmallTable":                     { _objSize = [1.018, 0.632, 0.81]; };
   case "WoodChair":                      { _objSize = [0.384, 0.461]; };
   
   // signs
   case "Land_RedWhiteBarrier":           { _objSize = [5.0, 0.175]; };
   case "Land_arrows_desk_L":             { _objSize = [1.5, 0.2]; };
   case "Land_arrows_desk_R":             { _objSize = [1.5, 0.2]; };
   case "RoadBarrier_long":               { _objSize = [3.12, 0.75]; };
   case "RoadBarrier_light":              { _objSize = [0.78, 0.78]; };
   case "Sign_tape_redwhite":             { _objSize = [3.167, 0.183]; };

   // dead bodies
   case "Body":                           { _objSize = [0.66, 2.25]; };
   case "Grave":                          { _objSize = [1.0, 2.0]; };
   case "Mass_grave":                     { _objSize = [7.0, 7.0]; };

   // Ammo
   case "GuerillaCacheBox":               { _objSize = [1.2, 1.2]; _objOffset = [0.25, 0.28, 0]; };
   case "Gunrack1":                       { _objSize = [0.8, 0.9]; };
   case "Gunrack2":                       { _objSize = [0.8, 0.9]; };
   case "LocalBasicAmmunitionBox":        { _objSize = [0.9, 0.6]; _objOffset = [-0.01, 0, 0]; };
   case "LocalBasicWeaponsBox":           { _objSize = [1.85, 1.55]; _objOffset = [0, -0.1, 0]; };
   case "RUBasicAmmunitionBox":           { _objSize = [0.8, 0.6]; };
   case "RUBasicWeaponsBox":              { _objSize = [2.1, 2.5]; _objOffset = [0, 0.1, 0]; };
   case "RULaunchersBox":                 { _objSize = [1.95, 0.275]; };
   case "RUOrdnanceBox":                  { _objSize = [1.8, 0.9]; };
   case "RUSpecialWeaponsBox":            { _objSize = [2.6, 1.3]; _objOffset = [0, 0.2, 0]; };
   case "RUVehicleBox":                   { _objSize = [4.8, 3.2]; _objOffset = [-0.2, -0.4, 0]; };
   case "SpecialWeaponsBox":              { _objSize = [2.3, 1.3]; _objOffset = [0.2, 0.05, 0]; };
   case "USBasicAmmunitionBox":           { _objSize = [0.9, 0.6]; _objOffset = [-0.01, 0, 0]; }; //
   case "USBasicWeaponsBox":              { _objSize = [0.9, 1.1]; _objOffset = [0, -0.31, 0]; };
   case "USLaunchersBox":                 { _objSize = [1.2, 1.0]; _objOffset = [0, -0.1, 0]; };
   case "USOrdnanceBox":                  { _objSize = [0.9, 0.6]; _objOffset = [-0.01, 0, 0]; }; //
   case "USSpecialWeaponsBox":            { _objSize = [1.5, 1.1]; };
   case "USVehicleBox":                   { _objSize = [2.4, 2.2]; _objOffset = [0, -0.1, 0]; };
   
   // more ammo (OA)
   case "AmmoCrate_NoInteractive_":        { _objSize = [0.9, 0.6]; _objOffset = [-0.01, 0, 0]; };
   case "AmmoCrates_NoInteractive_Medium": { _objSize = [0.9, 1.1]; _objOffset = [0, -0.2, 0]; };
   case "AmmoCrates_NoInteractive_Small":  { _objSize = [1.2, 0.8]; _objOffset = [0, -0.12, 0]; };
   case "CZBasicWeapons_EP1":              { _objSize = [2, 2.7]; _objOffset = [0, 0.1, 0]; };
   case "GERBasicWeapons_EP1":             { _objSize = [1.0, 1.1]; _objOffset = [0, -0.23, 0]; };
   case "GuerillaCacheBox_EP1":            { _objSize = [1.2, 1.2]; _objOffset = [0.25, 0.28, 0]; };
   case "GunrackTK_EP1":                   { _objSize = [0.8, 0.9]; };
   case "GunrackUS_EP1":                   { _objSize = [0.8, 0.9]; };
   case "TKBasicAmmunitionBox_EP1":        { _objSize = [0.8, 0.6]; };
   case "TKBasicWeapons_EP1":              { _objSize = [2.1, 2.5]; _objOffset = [0, 0.1, 0]; };
   case "TKLaunchers_EP1":                 { _objSize = [1.95, 0.275]; };
   case "TKOrdnanceBox_EP1":               { _objSize = [1.8, 0.9]; };
   case "TKSpecialWeapons_EP1":            { _objSize = [2.6, 1.3]; _objOffset = [0, 0.2, 0]; };
   case "TKVehicleBox_EP1":                { _objSize = [4.8, 3.2]; _objOffset = [-0.2, -0.4, 0]; };
   case "UNBasicWeapons_EP1":              { _objSize = [1.85, 1.55]; _objOffset = [0, -0.2, 0]; };
   case "UNBasicAmmunitionBox_EP1":        { _objSize = [0.9, 0.6]; _objOffset = [-0.01, 0, 0]; };
   case "USBasicAmmunitionBox_EP1":        { _objSize = [0.9, 0.6]; _objOffset = [-0.01, 0, 0]; };
   case "USBasicWeapons_EP1":              { _objSize = [0.9, 1.1]; _objOffset = [0, -0.31, 0]; };
   case "USLaunchers_EP1":                 { _objSize = [1.2, 1.0]; _objOffset = [0, -0.1, 0]; };
   case "USOrdnanceBox_EP1":               { _objSize = [0.9, 0.6]; _objOffset = [-0.01, 0, 0]; };
   case "USSpecialWeapons_EP1":            { _objSize = [1.5, 1.1]; };
   case "USVehicleBox_EP1":                { _objSize = [2.4, 2.2]; _objOffset = [0, -0.1, 0]; };   
   
   // warefare
   case "BMP2_HQ_CDF_unfolded":              { _objSize = [10, 11]; _objOffset = [3, 0, 0]; };
   case "BMP2_HQ_INS_unfolded":              { _objSize = [10, 11]; _objOffset = [3, 0, 0]; };
   case "BRDM2_HQ_Gue_unfolded":             { _objSize = [10, 11]; _objOffset = [3, 0, 0]; };
   case "BTR90_HQ_unfolded":                 { _objSize = [10, 11]; _objOffset = [3, 0, 0]; };
   case "CDF_WarfareBAntiAirRadar":          { _objSize = [22, 22]; _objOffset = [1, 0, 0]; };
   case "CDF_WarfareBArtilleryRadar":        { _objSize = [20, 21]; _objOffset = [5, 1, 0]; };
   case "CDF_WarfareBBarracks":              { _objSize = [18, 18]; _objOffset = [-1, -1, 0]; };
   case "CDF_WarfareBContructionSite":       { _objSize = [2.5, 6.5]; };
   case "CDF_WarfareBContructionSite1":      { _objSize = [2.5, 6.5]; };
   case "CDF_WarfareBFieldhHospital":        { _objSize = [11, 8]; };
   case "CDF_WarfareBHeavyFactory":          { _objSize = [20, 18]; _objOffset = [-3, -2.5, 0]; };
   case "CDF_WarfareBLightFactory":          { _objSize = [15, 16]; _objOffset = [0, 1, 0]; };
   case "CDF_WarfareBMGNest_PK":             { _objSize = [3.6, 3.6]; _objOffset = [0.6, 0.2, 0]; };
   case "CDF_WarfareBUAVterminal":           { _objSize = [6, 9]; };
   case "CDF_WarfareBVehicleServicePoint":   { _objSize = [10, 5]; _objOffset = [-1.5, -0.5, 0]; };
   case "GUE_WarfareBAntiAirRadar":          { _objSize = [22, 22]; _objOffset = [1, 0, 0]; };
   case "GUE_WarfareBFieldhHospital":        { _objSize = [11, 8]; };
   case "GUE_WarfareBMGNest_PK":             { _objSize = [3.6, 3.6]; _objOffset = [0.6, 0.2, 0]; };
   case "GUE_WarfareBUAVterminal":           { _objSize = [6, 9]; };
   case "GUE_WarfareBVehicleServicePoint":   { _objSize = [10, 5]; _objOffset = [-1.5, -0.5, 0]; };
   case "Gue_WarfareBArtilleryRadar":        { _objSize = [20, 21]; _objOffset = [5, 1, 0]; };
   case "Gue_WarfareBBarracks":              { _objSize = [18, 18]; _objOffset = [-1, -1, 0]; };
   case "Gue_WarfareBContructionSite":       { _objSize = [2.5, 6.5]; };
   case "Gue_WarfareBContructionSite1":      { _objSize = [2.5, 6.5]; };
   case "Gue_WarfareBHeavyFactory":          { _objSize = [20, 18]; _objOffset = [-3, -2.5, 0]; };
   case "Gue_WarfareBLightFactory":          { _objSize = [15, 16]; _objOffset = [0, 1, 0]; };
   case "INS_WarfareBAntiAirRadar":          { _objSize = [22, 22]; _objOffset = [1, 0, 0]; };
   case "INS_WarfareBFieldhHospital":        { _objSize = [11, 8]; };
   case "INS_WarfareBUAVterminal":           { _objSize = [6, 9]; };
   case "INS_WarfareBVehicleServicePoint":   { _objSize = [10, 5]; _objOffset = [-1.5, -0.5, 0]; };
   case "Ins_WarfareBArtilleryRadar":        { _objSize = [20, 21]; _objOffset = [5, 1, 0]; };
   case "Ins_WarfareBBarracks":              { _objSize = [18, 18]; _objOffset = [-1, -1, 0]; };
   case "Ins_WarfareBContructionSite":       { _objSize = [2.5, 6.5]; };
   case "Ins_WarfareBContructionSite1":      { _objSize = [2.5, 6.5]; };
   case "Ins_WarfareBHeavyFactory":          { _objSize = [20, 18]; _objOffset = [-3, -2.5, 0]; };
   case "Ins_WarfareBLightFactory":          { _objSize = [15, 16]; _objOffset = [0, 1, 0]; };
   case "Ins_WarfareBMGNest_PK":             { _objSize = [3.6, 3.6]; _objOffset = [0.6, 0.2, 0]; };
   case "LAV25_HQ_unfolded":                 { _objSize = [7, 10]; _objOffset = [1.5, 0, 0]; };
   case "RU_WarfareBAircraftFactory":        { _objSize = [16, 15]; _objOffset = [1, -2, 0]; };
   case "RU_WarfareBAntiAirRadar":           { _objSize = [22, 22]; _objOffset = [1, 0, 0]; };
   case "RU_WarfareBArtilleryRadar":         { _objSize = [20, 21]; _objOffset = [5, 1, 0]; };
   case "RU_WarfareBBarracks":               { _objSize = [18, 18]; _objOffset = [-1, -1, 0]; };
   case "RU_WarfareBContructionSite":        { _objSize = [2.5, 6.5]; };
   case "RU_WarfareBContructionSite1":       { _objSize = [2.5, 6.5]; };
   case "RU_WarfareBFieldhHospital":         { _objSize = [11, 8]; };
   case "RU_WarfareBHeavyFactory":           { _objSize = [20, 18]; _objOffset = [-3, -2.5, 0]; };
   case "RU_WarfareBLightFactory":           { _objSize = [15, 16]; _objOffset = [0, 1, 0]; };
   case "RU_WarfareBMGNest_PK":              { _objSize = [3.6, 3.6]; _objOffset = [0.6, 0.2, 0]; };
   case "RU_WarfareBUAVterminal":            { _objSize = [6, 9]; };
   case "RU_WarfareBVehicleServicePoint":    { _objSize = [10, 5]; _objOffset = [-1.5, -0.5, 0]; };
   case "USMC_WarfareBAircraftFactory":      { _objSize = [16, 15]; _objOffset = [1, -2, 0]; };
   case "USMC_WarfareBAntiAirRadar":         { _objSize = [22, 22]; _objOffset = [1, 0, 0]; };
   case "USMC_WarfareBArtilleryRadar":       { _objSize = [20, 21]; _objOffset = [5, 0, 0]; };
   case "USMC_WarfareBBarracks":             { _objSize = [14, 19]; _objOffset = [0.75, -4.5, 0]; };
   case "USMC_WarfareBContructionSite":      { _objSize = [2.5, 6.5]; };
   case "USMC_WarfareBContructionSite1":     { _objSize = [2.5, 6.5]; };
   case "USMC_WarfareBFieldhHospital":       { _objSize = [13, 17]; _objOffset = [2, 1.5, 0]; };
   case "USMC_WarfareBHeavyFactory":         { _objSize = [22, 21]; _objOffset = [1, -3, 0]; };
   case "USMC_WarfareBLightFactory":         { _objSize = [14, 17]; _objOffset = [3.5, -2, 0]; };
   case "USMC_WarfareBMGNest_M240":          { _objSize = [3.6, 3.6]; _objOffset = [0.6, 0.2, 0]; };
   case "USMC_WarfareBUAVterminal":          { _objSize = [6, 9]; };
   case "USMC_WarfareBVehicleServicePoint":  { _objSize = [4.5, 9]; _objOffset = [0.75, 1.25, 0]; };
   case "WarfareBAircraftFactory_CDF":       { _objSize = [16, 15]; _objOffset = [1, -2, 0]; };
   case "WarfareBAircraftFactory_Gue":       { _objSize = [16, 15]; _objOffset = [1, -2, 0]; };
   case "WarfareBAircraftFactory_Ins":       { _objSize = [16, 15]; _objOffset = [1, -2, 0]; };
   
   // warefare objects
   case "WarfareBDepot":                 { _objSize = [18, 24, 5.5]; };
   case "WarfareBCamp":                  { _objSize = [18, 14, 3]; _objOffset = [0, 2, 0]; };
   case "WarfareBunkerSign":             { _objSize = [2.43, 0.14, 2]; };
   case "USMC_WarfareBBarrier5x":        { _objSize = [7.8, 1.5, 1.5]; };
   case "USMC_WarfareBBarrier10x":       { _objSize = [15.6, 1.5, 1.5]; };
   case "USMC_WarfareBBarrier10xTall":   { _objSize = [15.6, 2.6, 2.7]; _objOffset = [0, -0.6, 0]; };
   case "RU_WarfareBBarrier5x":          { _objSize = [7.8, 1.5, 1.5]; };
   case "RU_WarfareBBarrier10x":         { _objSize = [15.6, 1.5, 1.5]; };
   case "RU_WarfareBBarrier10xTall":     { _objSize = [15.6, 2.6, 2.7]; _objOffset = [0, -0.6, 0]; };
   case "CDF_WarfareBBarrier5x":         { _objSize = [7.8, 1.5, 1.5]; };
   case "CDF_WarfareBBarrier10x":        { _objSize = [15.6, 1.5, 1.5]; };
   case "CDF_WarfareBBarrier10xTall":    { _objSize = [15.6, 2.6, 2.7]; _objOffset = [0, -0.6, 0]; };
   case "INS_WarfareBBarrier5x":         { _objSize = [7.8, 1.5, 1.5]; };
   case "INS_WarfareBBarrier10x":        { _objSize = [15.6, 1.5, 1.5]; };
   case "INS_WarfareBBarrier10xTall":    { _objSize = [15.6, 2.6, 2.7]; _objOffset = [0, -0.6, 0]; };
   case "GUE_WarfareBBarrier5x":         { _objSize = [7.8, 1.5, 1.5]; };
   case "GUE_WarfareBBarrier10x":        { _objSize = [15.6, 1.5, 1.5]; };
   case "GUE_WarfareBBarrier10xTall":    { _objSize = [15.6, 2.6, 2.7]; _objOffset = [0, -0.6, 0]; };
   
   // training
   case "Dirtmount_EP1":                  { _objSize = [14.3, 8.6]; _objOffset = [0.5, 0.14, 0]; };
   case "HumpsDirt":                      { _objSize = [28, 20]; };
   case "Land_Dirthump01":                { _objSize = [16, 8]; };
   case "Land_Dirthump02":                { _objSize = [22, 9]; };
   case "Land_Dirthump03":                { _objSize = [22, 10]; };
   case "Land_Climbing_Obstacle":         { _objSize = [5.4, 0.5]; };
   case "Land_ConcreteRamp":              { _objSize = [5.0, 6.4]; _objOffset = [1.25, 0.8, 0]; };
   case "Land_Shooting_range":            { _objSize = [2.0, 3.0]; };
   case "Land_WoodenRamp":                { _objSize = [1.6, 2.4]; };
   case "Land_obstacle_get_over":         { _objSize = [2.72, 3.25]; _objOffset = [0.4, 0.1, 0]; };
   case "Land_obstacle_prone":            { _objSize = [4.25, 1.55]; _objOffset = [0.1, 0, 0]; };
   case "Land_obstacle_run_duck":         { _objSize = [4.685, 1.947]; };
   case "Land_podlejzacka":               { _objSize = [2.6, 5.2]; _objOffset = [0, -0.2, 0]; };
   case "Land_prebehlavka":               { _objSize = [1.1, 9.2]; };
   case "Land_prolejzacka":               { _objSize = [3, 1.4]; _objOffset = [0, -0.6, 0]; };
   case "Obstacle_saddle":                { _objSize = [0.15, 4]; };
   case "PARACHUTE_TARGET":               { _objSize = [12, 12]; };
   case "RampConcrete":                   { _objSize = [4.8, 9.8]; _objOffset = [0.2, 0.2, 0]; };
   
   // buildings
   case "Land_A_Castle_Gate":             { _objSize = [19.45, 11.5]; _objOffset = [-1.235, 0.1, 0]; };
   case "Land_A_Castle_Wall1_20":         { _objSize = [22.5, 2.5]; _objOffset = [0, 0.6, 0]; };
   case "Land_A_Castle_Wall2_30":         { _objSize = [26.5, 1.42]; _objOffset = [0, 1.42, 0]; };
   case "Land_Dam_Barrier_40":            { _objSize = [40, 3.56]; _objOffset = [0, -0.07, 0]; };
   case "Land_Gate_Wood1_5":              { _objSize = [0.95, 0.07]; _objOffset = [0.05, -0.01, 0]; };
   case "Land_Gate_wood2_5":              { _objSize = [0.91, 0.1]; _objOffset = [0.075, -0.015, 0]; };
   case "Land_Wall_CBrk_5_D":             { _objSize = [5, 0.4]; _objOffset = [0, -0.01, 0]; };
   case "Land_Wall_CGry_5_D":             { _objSize = [5, 0.4]; _objOffset = [0, -0.01, 0]; }; 
   case "Land_Wall_Gate_Ind1_L":          { _objSize = [4, 0.12]; _objOffset = [2.05, -0.02, 0]; };
   case "Land_Wall_Gate_Ind1_R":          { _objSize = [4, 0.12]; _objOffset = [-2.05, -0.02, 0]; };
   case "Land_Wall_Gate_Ind2A_L":         { _objSize = [4.15, 0.18]; _objOffset = [2.02, -0.02, 0]; };
   case "Land_Wall_Gate_Ind2A_R":         { _objSize = [4.15, 0.18]; _objOffset = [-2.02, -0.02, 0]; };
   case "Land_Wall_Gate_Ind2B_L":         { _objSize = [4.15, 0.18]; _objOffset = [2.02, -0.02, 0]; };
   case "Land_Wall_Gate_Ind2B_R":         { _objSize = [4.15, 0.18]; _objOffset = [-2.02, -0.02, 0]; };
   case "Land_Wall_Gate_Ind2Rail_L":      { _objSize = [4.15, 0.18]; _objOffset = [2.02, -0.02, 0]; };
   case "Land_Wall_Gate_Ind2Rail_R":      { _objSize = [4.1, 0.18]; _objOffset = [-2.07, -0.02, 0]; };
   case "Land_plot_green_branka":         { _objSize = [1.35, 0.14]; _objOffset = [-0.1, 0, 0]; };
   case "Land_plot_green_vrata":          { _objSize = [4.7, 0.14]; };
   case "Land_plot_rust_branka":          { _objSize = [1.77, 0.34]; _objOffset = [-0.08, -0.02, 0]; };
   case "Land_plot_rust_vrata":           { _objSize = [4.7, 0.14]; };
   case "Land_Misc_WaterStation":         { _objSize = [3.55, 3.9]; _objOffset = [0, 0.175, 0]; };
   case "Land_Ind_IlluminantTower":       { _objSize = [4.0, 4.0]; };
   case "Land_Vysilac_FM":                { _objSize = [9.5, 9.5]; };
   case "Land_telek1":                    { _objSize = [6.8, 5.4]; };
   case "Land_vez":                       { _objSize = [2.0, 2.0]; _objOffset = [-3, 1, 0]; };
   
   /*
   case "":                               { _objSize = []; };
   case "":                               { _objSize = []; };
   case "":                               { _objSize = []; };
   */
};

// failsafe
if (((_objSize select 0) == 0) && ((_objSize select 1) == 0)) then
{
   _obj = createVehicle [_this, [0,0,0], [], 0, "NONE"];
   
   _box = boundingBox _obj;
   _objSize = [
      (((_box select 1) select 0) - ((_box select 0) select 0)),
      (((_box select 1) select 1) - ((_box select 0) select 1)),
      (((_box select 1) select 2) - ((_box select 0) select 2))
   ];
   
   _center = boundingCenter _obj;
   _objOffset = [
      ((_center select 0) * -1),
      ((_center select 1) * -1),
      0
   ];
   
   deleteVehicle _obj;
};

// return dimensions
[
   _objSize,
   _objOffset
]