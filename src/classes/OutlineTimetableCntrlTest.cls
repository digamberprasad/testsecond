/**
 * Description: OutlineTimetableCntrl test class
 * Date: 23/06/16
 * Author: makepositive
 **/
@isTest
public class OutlineTimetableCntrlTest {
    
    @testSetup 
    static void createData() {
        Event__c e = BETestUtility.createEvent(Date.newInstance(2016, 5, 5), Date.newInstance(2016, 5, 6));
        Class_Type__c cType = BETestUtility.createClassType('BE90', 't', 'test');
        Class__c c = BETestUtility.createClass(cType.Id, e.Id);
	}
    
    @isTest
    static void createOutlineTimetable() {
        Event__c e = [SELECT Id FROM Event__c LIMIT 1];
        
        Test.startTest();
	  		List<Outline_Timetable_Details__c> otDetails = OutlineTimetableCntrl.getOutlineTimetable(e.Id);
    	    List<OutlineTimetableCntrl.OutlineTimetableVersionWrapper> otVersions = OutlineTimetableCntrl.getOutlineTimetableVersions(e.Id);
       	Test.stopTest();
        System.assertEquals(1, otDetails.size());
        System.assertEquals(1, otVersions.size());
    }
    
    @isTest
    static void activateOutlineTimetableVersion() {
        Event__c e = [SELECT Id FROM Event__c LIMIT 1];
        Outline_Timetable__c ot1 = BETestUtility.createOutlineTimetable(e.Id, OutlineTimetableCntrl.OUTLINE_TIMETABLE_ACTIVE_STATUS, 1);
        Outline_Timetable__c ot2 = BETestUtility.createOutlineTimetable(e.Id, OutlineTimetableCntrl.OUTLINE_TIMETABLE_INACTIVE_STATUS, 2);
        
        Test.startTest();
        	OutlineTimetableCntrl.activateOutlineTimetableVersion(e.Id, 2);
        Test.stopTest();
        
        System.assertEquals(OutlineTimetableCntrl.OUTLINE_TIMETABLE_ACTIVE_STATUS, [SELECT Status__c FROM Outline_Timetable__c WHERE ID = :ot2.Id].Status__c);
        System.assertEquals(OutlineTimetableCntrl.OUTLINE_TIMETABLE_INACTIVE_STATUS, [SELECT Status__c FROM Outline_Timetable__c WHERE ID = :ot1.Id].Status__c);
    }
    
    @isTest
    static void createNewOutlineTimetableVersion() {
        Event__c e = [SELECT Id FROM Event__c LIMIT 1];
        
        Test.startTest();
        	OutlineTimetableCntrl.createNewOutlineTimetableVersion(e.Id);
        	OutlineTimetableCntrl.createNewOutlineTimetableVersion(e.Id);
        Test.stopTest();
        
        List<Outline_Timetable__c> otList = [SELECT Id, Version__c
                                             FROM Outline_Timetable__c
                                           	ORDER BY Version__c DESC];
        
        System.assertEquals(2, otList.size());
        System.assertEquals(2, otList.get(0).Version__c);
        
    }
    
}