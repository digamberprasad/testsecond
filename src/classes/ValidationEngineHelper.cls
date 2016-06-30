/**
 * Helper class for Validation Engine
 * @author : Puneet Sardana
 * @Created Date : 18/05/2016
*/
public class ValidationEngineHelper {
    private static Map<String,ValidationBusinessEntity> mapObjectBusinessEntity;
    private static Map<String,Validation_Rule_Components__c> mapValidationRuleComponentNo;
    private static Map<String,List<Rule_Criteria_Triggers__c>> mapCriteriaIdlstCriteriaTrigger;
    /**
     * This function returns map of criteria id and list of rule criteria trigger applicable to it
     * @author : Puneet Sardana
     * @Created Date : 02/06/2016
    **/
    public static Map<String,List<Rule_Criteria_Triggers__c>> getCriteriaIdTriggerMap() {
        return mapCriteriaIdlstCriteriaTrigger;
    }


    /**
     * This function returns map of object names and set of fields
     * @author : Puneet Sardana
     * @Created Date : 18/05/2016
    **/
    public static Map<String,ValidationBusinessEntity> getValidationObjectBusinessEntityMap() {
        return mapObjectBusinessEntity;
    }
   /**
     * This function returns map of  Validation Id + Component Number -> Validation_Rule_Components__c
     * @author : Puneet Sardana
     * @Created Date : 26/05/2016
    **/
    public static Map<String,Validation_Rule_Components__c> getValidationRuleComponentNoMap() {
        return mapValidationRuleComponentNo;
    }

    /**
     * This function returns map of entry id and custom class Entry validation having all validation rules applicable to that entry
     * @author : Puneet Sardana
     * @Created Date : 18/05/2016
    **/
    public static Map<Id,ValidationEntry> buildEntryValidationList(Map<Id,Entry__c> mapIdEntry,Map<Id,Id> mapEntryClassType) {
        Map<Id,ValidationEntry> mapValidationEntry = new Map<Id,ValidationEntry>();
        Map<String,Set<Id>> mapClassTypeListValidation = new Map<String,Set<Id>>();
        Set<Id> classValidations = new Set<Id>();
        Set<Id> criteriaIds = new Set<Id>();
        mapCriteriaIdlstCriteriaTrigger = new Map<String,List<Rule_Criteria_Triggers__c>>();
        // Find all validation rules of that classes
        System.debug('Puneet mapEntryClassType'+mapEntryClassType);
        for(Class_Rules_Mapping__c crm : [ SELECT Validation_Rule__c,Class_Type__c
                                                                    FROM Class_Rules_Mapping__c
                                                                    WHERE Class_Type__c IN :mapEntryClassType.values()
                                                                    AND Validation_Rule__r.Active__c = true
                                                                    ]) {
             System.debug('Puneet class rule mapping '+crm.Id );
             System.debug('Puneet class rule mapping '+crm.Validation_Rule__c );

             if(!mapClassTypeListValidation.containsKey(crm.Class_Type__c)) {
                mapClassTypeListValidation.put(crm.Class_Type__c, new Set<Id>());
             }
             if(crm.Validation_Rule__c != null ) {
                Set<Id> tempValiList = mapClassTypeListValidation.get(crm.Class_Type__c);
                tempValiList.add(crm.Validation_Rule__c);
                mapClassTypeListValidation.put(crm.Class_Type__c, tempValiList);
                classValidations.add(crm.Validation_Rule__c);
            }
        }
        Map<Id,Validation_Rule__c> mapValidationRule = new Map<Id,Validation_Rule__c>();
        mapObjectBusinessEntity = new Map<String,ValidationBusinessEntity>();
        mapValidationRuleComponentNo = new Map<String,Validation_Rule_Components__c>();
        ValidationBusinessEntity tempBusinessEntity;
        // Build several maps using this query
        // Map of Validation Rule Id + Component No -> Validation Component
        // Map for firing queries for different objects
        // Populate Validation Business Entity
        for(Validation_Rule__c vr : [SELECT Type__c,Id,
                                                    (SELECT Id,Attribute_API__c,Business_Entity_API__c,Attribute_Type__c,Component__c,Operator__c,
                                                    Field_API__c,Object_API__c,Operand_Type__c,Operand_Value__c,Field_Type__c,Value__c,Validation_Rule__c,
                                                    Business_Entity_Relationship_API__c,Object_Relationship_API__c,Relates_To__c,Object_Relationship_Type__c
                                                    FROM Validation_Rule_Criteria__r ORDER BY Component__c ASC NULLS LAST),
                                                    (SELECT Id,Applies_To__c,Calculation_Mode__c , Validation_Category__c,Criteria__c,
                                                    Criteria_Description__c,Message_Code__c,Message_Past_Tense__c,Msg_Present_Tense__c,
                                                    Rule_Hierarchy__c,Validation_Logic__c,Validation_Rule__c
                                                    FROM Rule_Criteria__r ORDER BY Rule_Hierarchy__c ASC NULLS LAST)
                                                    FROM Validation_Rule__c
                                                    WHERE ( Type__c = :ValidationConstants.VALIDATION_TYPE_INDEPENDENT
                                                                      OR Id IN :classValidations)
                                                    AND Active__c = true
                                                    ] )  {
            for(Validation_Rule_Components__c vrc : vr.Validation_Rule_Criteria__r) {
                if(!mapObjectBusinessEntity.containsKey(vrc.Business_Entity_API__c)) {
                    mapObjectBusinessEntity.put(vrc.Business_Entity_API__c, new ValidationBusinessEntity(vrc.Business_Entity_API__c));
                }
                if(!mapValidationRuleComponentNo.containsKey(String.valueOf(vr.Id) + String.valueOf(vrc.Component__c))) {
                    mapValidationRuleComponentNo.put(String.valueOf(vr.Id) + String.valueOf(vrc.Component__c),vrc);
                }
                tempBusinessEntity = mapObjectBusinessEntity.get(vrc.Business_Entity_API__c);
                tempBusinessEntity.attributes.add(vrc.Attribute_API__c);
                tempBusinessEntity.attributes.add(vrc.Business_Entity_Relationship_API__c);
                tempBusinessEntity.relationships.add(vrc.Business_Entity_Relationship_API__c);
                tempBusinessEntity.relatesTo.add(vrc.Relates_To__c);
                mapObjectBusinessEntity.put(vrc.Business_Entity_API__c,tempBusinessEntity);
                // If comparing with field add its business entity, field, relationship and relates to field
                if(vrc.Operand_Type__c == ValidationConstants.OPERAND_TYPE_FIELD) {
                    if(!mapObjectBusinessEntity.containsKey(vrc.Object_API__c)) {
                        mapObjectBusinessEntity.put(vrc.Object_API__c, new ValidationBusinessEntity(vrc.Object_API__c));
                    }
                    tempBusinessEntity = mapObjectBusinessEntity.get(vrc.Object_API__c);
                    tempBusinessEntity.attributes.add(vrc.Field_API__c);
                    tempBusinessEntity.attributes.add(vrc.Object_Relationship_API__c);
                    tempBusinessEntity.relationships.add(vrc.Object_Relationship_API__c);
                    mapObjectBusinessEntity.put(vrc.Object_API__c,tempBusinessEntity);
                }
            }
            for(Rule_Criteria__c rc : vr.Rule_Criteria__r) {
                criteriaIds.add(rc.Id);
            }
            // Put all Class Independent Rules in mapClassTypeListValidation with type ValidationConstants.VALIDATION_TYPE_INDEPENDENT
            if(vr.Type__c == ValidationConstants.VALIDATION_TYPE_INDEPENDENT) {
                  if(!mapClassTypeListValidation.containsKey(vr.Type__c)) {
                     mapClassTypeListValidation.put(vr.Type__c,new Set<Id>());
                  }
                 Set<Id> tempValiList = mapClassTypeListValidation.get(vr.Type__c);
                 tempValiList.add(vr.Id);
                 mapClassTypeListValidation.put(vr.Type__c, tempValiList);
            }
            mapValidationRule.put(vr.Id,vr);
        }
        System.debug('Validation Engine Helper  mapClassTypeListValidation'+mapClassTypeListValidation);
        List<Rule_Criteria_Triggers__c> tempCriteriaTrigger;
        // Build a map of Criteria Id and list of rule criteria trigger
        for(Rule_Criteria_Triggers__c ct : [ SELECT Id,Rule_Criteria__c,Attribute_API__c,Attribute_Type__c,
                                                                Business_Entity_API__c,Business_Entity_Relationship_API__c,
                                                                Field_API__c,Object_API__c,Relates_To__c,
                                                                Object_Relationship_API__c,Operand_Type__c,
                                                                Operator__c
                                                                FROM Rule_Criteria_Triggers__c
                                                                WHERE Rule_Criteria__c IN :criteriaIds]) {
            if(!mapCriteriaIdlstCriteriaTrigger.containsKey(ct.Rule_Criteria__c)) {
                mapCriteriaIdlstCriteriaTrigger.put(ct.Rule_Criteria__c, new List<Rule_Criteria_Triggers__c>());
            }
            tempCriteriaTrigger = mapCriteriaIdlstCriteriaTrigger.get(ct.Rule_Criteria__c);
            tempCriteriaTrigger.add(ct);
            mapCriteriaIdlstCriteriaTrigger.put(ct.Rule_Criteria__c, tempCriteriaTrigger);
            if(!mapObjectBusinessEntity.containsKey(ct.Business_Entity_API__c)) {
                    mapObjectBusinessEntity.put(ct.Business_Entity_API__c,
                                                                    new ValidationBusinessEntity(ct.Business_Entity_API__c));
            }
            // Add this to business entity, fields, object info for firing queries
            tempBusinessEntity = mapObjectBusinessEntity.get(ct.Business_Entity_API__c);
            tempBusinessEntity.attributes.add(ct.Attribute_API__c);
            tempBusinessEntity.attributes.add(ct.Business_Entity_Relationship_API__c);
            tempBusinessEntity.relationships.add(ct.Business_Entity_Relationship_API__c);
            tempBusinessEntity.relatesTo.add(ct.Relates_To__c);
            mapObjectBusinessEntity.put(ct.Business_Entity_API__c,tempBusinessEntity);
            if(ct.Operand_Type__c == ValidationConstants.OPERAND_TYPE_FIELD) {
                if(!mapObjectBusinessEntity.containsKey(ct.Object_API__c)) {
                    mapObjectBusinessEntity.put(ct.Object_API__c,
                                                new ValidationBusinessEntity(ct.Object_API__c));
                }
                tempBusinessEntity = mapObjectBusinessEntity.get(ct.Object_API__c);
                tempBusinessEntity.attributes.add(ct.Field_API__c);
                tempBusinessEntity.attributes.add(ct.Object_Relationship_API__c);
                tempBusinessEntity.relationships.add(ct.Object_Relationship_API__c);
                mapObjectBusinessEntity.put(ct.Object_API__c,tempBusinessEntity);
            }
        }
        List<Validation_Rule__c> lstTempRules = new List<Validation_Rule__c>();
        // For every entry add class independent validation rules and class dependent rules
        for(Entry__c ent : mapIdEntry.values()) {

            mapValidationEntry.put(ent.Id, new ValidationEntry(ent));
            lstTempRules = new List<Validation_Rule__c>();
            // Add Class independent ones
            if(mapClassTypeListValidation.containsKey(ValidationConstants.VALIDATION_TYPE_INDEPENDENT)) {
                for(Id valiId : mapClassTypeListValidation.get(ValidationConstants.VALIDATION_TYPE_INDEPENDENT)) {
                    mapValidationEntry.get(ent.Id).vRules.add(mapValidationRule.get(valiId));
                }
            }
          System.debug('Validation Engine Helper  mapValidationEntry'+mapValidationEntry);

            // Add Class dependent rules
            if(mapEntryClassType.containsKey(ent.Id) && mapClassTypeListValidation.containsKey(mapEntryClassType.get(ent.Id))) {
                for(Id valiId : mapClassTypeListValidation.get(mapEntryClassType.get(ent.Id))) {
                    mapValidationEntry.get(ent.Id).vRules.add(mapValidationRule.get(valiId));
                }
            }
            System.debug('Validation Engine Helper  mapValidationEntry'+mapValidationEntry);

        }
        return mapValidationEntry;
    }
    /**
     * This function returns map of
     * Key - EntryId & Criteria d
     * Value - Entries_Validation__c
     * @author : Puneet Sardana
     * @Created Date : 29/05/2016
    **/
    public static Map<Id,Map<Id,Entries_Validation__c>> getEntryStatusMap(Set<String> entriesId) {
        Map<Id,Map<Id,Entries_Validation__c>> mapEntriesStatus = new Map<Id,Map<Id,Entries_Validation__c>>();
        Map<Id,Entries_Validation__c> criteriaStatus;
        for(Entries_Validation__c ev : [ SELECT Entry__c,Rule_Criteria__c,Status__c,Validation_Rule__c
                                                          FROM Entries_Validation__c
                                                          WHERE Entry__c  IN :entriesId]) {
            if(!mapEntriesStatus.containsKey(ev.Entry__c)) {
                mapEntriesStatus.put(ev.Entry__c,new Map<Id,Entries_Validation__c>());
            }
            criteriaStatus = mapEntriesStatus.get(ev.Entry__c);
            if(!criteriaStatus.containsKey(ev.Rule_Criteria__c)) {
                criteriaStatus.put(ev.Rule_Criteria__c,ev);
            }
        }
        return mapEntriesStatus;
    }

    public static Map<String,Entry__c> getEntryOverrides(List<Entry__c> entries) {
       Set<Id> horses = new Set<Id>();
       Set<Id> riders = new Set<Id>();
       Set<Id> classes = new Set<Id>();
       for(Entry__c ent : entries) {
          if(ent.Horse__c != null)
              horses.add(ent.Horse__c);
          if(ent.Rider__c != null)
              riders.add(ent.Rider__c);
          if(ent.Class__c != null)
              classes.add(ent.Class__c);
       }
        Set<String> horseClassRiderOverrideSet = new Set<String>();
        Map<String,Entry__c> mapEntryOverride = new Map<String,Entry__c>();
        for(Validation_Override__c vo : [SELECT Id,Class__c,Horse__c,Override__c,Rider__c
                                                            FROM Validation_Override__c
                                                            WHERE Override__c = true
                                                            AND Horse__c IN :horses
                                                            AND Rider__c IN :riders
                                                            AND Class__c IN :classes]) {
            if(vo.Rider__c != null && vo.Horse__c != null && vo.Class__c != null) {
                horseClassRiderOverrideSet.add(String.valueOf(vo.Class__c) + String.valueOf(vo.Horse__c)
                                                                      + String.valueOf(vo.Rider__c));
            }
       }
       String entOver;
       for(Entry__c ent : entries){
          if(ent.Class__c != null && ent.Horse__c != null && ent.Rider__c != null) {
             entOver = String.valueOf(ent.Class__c) + String.valueOf(ent.Horse__c)
                                                                      + String.valueOf(ent.Rider__c);
            if(horseClassRiderOverrideSet.contains(entOver)) {
              mapEntryOverride.put(String.valueOf(ent.Id), ent);
            }
          }
       }
       return mapEntryOverride;
   }
}