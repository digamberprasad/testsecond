@isTest
private class OorderTriggerHandlerTest {
	
	static Opportunity opp;
	//static Order ord;
    static Account acc;
    static Contact con;
    static OpportunityLineItem oli;
    static Product2 pod;
    //static Order ord;
//Whenever an Opportunity is update is added to an Opportunity 
		
		@isTest
	public static void testCreateAssets() {
		Test.startTest();
        
      
        
        //define the standart price for the product
      /*  Id priceBkStdId = Test.getStandardPricebookId();
        insert new PricebookEntry(pricebook2id = priceBkStdId ,product2id = p.id,unitprice=1.0, isActive=true);
        */
        
        pod = BETestUtility.getProduct(BEHelper.getRecordTypeId(Product2.sObjectType,
                                                                BEConstants.RT_PRODUCT_MEMBERSHIP),'TNikhil');
        insert pod;
		
        Id priceBookstdId = Test.getStandardPricebookId();
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=priceBookstdId, product2id=pod.id,unitprice=2.0, isActive=true);
        insert pbe;
        
        acc = BETestUtility.getAccount(BEHelper.getRecordTypeId(Account.sObjectType, 
				  BEConstants.RT_ACCOUNT_HOUSEHOLD), 'TNikhil');
        insert acc;
        
        con = BETestUtility.getContact(BEHelper.getRecordTypeId(Contact.sObjectType, 
				  BEConstants.RT_CONTACT_MEMBER), 'TNikhil');
			insert con;
        
        opp = BETestUtility.getOpportunity(BEHelper.getRecordTypeId(Opportunity.sObjectType, 
				  BEConstants.RT_OPPORTUNITY_PRODUCT), 'Product', System.today() , 'Perception Analysis');
			insert opp;

        	oli = new OpportunityLineItem(OpportunityId = opp.id, PriceBooKEntryId = pbe.Id,Quantity = 1,TotalPrice = 5.0);
        	insert oli;
        	
        Order ord = new Order(OpportunityId = opp.Id,
        				ShipToContact = con,
        				Status = 'Activated');
        insert ord;

			opp.Is_Order_Created__c = true ;
        	opp.AccountId = acc.Id;
        	opp.Purchasing_Member__c = con.Id;
        	opp.Pricebook2Id = priceBookstdId;
			update opp;
			
        		
			
			//String insertAccName = con.LastName + ' ' + BEConstants.HOUSEHOLD_SUFFIX;
			List<Order> lstOrd = [SELECT Id,Name
						 	     FROM Order
						         WHERE Id = :opp.Id];
        	System.debug(lstOrd.size());
			System.assert(lstOrd.size() == 0);
					Test.stopTest();
	}
	
	

	
}