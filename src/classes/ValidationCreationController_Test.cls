@isTest

public  class ValidationCreationController_Test {  

 static Contact cnt; 
 static Validation_Rule__c vRule;
 static Validation_Rule_Components__c vRuleComp;
 static Rule_Criteria__c ruleCriteria;
 static Class_Type__c classType;
 static Class_Rules_Mapping__c classRuleMapping;
   
  @testSetup
  static void createTestData() { 

    Recordtype rec = [SELECT Id FROM Recordtype WHERE DeveloperName='Member'];
    cnt = BETestUtility.getContact(rec.ID,'Test');
    insert cnt;
    vRule= BETestUtility.getValidationRule(true,'Class Specific');
    insert vRule;


    
    
   

      }

  @isTest          
  static void test_ValidationUpdate() {  
     vRule = [SELECT Id,Type__c,Active__c
            FROM Validation_Rule__c
             WHERE Active__c = true
             LIMIT 1];

    vRuleComp= BETestUtility.getValidationComponent(vRule.Id,1,'Rider','Contact','Age__c','Id','less or equal','Value','6','AcceptedEventRelation','IsDeleted','AccountId');
    //insert vRuleComp;
     List<Validation_Rule_Components__c> vRuleCompList= new List<Validation_Rule_Components__c> ();
     vRuleCompList.add(vRuleComp);

    ruleCriteria= BETestUtility.getRuleCriteria(vRule.Id,1,'Rider', 'Is Met','2','msg2',
                                'Rider age should be more than 17 years of age', 
                                'Rider age should be more than 17 years of age',
                                'Mandatory','Runtime');
    List<Rule_Criteria__c> ruleCritList= new List<Rule_Criteria__c> ();
     ruleCritList.add(ruleCriteria);
     //insert ruleCriteria;

    classType=BETestUtility.getClassType('testClass','A','test');
    insert classType;

    classRuleMapping=BETestUtility.getClassRuleMapping(classType.Id,vRule.Id);
    List<Class_Rules_Mapping__c> classMappingList= new List<Class_Rules_Mapping__c> ();
     classMappingList.add(classRuleMapping);
    //insert classRuleMapping;
   /*   List<Validation_Rule_Components__c> vRuleCompList= [SELECT Id,Business_Entity_API__c,
                                                          Validation_Rule__c, Component__c,Relates_To__c,
                                                             Attribute_API__c, Business_Entity_Relationship_API__c,
                                                             Operator__c , Operand_Type__c, Value__c,
                                                             Object_API__c, Field_API__c,
                                                             Object_Relationship_API__c
                                                             FROM Validation_Rule_Components__c
                                                             WHERE Component__c = 1];
    List<Rule_Criteria__c> ruleCritList= [SELECT Id,Validation_Rule__c,Rule_Hierarchy__c,Applies_To__c,Criteria__c,
                                              Validation_Logic__c, Message_Code__c,Msg_Present_Tense__c,
                                              Message_Past_Tense__c,Validation_Category__c,Calculation_Mode__c
                                              FROM Rule_Criteria__c WHERE Rule_Hierarchy__c = 1];
    List<Class_Rules_Mapping__c> classMappingList= [SELECT Id,Class_Type__c,Validation_Rule__c
                                                    FROM Class_Rules_Mapping__c
                                                    WHERE Validation_Rule__c = :vRule.ID];*/
    Test.startTest();                 
        ValidationCreationController.getClassType();
        ValidationCreationController cntr= new ValidationCreationController();
       
        ValidationCreationController.ValidationCriteria vc=ValidationCreationController.getValidationCri();
        ValidationCreationController.getDropDownValue('Validation_Rule__c','Type__c');
        ValidationCreationController.ValidationComponent vCmp=ValidationCreationController.getValidationComp();
        ValidationCreationController.ValidationCreationInfo vInfo=ValidationCreationController.getValidation(vRule.Id);
        ValidationCreationController.getRelationship('Horse', 'Horse__c');
        
        ValidationCreationController.saveValidationCriteriaTrigger('[{"criteria":{"Id":"a0S4E0000009sLNUAY","Name":"CR-0058","Rule_Hierarchy__c":1,"Validation_Logic__c":"1"},"triggers":[{"Operand_Type__c":"Value","Operator__c":"equals","Relates_To__c":"Horse","Business_Entity_API__c":"AcceptedEventRelation","Attribute_API__c":"IsDeleted","Object_API__c":"AcceptedEventRelation","Field_API__c":"IsDeleted"}]}]');

       ValidationCreationController.ValidationCreationResult vr= ValidationCreationController.saveValidation(vRule,
                                                   vRuleCompList,ruleCritList,classMappingList);
       List<ValidationCriteriaTrigger> valTriggerList=ValidationCreationController.getValidationCriteriaTrigger(vRule.Id);

    Test.stopTest();
  }
    
    @isTest          
  static void test_ValidationInsert() {  
    vRule= BETestUtility.getValidationRule(true,'Class Specific');
   
    Test.startTest();                 
        
        ValidationCreationController cntr= new ValidationCreationController();
        ValidationCreationController.getDropDownValue('Validation_Rule__c','Type__c');
        ValidationCreationController.getRelationship('Horse', 'Horse__c');

       ValidationCreationController.ValidationCreationResult vr= ValidationCreationController.saveValidation(vRule,
                                                  	new List<Validation_Rule_Components__c>(),
                                                    new List<Rule_Criteria__c>(),
                                                    new List<Class_Rules_Mapping__c>());
    
    Test.stopTest();
  }

}