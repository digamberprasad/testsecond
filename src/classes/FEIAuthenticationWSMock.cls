/**
* Setting Mock responses for Test Class of FEIAuthentication class
* @Author : Nikhil Jaitly
* @Created Date : 28/06/2016
*/


@IsTest
  global class FEIAuthenticationWSMock implements WebServiceMock
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType)
        {
			
        	if(request instanceof FEIAuthentication.Login_element)
                response.put('response_x', new FEIAuthentication.LoginResponse_element());
            else if(request instanceof FEIAuthentication.Mode_element)
                response.put('response_x', new FEIAuthentication.ModeResponse_element());


		}
	
}