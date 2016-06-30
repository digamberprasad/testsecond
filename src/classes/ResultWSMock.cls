/**
* Class for setting mock responses for test classe of ResultWS class
* @Author : Nikhil Jaitly
* @Created Date : 26/06/2016
*/



@IsTest
  global class ResultWSMock implements WebServiceMock
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType)
        {
        	if(request instanceof ResultWS.ResultWSSoap)
                response.put('response_x', new ResultWS.getCompetitionsByEventCodeResponse_element());
            else if(request instanceof ResultWS.submitEventResultsResponse_element)   
            	 response.put('response_x', new ResultWS.submitEventResultsResponse_element());
            else if(request instanceof ResultWS.getCompetitionsResponse_element)   
            	 response.put('response_x', new ResultWS.getCompetitionsResponse_element());
            else if(request instanceof ResultWS.CheckCombinationEventingQualificationsResponse_element)   
            	 response.put('response_x', new ResultWS.CheckCombinationEventingQualificationsResponse_element());
            else if(request instanceof ResultWS.downloadEventResultsResponse_element)   
            	 response.put('response_x', new ResultWS.downloadEventResultsResponse_element());
			else if(request instanceof ResultWS.uploadEventResultsResponse_element)   
            	 response.put('response_x', new ResultWS.uploadEventResultsResponse_element());
			else if(request instanceof ResultWS.getNFResultsResponse_element)   
            	 response.put('response_x', new ResultWS.getNFResultsResponse_element());
			else if(request instanceof ResultWS.getCompetitionResponse_element)   
            	 response.put('response_x', new ResultWS.getCompetitionResponse_element());
			else if(request instanceof ResultWS.getCompetitionsByShowCodeResponse_element)   
            	 response.put('response_x', new ResultWS.getCompetitionsByShowCodeResponse_element());
			else if(request instanceof ResultWS.getCompetitionResultsResponse_element)   
            	 response.put('response_x', new ResultWS.getCompetitionResultsResponse_element());
			else if(request instanceof ResultWS.saveEventResultsResponse_element)   
            	 response.put('response_x', new ResultWS.saveEventResultsResponse_element());
			else if(request instanceof ResultWS.CheckHorseEventingQualificationsResponse_element)   
            	 response.put('response_x', new ResultWS.CheckHorseEventingQualificationsResponse_element());
			else if(request instanceof ResultWS.CheckAthleteEventingQualificationsResponse_element)   
            	 response.put('response_x', new ResultWS.CheckAthleteEventingQualificationsResponse_element());
			else if(request instanceof ResultWS.getEventResultsResponse_element)   
            	 response.put('response_x', new ResultWS.getEventResultsResponse_element());
        }
			 
            	 	 
	}