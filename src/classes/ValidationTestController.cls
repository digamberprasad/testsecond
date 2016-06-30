public class ValidationTestController {
    public String entry { get; set; }
    public List<String> lstEntries { get; set; }
    public List<VResults> lstResult { get; set; }
    public DateTime startTime { get; set; }
    public DateTime endTime { get; set; }
    public Decimal elapsedTime { get; set; }
    public Boolean mode { get; set; }
    public ValidationTestController() {
        entry = 'a0J4E000000ag8l';
    }
    public PageReference fetchValidationResults() {
        startTime = DateTime.now();
        lstEntries = entry.split(',');
        lstResult = new List<VResults>();
        VResults vTemp;
        for(ValidationResults vr : ValidationEngine.validateEntries(lstEntries, mode)) {
            vTemp = new VResults(vr.entryId);
            vTemp.isValidEntry = vr.isValidEntry;
            vTemp.errors = vr.errors;
            vTemp.warnings = vr.warnings;
            lstResult.add(vTemp);
        }
        endTime = DateTime.now();
        elapsedTime = ((endTime.getTime())) - ((startTime.getTime()));
        return null;
    }

    public class VResults {
        public String entryId { get; set; }
        public Boolean isValidEntry { get; set; }
        public List<String> warnings {get; set; }
        public List<String> errors {get; set; }
        public VResults(String ent) {
            this.entryId = ent;
            warnings = new List<String>();
            errors = new List<String>();
            isValidEntry = true;
        }
    }
}