/**
 * Constants for BE
 * @author : Puneet Sardana
 * @Created Date : 03/05/2016
 * */
public virtual class BEConstants {
      public static final Integer SF_QUERY_RESULT_LIMIT = 50000;

      public static final String CONTACT_TRIGGER = 'ContactTrigger';
      public static final String OPPORTUNITY_TRIGGER = 'OpportunityTrigger';
      public static final String ORDER_TRIGGER = 'OrderTrigger';
      public static final String HOUSEHOLD_SUFFIX = 'Household';
      ///////////////////////RECORD TYPE NAME/////////////////////////////////////////////////
      public static final String RT_ACCOUNT_HOUSEHOLD = 'Household';
      public static final String RT_CONTACT_MEMBER = 'Member';
      public static final String RT_CONTACT_GENERAL = 'General';
      public static final String RT_OPPORTUNITY_PRODUCT = 'Product';
      public static final String RT_OPPORTUNITY_SPONSOR = 'Sponsor';
      public static final String RT_PRODUCT_MEMBERSHIP = 'Membership';
      public static final String RT_ASSET_MEMBERSHIP = 'Membership';

      ///////////////////////////////////////////////////////////////////////////////////////////////////////////////

      ////////////////////////////////FEI Webservices///////////////////////////////////////////////////
      public static final String FEI_ENV_TEST = 'Test';
      public static final String FEI_ENV_PRODUCTION = 'Production';
      public static final String FEI_SERVICETYPE_AUTHENTICATION = 'AuthenticationService';
      public static final String FEI_SERVICETYPE_CALENDAR = 'CalendarWSService';
      public static final String FEI_SERVICETYPE_COMMON = 'CommonWSService';
      public static final String FEI_SERVICETYPE_HORSE = 'HorseWSService';
      public static final String FEI_SERVICETYPE_PERSON = 'PersonWSService';
      public static final String FEI_SERVICETYPE_RESULT = 'ResultWSService';
      public static final String FEI_SERVICETYPE_ENTRY = 'EntryService';
      public static final String FEI_ERRORCODE_NOERROR = 'NoError';
      //////////////////////////////////////////////////////////////////////////////////////////////////////////////

      ///////////////////////////////Customer Community////////////////////////////////////////////
      public static final String COMMUNITY_MEMBER_PROFILE = 'Customer Community Login User';
      public static final String COMMUNITY_ROLE = 'Community_User';
      public static final String TIMEZONESIDKEY_UK = 'Europe/London';
      public static final String LOCALESIDKEY_UK = 'en_GB';
      public static final String LANGUAGELOCALEKEY_UK = 'en_US';
      public static final String EMAILENCODINGKEY_UK = 'UTF-8';
      public static final String COMMUNITY_USERNAME_SUFFIX_DEV = '@britisheventing.com.dev';
      public static final String COMMUNITY_USERNAME_SUFFIX = '@britisheventing.com';
      //////////////////////////////////////////////////////////////////////////////////////////////////////////////
}