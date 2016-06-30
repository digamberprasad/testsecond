/**
 * Extension Controller for Opportunity_To_Order page
 * @author Digamber Prasad
 * */
public with sharing class OpportunityToOrderController{
    
    private final Opportunity oppty;
    
	/**
	* Constructor of Extensions
	* */
	public OpportunityToOrderController(ApexPages.StandardController stdController){
		
		this.oppty = [Select Id, Is_Order_Created__c from Opportunity where Id =: ((Opportunity)stdController.getRecord()).Id];
	}

	/**
	* Method which will check if Opportunity is already process or not. If processed it will redirect user to message page else mark opportunity as processed. Based upon this check box trigger will kick in to create Quote, Order and respective Line Items
	* @param none
	* @return PageReference
	* */
	public PageReference processOpportunity(){

		if(!oppty.Is_Order_Created__c){
			
			oppty.Is_Order_Created__c = true;
			update oppty;

			return new PageReference('/apex/Payment_Process');
		}

		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Opportunity_processed));

		return null;
	}

	/**
	* When user clicks on page it will go back to Opportunity Page
	* @param none
	* @return PageReference
	* */
	public PageReference back(){
		return new PageReference('/' + oppty.Id);
	}
}