/*
	File: arjay_client.sqf
	Author: ARJay
	Description: Client side handling
	Thanks to KillzoneKid for this one
*/

/*
	Event handler
*/
arjay_commandRoute = []; "arjay_commandRoute" addPublicVariableEventHandler 
{
    (_this select 1) call arjay_command;
};

/*
	Command undefined
*/
arjay_commandError = 
{
	//diag_log format["Client command undefined %1 [%2]", _this select 0, _this];
};

/*
	Command router
*/
arjay_command = 
{
	private ["_command", "_params", "_type"];
	
	_command = _this select 0;
	_params = _this select 1;
	_type = _this select 2;
	
	//diag_log format["Client command received %1 [%2]", _command, _params];
	
	_command = missionNamespace getVariable [format ["%1", _command], arjay_commandError];
	
	if (_type == "call") then 
	{
		_params call _command;
	} 
	else 
	{
		null = _params spawn _command;
	};
};

/*
	Command Create Room Music
*/
arjay_clientCommandCreateRoomMusic = 
{
	private ["_target", "_source", "_track"];
	
	//diag_log format["Client command Create Room Music [%2]", _this select 0, _this];
	
	_target = _this select 0;
	_source = _this select 1;
	_track = _this select 2;
	
	_source attachTo [_target,[1,1,1]];
	hideObject _source;
	
	_source say3d _track;
};

/*
	Command Create Room Light
*/
arjay_clientCommandCreateRoomLight = 
{
	private ["_target", "_colour", "_brightness", "_light"];
	
	//diag_log format["Client command Create Room Light [%2]", _this select 0, _this];
	
	_target = _this select 0;
	_light = _this select 1;
	_brightness = _this select 2;
	_colour = _this select 3;
		
	_light setLightBrightness _brightness;
	_light setLightColor _colour;
	_light lightAttachObject [_target, [1,1,1]];
};

/*
	Command Trigger Switch Move
*/
arjay_clientCommandSwitchMove = 
{
	private ["_target", "_move"];
	
	//diag_log format["Client command Switch Move [%2]", _this select 0, _this];
	
	_target = _this select 0;
	_move = _this select 1;
	
	_target switchMove _move;
};

/*
	Command Display Capture Dialog
*/
arjay_clientCommandDisplayCaptureDialog = 
{
	private ["_title", "_text", "_displayUI"];
	
	//diag_log format["Client command Display Capture Dialog [%2]", _this select 0, _this];
	
	_title = _this select 0;
	_text = _this select 1;
	
	2 cutRsc ["ARJAY_CAPTURE_DIALOG","PLAIN"];
	_displayUI = uiNamespace getVariable 'ARJAY_CAPTURE_DIALOG';
	(_displayUI displayCtrl 1001) ctrlSetText _title;
	(_displayUI displayCtrl 1002) ctrlSetText _text;
};

/*
	Command Update Capture Dialog
*/
arjay_clientCommandUpdateCaptureDialog = 
{
	private ["_title", "_text", "_displayUI"];
	
	//diag_log format["Client command Update Capture Dialog [%2]", _this select 0, _this];
	
	_title = _this select 0;
	_text = _this select 1;
	
	_displayUI = uiNamespace getVariable 'ARJAY_CAPTURE_DIALOG';
	(_displayUI displayCtrl 1001) ctrlSetText _title;
	(_displayUI displayCtrl 1002) ctrlSetText _text;
};