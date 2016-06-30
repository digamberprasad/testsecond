/**
 * Mock class for community Registration test class
 * @author : Puneet Sardana
 * @Created Date : 13/06/2016
 * */
global class BECommunityRegistrationMockImpl {
    global HTTPResponse respond(HTTPRequest req) {
       // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        BECommunityRegistration.CommunityRegistrationResponse resObj =
        new BECommunityRegistration.CommunityRegistrationResponse();
        resObj.isCreated = true;
        resObj.userId = UserInfo.getUserId();
        res.setBody(JSON.serialize(resObj));
        res.setStatusCode(200);
        return res;
    }
}