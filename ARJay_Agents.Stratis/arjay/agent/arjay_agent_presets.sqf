/*
	File: arjay_agent_presets.sqf
	Author: ARJay
	Description: Editable settings for the agent system
*/

// main loop cycle sleep times
arjay_agentMonitorCycleTime = 5;
arjay_agentMissionControllerCycleTime = 12;
arjay_agentCivilianControllerCycleTime = 13;
arjay_agentEastControllerCycleTime = 14;
arjay_agentWestControllerCycleTime = 15;

// if you have generated mission data using [true] call arjay_agentsGenerateStaticData; 
// and have saved the output from the rpt file in the correct filename arjay/static_data/arjay_mission_[arjay_missionName].sqf 
// turn this on to load location mission settings from the file instead of dynamically generating them
arjay_agentUseStaticMissionData = false;

// pre-initialise all locations on mission start
arjay_agentPreInitLocations = false;

// the radius around the players the locations will activate and garbage collection will occur on deactivation
arjay_agentLocationInitRadius = 800;

// the radius within which the location can be cleared and captured
arjay_agentLocationClearRadius = 250;

// the time in seconds after a location has been cleared that it can be captured
arjay_agentLocationCaptureTime = 20;

// global on / off switch to create agent vehicles
arjay_agentCreateVehicles = true; 

// create map markers for locations side makeup
arjay_agentCreateMapMarkers = true;

// create occupied house lights in the evening (pv broadcast)
arjay_agentCreateHouseLights = true;

// create ambient music for civilian houses (pv broadcast)
arjay_agentCreateHouseMusic = true;

// broadcast agent animations for switch move (pv broadcast)
arjay_agentBroadcastAgentAnimations = true;

// allow east units to attack civilian locations
arjay_agentEastAttackCivilians = true;

// allow west units to attack civilian locations
arjay_agentWestAttackCivilians = true;


// slightly altered config location data output 
// modified to cover most buildings on stratis
// commented out locations are overlapping, or contain no buildings
// [location name, location type, location position, location radius A, location radius B, plot perimeter routes, plot perimeter radius]
arjay_worldLocations = call Dictionary_fnc_new; 	
[arjay_worldLocations, "Agia Marina", ["Agia Marina", "NameCityCapital", [2815.2,6164.52], 550, 450, false, 0]] call Dictionary_fnc_set;
[arjay_worldLocations, "Agios Cephas", ["Agios Cephas", "NameLocal", [2718.53,1712.08], 96.81, 72.39, true, 100]] call Dictionary_fnc_set;
[arjay_worldLocations, "LZ Connor", ["LZ Connor", "NameLocal", [2979.45,1860.23], 121.02, 90.49, true, 100]] call Dictionary_fnc_set;
[arjay_worldLocations, "Girna", ["Girna", "NameCity", [1935.28,2722.61], 300, 300, false, 0]] call Dictionary_fnc_set;
[arjay_worldLocations, "Agios Ioannis", ["Agios Ioannis", "NameLocal", [3027.38,2183.84], 121.02, 90.49, true, 100]] call Dictionary_fnc_set;
[arjay_worldLocations, "Camp Maxwell", ["Camp Maxwell", "NameVillage", [3252.96,2984.3], 200, 200, true, 100]] call Dictionary_fnc_set;
[arjay_worldLocations, "Air Station Mike-26", ["Air Station Mike-26", "NameVillage", [4278.85,3855.6], 400, 400, true, 100]] call Dictionary_fnc_set;
[arjay_worldLocations, "Old Outpost", ["Old Outpost", "NameLocal", [4318.72,4398.14], 121.02, 90.49, true, 100]] call Dictionary_fnc_set;
[arjay_worldLocations, "Kamino Firing Range", ["Kamino Firing Range", "NameVillage", [6401.97,5427.13], 300, 300, true, 100]] call Dictionary_fnc_set;
[arjay_worldLocations, "Camp Tempest", ["Camp Tempest", "NameVillage", [2000,3556.72], 121.02, 90.49, true, 50]] call Dictionary_fnc_set;
[arjay_worldLocations, "Stratis Air Base", ["Stratis Air Base", "NameCity", [1987.31,5625.9], 500, 350, false, 0]] call Dictionary_fnc_set;
[arjay_worldLocations, "Kill Farm", ["Kill Farm", "NameLocal", [4449.56,6845.08], 236.36, 176.73, false, 0]] call Dictionary_fnc_set;
[arjay_worldLocations, "Camp Rogain", ["Camp Rogain", "NameVillage", [5000,5948.26], 100, 100, true, 100]] call Dictionary_fnc_set;
[arjay_worldLocations, "Tsoukalia", ["Tsoukalia", "NameLocal", [4205.64,2714.88], 121.02, 90.49, false, 0]] call Dictionary_fnc_set;
[arjay_worldLocations, "LZ Baldy", ["LZ Baldy", "NameLocal", [4800,5200], 650, 650, false, 0]] call Dictionary_fnc_set;
[arjay_worldLocations, "military range", ["military range", "NameLocal", [3250.44,5800.44], 50, 50, true, 50]] call Dictionary_fnc_set;
[arjay_worldLocations, "Jay Cove", ["Jay Cove", "NameMarine", [2250.92,1121.03], 295.45, 220.91, false, 0]] call Dictionary_fnc_set;
[arjay_worldLocations, "Strogos Bay", ["Strogos Bay", "NameMarine", [2024.23,1789.56], 236.36, 176.73, false, 0]] call Dictionary_fnc_set;
[arjay_worldLocations, "Limeri  Bay", ["Limeri  Bay", "NameMarine", [5439.83,3687.15], 300, 300, false, 0]] call Dictionary_fnc_set;
[arjay_worldLocations, "Kamino Bay", ["Kamino Bay", "NameMarine", [6544.24,4863.44], 300, 300, false, 0]] call Dictionary_fnc_set;
//[arjay_worldLocations, "Keiros Bay", ["Keiros Bay", "NameMarine", [6157.09,4348.65], 721.31, 539.34, false, 0]] call Dictionary_fnc_set;
//[arjay_worldLocations, "Kamino Coast", ["Kamino Coast", "NameLocal", [5690.81,6123.91], 901.64, 674.18, false, 0]] call Dictionary_fnc_set;
//[arjay_worldLocations, "airfield", ["airfield", "NameLocal", [1697.19,5554.18], 295.45, 220.91, false, 0]] call Dictionary_fnc_set;
//[arjay_worldLocations, "Nisi Bay", ["Nisi Bay", "NameMarine", [1784.43,4134.31], 295.45, 220.91, false, 0]] call Dictionary_fnc_set;
//[arjay_worldLocations, "Kyfi Bay", ["Kyfi Bay", "NameMarine", [1790.43,3511.78], 39.31, 26.14, false, 0]] call Dictionary_fnc_set;
//[arjay_worldLocations, "Tsoukala Bay", ["Tsoukala Bay", "NameMarine", [4240.81,2497.99], 91.64, 64.18, false, 0]] call Dictionary_fnc_set;
//[arjay_worldLocations, "Girna Bay", ["Girna Bay", "NameMarine", [1844.64,2656.39], 295.45, 220.91, false, 0]] call Dictionary_fnc_set;
//[arjay_worldLocations, "Marina Bay", ["Marina Bay", "NameMarine", [2647.88,5989.95], 100, 100, false, 0]] call Dictionary_fnc_set;
//[arjay_worldLocations, "The Spartan", ["The Spartan", "NameLocal", [2615.44,597.12], 39.66, 29.65, false, 0]] call Dictionary_fnc_set;
//[arjay_worldLocations, "Xiros", ["Xiros", "NameLocal", [3712.09,7940.36], 236.36, 176.73, false, 0]] call Dictionary_fnc_set;
//[arjay_worldLocations, "Pythos", ["Pythos", "NameLocal", [7055.11,5953.82], 236.36, 176.73, false, 0]] call Dictionary_fnc_set;


// default stratis location spawn probabilites and side
// [["SIDE","SIDE"],[[Agent spawn probability, Vehicle spawn probability, Marker Holder, Group spawn probability, Group types],[Agent spawn probability, Vehicle spawn probability, Marker Holder, Group spawn probability, Group types]]]
// SIDE VALUES : CIV, EAST, WEST, RANDOM
arjay_missionLocations = call Dictionary_fnc_new;
[arjay_missionLocations, "Agia Marina", [["CIV"],[[0.5, 0.3, objNull, 0, []]]]] call Dictionary_fnc_set;
[arjay_missionLocations, "Agios Cephas", [["CIV"],[[1, 0.5, objNull, 0, []]]]] call Dictionary_fnc_set;
[arjay_missionLocations, "LZ Connor", [["WEST"],[[1, 1, objNull, 1, ["FIRETEAM"]]]]] call Dictionary_fnc_set;
[arjay_missionLocations, "Girna", [["CIV"],[[1, 0.5, objNull, 0, []]]]] call Dictionary_fnc_set;
[arjay_missionLocations, "Agios Ioannis", [["CIV"],[[1, 0.5, objNull, 0, []]]]] call Dictionary_fnc_set;
//[arjay_missionLocations, "Agios Ioannis", [["CIV", "WEST"],[[0.5, 0.5, objNull, 0, []],[0.5, 0.5, objNull, 0, ["FIRETEAM", "SQUAD"]]]]] call Dictionary_fnc_set;
[arjay_missionLocations, "Camp Maxwell", [["WEST"],[[1, 0.5, objNull, 0.5, ["FIRETEAM", "SQUAD"]]]]] call Dictionary_fnc_set;
[arjay_missionLocations, "Air Station Mike-26", [["EAST"],[[1, 0.5, objNull, 0.5, ["FIRETEAM", "SQUAD"]]]]] call Dictionary_fnc_set;
[arjay_missionLocations, "Old Outpost", [["EAST"],[[1, 0.5, objNull, 0, ["FIRETEAM", "SQUAD"]]]]] call Dictionary_fnc_set;
[arjay_missionLocations, "Kamino Firing Range", [["EAST"],[[1, 0.5, objNull, 0.5, ["FIRETEAM", "SQUAD"]]]]] call Dictionary_fnc_set;
[arjay_missionLocations, "Camp Tempest", [["EAST"],[[1, 0.5, objNull, 0.5, ["FIRETEAM", "SQUAD"]]]]] call Dictionary_fnc_set;
[arjay_missionLocations, "Stratis Air Base", [["WEST"],[[0.5, 0.1, objNull, 0.2, ["FIRETEAM", "SQUAD"]]]]] call Dictionary_fnc_set;
[arjay_missionLocations, "Kill Farm", [["CIV"],[[1, 0.5, objNull, 0, []]]]] call Dictionary_fnc_set;
[arjay_missionLocations, "Camp Rogain", [["EAST"],[[1, 0.5, objNull, 0, ["FIRETEAM", "SQUAD"]]]]] call Dictionary_fnc_set;
[arjay_missionLocations, "Tsoukalia", [["CIV"],[[1, 0.5, objNull, 0, []]]]] call Dictionary_fnc_set;
[arjay_missionLocations, "LZ Baldy", [["CIV"],[[1, 0.5, objNull, 0, []]]]] call Dictionary_fnc_set;
[arjay_missionLocations, "military range", [["WEST"],[[1, 0.5, objNull, 0, ["FIRETEAM", "SQUAD"]]]]] call Dictionary_fnc_set;
[arjay_missionLocations, "Jay Cove", [["CIV"],[[1, 0.5, objNull, 0, []]]]] call Dictionary_fnc_set;
[arjay_missionLocations, "Strogos Bay", [["CIV"],[[1, 0.5, objNull, 0, []]]]] call Dictionary_fnc_set;
[arjay_missionLocations, "Limeri  Bay", [["CIV"],[[1, 0.5, objNull, 0, []]]]] call Dictionary_fnc_set;
[arjay_missionLocations, "Kamino Bay", [["CIV"],[[1, 0.5, objNull, 0, []]]]] call Dictionary_fnc_set;
//[arjay_missionLocations, "The Spartan", [["RANDOM"],[[1, 0.5, objNull, 0, []]]]] call Dictionary_fnc_set;
//[arjay_missionLocations, "Xiros", [["RANDOM"],[[1, 0.5, objNull, 0, []]]]] call Dictionary_fnc_set;
//[arjay_missionLocations, "Pythos", [["RANDOM"],[[1, 0.5, objNull, 0, []]]]] call Dictionary_fnc_set;
//[arjay_missionLocations, "airfield", [["WEST"],[[1, 0.5, objNull, 0, []]]]] call Dictionary_fnc_set;
//[arjay_missionLocations, "Kamino Coast", [["RANDOM"],[[1, 0.5, objNull, 0, []]]]] call Dictionary_fnc_set;
//[arjay_missionLocations, "Marina Bay", [["RANDOM"],[[1, 0.5, objNull, 0, []]]]] call Dictionary_fnc_set;
//[arjay_missionLocations, "Girna Bay", [["RANDOM"],[[1, 0.5, objNull, 0, []]]]] call Dictionary_fnc_set;
//[arjay_missionLocations, "Kyfi Bay", [["RANDOM"],[[1, 0.5, objNull, 0, []]]]] call Dictionary_fnc_set;
//[arjay_missionLocations, "Nisi Bay", [["RANDOM"],[[1, 0.5, objNull, 0, []]]]] call Dictionary_fnc_set;
//[arjay_missionLocations, "Keiros Bay", [["RANDOM"],[[1, 0.5, objNull, 0, []]]]] call Dictionary_fnc_set;
//[arjay_missionLocations, "Tsoukala Bay", [["RANDOM"],[[1, 0.5, objNull, 0, []]]]] call Dictionary_fnc_set;


// default stratis location allowed clearance
// [ALLOW CLEARANCE, HAS BEEN CLEARED]
arjay_missionLocationClearance = call Dictionary_fnc_new;
[arjay_missionLocationClearance, "Agia Marina", [true, false]] call Dictionary_fnc_set;
[arjay_missionLocationClearance, "Agios Cephas", [true, false]] call Dictionary_fnc_set;
[arjay_missionLocationClearance, "LZ Connor", [true, false]] call Dictionary_fnc_set;
[arjay_missionLocationClearance, "Girna", [true, false]] call Dictionary_fnc_set;
[arjay_missionLocationClearance, "Agios Ioannis", [true, false]] call Dictionary_fnc_set;
[arjay_missionLocationClearance, "Camp Maxwell", [true, false]] call Dictionary_fnc_set;
[arjay_missionLocationClearance, "Air Station Mike-26", [true, false]] call Dictionary_fnc_set;
[arjay_missionLocationClearance, "Old Outpost", [true, false]] call Dictionary_fnc_set;
[arjay_missionLocationClearance, "Kamino Firing Range", [true, false]] call Dictionary_fnc_set;
[arjay_missionLocationClearance, "Camp Tempest", [true, false]] call Dictionary_fnc_set;
[arjay_missionLocationClearance, "Stratis Air Base", [true, false]] call Dictionary_fnc_set;
[arjay_missionLocationClearance, "Kill Farm", [true, false]] call Dictionary_fnc_set;
[arjay_missionLocationClearance, "Camp Rogain", [true, false]] call Dictionary_fnc_set;
[arjay_missionLocationClearance, "Tsoukalia", [true, false]] call Dictionary_fnc_set;
[arjay_missionLocationClearance, "LZ Baldy", [true, false]] call Dictionary_fnc_set;
[arjay_missionLocationClearance, "military range", [true, false]] call Dictionary_fnc_set;
[arjay_missionLocationClearance, "Jay Cove", [true, false]] call Dictionary_fnc_set;
[arjay_missionLocationClearance, "Strogos Bay", [true, false]] call Dictionary_fnc_set;
[arjay_missionLocationClearance, "Limeri  Bay", [true, false]] call Dictionary_fnc_set;
[arjay_missionLocationClearance, "Kamino Bay", [true, false]] call Dictionary_fnc_set;
//[arjay_missionLocationClearance, "The Spartan", [true, false]] call Dictionary_fnc_set;
//[arjay_missionLocationClearance, "Xiros", [true, false]] call Dictionary_fnc_set;
//[arjay_missionLocationClearance, "Pythos", [true, false]] call Dictionary_fnc_set;
//[arjay_missionLocationClearance, "airfield", [true, false]] call Dictionary_fnc_set;
//[arjay_missionLocationClearance, "Kamino Coast", [true, false]] call Dictionary_fnc_set;
//[arjay_missionLocationClearance, "Marina Bay", [true, false]] call Dictionary_fnc_set;
//[arjay_missionLocationClearance, "Girna Bay", [true, false]] call Dictionary_fnc_set;
//[arjay_missionLocationClearance, "Kyfi Bay", [true, false]] call Dictionary_fnc_set;
//[arjay_missionLocationClearance, "Nisi Bay", [true, false]] call Dictionary_fnc_set;
//[arjay_missionLocationClearance, "Keiros Bay", [true, false]] call Dictionary_fnc_set;
//[arjay_missionLocationClearance, "Tsoukala Bay", [true, false]] call Dictionary_fnc_set;


// civilian buildings
arjay_civilianBuildings = [
	"Land_Slum_House01_F",
	"Land_Slum_House02_F",
	"Land_Slum_House03_F",
	"Land_u_House_Small_01_V1_F",
	"Land_u_House_Small_02_V1_F",	
	"Land_i_Stone_HouseSmall_V1_F",
	"Land_i_Stone_HouseBig_V1_F",
	"Land_i_Stone_Shed_V1_F",
	"Land_i_House_Small_01_V1_F",
	"Land_i_House_Small_01_V2_F",
	"Land_i_House_Small_02_V1_F",
	"Land_i_House_Small_03_V1_F",	
	"Land_i_House_Big_01_V1_F",
	"Land_i_House_Big_02_V1_F",
	"Land_i_Shop_01_V1_F",
	"Land_i_Shop_02_V1_F",
	"Land_FuelStation_Build_F"
];

// civilian task buildings
arjay_civilianTaskBuildings = [
	"Land_Chapel_Small_V1_F",
	"Land_FuelStation_Build_F",
	"Land_i_Shop_01_V1_F",
	"Land_i_Shop_02_V1_F",
	"Land_Pier_small_F",
	"Land_Pier_F"
];

// military buildings
arjay_militaryBuildings = [
	"Land_Slum_House01_F",
	"Land_Slum_House02_F",
	"Land_Slum_House03_F",
	"Land_u_House_Small_01_V1_F",
	"Land_u_House_Small_02_V1_F",	
	"Land_i_Stone_HouseSmall_V1_F",
	"Land_i_Stone_HouseBig_V1_F",
	"Land_i_Stone_Shed_V1_F",
	"Land_i_House_Small_01_V1_F",
	"Land_i_House_Small_01_V2_F",
	"Land_i_House_Small_02_V1_F",
	"Land_i_House_Small_03_V1_F",	
	"Land_i_House_Big_01_V1_F",
	"Land_i_House_Big_02_V1_F",
	"Land_i_Shop_01_V1_F",
	"Land_i_Shop_02_V1_F",
	"Land_MilOffices_V1_F",
	"Land_Cargo_HQ_V1_F",
	"Land_Cargo_Patrol_V1_F",	
	"Land_Cargo_Patrol_V2_F",
	"Land_Cargo_House_V1_F",
	"Land_Cargo_House_V2_F",
	"Land_Shed_Big_F",
	"Land_Airport_Tower_F"
];

// military task buildings
arjay_militaryTaskBuildings = [
	"Land_TentHangar_V1_F",
	"Land_Pier_small_F",
	"Land_Pier_F"
];

// military garison buildings
arjay_militaryGarisonBuildings = [
	"Land_Cargo_Patrol_V1_F",
	"Land_Cargo_Patrol_V2_F"
];

// some conversion data for sides
arjay_agentSideVarNames = call Dictionary_fnc_new;
[arjay_agentSideVarNames, "CIV", ["Civilian", civilian, "C_man_1"]] call Dictionary_fnc_set;
[arjay_agentSideVarNames, "EAST", ["East", east, "O_Soldier_base_F", west]] call Dictionary_fnc_set;
[arjay_agentSideVarNames, "WEST", ["West", west, "B_Soldier_base_F", east]] call Dictionary_fnc_set;

// marker setup for location markers
arjay_agentSideMarkers = call Dictionary_fnc_new;
[arjay_agentSideMarkers, "CIV", ["ELLIPSE", "FDiagonal", "ColorWhite"]] call Dictionary_fnc_set;
[arjay_agentSideMarkers, "EAST", ["ELLIPSE", "BDiagonal", "ColorRed"]] call Dictionary_fnc_set;
[arjay_agentSideMarkers, "WEST", ["ELLIPSE", "FDiagonal", "ColorBlue"]] call Dictionary_fnc_set;

// civilian agent loadouts
arjay_agentCivilianLoadoutSettings = call Dictionary_fnc_new;
[arjay_agentCivilianLoadoutSettings, "ROGUE1", ["ROGUE1", 0.01, false]] call Dictionary_fnc_set;

// civilian agent ambient house music tracks stores duration of tracks
arjay_agentCivilianHouseTracks = call Dictionary_fnc_new;
[arjay_agentCivilianHouseTracks, "Track1", 180] call Dictionary_fnc_set;
[arjay_agentCivilianHouseTracks, "Track2", 188] call Dictionary_fnc_set;
[arjay_agentCivilianHouseTracks, "Track3", 199] call Dictionary_fnc_set;
[arjay_agentCivilianHouseTracks, "Track4", 246] call Dictionary_fnc_set;
[arjay_agentCivilianHouseTracks, "Track5", 335] call Dictionary_fnc_set;
[arjay_agentCivilianHouseTracks, "Track6", 199] call Dictionary_fnc_set;
[arjay_agentCivilianHouseTracks, "Track7", 177] call Dictionary_fnc_set;
[arjay_agentCivilianHouseTracks, "Track8", 235] call Dictionary_fnc_set;
[arjay_agentCivilianHouseTracks, "Track9", 246] call Dictionary_fnc_set;
[arjay_agentCivilianHouseTracks, "Track10", 292] call Dictionary_fnc_set;
[arjay_agentCivilianHouseTracks, "Track11", 189] call Dictionary_fnc_set;
[arjay_agentCivilianHouseTracks, "Track12", 203] call Dictionary_fnc_set;