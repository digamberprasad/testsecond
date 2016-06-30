@IsTest
  global class EntrySystemWSMock implements WebServiceMock
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType)
        {
            if(request instanceof EntrySystemWS.EntrySystemWSSoap)
                response.put('response_x', new EntrySystemWS.getHorsesByIDResponse_element());
            else if(request instanceof EntrySystemWS.getCompetitorsHorsesResponse_element)   
                 response.put('response_x', new EntrySystemWS.getCompetitorsHorsesResponse_element());
            else if(request instanceof EntrySystemWS.getCompetitorHorsesResponse_element)   
                 response.put('response_x', new EntrySystemWS.getCompetitorHorsesResponse_element());
            else if(request instanceof EntrySystemWS.getCompetitorsByIDResponse_element)   
                 response.put('response_x', new EntrySystemWS.getCompetitorsByIDResponse_element());
            else if(request instanceof EntrySystemWS.getHorsesCompetitorsResponse_element)   
                 response.put('response_x', new EntrySystemWS.getHorsesCompetitorsResponse_element());
            else if(request instanceof EntrySystemWS.getHorseCompetitorsResponse_element)   
                 response.put('response_x', new EntrySystemWS.getHorseCompetitorsResponse_element());
                             
        }
    
}