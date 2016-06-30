@isTest
public class ContactTriggerHandlerTest {
	static Contact con;
	static Account acc;
	// Create auto account when Contact is member and no account is associated
	@isTest
	public static void testCreateAccountAndLink() {
		Test.startTest();
			con = BETestUtility.getContact(BEHelper.getRecordTypeId(Contact.sObjectType, 
				  BEConstants.RT_CONTACT_MEMBER), 'TPuneet');
			insert con;
			String insertAccName = con.LastName + ' ' + BEConstants.HOUSEHOLD_SUFFIX;
			List<Account> lstAcc = [SELECT Id,Name
						 	     FROM Account
						         WHERE Name = :insertAccName];
			System.assert(lstAcc.size() > 0);
			con = [SELECT Id,AccountId
				   FROM Contact
				   WHERE Id = :con.Id];
			System.assert(con.AccountId == lstAcc[0].Id);
        
        
		Test.stopTest();
	}
	// No account is created since account id is associated
	@isTest
	public static void testNoAccountCreation() {
		Test.startTest();
			acc = BETestUtility.getAccount(BEHelper.getRecordTypeId(Account.SObjectType,
										   BEConstants.RT_ACCOUNT_HOUSEHOLD),'TestPAccount');
			insert acc;
			con = BETestUtility.getContact(BEHelper.getRecordTypeId(Contact.sObjectType, 
				  BEConstants.RT_CONTACT_MEMBER), 'TPuneet');
			con.AccountId = acc.Id;
			insert con;
			String insertAccName = con.LastName + ' ' + BEConstants.HOUSEHOLD_SUFFIX;
			List<Account> lstAcc = [SELECT Id,Name
						 	     	FROM Account
						         	WHERE Name = :insertAccName];
			System.assert(lstAcc.size() == 0);							
		Test.stopTest();
	}
	// No accout created since record type of contact is general
	@isTest
	public static void testNoAccountCreationRecordType() {
		Test.startTest();
			acc = BETestUtility.getAccount(BEHelper.getRecordTypeId(Account.SObjectType,
										   BEConstants.RT_ACCOUNT_HOUSEHOLD),'TestPAccount');
			insert acc;
			con = BETestUtility.getContact(BEHelper.getRecordTypeId(Contact.sObjectType, 
				  BEConstants.RT_CONTACT_GENERAL), 'TPuneet');			
			insert con;
			String insertAccName = con.LastName + ' ' + BEConstants.HOUSEHOLD_SUFFIX;
			List<Account> lstAcc = [SELECT Id,Name
						 	     	FROM Account
						         	WHERE Name = :insertAccName];
			System.assert(lstAcc.size() == 0);		 					
		Test.stopTest();
        
        
	}
}