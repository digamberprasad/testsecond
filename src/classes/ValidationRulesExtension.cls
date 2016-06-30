public with sharing class ValidationRulesExtension {
    private final Validation_Rule__c vRule;
    public String url { get; set; }
    public ValidationRulesExtension(ApexPages.StandardController stdController) {
        vRule  = (Validation_Rule__c)stdController.getRecord();
        url = System.URL.getSalesforceBaseUrl().toExternalForm();
        url += '/c/CreateValidation.app';
        if(vRule.Id != null) {
            url+='?id='+vRule.Id;
        }
    }
}