/*
	File: arjay_kickstart_server.sqf
	Author: ARJay
	Description: ARJay LIB Agent Server Init
*/

diag_log "--- ARJay Agents Server INIT -------------------------------------------------------------------------";

call compile preprocessFileLineNumbers "arjay\arjay_announce.sqf";
call compile preprocessFileLineNumbers "arjay\arjay_camera.sqf";
call compile preprocessFileLineNumbers "arjay\arjay_effect.sqf";
call compile preprocessFileLineNumbers "arjay\arjay_environment.sqf";
call compile preprocessFileLineNumbers "arjay\arjay_garbage_collection.sqf";
call compile preprocessFileLineNumbers "arjay\arjay_gear.sqf";
call compile preprocessFileLineNumbers "arjay\arjay_group.sqf";
call compile preprocessFileLineNumbers "arjay\arjay_marker.sqf";
call compile preprocessFileLineNumbers "arjay\arjay_modify.sqf";
call compile preprocessFileLineNumbers "arjay\arjay_monitor.sqf";
call compile preprocessFileLineNumbers "arjay\arjay_position.sqf";
call compile preprocessFileLineNumbers "arjay\arjay_spawn.sqf";
call compile preprocessFileLineNumbers "arjay\arjay_task.sqf";
call compile preprocessFileLineNumbers "arjay\arjay_util.sqf";
call compile preprocessFileLineNumbers "arjay\arjay_vehicle.sqf";
call compile preprocessFileLineNumbers "arjay\arjay_world.sqf";
call compile preprocessFileLineNumbers "arjay\agent\arjay_agent.sqf";
call compile preprocessFileLineNumbers "arjay\agent\arjay_agent_controller_mission.sqf";
call compile preprocessFileLineNumbers "arjay\agent\arjay_agent_controller_civilian.sqf";
call compile preprocessFileLineNumbers "arjay\agent\arjay_agent_controller_east.sqf";
call compile preprocessFileLineNumbers "arjay\agent\arjay_agent_controller_west.sqf";
call compile preprocessFileLineNumbers "arjay\agent\arjay_agent_presets.sqf";
call compile preprocessFileLineNumbers "arjay\agent\arjay_agent_profile.sqf";
call compile preprocessFileLineNumbers "arjay\agent\arjay_agent_utils.sqf";
call compile preprocessFileLineNumbers "arjay\server\arjay_server.sqf";

// inlcude the RUBE script library
#include "third_party\RUBE\init.sqf"

arjay_missionName = "arjay_sandbox";

arjay_debug = false; // output debug messages

// enable main arjay monitoring loop
[] call arjay_monitor;

// start the agent system
[] call arjay_initAgents;

// generate world data
//[false, true] call arjay_agentsGenerateStaticData;

// generate mission data
//[true] call arjay_agentsGenerateStaticData;