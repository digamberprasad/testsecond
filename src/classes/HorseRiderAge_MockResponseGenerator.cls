@isTest
global class HorseRiderAge_MockResponseGenerator implements HttpCalloutMock{
    
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals(URL.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/s/35.0', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        // Create a fake response
        HttpResponse res = new HttpResponse();
        String response = '<?xml version=\"1.0\" encoding=\"UTF-8\"?><soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns=\"http://soap.sforce.com/2006/08/apex\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\r\n        <soapenv:Header><DebuggingInfo><debugLog>35.0 APEX_CODE,FINEST;APEX_PROFILING,INFO;CALLOUT,INFO;DB,INFO;SYSTEM,DEBUG;VALIDATION,INFO;VISUALFORCE,INFO;WORKFLOW,FINER\r\nExecute Anonymous: Boolean BECR1=true;System.debug(LoggingLevel.Error,&apos;BERS&apos;+&apos;1&apos;+String.valueOf(BECR1));Boolean BECR2=false;System.debug(LoggingLevel.Error,&apos;BERS&apos;+&apos;2&apos;+String.valueOf(BECR2));\r\n13:55:03.4 (4531578)&#124;USER_INFO&#124;[EXTERNAL]&#124;0054E000000L2wR&#124;puneet.sardana@makepositive.com.be.dev&#124;Greenwich Mean Time&#124;GMT+01:00\r\n13:55:03.4 (5426075)&#124;USER_DEBUG&#124;[1]&#124;ERROR&#124;BERS1true\r\n13:55:03.4 (5489623)&#124;USER_DEBUG&#124;[1]&#124;ERROR&#124;BERS2false\r\n</debugLog></DebuggingInfo></soapenv:Header><soapenv:Body><executeAnonymousResponse><result><column>-1</column><compileProblem xsi:nil=\"true\"/><compiled>true</compiled><exceptionMessage xsi:nil=\"true\"/><exceptionStackTrace\r\n xsi:nil=\"true\"/><line>-1</line><success>true</success></result></executeAnonymousResponse></soapenv:Body></soapenv:Envelope>';
        res.setBody(response);
        res.setStatusCode(200);
        return res;
    }

}