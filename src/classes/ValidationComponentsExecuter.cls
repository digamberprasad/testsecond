/**
 * Validation components executer class
 * @author : Puneet Sardana
 * @Created Date : 02/06/2016
*/
public class ValidationComponentsExecuter {
    /**
     * Main method that executes validation components
     * @author : Puneet Sardana
     * @Created Date : 27/05/2016
     * mapEntryVali - Entry Id => ValidationEntry object
     * mapObjectInfo - Map of Related Object Id => Business Entity => Field Id => Value => Set of Object Ids
     * mapValidationRuleComponentNo - Map of validation id and component number ==> Validation Rule Component
     * mapAssObjects ==> Map of Object Name (Horse,Event or Rider) => Set of their associated Ids
     * mapCriteriaIdlstCriteriaTrigger ==> Map of Criteria Id ==> List of Rule Criteria Trigger
     *
    */
    public enum CriteriaResult { PASS , FAIL , CANNOT_TRIGGER, PASS_STATUS, FAIL_STATUS }
    public static Map<String,CriteriaResult> executeValidationComponents(Map<Id,ValidationEntry> mapEntryVali,Map<String,Map<String,ValidationObjectInfo>> mapObjectInfo,
                                                                                Map<String,Validation_Rule_Components__c> mapValidationRuleComponentNo,Map<String,Set<Id>> mapAssObjects,
                                                                                Map<String,List<Rule_Criteria_Triggers__c>> mapCriteriaIdlstCriteriaTrigger,Map<Id,Map<Id,Entries_Validation__c>> mapEntryCriteriaMap,
                                                                                Boolean isBatchMode) {
        System.debug('Puneet executer mapObjectInfo '+mapObjectInfo);
        Set<Id> horses = mapAssObjects.get(ValidationConstants.RELATES_TO_HORSE);
        Set<Id> events = mapAssObjects.get(ValidationConstants.RELATES_TO_EVENT);
        Set<Id> riders = mapAssObjects.get(ValidationConstants.RELATES_TO_RIDER);
        Boolean isValidationRuleValid,foundInStatus;
        Map<String,String> mapCriteriaIdReplacementString = new Map<String,String>();
        Map<String,CriteriaResult> mapCriteriaIdResult = new Map<String,CriteriaResult>();
        Boolean canTriggerCritera;

        for(ValidationEntry ev : mapEntryVali.values()) {
            System.debug('Puneet validation entry '+ev);
            for(Validation_Rule__c vr : ev.vRules) {
                isValidationRuleValid = false;
                for(Rule_Criteria__c vrc : vr.Rule_Criteria__r) {
                    foundInStatus = false;
                    if(vrc.Calculation_Mode__c == ValidationConstants.CRITERIA_CALMODE_BATCH && !isBatchMode) {
                        foundInStatus = mapEntryCriteriaMap.containsKey(ev.entry.Id) && mapEntryCriteriaMap.get(ev.entry.Id).containsKey(vrc.Id);
                    }
                    canTriggerCritera = !mapCriteriaIdlstCriteriaTrigger.containsKey(vrc.Id) || mapCriteriaIdlstCriteriaTrigger.get(vrc.Id).size() == 0 ||
                                                        evalCriteriaTrigger(ev,mapCriteriaIdlstCriteriaTrigger.get(vrc.Id),mapObjectInfo);
                    if(canTriggerCritera) {
                        if(foundInStatus) {
                            mapCriteriaIdResult.put(vrc.Id,mapEntryCriteriaMap.get(ev.entry.Id).get(vrc.Id).Status__c == ValidationConstants.VALIDATION_RESULT_PASS ? CriteriaResult.PASS_STATUS : CriteriaResult.FAIL_STATUS);
                        } else {
                             ValidationLogicInfo vInfo = getComponentsInValidationLogic(vrc);
                             System.debug('Sardana criteria '+vrc);
                             mapCriteriaIdReplacementString.put(vrc.Id,createBooleanExpression(ev,vrc,vInfo,mapObjectInfo,mapValidationRuleComponentNo));
                        }
                    } else {
                        mapCriteriaIdResult.put(vrc.Id, CriteriaResult.CANNOT_TRIGGER);
                    }
                }
            }
        }
        System.debug('Before Tooling');
        if(mapCriteriaIdReplacementString != null && mapCriteriaIdReplacementString.size() > 0) {
           // Map<String,Boolean> mapToolingResult = new Map<String,Boolean>();
            Map<String,Boolean> mapToolingResult = evalExpressionsFromTooling(mapCriteriaIdReplacementString);
            for(String criId : mapToolingResult.keySet()) {
                mapCriteriaIdResult.put(criId, mapToolingResult.get(criId) ? CriteriaResult.PASS : CriteriaResult.FAIL);
            }
        }
        return mapCriteriaIdResult;
    }
    /**
     * This method makes call to tooling API to evaluate expressions
     * *******************************WORKS IN BATCHES ONLY SINCE TOOLING API
     *                                             GIVES ERROR FOR LARGE EXPRESSIONS******************
     * @author : Puneet Sardana
     * @Created Date : 02/06/2016
    */
    private static Map<String,Boolean> evalExpressionsFromTooling(Map<String,String> mapCriExpression) {
        Map<String,Boolean> mapCriResult = new Map<String,Boolean>();
        Map<String,String> mapToolingCall = new Map<String,String>();
        Integer batchSize = 0;
        String andORReplacement = '';
        for(String criId : mapCriExpression.keySet()) {
            andORReplacement = mapCriExpression.get(criId);
            // Replace AND,OR with &&, ||
            andORReplacement = andORReplacement.replaceAll(ValidationConstants.VALIDATION_AND,
                                                                                                    ValidationConstants.VALIDATION_TOOLING_AND) ;
            andORReplacement = andORReplacement.replaceAll(ValidationConstants.VALIDATION_OR,
                                                                                                    ValidationConstants.VALIDATION_TOOLING_OR) ;

            mapToolingCall.put(criId,andORReplacement);
            if(batchSize == ValidationConstants.TOOLING_API_BATCHSIZE) {
                mapCriResult.putAll(ValidationEvalTooling.evalCriteria(mapToolingCall));
                batchSize = 0;
                mapToolingCall = new Map<String,String>();
            }
            batchSize++;
        }
        if(mapToolingCall.size() > 0) {
            mapCriResult.putAll(ValidationEvalTooling.evalCriteria(mapToolingCall));
        }
        System.debug('Puneet mapToolingCall '+mapToolingCall);
        return mapCriResult;
    }
     /**
     * This method evaluates rule criteria trigger for every rule criteria
     * @author : Puneet Sardana
     * @Created Date : 01/06/2016
    */
    private static Boolean evalCriteriaTrigger(ValidationEntry ve,List<Rule_Criteria_Triggers__c> criteriaTriggers,Map<String,Map<String,ValidationObjectInfo>> mapObjectInfo) {
        Boolean canTrigger = true;
        String relatedToId,fieldTypeId;
        ValidationObjectInfo objInfo;
        Set<String> matchedObjectIds;
        for(Rule_Criteria_Triggers__c rct : criteriaTriggers) {
            matchedObjectIds = new Set<String>();
            if(rct.Relates_To__c == ValidationConstants.RELATES_TO_HORSE) {
                relatedToId = ve.entry.Horse__c;
            } else if(rct.Relates_To__c == ValidationConstants.RELATES_TO_RIDER) {
                relatedToId = ve.entry.Rider__c;
            }else if(rct.Relates_To__c == ValidationConstants.RELATES_TO_EVENT) {
                relatedToId = ve.entry.Event__c;
            }
            objInfo = mapObjectInfo.get(relatedToId).get(rct.Business_Entity_API__c);
            Set<String> fieldValues;
            // Get values related to that field/value
            if(rct.Operand_Type__c == ValidationConstants.VRCOMPONENT_OPERANDTYPE_FIELD) {
                if(rct.Object_API__c == ValidationConstants.RELATES_TO_HORSEAPI) {
                    fieldTypeId = ve.Entry.Horse__c;
                } else if(rct.Object_API__c == ValidationConstants.RELATES_TO_RIDERAPI) {
                    fieldTypeId = ve.Entry.Rider__c;
                } else if(rct.Object_API__c == ValidationConstants.RELATES_TO_EVENTAPI) {
                    fieldTypeId = ve.Entry.Event__c;
                }
                fieldValues = mapObjectInfo.get(fieldTypeId).get(rct.Object_API__c).mapfieldNameValueObjectIds.get(rct.Field_API__c).keySet();
            } else if(rct.Operand_Type__c == ValidationConstants.VRCOMPONENT_OPERANDTYPE_VALUE) {
                fieldValues = new Set<String>(rct.Value__c.Split(ValidationConstants.VRCOMPONENT_VALUE_SPLITTER));
            }
            matchedObjectIds.addAll(evalComponent(rct.Attribute_API__c,rct.Attribute_Type__c,rct.Operator__c,objInfo,fieldValues));
             // If any of the trigger condition fails, skips the rest and exit
            if(matchedObjectIds.size() == 0) {
                canTrigger = false;
                break;
            }
        }
        return canTrigger;
    }
    private static String createBooleanExpression(ValidationEntry ve,Rule_Criteria__c rc,ValidationLogicInfo info,
                                                                              Map<String,Map<String,ValidationObjectInfo>> mapObjectInfo,
                                                                              Map<String,Validation_Rule_Components__c> mapValidationRuleComponentNo) {
        System.debug(' inside createBooleanExpression ');
        String strForTooling = '',relatedToId,fieldTypeId;
        Set<String> fieldValues;
        Validation_Rule_Components__c vComp;
        Map<String,Boolean> replaceCompValue = new Map<String,Boolean>();
        ValidationObjectInfo objInfo;
        // For all replacements
        Boolean oldComponent = false;
        Set<String> matchedObjectIds;
        for(String replace : info.replacements) {
            matchedObjectIds = new Set<String>();
            if(info.mapCriteriaIdReplacementComponents.containsKey(rc.Id + replace)) {
                oldComponent = false;
                for(String comp : info.mapCriteriaIdReplacementComponents.get(rc.Id + replace)) {
                    fieldValues = new Set<String>();
                    vComp = mapValidationRuleComponentNo.get(rc.Validation_Rule__c + comp);
                    System.debug('Puneet vComp '+vComp);
                    if(vComp.Relates_To__c == ValidationConstants.RELATES_TO_HORSE) {
                        relatedToId = ve.entry.Horse__c;
                    } else if(vComp.Relates_To__c == ValidationConstants.RELATES_TO_RIDER) {
                        relatedToId = ve.entry.Rider__c;
                    }else if(vComp.Relates_To__c == ValidationConstants.RELATES_TO_EVENT) {
                        relatedToId = ve.entry.Event__c;
                    }

                    if(mapObjectInfo.containsKey(relatedToId) && mapObjectInfo.get(relatedToId).containsKey(vComp.Business_Entity_API__c)) {
                        objInfo = mapObjectInfo.get(relatedToId).get(vComp.Business_Entity_API__c);
                        if(vComp.Operand_Type__c == ValidationConstants.VRCOMPONENT_OPERANDTYPE_FIELD) {
                           if(vComp.Object_API__c == ValidationConstants.RELATES_TO_HORSEAPI) {
                                fieldTypeId = ve.Entry.Horse__c;
                            } else if(vComp.Object_API__c == ValidationConstants.RELATES_TO_RIDERAPI) {
                                fieldTypeId = ve.Entry.Rider__c;
                            } else if(vComp.Object_API__c == ValidationConstants.RELATES_TO_EVENTAPI) {
                                fieldTypeId = ve.Entry.Event__c;
                            }
                            System.debug('Puneet inside field relatedToId '+relatedToId);
                            System.debug('Puneet inside field relatedToId '+vComp.Object_API__c);
                            System.debug('Puneet inside field relatedToId '+vComp.Field_API__c);
                            System.debug('Puneet inside field map relatedToId '+mapObjectInfo.get(fieldTypeId));
                            System.debug('Puneet inside field map Object_API__c '+mapObjectInfo.get(fieldTypeId).get(vComp.Object_API__c));

                            fieldValues = mapObjectInfo.get(fieldTypeId).get(vComp.Object_API__c).mapfieldNameValueObjectIds.get(vComp.Field_API__c).keySet();
                        } else if(vComp.Operand_Type__c == ValidationConstants.VRCOMPONENT_OPERANDTYPE_VALUE) {
                            System.debug('Puneet Value__c '+vComp.Value__c);
                            fieldValues = new Set<String>(vComp.Value__c.Split(ValidationConstants.VRCOMPONENT_VALUE_SPLITTER));
                            System.debug('Puneet fieldValues '+fieldValues);
                        }
                        if(!oldComponent) {
                            oldComponent = true;
                            matchedObjectIds.addAll(evalComponent(vComp.Attribute_API__c,vComp.Attribute_Type__c,vComp.Operator__c,objInfo,fieldValues));
                        } else {
                            matchedObjectIds.retainAll(evalComponent(vComp.Attribute_API__c,vComp.Attribute_Type__c,vComp.Operator__c,objInfo,fieldValues));
                        }
                    }
                }
            }
            System.debug('Puneet matchedObjectIds '+matchedObjectIds);
            if(matchedObjectIds.size() > 0) {
               info.replaced = info.replaced.replace(replace ,ValidationConstants.TRUE_STRING);
            } else{
               info.replaced = info.replaced.replace(replace ,ValidationConstants.FALSE_STRING);
            }
            System.debug('Puneet info.replaced '+info.replaced);

        }
        System.debug('Puneet info.replaced '+info.replaced);
        return info.replaced;
    }

    private static Set<String> evalComponent(String attrAPI,String attrType,String operator,ValidationObjectInfo info,Set<String> fieldValues) {
        System.debug('Sardana evalComponent info '+info);

        Set<String> matchedObjectIds = new Set<String>();
        Boolean isMatched = false;
        if(info != null && info.mapfieldNameValueObjectIds != null &&
           info.mapfieldNameValueObjectIds.containsKey(attrAPI)) {
            for(String value : info.mapfieldNameValueObjectIds.get(attrAPI).keySet()) {
                isMatched = false;
                if(attrType == ValidationConstants.VRCOMPONENT_ATTRIBUTETYPE_TEXT) {
                    isMatched = isMatch(value,fieldValues,operator);
                } else if(attrType == ValidationConstants.VRCOMPONENT_ATTRIBUTETYPE_NUMBER) {
                    isMatched = isMatch(String.isNotBlank(value) ? Decimal.valueOf(value) : 0,fieldValues,operator);
                } else if(attrType == ValidationConstants.VRCOMPONENT_ATTRIBUTETYPE_DATE) {
                    isMatched = isMatch(String.isNotBlank(value) ? Date.valueOf(value) : null,fieldValues,operator);
                } else if(attrType == ValidationConstants.VRCOMPONENT_ATTRIBUTETYPE_DATETIME) {
                    isMatched = isMatch(String.isNotBlank(value) ? DateTime.valueOf(value) : null,fieldValues,operator);
                } else if(attrType == ValidationConstants.VRCOMPONENT_ATTRIBUTETYPE_BOOLEAN) {
                    isMatched = isMatch(String.isNotBlank(value) ? Boolean.valueOf(value) : null,fieldValues,operator);
                }
                if(isMatched) {
                    matchedObjectIds.addAll(info.mapfieldNameValueObjectIds.get(attrAPI).get(value));
                }
            }
        }
        System.debug('Sardana evalComponent matchedObjectIds '+matchedObjectIds);
        return matchedObjectIds;
    }

    private static Boolean isMatch(String lValue,Set<String> rValues,String operator) {
        Boolean isMatched = false;
        for(String rv : rValues) {
            if(isMatched) {
                break;
            }
            if(operator == ValidationConstants.VRCOMPONENT_OPERATOR_EQUALS) {
                isMatched = (lValue == rv);
            } else if(operator == ValidationConstants.VRCOMPONENT_OPERATOR_NOTEQUAL) {
                isMatched = (lValue != rv);
            } else if(operator == ValidationConstants.VRCOMPONENT_OPERATOR_GREATERTHAN) {
                isMatched = (lValue > rv);
            } else if(operator == ValidationConstants.VRCOMPONENT_OPERATOR_GREATERTHANEQUAL) {
                isMatched = (lValue >= rv);
            } else if(operator == ValidationConstants.VRCOMPONENT_OPERATOR_LESSTHAN) {
                isMatched = (lValue < rv);
            } else if(operator == ValidationConstants.VRCOMPONENT_OPERATOR_LESSTHANEQUAL) {
                isMatched = (lValue <= rv);
            }  else if(operator == ValidationConstants.VRCOMPONENT_OPERATOR_CONTAINS) {
                isMatched = (lValue.contains(rv));
            }
        }
        return isMatched;
    }
    private static Boolean isMatch(Date lValue,Set<String> rValues,String operator) {
        Boolean isMatched = false;
        Date rvDate;
        for(String rv : rValues) {
            rvDate = String.isNotBlank(rv) ? Date.valueOf(rv) : null;
            if(isMatched) {
                break;
            }
            if(operator == ValidationConstants.VRCOMPONENT_OPERATOR_EQUALS) {
                isMatched = (lValue == rvDate);
            } else if(operator == ValidationConstants.VRCOMPONENT_OPERATOR_NOTEQUAL) {
                isMatched = (lValue != rvDate);
            } else if(operator == ValidationConstants.VRCOMPONENT_OPERATOR_GREATERTHAN) {
                isMatched = (lValue > rvDate);
            } else if(operator == ValidationConstants.VRCOMPONENT_OPERATOR_GREATERTHANEQUAL) {
                isMatched = (lValue >= rvDate);
            } else if(operator == ValidationConstants.VRCOMPONENT_OPERATOR_LESSTHAN) {
                isMatched = (lValue < rvDate);
            } else if(operator == ValidationConstants.VRCOMPONENT_OPERATOR_LESSTHANEQUAL) {
                isMatched = (lValue <= rvDate);
            }
        }
        return isMatched;
    }
    private static Boolean isMatch(DateTime lValue,Set<String> rValues,String operator) {
        Boolean isMatched = false;
        DateTime rvDate;
        System.debug('Puneet datetime lValue '+lValue);
        System.debug('Puneet datetime rValues '+rValues);

        for(String rv : rValues) {
            rvDate = String.isNotBlank(rv) ? DateTime.valueOf(rv) : null;
            if(isMatched) {
                break;
            }
            if(operator == ValidationConstants.VRCOMPONENT_OPERATOR_EQUALS) {
                isMatched = (lValue == rvDate);
            } else if(operator == ValidationConstants.VRCOMPONENT_OPERATOR_NOTEQUAL) {
                isMatched = (lValue != rvDate);
            } else if(operator == ValidationConstants.VRCOMPONENT_OPERATOR_GREATERTHAN) {
                isMatched = (lValue > rvDate);
            } else if(operator == ValidationConstants.VRCOMPONENT_OPERATOR_GREATERTHANEQUAL) {
                isMatched = (lValue >= rvDate);
            } else if(operator == ValidationConstants.VRCOMPONENT_OPERATOR_LESSTHAN) {
                isMatched = (lValue < rvDate);
            } else if(operator == ValidationConstants.VRCOMPONENT_OPERATOR_LESSTHANEQUAL) {
                isMatched = (lValue <= rvDate);
            }
        }
        return isMatched;
    }
    private static Boolean isMatch(Decimal lValue,Set<String> rValues,String operator) {
        Boolean isMatched = false;
        Decimal rvDecimal;
        for(String rv : rValues) {
            rvDecimal = String.isNotBlank(rv) ? Decimal.valueOf(rv) : null;
            if(isMatched) {
                break;
            }
            if(operator == ValidationConstants.VRCOMPONENT_OPERATOR_EQUALS) {
                isMatched = (lValue == rvDecimal);
            } else if(operator == ValidationConstants.VRCOMPONENT_OPERATOR_NOTEQUAL) {
                isMatched = (lValue != rvDecimal);
            } else if(operator == ValidationConstants.VRCOMPONENT_OPERATOR_GREATERTHAN) {
                isMatched = (lValue > rvDecimal);
            } else if(operator == ValidationConstants.VRCOMPONENT_OPERATOR_GREATERTHANEQUAL) {
                isMatched = (lValue >= rvDecimal);
            } else if(operator == ValidationConstants.VRCOMPONENT_OPERATOR_LESSTHAN) {
                isMatched = (lValue < rvDecimal);
            } else if(operator == ValidationConstants.VRCOMPONENT_OPERATOR_LESSTHANEQUAL) {
                isMatched = (lValue <= rvDecimal);
            }
        }
        return isMatched;
    }
    private static Boolean isMatch(Boolean lValue,Set<String> rValues,String operator) {
        Boolean isMatched = false;
        Boolean rvBoolean;
        for(String rv : rValues) {
            rvBoolean = String.isNotBlank(rv) ? Boolean.valueOf(rv) : null;
            if(isMatched) {
                break;
            }
            if(operator == ValidationConstants.VRCOMPONENT_OPERATOR_EQUALS) {
                isMatched = (lValue == rvBoolean);
            } else if(operator == ValidationConstants.VRCOMPONENT_OPERATOR_NOTEQUAL) {
                isMatched = (lValue != rvBoolean);
            }
        }
        return isMatched;
    }
    private static ValidationLogicInfo getComponentsInValidationLogic(Rule_Criteria__c rc) {
        Set<String> validNumbers = new Set<String> { '0' , '1' , '2' , '3' , '4' , '5' , '6' , '7' , '8', '9' };
        String valLogic = rc.Validation_Logic__c;
        Integer valLogicLen = valLogic.length();
        String currChar,nextChar;
        ValidationLogicInfo vInfo = new ValidationLogicInfo();
        vInfo.original = valLogic;
        String replaceStr = 'CRI';
        Integer replaceNo = 1;
        Set<String> valuesTemp;
        for(Integer pos =0 ; pos < valLogicLen ;  ) {
            currChar = valLogic.substring(pos, pos +1);
            nextChar = '';
            if( valLogicLen > pos + 1 ) {
                 nextChar = valLogic.substring(pos + 1, pos +2);
            }
            String values,replaceFullStr;
            // For Range [1,2]
            if(currChar == ValidationConstants.VALIDATION_LOGIC_START_DELIMITER) {
                values = valLogic.substring(pos +1, valLogic.indexOf(ValidationConstants.VALIDATION_LOGIC_END_DELIMITER, pos + 1));
                replaceFullStr = replaceStr + String.valueOf(replaceNo);
                vInfo.replacements.add(replaceFullStr);
                vInfo.replaced += replaceFullStr;
                if(!vInfo.mapCriteriaIdReplacementComponents.containsKey(rc.Id +replaceFullStr )) {
                    vInfo.mapCriteriaIdReplacementComponents.put(rc.Id + replaceFullStr,new Set<String>());
                }
                valuesTemp = vInfo.mapCriteriaIdReplacementComponents.get(rc.Id + replaceFullStr);
                valuesTemp.addAll(values.split(ValidationConstants.VALIDATION_COMPONENT_SPLITTER));
                vInfo.mapCriteriaIdReplacementComponents.put(rc.Id + replaceFullStr,valuesTemp);
                replaceNo++;
                pos = valLogic.indexOf(ValidationConstants.VALIDATION_LOGIC_END_DELIMITER, pos + 1) + 1;
            }
            // For double number like 10 or 20
            else if(validNumbers.contains(currChar) && String.isNotBlank(nextChar) && validNumbers.contains(nextChar)) {
                values = valLogic.substring(pos ,pos + 2 );
                replaceFullStr = replaceStr + String.valueOf(replaceNo);
                vInfo.replacements.add(replaceFullStr);
                vInfo.replaced += replaceFullStr;
                if(!vInfo.mapCriteriaIdReplacementComponents.containsKey(rc.Id + replaceFullStr )) {
                    vInfo.mapCriteriaIdReplacementComponents.put(rc.Id + replaceFullStr,new Set<String>());
                }
                valuesTemp = vInfo.mapCriteriaIdReplacementComponents.get(rc.Id + replaceFullStr);
                valuesTemp.add(values);
                vInfo.mapCriteriaIdReplacementComponents.put(rc.Id + replaceFullStr,valuesTemp);
                replaceNo++;
                pos += 2;
            }
            // For single Numbers
            else if(validNumbers.contains(currChar) && (String.isBlank(nextChar) || !validNumbers.contains(nextChar))) {
                values = valLogic.substring(pos  ,pos + 1 );
                replaceFullStr = replaceStr + String.valueOf(replaceNo);
                vInfo.replacements.add(replaceFullStr);
                vInfo.replaced += replaceFullStr;
                if(!vInfo.mapCriteriaIdReplacementComponents.containsKey(rc.Id + replaceFullStr )) {
                    vInfo.mapCriteriaIdReplacementComponents.put(rc.Id + replaceFullStr,new Set<String>());
                }
                valuesTemp = vInfo.mapCriteriaIdReplacementComponents.get(rc.Id + replaceFullStr);
                valuesTemp.add(values);
                vInfo.mapCriteriaIdReplacementComponents.put(rc.Id + replaceFullStr,valuesTemp);
                replaceNo++;
                pos++;
            } else {
                vInfo.replaced += currChar;
                pos++;
            }
        }
        return vInfo;
    }
    public class ValidationLogicInfo {
        public String original;
        public String replaced;
        public Set<String> replacements;
        // Map of RuleCriteria Id + Replacement String (CRI1) --> Set of components in that replacement
        public Map<String,Set<String>> mapCriteriaIdReplacementComponents;
        public ValidationLogicInfo() {
            original = replaced = '';
            replacements = new Set<String>();
            mapCriteriaIdReplacementComponents = new Map<String,Set<String>>();
        }
    }
}