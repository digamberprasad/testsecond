/**
* Class for getting data for test classes
* @Author : Puneet Sardana
* @Created Date : 22/06/2016
*/
@isTest
public with sharing class BETestUtility {
	/**
	*
	* @Author : Puneet Sardana
	* @Created Date : 22/06/2016
	*/
    @testSetup
    public static void createData() {

     }

    public static Contact getContact(Id rTId,String lName) {
        return new Contact(RecordTypeId = rTId,LastName = lName);
    }
    public static Account getAccount(Id rTId,String name) {
        return new Account(RecordTypeId = rTId,Name = name);
    }

    public static Opportunity getOpportunity(Id rTId,String name, Date clsdate , String stage) {
        return new Opportunity(RecordTypeId = rTId, Name = name, CloseDate = clsdate, StageName = stage);
    }

    public static Product2 getProduct(Id rTId,String podname){
        return new Product2(RecordTypeId = rTId, Name = podname);
    }
    public static Asset getAsset(Id rTypeId, String nme, Id accId, Id productId, Id memberId, Id horseId ) {
      return new Asset(RecordTypeId = BEHelper.getRecordTypeId(Asset.sObjectType, BEConstants.RT_ASSET_MEMBERSHIP),
                                  Name = nme, AccountId = accId, Product2Id = productId, Member__c = memberId, Horse__c = horseId);
    }
    public static Validation_Rule__c getValidationRule(Boolean isActive, String type) {
        return new Validation_Rule__c(Active__c = isActive, Type__c = type);
    }
    public static Validation_Rule_Components__c getValidationComponent(Id validRule,Integer comp,String relatedTo,String busiEntityAPI,
                                                                       String attrAPI,String relationAPI,String operator, String operType,String value,
                                                                       String objAPI, String fieldAPI,String objFieldRelationshipAPI) {
        return new Validation_Rule_Components__c(Validation_Rule__c = validRule, Component__c = comp,
                                                 		         Relates_To__c = relatedTo, Business_Entity_API__c = busiEntityAPI,
                                                 		         Attribute_API__c = attrAPI, Business_Entity_Relationship_API__c = relationAPI,
                                                 		         Operator__c = operator, Operand_Type__c = operType, Value__c = value,
                                                 		         Object_API__c = objAPI, Field_API__c = fieldAPI,
                                                 		         Object_Relationship_API__c = objFieldRelationshipAPI );
    }
    public static Class_Rules_Mapping__c getClassRuleMapping(Id classTypeId, Id validationRuleId) {
        return new Class_Rules_Mapping__c(Class_Type__c = classTypeId, Validation_Rule__c = validationRuleId);
    }
    public static Class_Type__c getClassType(String name,String aff, String descrip) {
        return new Class_Type__c(Name=name,Affiliated__c = aff, Description__c = descrip);
    }
    public static Rule_Criteria__c getRuleCriteria(Id vId,Integer hier,String applies, String criteria,String logic,
                                                                            String code,String msgPre, String msgPast,String category,String mode) {
        return new Rule_Criteria__c(Validation_Rule__c = vId,Rule_Hierarchy__c=hier,Applies_To__c = applies,Criteria__c = criteria,
                                              Validation_Logic__c = logic, Message_Code__c = code,Msg_Present_Tense__c = msgPre,
                                              Message_Past_Tense__c = msgPast,Validation_Category__c = category,Calculation_Mode__c = mode);

    }
    public static Class__c getClass(Id clsType, Id event) {
        return new Class__c(Class_Type__c = clsType, Event__c = event);
    }
    public static Event__c getEvent(Date startDate, Date endDate) {
        return new Event__c(Start_Date__c = startDate, End_Date__c = endDate);
    }
    public static Horse__c getHorse(String name,Id primaryOwnr, String year) {
        return new Horse__c(Name = name, Primary_Owner__c = primaryOwnr,
                            Year_horse_was_foaled__c = year);

    }
    public static Entry__c getEntry(Id classId, Id eventId, Id riderId, Id horseId) {
        return new Entry__c(Class__c = classId, Event__c = eventId, Rider__c = riderId, Horse__c = horseId);
    }

    public static Outline_Timetable__c createOutlineTimetable_inMemory(Id eventId, String status, Integer version) {
        return new Outline_Timetable__c(Event__c = eventId, Version__c = version, Status__c = status);
    }

    public static Outline_Timetable__c createOutlineTimetable(Id eventId, String status, Integer version) {
        Outline_Timetable__c ot = createOutlineTimetable_inMemory(eventId, status, version);
        insert ot;
        return ot;
    }
    
    public static Class_Type__c createClassType(String name, String aff, String descrip) {
        Class_Type__c cType = getClassType(name, aff, descrip);
        insert cType;
        return cType;
    }
    
    public static Class__c createClass(Id clsType, Id event) {
        Class__c c = getClass(clsType, event);
        insert c;
        return c;
    }
    
    public static Event__c createEvent(Date startDate, Date endDate) {
        Event__c e = getEvent(startDate, endDate);
        insert e;
        return e;
    }
}