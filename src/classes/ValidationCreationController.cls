public class ValidationCreationController {

    @AuraEnabled
    public static List<SelectOption> getDropDownValue(String objName, String fieldName) {
            Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(new List<String> { objName } );
            List<SelectOption> options = new List<SelectOption>();
            if(descResult.size() > 0) {
                 options = BEHelper.getPicklistValues(descResult[0],fieldName);
            }
            return options;
    }
    @AuraEnabled
    public static List<SelectOption> getClassType() {
        List<SelectOption> lstOption = new List<SelectOption>();
        for(Class_Type__c ct : [SELECT Id,Name
                                              FROM Class_Type__c
                                              LIMIT :BEConstants.SF_QUERY_RESULT_LIMIT
                                              ]) {
            lstOption.add(new SelectOption(ct.Id , ct.Name));
        }
        return lstOption;
    }

    @AuraEnabled
    public static void saveValidationCriteriaTrigger(String criTriggerList) {
        System.debug('Puneet lstValidationCriTrigger '+criTriggerList);
        Type valiCriTriggerType = Type.forName('List<ValidationCriteriaTrigger>');
        List<ValidationCriteriaTrigger> lstValidationCriTrigger = (List<ValidationCriteriaTrigger>)JSON.deserialize(criTriggerList,valiCriTriggerType);
        List<Rule_Criteria_Triggers__c> lstCriteriaTrigger = new List<Rule_Criteria_Triggers__c>();
        Set<String> entities = new Set<String>();
        for(ValidationCriteriaTrigger vct : lstValidationCriTrigger) {
            for(Rule_Criteria_Triggers__c vrc : vct.triggers) {
                entities.add(vrc.Business_Entity_API__c);
             }
         }
        Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(new List<String>(entities));
        Map<String,Schema.DescribeSObjectResult> mapObjectResult = new Map<String,Schema.DescribeSObjectResult>();
        for(Schema.DescribeSObjectResult res : descResult) {
            mapObjectResult.put(res.getName(),res);
         }
        Schema.DescribeSObjectResult tempObjectResult;
        for(ValidationCriteriaTrigger vct : lstValidationCriTrigger) {
            for(Rule_Criteria_Triggers__c rct : vct.triggers) {
                rct.Rule_Criteria__c = vct.criteria.Id;
                tempObjectResult = mapObjectResult.get(rct.Business_Entity_API__c);
                rct.Attribute_Type__c  = findFieldType(tempObjectResult,rct.Attribute_API__c);
                lstCriteriaTrigger.add(rct);
            }
        }
        try {
            insert lstCriteriaTrigger;
        } catch(Exception ex) {
            // To Do : Add exception handling
        }
    }

    @AuraEnabled
    public static List<ValidationCriteriaTrigger> getValidationCriteriaTrigger(String vId) {
        System.debug('Validation Id'+vId);
        List<ValidationCriteriaTrigger> vTriggers = new List<ValidationCriteriaTrigger>();
        Map<Id,Rule_Criteria__c> mapRuleCriteria = new Map<Id,Rule_Criteria__c> ( [ SELECT Id,Name,Rule_Hierarchy__c,
                                                                                                                                        Validation_Logic__c
                                                                                                                                        FROM Rule_Criteria__c
                                                                                                                                        WHERE Validation_Rule__c = :vId]);
        System.debug('mapRuleCriteria '+mapRuleCriteria);
        List<Rule_Criteria_Triggers__c> tempTrigger;
        Map<String,List<Rule_Criteria_Triggers__c>> mapCriteriaIdTrigger= new Map<String,List<Rule_Criteria_Triggers__c>>();
        for(Rule_Criteria_Triggers__c  cr : [SELECT Id,Rule_Criteria__c,Attribute__c,
                                                                Attribute_API__c ,Attribute_Type__c,Business_Entity__c,
                                                                Business_Entity_API__c,Business_Entity_Relationship_API__c,Field_API__c,
                                                                Object_API__c,Object_Relationship_API__c,Operand_Type__c,
                                                                Operator__c,Relates_To__c,Value__c
                                                                FROM Rule_Criteria_Triggers__c
                                                                WHERE Rule_Criteria__c IN :mapRuleCriteria.keySet() ]) {
            if(!mapCriteriaIdTrigger.containsKey(cr.Rule_Criteria__c) ) {
                mapCriteriaIdTrigger.put(cr.Rule_Criteria__c, new List<Rule_Criteria_Triggers__c>());
            }
            tempTrigger = mapCriteriaIdTrigger.get(cr.Rule_Criteria__c);
            tempTrigger.add(cr);
            mapCriteriaIdTrigger.put(cr.Rule_Criteria__c,tempTrigger);
        }
        ValidationCriteriaTrigger temp;
        for(String criId : mapRuleCriteria.keySet()) {
            temp = new ValidationCriteriaTrigger();
            if(!mapCriteriaIdTrigger.containsKey(criId)) {
                temp.triggers = new List<Rule_Criteria_Triggers__c>();
            } else {
                temp.triggers = mapCriteriaIdTrigger.get(criId);
            }
            temp.criteria = mapRuleCriteria.get(criId);
            vTriggers.add(temp);
        }
        System.debug('vTriggers'+vTriggers);
        return vTriggers;
    }
    @AuraEnabled
    public static List<SelectOption> getRelationship(String relatedTo, String objName) {
        String relatedToAPI;
        List<SelectOption> lstRelationFields = new List<SelectOption>();
        Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(new List<String> { objName   });
        if(relatedTo == ValidationConstants.RELATES_TO_HORSE) {
            relatedToAPI = ValidationConstants.RELATES_TO_HORSEAPI;
        } else if(relatedTo == ValidationConstants.RELATES_TO_RIDER) {
            relatedToAPI = ValidationConstants.RELATES_TO_RIDERAPI;
        } else if (relatedTo == ValidationConstants.RELATES_TO_EVENT) {
            relatedToAPI = ValidationConstants.RELATES_TO_EVENTAPI;
        }
        for(Schema.DescribeSObjectResult res : descResult) {
            Map<String,Schema.SObjectField> fieldMap = res.fields.getMap();
            for(String ty : fieldMap.keySet()) {
                Schema.DescribeFieldResult fResult = fieldMap.get(ty).getDescribe();
                if(fResult.getType() == Schema.DisplayType.REFERENCE
                   && fResult.getReferenceTo()[0].getDescribe().getName() == relatedToAPI) {
                    lstRelationFields.add(new SelectOption(fResult.getName(),fResult.getLabel()));
                }
            }
        }
        return lstRelationFields;
    }
    @AuraEnabled
    public static ValidationCreationInfo getValidation(String vId)  {
        ValidationCreationInfo vInfo = new ValidationCreationInfo();
        if(vId != null) {
            for(Validation_Rule__c vr : [ SELECT Id,Active__c,Type__c,Name
                                                          FROM Validation_Rule__c
                                                          WHERE Id = :vId
                                                          LIMIT 1]) {
                vInfo.vRule = vr;
            }
            vInfo.isClassSpecific = vInfo.vRule.Type__c == ValidationConstants.VALIDATION_TYPE_CLASSSPECIFIC;
            for(Validation_Rule_Components__c vrc : [ SELECT Id,Name,Attribute__c,Attribute_API__c,Attribute_Type__c,
                                                                                   Business_Entity__c,Business_Entity_API__c,Business_Entity_Relationship_API__c,
                                                                                   Component__c,Field__c,Field_API__c,Field_Type__c,Object__c,Object_API__c,
                                                                                   Object_Relationship_API__c,Operand_Type__c,Operator__c,Relates_To__c,
                                                                                   Validation_Rule__c,Value__c,Value_Type__c
                                                                                   FROM Validation_Rule_Components__c
                                                                                   WHERE Validation_Rule__c = :vId
                                                                                   ORDER BY Component__c ASC NULLS LAST
                                                                                ]) {
                vInfo.vComponents.add(vrc);
            }
            vInfo.compSize = vInfo.vComponents.size();
            for(Rule_Criteria__c vc : [ SELECT Id,Name,Applies_To__c,Calculation_Mode__c,Validation_Category__c,
                                                      Criteria__c,Criteria_Description__c,Message_Code__c,Message_Past_Tense__c,
                                                      Msg_Present_Tense__c,Rule_Hierarchy__c,Validation_Logic__c,Validation_Rule__c
                                                      FROM Rule_Criteria__c
                                                      WHERE Validation_Rule__c = :vId
                                                      ORDER BY Rule_Hierarchy__c ASC NULLS LAST
                                                    ]) {
                vInfo.vCriterias.add(vc);
            }
            vInfo.criSize = vInfo.vCriterias.size();
            for(Class_Rules_Mapping__c crm : [ SELECT Id,Class_Type__c, Validation_Rule__c
                                                                        FROM Class_Rules_Mapping__c
                                                                        WHERE Validation_Rule__c = :vId]) {
                vInfo.vRules.add(crm);
            }
            vInfo.rulesSize = vInfo.vRules.size();
        }
        System.debug('Puneet '+vInfo);
        return vInfo;
    }
    @AuraEnabled
    public static ValidationCreationResult saveValidation(Validation_Rule__c vr,
                                                    List<Validation_Rule_Components__c> lstRuleComp,
                                                    List<Rule_Criteria__c> lstRuleCri,
                                                    List<Class_Rules_Mapping__c> lstRuleMapping) {
        ValidationCreationResult vCreationResult = new ValidationCreationResult();
        vCreationResult.isCreated = true;
        Savepoint sp;
        try {
            System.debug('Puneet Validation_Rule__c '+vr);
            System.debug('Puneet Validation_Rule_Components__c '+lstRuleComp);
            System.debug('Puneet Validation_Rule_Components__c size '+lstRuleComp.size());
            System.debug('Puneet Rule_Criteria__c '+lstRuleCri);
            System.debug('Puneet Class Rule Mapping '+vr.Type__c);
            System.debug('Puneet Validation_Rule__c vr.Id '+vr.Id);
            // Create save point for entire transaction
            sp = Database.setSavepoint();
            Boolean isInsert = vr.Id == null;
            if(isInsert) {
                insert vr;
             } else {
                update vr;
            }
            vCreationResult.valiRules = vr;
            Set<String> entities = new Set<String>();
            for(Validation_Rule_Components__c vrc : lstRuleComp) {
                entities.add(vrc.Business_Entity_API__c);
            }
            Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(new List<String>(entities));
            Map<String,Schema.DescribeSObjectResult> mapObjectResult = new Map<String,Schema.DescribeSObjectResult>();
            for(Schema.DescribeSObjectResult res : descResult) {
                mapObjectResult.put(res.getName(),res);
             }
            Schema.DescribeSObjectResult tempObjectResult;
            for(Validation_Rule_Components__c vrc : lstRuleComp) {
                tempObjectResult = mapObjectResult.get(vrc.Business_Entity_API__c);
                vrc.Attribute_Type__c  = findFieldType(tempObjectResult,vrc.Attribute_API__c);
                if(vrc.Id == null) {
                    vrc.Validation_Rule__c = vr.Id;
                }
                if(vrc.Operand_Type__c != ValidationConstants.VRCOMPONENT_OPERANDTYPE_FIELD) {
                    vrc.Object__c  = vrc.Object_API__c = vrc.Object_Relationship_API__c = vrc.Field_API__c = '';
                }
           }
           for(Rule_Criteria__c rc : lstRuleCri) {
               if(rc.Id == null) {
                    rc.Validation_Rule__c = vr.Id;
                }
            }
            // If insert insert the records
            if(isInsert) {
                insert lstRuleComp;
                insert lstRuleCri;
                if(vr.Type__c == ValidationConstants.VALIDATION_TYPE_CLASSSPECIFIC) {
                    for(Class_Rules_Mapping__c crm : lstRuleMapping) {
                        if(crm.Id == null) {
                            crm.Validation_Rule__c = vr.Id;
                        }
                    }
                    if(lstRuleMapping.size() > 0) {
                        insert lstRuleMapping;
                    }
                }
            } else {
                Set<Id> existingComp = new Set<Id>();
                Set<Id> existingCri = new Set<Id>();
                Set<Id> existingMapping = new Set<Id>();
                List<Validation_Rule_Components__c> lstCompIns = new List<Validation_Rule_Components__c>();
                List<Validation_Rule_Components__c> lstCompUp = new List<Validation_Rule_Components__c>();
                List<Validation_Rule_Components__c> lstCompDel = new List<Validation_Rule_Components__c>();
                List<Rule_Criteria__c> lstCriIns = new List<Rule_Criteria__c>();
                List<Rule_Criteria__c> lstCriUp = new List<Rule_Criteria__c>();
                List<Rule_Criteria__c> lstCriDel = new List<Rule_Criteria__c>();
                List<Class_Rules_Mapping__c> lstCrmIns = new List<Class_Rules_Mapping__c>();
                List<Class_Rules_Mapping__c> lstCrmUp = new List<Class_Rules_Mapping__c>();
                List<Class_Rules_Mapping__c> lstCrmDel = new List<Class_Rules_Mapping__c>();
                for(Validation_Rule_Components__c vrc : [SELECT Id
                                                                                    FROM Validation_Rule_Components__c
                                                                                    WHERE Validation_Rule__c = :vr.Id]) {
                    existingComp.add(vrc.Id);
                }
                for(Rule_Criteria__c rc : [SELECT Id
                                                        FROM Rule_Criteria__c
                                                        WHERE Validation_Rule__c = :vr.Id]) {
                    existingCri.add(rc.Id);
                }
                for(Class_Rules_Mapping__c crm: [SELECT Id
                                                                         FROM Class_Rules_Mapping__c
                                                                         WHERE Validation_Rule__c = :vr.Id]) {
                    existingMapping.add(crm.Id);
                }
                for(Validation_Rule_Components__c vrc : lstRuleComp) {
                    if(vrc.Id == null) {
                        lstCompIns.add(vrc);
                    } else if(existingComp.contains(vrc.Id)) {
                        lstCompUp.add(vrc);
                        existingComp.remove(vrc.Id);
                    }
                }
                for(Rule_Criteria__c rc : lstRuleCri) {
                    if(rc.Id == null) {
                        lstCriIns.add(rc);
                    } else if(existingCri.contains(rc.Id)) {
                        lstCriUp.add(rc);
                        existingCri.remove(rc.Id);
                    }
                }
                for(Class_Rules_Mapping__c crm : lstRuleMapping) {
                    if(crm.Id == null) {
                        lstCrmIns.add(crm);
                    } else if(existingMapping.contains(crm.Id)) {
                        lstCrmUp.add(crm);
                        existingMapping.remove(crm.Id);
                    }
                }
                for(Id com : existingComp) {
                    lstCompDel.add(new Validation_Rule_Components__c(Id = com));
                }
                for(Id cri : existingCri) {
                    lstCriDel.add(new Rule_Criteria__c(Id = cri));
                }
                for(Id mp : existingMapping) {
                    lstCrmDel.add(new Class_Rules_Mapping__c(Id = mp));
                }
                if(lstCompIns.size() > 0) {
                    insert lstCompIns;
                }
                if(lstCompUp.size() > 0) {
                    update lstCompUp;
                }
                if(lstCompDel.size() > 0) {
                    delete lstCompDel;
                }
                if(lstCriIns.size() > 0) {
                    insert lstCriIns;
                }
                if(lstCriUp.size() > 0) {
                    update lstCriUp;
                }
                if(lstCriDel.size() > 0) {
                    delete lstCriDel;
                }
                if(lstCrmIns.size() > 0) {
                    insert lstCrmIns;
                }
                if(lstCrmUp.size() > 0) {
                    update lstCrmUp;
                }
                if(lstCrmDel.size() > 0) {
                    delete lstCrmDel;
                }
            }
        } catch(Exception e) {
            // To Do : Log Exception
            //Roll back all changes, either save all validation data or nothing
            System.debug('Error while updating validation '+e);
            vCreationResult.isCreated = false;
            vCreationResult.error = e.getMessage();
            System.debug('Error Stacktrace '+e.getStackTraceString());
            Database.rollback(sp);
        }
        return vCreationResult;
    }

    public class ValidationCreationResult {
        @AuraEnabled
        public Boolean isCreated;
        @AuraEnabled
        public String error;
        @AuraEnabled
        public Validation_Rule__c valiRules;
    }

    private static String findFieldType(Schema.DescribeSObjectResult objResult,String field) {
        String fType = '';
        Map<String,Schema.SObjectField> fieldMap = objResult.fields.getMap();
        Schema.DescribeFieldResult fResult;
        Schema.DisplayType resType;
        fResult = fieldMap.get(field).getDescribe();
        resType = fResult.getType();
        if(resType == Schema.DisplayType.Boolean) {
            fType = ValidationConstants.VRCOMPONENT_ATTRIBUTE_TYPEBOOLEAN;
        } else if(resType == Schema.DisplayType.Date) {
            fType = ValidationConstants.VRCOMPONENT_ATTRIBUTE_TYPEDATE;
        } else if(resType == Schema.DisplayType.DateTime) {
            fType = ValidationConstants.VRCOMPONENT_ATTRIBUTE_TYPEDATETIME;
        }
        else if(resType == Schema.DisplayType.Email || resType == Schema.DisplayType.ID
                  || resType == Schema.DisplayType.Picklist || resType == Schema.DisplayType.String
                  || resType == Schema.DisplayType.TextArea ||  resType == Schema.DisplayType.URL) {
            fType = ValidationConstants.VRCOMPONENT_ATTRIBUTETYPE_TEXT;
        }  else if(resType == Schema.DisplayType.Double || resType == Schema.DisplayType.Integer
                  || resType == Schema.DisplayType.Currency) {
            fType = ValidationConstants.VRCOMPONENT_ATTRIBUTE_TYPENUMBER;
        }
        return fType;
    }
   @AuraEnabled
    public static ValidationComponent getValidationComp() {
        ValidationComponent vc = new ValidationComponent();
        vc.operand = getDropDownValue('Validation_Rule_Components__c','Operand_Type__c');
        vc.operator = getDropDownValue('Validation_Rule_Components__c','Operator__c');
        vc.relatesTo = getDropDownValue('Validation_Rule_Components__c','Relates_To__c');
        return vc;
    }
    @AuraEnabled
    public static ValidationCriteria getValidationCri() {
        ValidationCriteria vc = new ValidationCriteria();
        vc.appliesTo = getDropDownValue('Rule_Criteria__c','Applies_To__c');
        vc.category = getDropDownValue('Rule_Criteria__c','Validation_Category__c');
        vc.criteria = getDropDownValue('Rule_Criteria__c','Criteria__c');
        return vc;
    }

    public class ValidationCriteria {
        @AuraEnabled
        public List<SelectOption> appliesTo;
        @AuraEnabled
        public List<SelectOption> category;
        @AuraEnabled
        public List<SelectOption> criteria;
    }
    public class ValidationComponent {
        @AuraEnabled
        public List<SelectOption> operand;
        @AuraEnabled
        public List<SelectOption> operator;
        @AuraEnabled
        public List<SelectOption> relatesTo;
    }

    public class ValidationCreationInfo {
        @AuraEnabled
        public Validation_Rule__c vRule;
        @AuraEnabled
        public List<Validation_Rule_Components__c> vComponents;
        @AuraEnabled
        public Integer compSize;
        @AuraEnabled
        public List<Rule_Criteria__c> vCriterias;
        @AuraEnabled
        public Integer criSize;
        @AuraEnabled
        public List<Class_Rules_Mapping__c> vRules;
        @AuraEnabled
        public Integer rulesSize;
        @AuraEnabled
        public Boolean isClassSpecific;

        public ValidationCreationInfo() {
            vComponents = new List<Validation_Rule_Components__c>();
            vCriterias = new List<Rule_Criteria__c>();
            vRules = new List<Class_Rules_Mapping__c>();
        }
    }
}