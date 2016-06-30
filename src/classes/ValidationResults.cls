/**
 * Output of ValidationEngine Execution
 * @author : Puneet Sardana
 * @Created Date : 26/05/2016
*/
public class ValidationResults {
    public String entryId;
    public Boolean isValidEntry;
    public List<String> warnings;
    public List<String> errors;
    public ValidationResults(String ent) {
        this.entryId = ent;
        warnings = new List<String>();
        errors = new List<String>();
        isValidEntry = true;
    }
}