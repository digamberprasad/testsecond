/**
 * Handler for OrderTrigger
 * @author Digamber Prasad
 * */
public with sharing class OrderTriggerHandler implements ITriggerHandler {

	/**
	* Method which checks if trigger need to run or not
	* @param none
	* @return boolean
	* */
	public boolean isDisabled() {

		BE_Trigger_Setting__mdt setting = [SELECT TriggerDisabled__c FROM BE_Trigger_Setting__mdt WHERE DeveloperName =: BEConstants.ORDER_TRIGGER];

		return (setting!=null ? setting.TriggerDisabled__c : false);
	}

	/**
	* Method which runs on after insert event
	* @param Map<Id, SObject> map of new Orders
	* @return void
	* */
	public void afterInsert(Map<Id, SObject> newItems) { }

	/**
	* Method which runs on after update event
	* @param Map<Id, SObject> map of new Orders
	* @param Map<Id, SObject> map of old Orders
	* @return void
	* */
	public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) { 
		
		List<Order> lstOrderToProcess = new List<Order>();

		for(Id i : newItems.keySet()){

			Order newOrder = (Order)newItems.get(i);
			Order oldOrder = (Order)oldItems.get(i);

			if(newOrder.Status != oldOrder.Status && newOrder.Status == 'Payment Successful')
				lstOrderToProcess.add(newOrder);
			
		}

		if(lstOrderToProcess.size() > 0)
			OrderTriggerHelper.createAssets(lstOrderToProcess);
	}

	public void beforeInsert(List<SObject> newItems) { }
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) { }
    public void beforeDelete(Map<Id, SObject> oldItems) { }
    public void afterDelete(Map<Id, SObject> oldItems) { }
    public void afterUndelete(Map<Id, SObject> oldItems) { }

}