/**
 * Handler for OpportunityTrigger
 * @author Digamber Prasad
 * */
public with sharing class OpportunityTriggerHandler implements ITriggerHandler{
    
	/**
	* Method which checks if trigger need to run or not
	* @param none
	* @return boolean
	* */
	public boolean isDisabled() {
        
		BE_Trigger_Setting__mdt setting = [SELECT TriggerDisabled__c FROM BE_Trigger_Setting__mdt WHERE DeveloperName =: BEConstants.OPPORTUNITY_TRIGGER];

		return (setting!=null ? setting.TriggerDisabled__c : false);
    }

    /**
    * Method which runs on after insert event
    * @param Map<Id, SObject> map of new Opportunities
    * @return void
    * */
    public void afterInsert(Map<Id, SObject> newItems) { 

        /*
        List<Opportunity> lstClosedOppty = new List<Opportunity>();

        for(Id i : newItems.keySet()){

            Opportunity oppty = (Opportunity)newItems.get(i);
            
            if(oppty.Is_Order_Created__c){
                lstClosedOppty.add(oppty);
            }
        }

        if(lstClosedOppty.size() > 0)
            OpportunityTriggerHelper.createQuoteAndOrder(lstClosedOppty);
        */
    }

    /**
    * Method which runs on after update event
    * @param Map<Id, SObject> map of new Opportunities
    * @param Map<Id, SObject> map of old Opportunities
    * @return void
    * */
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) { 

        List<Opportunity> lstOppty = new List<Opportunity>();

        for(Id i : newItems.keySet()){

            Opportunity newOppty = (Opportunity)newItems.get(i);
            Opportunity oldOppty = (Opportunity)oldItems.get(i);
            
            if(newOppty.Is_Order_Created__c != oldOppty.Is_Order_Created__c && newOppty.Is_Order_Created__c){
                lstOppty.add(newOppty);
            }
        }

        if(lstOppty.size() > 0)
            OpportunityTriggerHelper.createQuoteAndOrder(lstOppty);
    }
    
   public void beforeInsert(List<SObject> newItems) { }
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) { }
    public void beforeDelete(Map<Id, SObject> oldItems) { }
    public void afterDelete(Map<Id, SObject> oldItems) { }
    public void afterUndelete(Map<Id, SObject> oldItems) { }

}