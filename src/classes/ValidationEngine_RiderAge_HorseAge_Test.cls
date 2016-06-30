/**
* Test class for BE 110
* @Author : Anjali Pande
* @Created Date : 23/06/2016
*/
@isTest
public class ValidationEngine_RiderAge_HorseAge_Test {
     static Contact cnt;
     static Rule_Criteria__c ruleCriteria;
     static Class_Rules_Mapping__c classRuleMapping;
    @testSetUp
     static void createData() {
        Validation_Rule__c vRule= BETestUtility.getValidationRule(true,'Class Specific');
        insert vRule;
        List<Validation_Rule_Components__c> vListComponents = new List<Validation_Rule_Components__c>();
        vListComponents.add(BETestUtility.getValidationComponent(vRule.Id,1,'Horse','Horse__c','Age_of_Horse__c','Id','less or equal','Value','6',null,null,null));
        vListComponents.add(BETestUtility.getValidationComponent(vRule.Id,2,'Rider','Contact','Age__c','Id','less or equal','Value','17',null,null,null));
        insert vListComponents;
        List<Rule_Criteria__c> lstRuleCriteria = new List<Rule_Criteria__c>();
        lstRuleCriteria.add(BETestUtility.getRuleCriteria(vRule.Id,1,'Horse', 'Is Met','1','msg1','Horse age should be more than 6 years as on 1st  Jan on the year in which it was foaled',
                                                        'Horse age should be more than 6 years as on 1st  Jan on the year in which it was foaled','Mandatory','Runtime'));
        lstRuleCriteria.add(BETestUtility.getRuleCriteria(vRule.Id,2,'Rider', 'Is Met','2','msg2','Rider age should be more than 17 years of age',
                                                                                     'Rider age should be more than 17 years of age','Mandatory','Runtime'));
        insert lstRuleCriteria;
        Class_Type__c cType = BETestUtility.getClassType('Testing', '', '');
        insert cType;
        Class_Rules_Mapping__c crm = BETestUtility.getClassRuleMapping(cType.Id, vRule.Id);
        insert crm;
     }
    @isTest
    static void test_BE110_MSG01() {
        
        Test.setMock(HttpCalloutMock.class, new HorseRiderAge_MockResponseGenerator());

        Contact rider = BETestUtility.getContact(BEHelper.getRecordTypeId(Contact.sObjectType, BEConstants.RT_CONTACT_MEMBER), 'Test Contact');
        rider.BirthDate=Date.parse('22/06/2009');
        insert rider;
        Horse__c hor = BETestUtility.getHorse('Puneet ', rider.Id, '2012');
        hor.Passport_Number__c = 'ABC123456789123';
        insert hor;
        Class_Type__c cType = [SELECT Id
                                                FROM Class_Type__c
                                                WHERE Name = 'Testing'
                                                LIMIT 1];
        Event__c event = BETestUtility.getEvent(Date.today().addDays(4), Date.today().addDays(20));
        insert event;
        Class__c cls = BETestUtility.getClass(cType.Id, event.Id);
        insert cls;
        Entry__c entry = BETestUtility.getEntry(cls.Id,  event.Id,  rider.Id, hor.Id);
        insert entry;
        List<String> entryIdList= new List<String>();
        entryIdList.add(entry.Id);
       
            Test.startTest();
             List<ValidationResults> res=ValidationEngine.validateEntries(entryIdList,false);

            Test.stopTest();

    }
}