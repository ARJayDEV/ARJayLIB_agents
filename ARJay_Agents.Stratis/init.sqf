/*
	File: init.sqf
	Author: ARJay
	Description: Main init
*/

//#include "initBriefing.hpp"
//#include "initMission.hpp"

enableSaving [false, false];

arjay_agentRunHeadless = false;
arjay_isMultiplayerHost = false;
arjay_isHeadlessClient = false;

if(isServer) then
{
	// sp or mp server
	if!(arjay_agentRunHeadless) then
	{
		#include "arjay\arjay_kickstart_server.sqf"
	};
	
	if(hasInterface) then
	{
		// mp non dedicated host
		if(isMultiplayer) then
		{
			arjay_isMultiplayerHost = true;
		};
	};
}
else
{
	if(hasInterface) then
	{
		waitUntil{!isNull player};
		// mp client
		#include "arjay\arjay_kickstart_client.sqf"
	}
	else
	{
		// headless client
		if(arjay_agentRunHeadless) then
		{
			arjay_isHeadlessClient = true;
			#include "arjay\arjay_kickstart_server.sqf"
		};
	};
};