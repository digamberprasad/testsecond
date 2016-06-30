/**
 * Wrapper for the FEI related callouts
 * @author Puneet Sardana
 * */
global with sharing class FEIAuthenticationWrapper {
  
  /**
  * Login into FEI service and return authentication token which will be used to make subsequent calls.
  * @param none
  * @return String
  * */
  webservice static String getFEIAuthenticationCookie() {
    String token;
    try {

      FEI_Credential__mdt feiCredential = BEHelper.getFEICredential();
      
      FEIAuthentication.AuthenticationSoap  authen = new FEIAuthentication.AuthenticationSoap();
      authen.outputHttpHeaders_x = new Map<String, String>();
      FEIAuthentication.LoginResult loginRes = authen.Login(feiCredential.UserName__c, feiCredential.Password__c);
      
      if(loginRes != null && loginRes.ErrorCode.equals(BEConstants.FEI_ERRORCODE_NOERROR)) {
        //token = loginRes.CookieName;
        token = authen.outputHttpHeaders_x.get('Set-Cookie');
        token = token.substringBefore(';');
      }
      return token;

    } catch(Exception ex) {

    }
    return token;
  }
}