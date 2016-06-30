/**
 * Validation Engine
 * The engine is divided into several parts :-
 * Part 1 - Build Validation Entry List ---- It builds entry with list of all validation rules applicable to this entry
 * Part 2 - Object Builder - It builds the following Map --
 * Related To ID (Horse Id or Rider Id or Event Id) ==> Business Entity API ==> Field API ==> Value ==> List of object ids matching that value
 * Part 3 - Validation Component Executor -- This class executed the validation rules, components and criterias
 * Part 4 - Validation Results Processor - Process Validation Results based on results obtained from validation component executor
 * @author : Puneet Sardana
 * @Created Date : 18/05/2016
*/
public class ValidationEngine {
    private static Set<Id> riders;
    private static Set<Id> horses;
    private static Set<Id> classes;
    private static Set<Id> events;
    private static List<Entry__c> entries;
    private static List<Entry__c> entriesOverRidden;
    // Map of entry id and entry entity
    private static Map<Id,Entry__c> mapEntryIdEntry;
    // Map of entry and class type
    private static Map<Id,Id> mapEntryClassType;
    private static Map<Id,Event__c> mapIdEvent;

    public static List<ValidationResults> validateEntries(List<String> entriesId, Boolean isBatchMode) {
        // init all sets, maps needed
        List<Entry__c> allEntries = [SELECT Class__c, Rider__c, Horse__c, Validation_Status__c
                                                    FROM Entry__c
                                                    WHERE Id IN :entriesId];
        Map<String,Entry__c> mapOverRideEntries = ValidationEngineHelper.getEntryOverrides(allEntries);
        Set<String> entriesToCalculate = new Set<String>(entriesId);
        entriesToCalculate.removeAll(mapOverRideEntries.keySet());
        initValidationEngine(entriesToCalculate);

        // Build Map of Entry Id --> All validation rules applicable to that entry
        Map<Id,ValidationEntry> mapValidationEntry = ValidationEngineHelper.buildEntryValidationList(mapEntryIdEntry, mapEntryClassType);
        System.debug('Puneet mapValidationEntry '+mapValidationEntry);
        System.debug('After ValidationEngineHelper.buildEntryValidationList getCpuTime() '+Limits.getCpuTime());
        System.debug('After ValidationEngineHelper.buildEntryValidationList getLimitCpuTime() '+Limits.getLimitCpuTime());
        // Put all related objects  set in a map
        Map<String,Set<Id>> mapObjects = new Map<String,Set<Id>>();
        mapObjects.put(ValidationConstants.RELATES_TO_HORSE,horses);
        mapObjects.put(ValidationConstants.RELATES_TO_EVENT,events);
        mapObjects.put(ValidationConstants.RELATES_TO_RIDER,riders);
        // Fire queries related to all business objects and get results
        Map<String,Map<String,ValidationObjectInfo>> mapEntryValidationValues = ValidationEngineObjectsBuilder.getObjectsMap(ValidationEngineHelper.getValidationObjectBusinessEntityMap()
                                                     , mapObjects);
        System.debug('After ValidationEngineObjectsBuilder.getObjectsMap getCpuTime() '+Limits.getCpuTime());
        System.debug('After ValidationEngineObjectsBuilder.getObjectsMap getLimitCpuTime() '+Limits.getLimitCpuTime());
        // Validation Component Executor ==> execute validation engine and get result Result Criteria ID and whether that criteria is passed or not
        Map<Id,Map<Id,Entries_Validation__c>> mapEntryStatus = ValidationEngineHelper.getEntryStatusMap(new Set<String>(entriesId));
        Map<String,ValidationComponentsExecuter.CriteriaResult> mapCriteriaValidity = ValidationComponentsExecuter.executeValidationComponents(mapValidationEntry,mapEntryValidationValues,
                                                                                                                                        ValidationEngineHelper.getValidationRuleComponentNoMap(),mapObjects,
                                                                                                                                        ValidationEngineHelper.getCriteriaIdTriggerMap(),mapEntryStatus,isBatchMode);
        System.debug('After ValidationComponentsExecuter.executeValidationComponents getCpuTime() '+Limits.getCpuTime());
        System.debug('After ValidationComponentsExecuter.executeValidationComponents getLimitCpuTime() '+Limits.getLimitCpuTime());
        // Process validation results got from the executor
        List<ValidationResults> lstValiResults = ValidationResultsProcessor.processValidationResults(mapValidationEntry, mapCriteriaValidity,
                                                                                                                                                               mapIdEvent,mapObjects,mapEntryStatus,isBatchMode);
        System.debug('After ValidationResultsProcessor.processValidationResults getCpuTime() '+Limits.getCpuTime());
        System.debug('After ValidationResultsProcessor.processValidationResults getLimitCpuTime() '+Limits.getLimitCpuTime());
        System.debug('----FINAL OUTPUT-----'+lstValiResults);
        return lstValiResults;
    }
    /**
     * Method used to initialize all sets, maps of horses, riders and events to be used in validation engine
     * @author : Puneet Sardana
     * @Created Date : 20/05/2016
    */
    private static void initValidationEngine(Set<String> entriesId) {
        riders = new Set<Id>();
        horses = new Set<Id>();
        classes = new Set<Id>();
        events = new Set<Id>();
        entries = new List<Entry__c>();
        mapEntryIdEntry = new Map<Id,Entry__c>();
        mapEntryClassType = new Map<Id,Id>();
        mapIdEvent = new Map<Id,Event__c>();
        for(Entry__c ent : [ SELECT Id,Rider__c,Horse__c,Event__c,Class__c,Class__r.Class_Type__c,
                                       Event__r.Start_Date__c,Event__r.End_Date__c,Validation_Status__c
                                      FROM Entry__c
                                      WHERE Id IN :entriesId ] ) {
            mapEntryClassType.put(ent.Id,ent.Class__r.Class_Type__c);
            mapIdEvent.put(ent.Event__c,ent.Event__r);
            entries.add(ent);
            mapEntryIdEntry.put(ent.Id,ent);
            riders.add(ent.Rider__c);
            horses.add(ent.Horse__c);
            classes.add(ent.Class__c);
            events.add(ent.Event__c);
        }
    }
}