/**
 *  Validation Object Information class
 * @author : Puneet Sardana
 * @Created Date : 27/05/2016
*/
public class ValidationObjectInfo {
        public List<sObject> sObjects;
        // Map of field => values => set of object id with that value
        public Map<String,Map<String,Set<String>>> mapfieldNameValueObjectIds;
        public ValidationObjectInfo() {
            sObjects = new List<sObject>();
            mapfieldNameValueObjectIds = new Map<String,Map<String,Set<String>>>();
        }
}