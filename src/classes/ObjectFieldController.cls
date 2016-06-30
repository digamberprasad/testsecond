/**
 *  Controller for Object Field lightning component
 * @author : Puneet Sardana
 * @Created Date : 17/05/2016
 * */
public  class ObjectFieldController {
    // To Do : Read from custom settings
    private static final Set<String> lstSupportedObjects = new Set<String> { 'Rider__c' , 'Horse__c' , 'Contact', 'Event__c' };
    private static final Set<String> lstExcludeObjects = new Set<String> { 'Rider_Validation_Status__c' , 'Horse_Validation_Status__c'};
    /**
     *  Controller for Object Field lightning component
     * @author : Puneet Sardana
     * @Created Date : 17/05/2016
     * */
    @AuraEnabled
    public static List<SelectOption> getObjects() {
        List<SelectOption> lstOptions = new List<SelectOption>();
        Map<String,Schema.SobjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.DescribeSObjectResult objResult;
        for(String ty : schemaMap.keySet()) {
            objResult = schemaMap.get(ty).getDescribe();
            if(!lstExcludeObjects.contains(objResult.getName()) &&
               (lstSupportedObjects.contains(objResult.getName()) || containsObjectLookUp(schemaMap.get(ty)) )) {
                if(objResult.isCustom()) {
                    lstOptions.add(new SelectOption(objResult.getName(),objResult.getLabel() +
                                                                            ValidationConstants.BLANK_VALUE +
                                                                            ValidationConstants.CUSTOM_OBJECT));
                } else {
                    lstOptions.add(new SelectOption(objResult.getName(),objResult.getLabel()));

                }
            }
        }
        lstOptions.sort();
        return lstOptions;
    }
    /**
     *  Check if object has any field that is lookup to supported objects
     * @author : Puneet Sardana
     * @Created Date : 06/06/2016
     * */
    private static Boolean containsObjectLookUp(Schema.SobjectType obj) {
        Boolean containsLookup = false;
        Schema.DescribeSObjectResult objDescribe = obj.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        for(Schema.SObjectField obField : fieldMap.values() ) {
            Schema.DescribeFieldResult fr = obField.getDescribe();
            if(fr.getType() == Schema.DisplayType.REFERENCE) {
                for(Schema.SObjectType oType : fr.getReferenceTo()) {
                    if(lstSupportedObjects.contains(oType.getDescribe().getName())) {
                        containsLookup = true;
                        break;
                    }
                }
            }
            if(containsLookup) {
                break;
            }
        }
        return containsLookup;
    }
   /**
     *  List of fields of object
     * @author : Puneet Sardana
     * @Created Date : 06/06/2016
     * */
    @AuraEnabled
    public static List<SelectOption> getObjectFields(String objName) {
        List<SelectOption> lstOptions = new List<SelectOption>();
        Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(new List<String> { objName });
        Set<Schema.DisplayType> supportedFieldTypes = ValidationConstants.VALIDATION_SUPPORTED_FIELDTYPES;
        Schema.DescribeFieldResult fResult;
        for(Schema.DescribeSObjectResult res : descResult) {
            Map<String,Schema.SObjectField> fieldMap = res.fields.getMap();
            for(String ty : fieldMap.keySet()) {
                fResult = fieldMap.get(ty).getDescribe();
                if(supportedFieldTypes.contains(fResult.getType())) {
                    if(fResult.getName().equals(ValidationConstants.QUERY_FIELD_ID)) {
                        lstOptions.add(new SelectOption(fResult.getName(),ValidationConstants.SELF_OBJECT));
                    } else {
                        lstOptions.add(new SelectOption(fResult.getName(),fResult.getLabel()));
                    }
                }
            }
        }
        lstOptions.sort();
        return lstOptions;
    }

     /**
     *  List of fields of object
     * @author : Puneet Sardana
     * @Created Date : 06/06/2016
     * */
    @AuraEnabled
    public static List<SelectOption> getObjectRelationships(String objName) {
        List<SelectOption> lstOptions = new List<SelectOption>();
        Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(new List<String> { objName });
        Schema.DescribeFieldResult fResult;
        for(Schema.DescribeSObjectResult res : descResult) {
            Map<String,Schema.SObjectField> fieldMap = res.fields.getMap();
            for(String ty : fieldMap.keySet()) {
                fResult = fieldMap.get(ty).getDescribe();
                if(fResult.getType() == Schema.DisplayType.Reference ||
                   fResult.getType() == Schema.DisplayType.ID) {
                    if(fResult.getName().equals(ValidationConstants.QUERY_FIELD_ID)) {
                        lstOptions.add(new SelectOption(fResult.getName(),ValidationConstants.SELF_OBJECT));
                    } else {
                        lstOptions.add(new SelectOption(fResult.getName(),fResult.getLabel()));
                    }
                }
            }
        }
        lstOptions.sort();
        return lstOptions;
    }

}