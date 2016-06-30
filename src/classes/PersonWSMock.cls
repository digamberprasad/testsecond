/**
* Class for setting mock responses for test class of PersonWS class
* @Author : Nikhil Jaitly
* @Created Date : 25/06/2016
*/



@IsTest
  global class PersonWSMock implements WebServiceMock
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType)
        {
        	if(request instanceof PersonWS.PersonWSSoap)
                response.put('response_x', new PersonWS.addPersonResponse_element());
            else if(request instanceof PersonWS.getPersonRegistrationListResponse_element)
                response.put('response_x', new PersonWS.getPersonRegistrationListResponse_element());
            else if(request instanceof PersonWS.requestAdministrationChangeResponse_element)
                response.put('response_x', new PersonWS.requestAdministrationChangeResponse_element());	
            else if(request instanceof PersonWS.confirmUpdatePersonResponse_element)
                response.put('response_x', new PersonWS.confirmUpdatePersonResponse_element());
            else if(request instanceof PersonWS.getPersonRegistrationYearListResponse_element)
                response.put('response_x', new PersonWS.getPersonRegistrationYearListResponse_element());
			else if(request instanceof PersonWS.getPersonLeaguesResponse_element)
                response.put('response_x', new PersonWS.getPersonLeaguesResponse_element());
			else if(request instanceof PersonWS.getPersonsResponse_element)
                response.put('response_x', new PersonWS.getPersonsResponse_element());
			else if(request instanceof PersonWS.searchForPersonAltResponse_element)
                response.put('response_x', new PersonWS.searchForPersonAltResponse_element());
			else if(request instanceof PersonWS.ArrayOfAdminChangeStatusPerson)
                response.put('response_x', new PersonWS.ArrayOfAdminChangeStatusPerson());
			else if(request instanceof PersonWS.updateAddressPersonResponse_element)
                response.put('response_x', new PersonWS.updateAddressPersonResponse_element());
			else if(request instanceof PersonWS.deletePersonNoviceQualificationResponse_element)
                response.put('response_x', new PersonWS.deletePersonNoviceQualificationResponse_element());
			else if(request instanceof PersonWS.addAddressPersonResponse_element)
                response.put('response_x', new PersonWS.addAddressPersonResponse_element());
			else if(request instanceof PersonWS.confirmAddPersonResponse_element)
                response.put('response_x', new PersonWS.confirmAddPersonResponse_element());
			else if(request instanceof PersonWS.addPersonNoviceQualificationResponse_element)
                response.put('response_x', new PersonWS.addPersonNoviceQualificationResponse_element());
			else if(request instanceof PersonWS.updatePersonResponse_element)
                response.put('response_x', new PersonWS.updatePersonResponse_element());
			else if(request instanceof PersonWS.registerTrainerResponse_element)
                response.put('response_x', new PersonWS.registerTrainerResponse_element());
		    else if(request instanceof PersonWS.ArrayOfAdminChangeReasonPerson)
                response.put('response_x', new PersonWS.ArrayOfAdminChangeReasonPerson());
            else if(request instanceof PersonWS.registerPersonResponse_element)
                response.put('response_x', new PersonWS.registerPersonResponse_element());
            else if(request instanceof PersonWS.setPersonLeagueResponse_element)
                response.put('response_x', new PersonWS.setPersonLeagueResponse_element());
            else if(request instanceof PersonWS.getPersonAddressListResponse_element)
                response.put('response_x', new PersonWS.getPersonAddressListResponse_element());
            else if(request instanceof PersonWS.updatePersonNoviceQualificationResponse_element)
                response.put('response_x', new PersonWS.updatePersonNoviceQualificationResponse_element());
            else if(request instanceof PersonWS.searchForPersonResponse_element)
                response.put('response_x', new PersonWS.searchForPersonResponse_element());
            else if(request instanceof PersonWS.getPersonResponse_element)
                response.put('response_x', new PersonWS.getPersonResponse_element());
            else if(request instanceof PersonWS.getPersonCurrentNoviceQualificationResponse_element)
                response.put('response_x', new PersonWS.getPersonCurrentNoviceQualificationResponse_element());
            
        }
    }