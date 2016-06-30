/**
* Test class for BE 110
* @Author : Puneet Sardana
* @Created Date : 23/06/2016
*/
@isTest
public class ValidationEngine_BE110_Test {
     static Contact cnt;
     static Rule_Criteria__c ruleCriteria;
     static Class_Rules_Mapping__c classRuleMapping;
    @testSetUp
     static void createData() {
        Validation_Rule__c vRule= BETestUtility.getValidationRule(true,'Class Specific');
        insert vRule;
        List<Validation_Rule_Components__c> vListComponents = new List<Validation_Rule_Components__c>();
        vListComponents.add(BETestUtility.getValidationComponent(vRule.Id,1,'Horse','Horse__c','Age_of_Horse__c','Id','greater or equal','Value','5',null,null,null));
        vListComponents.add(BETestUtility.getValidationComponent(vRule.Id,2,'Horse','Horse__c','Height__c','Id','greater or equal','Value','142',null,null,null));
        vListComponents.add(BETestUtility.getValidationComponent(vRule.Id,3,'Horse','Asset','Product_Name__c','Horse__c','equals','Value','Valid Training Pass,Half Season Ticket,Full Season Ticket',null,null,null));
        vListComponents.add(BETestUtility.getValidationComponent(vRule.Id,4,'Rider','Asset','Product_Name__c','Member__c','equals','Value','Full Membership,Day Pass Membership,Valid Day Pass',null,null,null));
        insert vListComponents;
        List<Rule_Criteria__c> lstRuleCriteria = new List<Rule_Criteria__c>();
        lstRuleCriteria.add(BETestUtility.getRuleCriteria(vRule.Id,2,'Horse', 'Is Not Met','1 AND 2 AND 3','BE110-MSG01','Horse did not have Valid membership',
                                                                                     'Horse does not have a valid membership','Mandatory','Runtime'));
        lstRuleCriteria.add(BETestUtility.getRuleCriteria(vRule.Id,1,'Rider', 'Is Not Met','4','BE110-MSG03','Rider did not have a valid membership',
                                                                                     'Rider does not have a valid membership','Mandatory','Runtime'));
        insert lstRuleCriteria;
        Class_Type__c cType = BETestUtility.getClassType('BE90 PC', 'A', 'BE90 PC Description ');
        insert cType;
        Class_Rules_Mapping__c crm = BETestUtility.getClassRuleMapping(cType.Id, vRule.Id);
        insert crm;
     }
    @isTest
    static void test_BE110_MSG01() {
        Test.setMock(HttpCalloutMock.class, new Validation_BE110_MockResponseGenerator());
        Account acc = BETestUtility.getAccount(BEHelper.getRecordTypeId(Account.sObjectType, BEConstants.RT_ACCOUNT_HOUSEHOLD),  'Test Puneet Account');
        insert acc;
        Contact rider = BETestUtility.getContact(BEHelper.getRecordTypeId(Contact.sObjectType, BEConstants.RT_CONTACT_MEMBER), 'Test Contact');
        insert rider;
        Horse__c hor = BETestUtility.getHorse('Anjali ', rider.Id, '2010');
        hor.Passport_Number__c = 'ABC123456789123';
        hor.Height__c = 150;
        insert hor;
        Class_Type__c cType = [SELECT Id
                                                FROM Class_Type__c
                                                WHERE Name = 'BE90 PC'
                                                LIMIT 1];
        Event__c event = BETestUtility.getEvent(Date.today().addDays(4), Date.today().addDays(20));
        insert event;
        Class__c cls = BETestUtility.getClass(cType.Id, event.Id);
        insert cls;
        Product2 prodValidTrainingPass,prodHalfSeason,fullSeason,fullMembership,dayPassMembership,validDayPass;
        List<Product2> lstProduct = new List<Product2>();
        lstProduct.add(prodValidTrainingPass = BETestUtility.getProduct(BEHelper.getRecordTypeId(Product2.sObjectType, BEConstants.RT_PRODUCT_MEMBERSHIP),'Valid Training Pass'));
        lstProduct.add(prodHalfSeason = BETestUtility.getProduct(BEHelper.getRecordTypeId(Product2.sObjectType, BEConstants.RT_PRODUCT_MEMBERSHIP),'Half Season Ticket'));
        lstProduct.add(fullSeason = BETestUtility.getProduct(BEHelper.getRecordTypeId(Product2.sObjectType, BEConstants.RT_PRODUCT_MEMBERSHIP),'Full Season Ticket'));
        lstProduct.add(fullMembership = BETestUtility.getProduct(BEHelper.getRecordTypeId(Product2.sObjectType, BEConstants.RT_PRODUCT_MEMBERSHIP),'Full Membership'));
        lstProduct.add(dayPassMembership = BETestUtility.getProduct(BEHelper.getRecordTypeId(Product2.sObjectType, BEConstants.RT_PRODUCT_MEMBERSHIP),'Day Pass Membership'));
        lstProduct.add(validDayPass = BETestUtility.getProduct(BEHelper.getRecordTypeId(Product2.sObjectType, BEConstants.RT_PRODUCT_MEMBERSHIP),'Valid Day Pass'));
        insert lstProduct;
        List<Asset> lstAssets = new List<Asset>();
        Asset ass1,ass2;

        lstAssets.add(ass1 = BETestUtility.getAsset(BEHelper.getRecordTypeId(Asset.sObjectType, BEConstants.RT_ASSET_MEMBERSHIP), 'Asset 1', acc.Id,  prodValidTrainingPass.Id, null, hor.Id));
        lstAssets.add(ass2 = BETestUtility.getAsset(BEHelper.getRecordTypeId(Asset.sObjectType, BEConstants.RT_ASSET_MEMBERSHIP), 'Asset 5', acc.Id,  validDayPass.Id, rider.Id, null));
        ass1.Life_Membership__c = true;
        ass2.Life_Membership__c = true;
        insert lstAssets;
        Entry__c entry = BETestUtility.getEntry(cls.Id,  event.Id,  rider.Id, hor.Id);
        insert entry;
        Test.startTest();
            System.debug('Puneet Test class result '+ValidationEngine.validateEntries(new List<Id> { entry.Id },false));
        Test.stopTest();

    }
}