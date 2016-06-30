/**
 * Trigger on Opportunity to create Quote and Order
 * @author Digamber Prasad
 * */
trigger OpportunityTrigger on Opportunity (after insert, after update) {
	TriggerDispatcher.Run(new OpportunityTriggerHandler()); 
}