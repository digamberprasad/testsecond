/**
 * This is object builder class that fires quesries related to all different objects mentioned in the validation engine
 * @author : Puneet Sardana
 * @Created Date : 26/05/2016
*/
public class ValidationEngineObjectsBuilder {
    // map of Map<Relationship Id (Rider or Horse or Event)<Map<Object name,ValidationObjectInformation>>>
    public static Map<String,Map<String,ValidationObjectInfo>> getObjectsMap(Map<String,ValidationBusinessEntity> mapBusinessEntity,Map<String,Set<Id>> assObjects) {
        Set<Id> horses = assObjects.get(ValidationConstants.RELATES_TO_HORSE);
        Set<Id> events = assObjects.get(ValidationConstants.RELATES_TO_EVENT);
        Set<Id> riders = assObjects.get(ValidationConstants.RELATES_TO_RIDER);
        Map<String,Map<String,ValidationObjectInfo>> mapRelatedEntityObjectInfo = new Map<String,Map<String,ValidationObjectInfo>>();
        ValidationBusinessEntity tempBusinessEntity;
        Set<String> busiEntities = new Set<String>();
        for(ValidationBusinessEntity vbe : mapBusinessEntity.values()) {
            busiEntities.add(vbe.businessEntity);
        }
        Map<String,Map<String,String>> mapObjectFieldLookUp = getObjectLookUpName(busiEntities);
        System.debug('Puneet mapObjectFieldLookUp '+mapObjectFieldLookUp);
        // for every entity / object build the query
        for(String entity : mapBusinessEntity.keySet()) {
            String query = buildQuery(mapBusinessEntity.get(entity),mapObjectFieldLookUp);
            System.debug('Puneet object query'+query);
            tempBusinessEntity = mapBusinessEntity.get(entity);
            System.debug('Puneet tempBusinessEntity'+tempBusinessEntity);

            //Fire the query
            for(sObject obj : Database.query(query)) {
                ValidationObjectInfo tempObjInfo = new ValidationObjectInfo();
                tempObjInfo.sObjects.add(obj);
                tempObjInfo.mapfieldNameValueObjectIds = new Map<String,Map<String,Set<String>>>();
                //For every field of this object fill ValidationObjectInfo
                for(String field : tempBusinessEntity.attributes) {
                    // Fill Map with field name
                    if(!tempObjInfo.mapfieldNameValueObjectIds.containsKey(field)) {
                        tempObjInfo.mapfieldNameValueObjectIds.put(field,new Map<String,Set<String>>());
                    }
                    String fieldVal = String.valueOf(obj.get(field));
                    fieldVal = String.isBlank(fieldVal) ? ValidationConstants.BLANK_VALUE : fieldVal;
                    System.debug('Puneet object builder field'+field);
                    System.debug('Puneet object builder fieldVal'+obj.get(field));
                    // Fill map wtih field value and set of Ids
                    if(!tempObjInfo.mapfieldNameValueObjectIds.get(field).containsKey(fieldVal)) {
                        tempObjInfo.mapfieldNameValueObjectIds.get(field).put(fieldVal,new Set<String>());
                    }
                    Set<String> objectIds = tempObjInfo.mapfieldNameValueObjectIds.get(field).get(fieldVal);
                    // Add the standard ID field
                    objectIds.add(String.valueOf(obj.get(ValidationConstants.QUERY_FIELD_ID)));
                    tempObjInfo.mapfieldNameValueObjectIds.get(field).put(fieldVal,objectIds);
                }
                for(String rel : tempBusinessEntity.relationships) {
                    System.debug('puneet relationship '+rel);
                    System.debug('puneet relationship '+obj);
                    System.debug('puneet relationship value '+obj.get(rel));

                    if(obj.get(rel) != null) {
                        String relId = String.valueOf(obj.get(rel));
                        if(!mapRelatedEntityObjectInfo.containsKey(relId)) {
                            mapRelatedEntityObjectInfo.put(relId,new Map<String,ValidationObjectInfo>());
                        }
                        if(!mapRelatedEntityObjectInfo.get(relId).containsKey(tempBusinessEntity.businessEntity)) {
                            mapRelatedEntityObjectInfo.get(relId).put(tempBusinessEntity.businessEntity,tempObjInfo);
                        }
                    }
                }
            }
        }
        System.debug('Puneet object builder mapRelatedEntityObjectInfo '+mapRelatedEntityObjectInfo);
        return mapRelatedEntityObjectInfo;
    }


    private static Map<String,Map<String,String>> getObjectLookUpName(Set<String> entities) {
        Map<String,Map<String,String>> mapObjectFieldLookUp = new Map<String,Map<String,String>>();
        Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(new List<String>(entities));
        Schema.DescribeFieldResult fResult;
        Map<String,String> fieldLookUpTemp;
        for(Schema.DescribeSObjectResult res : descResult) {
            Map<String,Schema.SObjectField> fieldMap = res.fields.getMap();
            for(String ty : fieldMap.keySet()) {
                fResult = fieldMap.get(ty).getDescribe();
                if(fResult.getType() == Schema.DisplayType.Reference) {
                    if(!mapObjectFieldLookUp.containsKey(res.getName())) {
                        mapObjectFieldLookUp.put(res.getName(),new Map<String,String>());
                    }
                    fieldLookUpTemp = mapObjectFieldLookUp.get(res.getName());
                    if(!fieldLookUpTemp.containsKey(fResult.getName())) {
                        fieldLookUpTemp.put(fResult.getName(),fResult.getReferenceTo().get(0).getDescribe().getName());
                    }
                    mapObjectFieldLookUp.put(res.getName(),fieldLookUpTemp);
                }
            }
        }
        return mapObjectFieldLookUp;
    }
    /**
     * This method is used to build query for a business entity
     * @author : Puneet Sardana
     * @Created Date : 26/05/2016
    */
    private static String buildQuery(ValidationBusinessEntity vbe, Map<String,Map<String,String>> mapObjectFieldLookUp ) {
        System.debug('Puneet validate business entity '+vbe);
        vbe.attributes.add(ValidationConstants.QUERY_FIELD_ID);
        // Create SELECT Clause
        String qry = '';
        qry += ValidationConstants.QUERY_SELECT;
        for(String field : vbe.attributes) {
            qry += (field + ValidationConstants.QUERY_FIELD_SEPARATOR);
        }
        // Remove the extra comma
        qry = qry.substring(0, qry.length() -1 );
        // Create From Clause
        qry += (ValidationConstants.QUERY_FROM + vbe.businessEntity);
        //Create Where clause (Add always true clause Id!=null)
        qry += (ValidationConstants.QUERY_WHERE + ValidationConstants.QUERY_FIELD_ID + ' != null ');

        String orClause = '',relatedObjectName;
        //Create OR Clause
        for(String rel : vbe.relationships) {
            if(mapObjectFieldLookUp.containsKey(vbe.businessEntity) &&
               mapObjectFieldLookUp.get(vbe.businessEntity).containsKey(rel)) {
                relatedObjectName = mapObjectFieldLookUp.get(vbe.businessEntity).get(rel);
                if(relatedObjectName.containsIgnoreCase(ValidationConstants.RELATES_TO_RIDERAPI)) {
                    orClause += rel + ValidationConstants.QUERY_IN + ' :riders ' + ValidationConstants.QUERY_OR;
                } else if(relatedObjectName.containsIgnoreCase(ValidationConstants.RELATES_TO_HORSEAPI)) {
                    orClause += rel + ValidationConstants.QUERY_IN + ' :horses ' + ValidationConstants.QUERY_OR;
                } else if(relatedObjectName.containsIgnoreCase(ValidationConstants.RELATES_TO_EVENTAPI)) {
                    orClause += rel + ValidationConstants.QUERY_IN + ' :events ' + ValidationConstants.QUERY_OR;
                }
            }
            if(rel.equals(ValidationConstants.RELATES_TO_ID)) {
                 if(vbe.businessEntity.containsIgnoreCase(ValidationConstants.RELATES_TO_RIDERAPI)) {
                    orClause += rel + ValidationConstants.QUERY_IN + ' :riders ' + ValidationConstants.QUERY_OR;
                 } else if(vbe.businessEntity.containsIgnoreCase(ValidationConstants.RELATES_TO_HORSEAPI)) {
                    orClause += rel + ValidationConstants.QUERY_IN + ' :horses ' + ValidationConstants.QUERY_OR;
                 } else if(vbe.businessEntity.containsIgnoreCase(ValidationConstants.RELATES_TO_EVENTAPI)) {
                    orClause += rel + ValidationConstants.QUERY_IN + ' :events ' + ValidationConstants.QUERY_OR;
                 }
             }
        }
        Integer orLastIndex = orClause.lastIndexOf(ValidationConstants.QUERY_OR);
        if(orLastIndex != -1) {
            orClause = orClause.substring(0, orLastIndex -1);
            qry += ValidationConstants.QUERY_AND + ' ( ' + orClause + ' ) ';
        }
        return qry;
    }
}