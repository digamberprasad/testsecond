/**
 * Business entity class for firing queries in validation
 * @author : Puneet Sardana
 * @Created Date : 02/06/2016
*/
public class ValidationBusinessEntity {
    // Name of business entity
    public String businessEntity;
    // list of fields of that business entity
    public Set<String> attributes;
    // relationship fields of that business entity
    public Set<String> relationships;
    // Relates to - either horse , rider or event
    public Set<String> relatesTo;
    public ValidationBusinessEntity(String objName) {
         businessEntity = objName;
         attributes = new Set<String>();
         relationships = new Set<String>();
         relatesTo = new Set<String>();
    }
}