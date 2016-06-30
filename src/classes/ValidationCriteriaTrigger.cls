/**
 * Wrapper class for criteria trigger
 * @author : Puneet Sardana
 * @Created Date : 11/06/2016
*/
public class ValidationCriteriaTrigger {
    @AuraEnabled
    public Rule_Criteria__c criteria { get; set; }
    @AuraEnabled
    public List<Rule_Criteria_Triggers__c> triggers { get; set; }
}