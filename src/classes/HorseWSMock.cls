/**
* Class for setting mock responses for test classe of HorseWS class
* @Author : Nikhil Jaitly
* @Created Date : 24/06/2016
*/


@IsTest
  global class HorseWSMock implements WebServiceMock
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType)
        {
            if(request instanceof HOrseWS.HorseWSSoap)
                response.put('response_x', new HorseWS.getHorsesResponse_element());
            else if(request instanceof HorseWS.downloadHorseStickerResponse_element)   
            	 response.put('response_x', new HorseWS.downloadHorseStickerResponse_element());
            else if(request instanceof HorseWS.requestAdministrationChangeResponse_element)
            	 response.put('response_x', new HorseWS.requestAdministrationChangeResponse_element());
            else if(request instanceof HorseWS.searchForHorseAltResponse_element)
            	 response.put('response_x', new HorseWS.searchForHorseAltResponse_element());
            else if(request instanceof HorseWS.assignHorseOwnerResponse_element)
            	 response.put('response_x', new HorseWS.assignHorseOwnerResponse_element());	 
            else if(request instanceof HorseWS.upgradeHorseRecognitionCardResponse_element)
            	 response.put('response_x', new HorseWS.upgradeHorseRecognitionCardResponse_element());	 
            else if(request instanceof HorseWS.getHorseNameHistoryListResponse_element)
            	 response.put('response_x', new HorseWS.getHorseNameHistoryListResponse_element());	 
            else if(request instanceof HorseWS.updateHorseResponse_element)
            	 response.put('response_x', new HorseWS.updateHorseResponse_element());
            else if(request instanceof HorseWS.searchForHorseResponse_element)
            	 response.put('response_x', new HorseWS.searchForHorseResponse_element());
            else if(request instanceof HorseWS.registerHorseResponse_element)
            	 response.put('response_x', new HorseWS.registerHorseResponse_element());
            else if(request instanceof HorseWS.uploadHorseDocumentResponse_element)
            	 response.put('response_x', new HorseWS.uploadHorseDocumentResponse_element());
            else if(request instanceof HorseWS.ArrayOfAdminChangeStatusHorse)
            	 response.put('response_x', new HorseWS.ArrayOfAdminChangeStatusHorse());
            else if(request instanceof HorseWS.downloadHorseDiagramResponse_element)
            	 response.put('response_x', new HorseWS.downloadHorseDiagramResponse_element());
			else if(request instanceof HorseWS.getHorseOwnerResponse_element)
            	 response.put('response_x', new HorseWS.getHorseOwnerResponse_element()); 
            else if(request instanceof HorseWS.addTrainerToHorseResponse_element)
            	 response.put('response_x', new HorseWS.addTrainerToHorseResponse_element());
            else if(request instanceof HorseWS.ArrayOfStudBook)
            	 response.put('response_x', new HorseWS.ArrayOfStudBook());
            else if(request instanceof HorseWS.searchHorseTrainersResponse_element)
            	 response.put('response_x', new HorseWS.searchHorseTrainersResponse_element());
            else if(request instanceof HorseWS.getHorseResponse_element)
            	 response.put('response_x', new HorseWS.getHorseResponse_element());
            else if(request instanceof HorseWS.addHorseResponse_element)
            	 response.put('response_x', new HorseWS.addHorseResponse_element());
            else if(request instanceof HorseWS.getHorseRegistrationYearListResponse_element)
            	 response.put('response_x', new HorseWS.getHorseRegistrationYearListResponse_element());
            else if(request instanceof HorseWS.ArrayOfHorseColor)
            	 response.put('response_x', new HorseWS.ArrayOfHorseColor());
            else if(request instanceof HorseWS.confirmUpdateHorseResponse_element)
            	 response.put('response_x', new HorseWS.confirmUpdateHorseResponse_element());
             else if(request instanceof HorseWS.changeHorseNameResponse_element)
            	 response.put('response_x', new HorseWS.changeHorseNameResponse_element());
            else if(request instanceof HorseWS.confirmChangeHorseNameResponse_element)
            	 response.put('response_x', new HorseWS.confirmChangeHorseNameResponse_element());
           else if(request instanceof HorseWS.ArrayOfAdminChangeReasonHorse)
            	 response.put('response_x', new HorseWS.ArrayOfAdminChangeReasonHorse());
           else if(request instanceof HorseWS.upgradeHorsePassportResponse_element )
            	 response.put('response_x', new HorseWS.upgradeHorsePassportResponse_element ()); 
           else if(request instanceof HorseWS.getHorseCurrentNoviceQualificationResponse_element )
            	 response.put('response_x', new HorseWS.getHorseCurrentNoviceQualificationResponse_element ());  
      		else if(request instanceof HorseWS.deleteHorseNoviceQualificationResponse_element )
            	 response.put('response_x', new HorseWS.deleteHorseNoviceQualificationResponse_element ()); 
            else if(request instanceof HorseWS.confirmAddHorseResponse_element )
            	 response.put('response_x', new HorseWS.confirmAddHorseResponse_element ());
            else if(request instanceof HorseWS.addHorseNoviceQualificationResponse_element )
            	 response.put('response_x', new HorseWS.addHorseNoviceQualificationResponse_element());
            else if(request instanceof HorseWS.getHorseRegistrationListResponse_element )
            	 response.put('response_x', new HorseWS.getHorseRegistrationListResponse_element());
            else if(request instanceof HorseWS.uploadHorseDiagramResponse_element )
            	 response.put('response_x', new HorseWS.uploadHorseDiagramResponse_element());
            else if(request instanceof HorseWS.updateHorseNoviceQualificationResponse_element )
            	 response.put('response_x', new HorseWS.updateHorseNoviceQualificationResponse_element());
            
            
            return;
        }
   
}