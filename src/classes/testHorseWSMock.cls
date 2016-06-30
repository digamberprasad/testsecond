@IsTest
private with sharing class testHorseWSMock
{
    private class HorseWSMock implements WebServiceMock
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType)
        {
            if(request instanceof HOrseWS.HorseWSSoap)
                response.put('response_x', new HorseWS.getHorsesResponse_element());
            return;
        }
    }
}