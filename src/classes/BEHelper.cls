/**
 * Handler for OpportunityTrigger
 * @author : Puneet Sardana
 * @Created Date : 03/05/2016
 * */
public with sharing class BEHelper {

  public static final String PRODUCTION_ORG_ID = '00D58000000IWk6';
  /**
   * Check if current org is production
   * @author : Puneet Sardana
   * @Created Date : 03/05/2016
   * */
  public static Boolean isProductionOrg() {
       return idsAreEqual(Userinfo.getOrganizationId(),PRODUCTION_ORG_ID);
   }
   /**
   * This method gets fei environment based on org - sandbox or production
   * @author : Puneet Sardana
   * @Created Date : 03/05/2016
   * */
   public static String getFeiEnvironment() {
    return isProductionOrg() ? BEConstants.FEI_ENV_PRODUCTION : BEConstants.FEI_ENV_TEST;
   }
   /**
   * Check if current org is Sandbox
   * @author : Puneet Sardana
   * @Created Date : 03/05/2016
   * */
  public static Boolean isSandboxOrg() {
       return !(idsAreEqual(Userinfo.getOrganizationId(),PRODUCTION_ORG_ID));
   }
   /**
   * Check if two if ids are equal
   * @author : Puneet Sardana
   * @Created Date : 03/05/2016
   * */
   public static Boolean idsAreEqual(String id1, String id2) {
     Boolean isEqual = false;
     if (id1 != null) {
       if (id2 != null) {
         if(id1.subString(0, 15).equals(id2.subString(0, 15)))
               {
                   return true;
               }
       }
     } else {
           if (id2 == null) {
               isEqual = true;
           }
     }
       return isEqual;
   }
  /**
   * Get record type by its Name
   * @author : Puneet Sardana
   * @Created Date : 03/05/2016
   * */
   public static String getRecordTypeId(SObjectType sObjectType, String recordTypeName) {
        //Generate a map of tokens for all the Record Types for the desired object
        Map<String,Schema.RecordTypeInfo> recordTypeInfo = sObjectType.getDescribe().getRecordTypeInfosByName();
        if(!recordTypeInfo.containsKey(recordTypeName))
            return null;
        //Retrieve the record type id by name
        return recordTypeInfo.get(recordTypeName).getRecordTypeId();
    }
    /**
     * Get  pick list values of field from an object
     * @author : Puneet Sardana
     * @Param : obj - Object
     * @Param : fld - Field Name
     * @Created Date : 16/05/2016
     * */
    public static List<SelectOption> getPicklistValues(SObjectType sObjectType, String fld){
      List<SelectOption> options = new list<SelectOption>();
      Schema.DescribeSObjectResult objDescribe = sObjectType.getDescribe();
      Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
      List<Schema.PicklistEntry> values = fieldMap.get(fld).getDescribe().getPickListValues();
      for (Schema.PicklistEntry a : values) {
        options.add(new SelectOption(a.getLabel(), a.getValue()));
      }
      return options;
    }

    /**
     * Get  pick list values of field from an object
     * @author : Puneet Sardana
     * @Param : obj - Object
     * @Param : fld - Field Name
     * @Created Date : 16/05/2016
     * */
    public static List<SelectOption> getPicklistValues(Schema.DescribeSObjectResult objResult, String fld){
      List<SelectOption> options = new list<SelectOption>();
      Map<String, Schema.SObjectField> fieldMap = objResult.fields.getMap();
      List<Schema.PicklistEntry> values = fieldMap.get(fld).getDescribe().getPickListValues();
      for (Schema.PicklistEntry a : values) {
        options.add(new SelectOption(a.getLabel(), a.getValue()));
      }
      return options;
    }

    /**
    * Method which returns the end-point for FEI authentication
    * @param void
    * @return string
    * */
    public static String getAuthenticationURL(){
      return [SELECT Endpoint__c FROM FEI_Settings__mdt WHERE Environment__c = :BEHelper.getFeiEnvironment()
              AND Service_Type__c = :BEConstants.FEI_SERVICETYPE_AUTHENTICATION LIMIT 1].Endpoint__c;
    }

    /**
    * Method which returns the end-point for FEI Person related callout
    * @param void
    * @return string
    * */
    public static String getPersonURL(){
      return [SELECT Endpoint__c FROM FEI_Settings__mdt WHERE Environment__c = :BEHelper.getFeiEnvironment()
              AND Service_Type__c = :BEConstants.FEI_SERVICETYPE_PERSON LIMIT 1].Endpoint__c;
    }

    /**
    * Method which returns the credential for FEI service based upon environment
    * @param void
    * @return FEI_Credential__mdt
    * */
    public static FEI_Credential__mdt getFEICredential(){
      return [SELECT UserName__c, Password__c FROM FEI_Credential__mdt WHERE Environment__c = :BEHelper.getFeiEnvironment() LIMIT 1];
    }
    /**
    * Method to send email as attachment
    * @param finalStr -
    * @return None
    * */
    public static void sendEmailWithCsv(String finalStr, String fileName,List<String> receipt,String subject,String body) {
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(finalStr);
        String csvname= fileName;
        csvAttc.setFileName(fileName);
        csvAttc.setBody(csvBlob);
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        email.setSubject(subject);
        email.setToAddresses( receipt );
        email.setUseSignature(false);
        email.setHtmlBody(body);
        if(String.isNotBlank(finalStr)) {
          email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        }
        if(!Test.isRunningTest()) {
          Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }
   }
}