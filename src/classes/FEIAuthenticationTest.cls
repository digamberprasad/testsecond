/**
* Test class of FEIAuthentication class
* @Author : Nikhil Jaitly
* @Created Date : 28/06/2016
*/


@isTest
private class FEIAuthenticationTest {
	
	@isTest static void testLoginResult() {
		new FEIAuthentication.LoginResult();
	}
	
	@isTest static void testLoginResponse_element() {
		new FEIAuthentication.LoginResponse_element();
	}


	@isTest static void testModeResponse_element() {
		new FEIAuthentication.ModeResponse_element();
	}
	

	@isTest static void testMode_element() {
		new FEIAuthentication.Mode_element();
	}
	

	@isTest static void testLogin_element() {
		new FEIAuthentication.Login_element();
	}
	
	
	@isTest static void testFEIAuthenticationWSSoap() {


		Test.setMock(WebServiceMock.class, new FEIAuthenticationWSMock());
		Test.startTest();	
		FEIAuthentication.AuthenticationSoap fsp = new FEIAuthentication.AuthenticationSoap();

		fsp.Login('','');
		fsp.Mode();
		Test.stopTest();
	
	
}

}