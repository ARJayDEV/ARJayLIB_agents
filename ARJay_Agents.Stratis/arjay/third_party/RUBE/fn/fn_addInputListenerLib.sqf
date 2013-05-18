/*
   private functions for RUBE inputListeners
*/

// this is where we keep our displayEventHandlers (used in fn_addInputListener.sqf)
// :inputListenerID: => [display, handlername, original-id, code]
RUBE_INTERN_INPUT_LISTENERS = [];
// holds old/discarded inputListener slots/ids we may reuse
RUBE_INTERN_INPUT_LISTENERS_FREE = [];


// [inputListenerID, eventHandler's _this] => boolean
RUBE_addInputListenerCall = {
   private ["_id", "_msg", "_n"];
   
   _id = _this select 0;
   
   // out of bounds
   _n = count RUBE_INTERN_INPUT_LISTENERS;
   if (_n < _id) exitWith {};
   
   (_this call ((RUBE_INTERN_INPUT_LISTENERS select _id) select 3))
};