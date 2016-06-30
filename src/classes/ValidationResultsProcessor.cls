/**
     * This class is used to process results of validation
     * @author : Puneet Sardana
     * @Created Date : 23/05/2016
    **/
public class ValidationResultsProcessor {
    public static List<ValidationResults> processValidationResults(Map<Id,ValidationEntry> mapEntryVali,Map<String,ValidationComponentsExecuter.CriteriaResult> mapCriteriaValidity,
                                                                                                        Map<Id,Event__c> mapIdEvent,Map<String,Set<Id>> mapAssObjects,
                                                                                                        Map<Id,Map<Id,Entries_Validation__c>> mapEntryStatus,
                                                                                                        Boolean isBatchMode) {
        System.debug('Puneet validation result processor mapCriteriaValidity '+mapCriteriaValidity );
        List<ValidationResults> lstValiResults = new List<ValidationResults>();
        ValidationResults tempVali;
        Boolean isValidationRuleValid,isEntryValid,toShowPresentMessage,isCriteriaValid;
        Object evtDate;
        Set<Id> horses = mapAssObjects.get(ValidationConstants.RELATES_TO_HORSE);
        Set<Id> riders = mapAssObjects.get(ValidationConstants.RELATES_TO_RIDER);
        Entries_Validation__c evTemp;
        List<Entries_Validation__c> lstEntriesValidation = new List<Entries_Validation__c>();
        for(ValidationEntry ev : mapEntryVali.values()) {
            tempVali = new ValidationResults(ev.entry.Id);
            isEntryValid = true;
            toShowPresentMessage = true;
            //Decide on past / present message based on field value present on constants
            evtDate = mapIdEvent.get(ev.entry.Event__c).get(ValidationConstants.VRCRITERIA_MESSAGE_FIELD_PASTPRESENT);
            // Check which message needs to be shown based on event date
            if(evtDate != null && Date.valueOf(evtDate) >= Date.today()) {
                    toShowPresentMessage = true;
            } else {
                    toShowPresentMessage = false;
            }
            for(Validation_Rule__c vr : ev.vRules) {
                isValidationRuleValid = true;
                for(Rule_Criteria__c vrc : vr.Rule_Criteria__r) {

                    // If the criteria can be triggered
                    if(!(mapCriteriaValidity.get(vrc.Id) == ValidationComponentsExecuter.CriteriaResult.CANNOT_TRIGGER)) {
                        //If mandatory then break and add to errors
                        if( ((mapCriteriaValidity.get(vrc.Id) == ValidationComponentsExecuter.CriteriaResult.FAIL || mapCriteriaValidity.get(vrc.Id) == ValidationComponentsExecuter.CriteriaResult.FAIL_STATUS)
                             && vrc.Criteria__c == ValidationConstants.VRCRITERIA_ISNOTMET)
                            ||
                            ( (mapCriteriaValidity.get(vrc.Id) == ValidationComponentsExecuter.CriteriaResult.PASS || mapCriteriaValidity.get(vrc.Id) == ValidationComponentsExecuter.CriteriaResult.PASS_STATUS)
                             && vrc.Criteria__c == ValidationConstants.VRCRITERIA_ISMET)
                          ) {
                                if(vrc.Validation_Category__c == ValidationConstants.VRCRITERIA_CATEGORY_MANDATORY ) {
                                    isValidationRuleValid = false;
                                    isEntryValid = false;
                                    tempVali.errors.add(toShowPresentMessage ? vrc.Msg_Present_Tense__c : vrc.Message_Past_Tense__c);
                                    break;
                                }// If warning then simply add to warnings
                                else if(vrc.Validation_Category__c == ValidationConstants.VRCRITERIA_CATEGORY_WARNING) {
                                    tempVali.warnings.add(toShowPresentMessage ? vrc.Msg_Present_Tense__c : vrc.Message_Past_Tense__c);
                                }
                             }
                    }
                    // If its in batch mode, insert/update records for horse / rider validation status
                    if(isBatchMode && vrc.Calculation_Mode__c == ValidationConstants.CRITERIA_CALMODE_BATCH &&
                        mapCriteriaValidity.get(vrc.Id) != ValidationComponentsExecuter.CriteriaResult.CANNOT_TRIGGER) {

                        if(mapEntryStatus.containsKey(ev.entry.Id) && mapEntryStatus.get(ev.entry.Id).containsKey(vrc.Id)) {
                            evTemp = mapEntryStatus.get(ev.entry.Id).get(vrc.Id);
                        } else {
                            evTemp = new Entries_Validation__c();
                            evTemp.Rule_Criteria__c =vrc.Id;
                            evTemp.Entry__c = ev.entry.Id;
                            evTemp.Validation_Rule__c = vr.Id;
                        }
                        evTemp.Status__c = isValidationRuleValid ?
                                                          ValidationConstants.VALIDATION_RESULT_PASS
                                                          : ValidationConstants.VALIDATION_RESULT_FAIL;
                        lstEntriesValidation.add(evTemp);
                    }
                }
                // If validation rule is not valid, break the flow and skip other rules
                if(!isValidationRuleValid) {
                    break;
                }
            }
            if(isEntryValid) {
                tempVali.isValidEntry = true;
            } else {
                tempVali.isValidEntry = false;
            }
            lstValiResults.add(tempVali);
        }
        if(lstEntriesValidation.size() >0 ) {
            upsert lstEntriesValidation;
        }
        return lstValiResults;
    }
}