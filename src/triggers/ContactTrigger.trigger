// ------------------------------------------------------------------------------------
// Contact Trigger
// Version#   Date           Author              Description
// ------------------------------------------------------------------------------------
// 1.0        26-Apr-2016    Puneet              Initial Version
// ------------------------------------------------------------------------------------
trigger ContactTrigger on Contact (after insert) {
	TriggerDispatcher.Run(new ContactTriggerHandler()); 
}