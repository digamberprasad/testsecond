/**
* Test class for BE community registration
* @Author : Puneet Sardana
* @ Created Date : 13-06-2016
*
*/
@isTest
public  class BECommunityRegistrationTest {
    // Create auto account when Contact is member and no account is associated
    @isTest
    public static void testCreateAccountAndLink() {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new BECommunityRegistrationMockImpl());
            //HttpResponse res = CalloutClass.getInfoFromExternalService();
        Test.stopTest();
    }

    private static BECommunityRegistration.CommunityRegistrationRequest getRequest() {
        BECommunityRegistration.CommunityRegistrationRequest req =
            new BECommunityRegistration.CommunityRegistrationRequest();
        req.firstName = 'Puneet';
        req.lastName = 'Sardana';
        req.email = 'puneet.sardanatest@makepositive.com';
        req.nickname = 'puneets';
        req.username = 'psardana@makepositive.com';
        return req;
    }


}