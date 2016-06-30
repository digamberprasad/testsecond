/**
 * Trigger on Order to create Assets
 * @author Digamber Prasad
 * */
trigger OrderTrigger on Order (after insert, after update) {
	TriggerDispatcher.Run(new OrderTriggerHandler()); 
}