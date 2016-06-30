/**
 * This class contains the following :-
 * Entry - Single Entry
 * List of Validation Rules applicable on that entry
 * @author : Puneet Sardana
 * @Created Date : 18/05/2016
*/
public class EntryValidations {
	public Entry__c entry;
            public List<Validation_Rule__c> vRules;
            public EntryValidations(Entry__c ent) {
                this.entry = ent;
                vRules = new List<Validation_Rule__c>();
            }
            public EntryValidations(Entry__c ent, List<Validation_Rule__c> rules) {
                this.entry = ent;
                this.vRules = rules;
            }
}