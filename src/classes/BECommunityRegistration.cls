/**
* Rest API to register community user
* @Author : Puneet Sardana
* @ Created Date : 10-06-2016
*
*/
@RestResource(urlMapping='/BECommunityRegistration/*')
global class BECommunityRegistration {
    private static final String FIRSTNAME_BLANKERROR = Label.FirstNameBlankError;
    private static final String LASTNAME_BLANKERROR = Label.LastNameBlankError;
    private static final String EMAIL_BLANKERROR = Label.EmailBlankError;
    private static final String USER_EXISTS_ERROR = Label.UserAlreadyExistsError;
    private static final String DOB_BLANKERROR = Label.DobBlankError;
    /**
    * This method is used to create community user
    * @Author : Puneet Sardana
    * @ Created Date : 10-06-2016
    */
    @HttpPost
    global static CommunityRegistrationResponse registerCommunityUser() {
        CommunityRegistrationResponse response = new CommunityRegistrationResponse();
        RestRequest req = RestContext.request;
        System.debug('Puneet request '+req);
        CommunityRegistrationRequest crr = (CommunityRegistrationRequest) JSON.deserialize(req.requestBody.toString(), CommunityRegistrationRequest.class);
        if(String.isBlank(crr.first_name)) {
            response.errors.add(FIRSTNAME_BLANKERROR);
        }
        if(String.isBlank(crr.last_name)) {
            response.errors.add(LASTNAME_BLANKERROR);
        }
        if(String.isBlank(crr.email)) {
            response.errors.add(EMAIL_BLANKERROR);
        }
        if(String.isBlank(crr.dob)) {
            response.errors.add(DOB_BLANKERROR);
        }
        Contact existingContact;
        User existingUser;
        Savepoint sp = Database.setSavepoint();

        try {
            if(response.errors.size() == 0) {
                    for(Contact ct : [SELECT Id,AccountId,FirstName,LastName,BE_Membership_Number__c
                                              FROM Contact
                                              WHERE Email = :crr.email
                                              LIMIT 1]) {
                        existingContact = ct;
                    }
                  // check if contact exists
                    if(existingContact == null) {
                        existingContact = getNewContact(crr);
                        insert existingContact;
                        existingContact = [SELECT Id,AccountId,FirstName,LastName,BE_Membership_Number__c
                                                     FROM Contact
                                                     WHERE Id = :existingContact.Id
                                                     LIMIT 1];
                    } else {
                            for(User ur : [SELECT Id
                                                 FROM User
                                                 WHERE ContactId = :existingContact.Id
                                                 LIMIT 1]) {
                                existingUser = ur;
                            }
                        }
                        if(existingUser != null) {
                            response.errors.add(USER_EXISTS_ERROR);
                            response.userId = existingUser.Id;
                            response.membership_no = existingContact.BE_Membership_Number__c;
                        } else {
                                User usr = new User();
                                //To be filled
                                String profileId,userRoleId;
                                for(Profile pf : [ SELECT Id
                                                         FROM Profile
                                                         WHERE Name = :BEConstants.COMMUNITY_MEMBER_PROFILE
                                                         LIMIT 1]) {
                                    profileId = pf.Id;
                                }
                                for(UserRole ur : [SELECT Id
                                                               FROM UserRole
                                                               WHERE DeveloperName = :BEConstants.COMMUNITY_ROLE]) {
                                    userRoleId = ur.Id;
                                }
                                String accountId = existingContact.AccountId ; // To be filled in by customer.
                                usr.UserName = existingContact.BE_Membership_Number__c +
                                                            (BEHelper.isProductionOrg() ? BEConstants.COMMUNITY_USERNAME_SUFFIX
                                                             : BEConstants.COMMUNITY_USERNAME_SUFFIX_DEV);
                                usr.FirstName = crr.first_name;
                                usr.LastName = crr.last_name;
                                usr.FederationIdentifier = existingContact.BE_Membership_Number__c;
                                usr.Alias = String.isNotBlank(crr.alias) ? crr.alias : (crr.first_name.substring(0,4) + crr.last_name.substring(0,4) );
                                usr.LocaleSidKey = BEConstants.LOCALESIDKEY_UK;
                                usr.TimeZoneSidKey=BEConstants.TIMEZONESIDKEY_UK;
                                usr.Email = crr.email;
                                usr.ContactId = existingContact.Id;
                                String fullName = crr.first_name + crr.last_name;
                                Integer len = 10;
                                Blob blobKey = crypto.generateAesKey(128);
                                String key = EncodingUtil.convertToHex(blobKey);
                                String pwd = key.substring(0,len);
                                fullName +=  pwd;
                                usr.CommunityNickname = String.isNotBlank(crr.forum_nickname) && crr.forum_nickname.trim().length() > 0
                                ? crr.forum_nickname : fullName.length() > 40 ? fullName.substring(0,40) : fullName;
                                usr.ProfileId = profileId;
                                usr.IsActive = true;
                                usr.EmailEncodingKey = BEConstants.EMAILENCODINGKEY_UK;
                                usr.LanguageLocaleKey = BEConstants.LANGUAGELOCALEKEY_UK;
                              //  String userId = Site.createExternalUser(usr, existingContact.AccountId, 'puneet@makepositive.com');
                                System.debug('Puneet user '+usr);
                                insert usr;
                                response.isCreated = usr.Id != null && response.errors.size() == 0;
                                response.userId = usr.Id;
                                response.membership_no = existingContact.BE_Membership_Number__c;
                    }
                }
            }
            catch(Exception ex) {
                System.debug('Puneet registration '+ex);
                System.debug('Puneet stacktrace '+ex.getStackTraceString());
                response.errors.add(ex.getMessage());
                Database.rollback(sp);
            }
        return response;
    }

    private static Contact getNewContact(CommunityRegistrationRequest crr) {
        Contact con = new Contact();
        con.RecordTypeId = BEHelper.getRecordTypeId(Contact.sObjectType,
                                                                                        BEConstants.RT_CONTACT_MEMBER);
        con.FirstName = crr.first_name;
        con.LastName = crr.last_name;
        con.Email = crr.email;
        con.Birthdate = Date.valueOf(crr.dob);
        return con;
    }

    /**
    * Request for community registration
    * @Author : Puneet Sardana
    * @ Created Date : 13-06-2016
    *
    */
    global class CommunityRegistrationRequest {
        public String membership_type;
        public String first_name;
        public String last_name;
        public String postcode;
        public String nickname;
        public String address_1;
        public String address_2;
        public String address_3;
        public String town;
        public String country;
        public String phone;
        public String mobile;
        public String email;
        public String forum_nickname;
        public String alias;
        public String dob;
    }
    /**
    * Response for community registration
    * @Author : Puneet Sardana
    * @ Created Date : 10-06-2016
    *
    */
    global class CommunityRegistrationResponse {
        public Boolean isCreated;
        public List<String> errors;
        public String userId;
        public String membership_no;

        public CommunityRegistrationResponse() {
            isCreated = false;
            errors = new List<String>();
        }
    }
}