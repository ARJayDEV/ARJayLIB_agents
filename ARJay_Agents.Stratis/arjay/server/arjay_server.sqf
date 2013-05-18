/*
	File: arjay_server.sqf
	Author: ARJay
	Description: Server to client comms
*/

/*
	Broadcast a command
*/
arjay_broadcastClientCommand = 
{
	private ["_command", "_params", "_callType"];
	
	_command = _this select 0;
	_params = _this select 1;
	_callType = if(count _this > 2) then {_this select 2} else {"call"};
	
    arjay_commandRoute = [_command, _params, _callType];
	publicVariable "arjay_commandRoute";
};

/*
	Send a command
*/
arjay_sendClientsCommand = 
{
	private ["_clients", "_command", "_params", "_callType", "_clientId"];
	
	_clients = _this select 0;
	_command = _this select 1;
	_params = _this select 2;
	_callType = if(count _this > 3) then {_this select 3} else {"call"};
	
	arjay_commandRoute = [_command, _params, _callType];
	
	{
		_clientId = owner _x;		
		_clientId publicVariableClient "arjay_commandRoute";
	} forEach _clients;   
};