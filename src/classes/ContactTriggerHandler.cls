// ------------------------------------------------------------------------------------
// Trigger handler for contact
// Version#   Date           Author              Description
// ------------------------------------------------------------------------------------
// 1.0        26-Apr-2016    Puneet              Initial Version
// ------------------------------------------------------------------------------------
public class ContactTriggerHandler implements ITriggerHandler {	
    public static Boolean TriggerDisabled = false;
    // 26/04/2016  Puneet Sardana  Checks whether trigger is disabled or not
    public Boolean IsDisabled() {
      for(BE_Trigger_Setting__mdt setting : [SELECT TriggerDisabled__c
    									                       FROM BE_Trigger_Setting__mdt
    									                       WHERE DeveloperName = :BEConstants.CONTACT_TRIGGER
    									                       LIMIT 1] ) {
    		TriggerDisabled = setting.TriggerDisabled__c; 
       }
       return TriggerDisabled;
    }
   // 26-Apr-2016    Puneet    This does the following 
   //                           a. Create Account for those member contact which are not associated with Account.
   //                           b. Link Contact with Account
   // @params 
   // newItems - Map of Contact Id and Contact  
   // @return - NA
    public void AfterInsert(Map<Id, SObject> newItems) { 
    	List<Contact> lstContactWithoutAccount = new List<Contact>();
    	Contact tempCon;
    	String conMemberRTId = BEHelper.getRecordTypeId(Contact.sObjectType, BEConstants.RT_CONTACT_MEMBER);
    	for(Id con : newItems.keySet()) {
    		tempCon = (Contact)newItems.get(con);
    		if(tempCon.AccountId == null && tempCon.RecordTypeId == conMemberRTId) {
    			lstContactWithoutAccount.add(tempCon);
    		}
    	}
    	// Create Account 
    	Map<Id,Account> mapConAccount = createAccount(lstContactWithoutAccount);
    	// Link Contacts with Account
    	List<Contact> linkedContacts = linkContactWithAccount(mapConAccount);
    }  
   // 26-Apr-2016    Puneet    This method creates Account for Contact if there isnt one
   // @params 
   // lstContacts - List of Contacts for which Account should be created   
   // @return - Map of Contact Id and Associate Account
    private Map<Id,Account> createAccount(List<Contact> lstContacts) {
    	Map<Id,Account> mapContactAccount = new Map<Id,Account>(); 
    	String accHouseholdRTId = BEHelper.getRecordTypeId(Account.sObjectType, BEConstants.RT_ACCOUNT_HOUSEHOLD);
    	for(Contact con : lstContacts) {
    		mapContactAccount.put(con.Id,new Account (RecordTypeId = accHouseholdRTId,
    										  		  Name = con.LastName + ' ' + BEConstants.HOUSEHOLD_SUFFIX));
    	}
    	try {
    		insert mapContactAccount.values();  
    	} catch(Exception ex) {
    		//To Do : Error handling
        System.debug(ex);
    	}
    	return mapContactAccount;
    }  
   // 26-Apr-2016    Puneet    This method links contact with Account
   // @params 
   // conAccountMap - Map of Contact Id and associated Account 
   // @return - Map of Contact Id and Associate Account
    private List<Contact> linkContactWithAccount(Map<Id,Account> conAccountMap) {
    	List<Contact> contactsToLink = new List<Contact>();    	
    	for(Id con : conAccountMap.keySet()) {
    		contactsToLink.add(new Contact( Id = con,
    										AccountId = conAccountMap.get(con).Id));
    	}
    	try {
    		update contactsToLink;
    	} catch(Exception ex) {
    		//To Do : Error handling
        System.debug(ex);
    	}
    	return contactsToLink;
    }
    public void BeforeInsert(List<SObject> newItems) { }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
    public void BeforeDelete(Map<Id, SObject> oldItems) {}    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) { }
    public void AfterDelete(Map<Id, SObject> oldItems) {}
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
}