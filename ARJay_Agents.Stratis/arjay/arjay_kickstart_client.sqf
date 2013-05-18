/*
	File: arjay_kickstart_client.sqf
	Author: ARJay
	Description: ARJay LIB Agent Client Init
*/

diag_log "--- ARJay Agents Client INIT -------------------------------------------------------------------------";

call compile preprocessFileLineNumbers "arjay\client\arjay_client.sqf";

/*
if(name player == "ARJay") then
{
	onMapSingleClick "vehicle player setPos _pos; true;";
	player setCaptive true;
};
*/