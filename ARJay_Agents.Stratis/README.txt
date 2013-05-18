==========================================
ARJAY ARMA 3 Agent System 0.1 ALPHA
==========================================

The ARJay agents system is a dynamic AI generator for locations - villages, towns, cities and military installations (at the moment). 
Bringing dynamic life to Stratis, the agent system will populate all locations on the island. 

Generated agents don't just stand around, the system runs a number of AI subroutines to give agents the illusion of intelligence (up to a point.. their driving skills leave a lot to be desired!). 
Civilians will congregate for meetings, walk around their locations, turn on house lights in the evening, turn on music in their houses, sleep, go for drives to other locations..
Military agents will patrol their bases, patrol using vehicles (land and air currently) to other locations, man static weapons, garison strong points..

The system uses a distance based garbage collection system to remove agents and vehicles from locations depending on how close any players are. If players return to locations the system
remembers agents who have been killed when recreating them, giving the illusion of a whole island of activity but keeping performance as the main focus.

The system is entirely script based, you can configure the world of Stratis to be however you want it, have all locations occupied by OPFOR, or BLUFOR, or a mixture.
Locations can be setup to be occupied by mulitple groups, so a firefight may be in progress when you arrive.. There are a host of configurable options to tailor the system to you mission.

Locations can be captured by eliminating all agents within it, map markers can be created to display current location occupation.

The system works with single player, multiplayer, client server, and dedicated server setups.

This is a alpha release of the system, I would apreciate some help with testing the system. If you want to help test please let me know.


THE FUTURE
------------------------------------------------------
Faction command / intelligence, a commander for each faction that reacts to changes on the battlefield, directing re-inforcements etc.
Ambient traffic / non location based agents
I have a lot of ideas for new extended features, if you do as well, let me know.


THE TEST MISSION
------------------------------------------------------
The agent system comes with a co-op test mission, the mission has no tasks just displays the system running in a multiplayer environment.


INSTALLATION
------------------------------------------------------

It's probably easiest to modifiy the test mission to suit your needs, but if you want to install the agent system in your own mission you need to:

copy the following files and folders to your mission folder

arjay/
functions/
arjay_config.hpp

copy the contents of the init.sqf to your own init.sqf

copy the following into your description.ext

// arjay config
#include "arjay_config.hpp"


CONFIGURATION
------------------------------------------------------

The majority of user editable settings are defined in the file:

arjay/agent/arjay_agent_presets.sqf

Probably the most important part of these settings are the mission location settings (excerpt below). These settings control the side or sides present at a given location.
So for example

[arjay_missionLocations, "Agia Marina", [["CIV"],[[0.5, 0.3, objNull, 0, []]]]] call Dictionary_fnc_set;

Sets Agia Marina as occupied by civilians
For every building in the location there will be a 0.5 probability (50%) that an agent will spawn inside it
For every building in the location there will be a 0.3 probability (30%) that a vehicle will spawn outside it
The objNull is a placeholder for the created map marker if using map markers (do not edit)

Anothe example for an OPFOR occupied location

[arjay_missionLocations, "LZ Connor", [["EAST"],[[1, 1, objNull, 1, ["FIRETEAM"]]]]] call Dictionary_fnc_set;

Sets LZ Connor as occupied by EAST (OPFOR)
For every building in the location there will be a 1 probability (100%) that an agent will spawn inside it
For every building in the location there will be a 1 probability (100%) that a vehicle will spawn outside it
The objNull is a placeholder for the created map marker if using map markers (do not edit)
For every agent spawned in the location there will be a 1 probability (100%) that the agent will be in command of a group of units
And the ["FIRETEAM"] array defines the group types that will be spawned. You can add multiple group types and the system will randomly chose one for each agent in command (see arjay/arjay_group.sqf to modify or add your own group types)


AI CONFIGURATION
------------------------------------------------------

You can configure the AI settings for each side in their controllers

arjay/agent/arjay_agent_controller_civillian.sqf - Civilian AI controller
arjay/agent/arjay_agent_controller_east.sqf - East AI controller
arjay/agent/arjay_agent_controller_west.sqf - West AI controller

Within these controllers you can set the AI subroutines that can be used by the agents by modifying their allowed commands:

arjay_agentCivilianAllowedCommands = ["IDLE", "WALK", "HOUSEWORK", "SLEEP", "OBSERVE", "CAMPFIRE", "MEETING_INIT", "GATHERING_INIT", "TASK"];

You can also alter the probabilites of the commands for example the random walk civilian command:

// walk [probability, maxDistance]
arjay_agentCivilianCommand = call Dictionary_fnc_new;
[arjay_agentCivilianCommand, "DAY", [0.5, 60]] call Dictionary_fnc_set;
[arjay_agentCivilianCommand, "EVENING", [0.1, 60]] call Dictionary_fnc_set;
[arjay_agentCivilianCommand, "NIGHT", [0.01, 60]] call Dictionary_fnc_set;
[arjay_agentCivilianCommands, "WALK", arjay_agentCivilianCommand] call Dictionary_fnc_set;

These settings effect how the probability of the command being issued to an agent based on the time of day.

NOTE:
Currently the civilian AI subroutines "ROGUE", "IED", "SUICIDE_BOMBER" are disabled due to bugs currently in the ARMA 3 engine, as reported here:

http://feedback.arma3.com/view.php?id=8169

Please upvote this issue so I can complete this functionality.


PERFORMANCE
------------------------------------------------------

Be careful with the spawn rate settings in the larger towns - The airfield and agia marina can be slow if you set a 100% probabilty of agent spawning for every building and have every building spawn a vehicle.
These spawn settings may need adjustment according to your requirements / number of players etc.

I have tested the agent system mainy on single player, which has hopefully eliminated most bugs, if you find a bug I would appreciate a response in the BI forum thread.

I have done limited testing on dedicated servers, it seems to work, but I need more player load to properly test. If you have a dedicated server and can spare some time to assist in testing please let me know.


DEBUG
------------------------------------------------------

I have released a debug and non debug versions. The non debug version should be used in real play. 
The debug version will describe the agent system processes to the RPT file, you can set the debug output level in 

arjay/arjay_kickstart_server.sqf 

Turn on debug mode to travel instantly when you click on the map, useful for testing mission setup.


THANKS
------------------------------------------------------

To the awesome community, who have already answered most of my questions
at some point in the long history of arma modding and scripting. In particular to:
armaholic staff for curating a heap of content and posts
bi forum staff for the same
kylania for some great more advanced code snippets and forum responses
Sickboy for his class reference browser
KillzoneKid for his callback system in MP environment
RUEBE if your still around man, your library is amazing - I use the convex hull functions to great effect - Thank you!