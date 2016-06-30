@isTest
private class EntrySystemWSTest {
	
	@isTest static void testCompetitorHorses() {
		new EntrySystemWS.CompetitorHorses();
	}
	
	@isTest static void testArrayOfPerson() {
		new EntrySystemWS.ArrayOfPerson();
	}

	@isTest static void testHorseEntryDataBE() {
		new EntrySystemWS.HorseEntryDataBE();
	}

	@isTest static void testgetCompetitorsHorsesResponse_element() {
		new EntrySystemWS.getCompetitorsHorsesResponse_element();
	}

	@isTest static void testMessage() {
		new EntrySystemWS.Message();
	}

	@isTest static void testArrayOfHorse() {
		new EntrySystemWS.ArrayOfHorse();
	}

	@isTest static void testgetHorsesCompetitors_element() {
		new EntrySystemWS.getHorsesCompetitors_element();
	}

	@isTest static void testArrayOfHorseEntrySystemData() {
		new EntrySystemWS.ArrayOfHorseEntrySystemData();
	}

	@isTest static void testgetCompetitorsHorses_element() {
		new EntrySystemWS.getCompetitorsHorses_element();
	}

	@isTest static void testCompetitorEntryDataBE() {
		new EntrySystemWS.CompetitorEntryDataBE();
	}

	@isTest static void testgetCompetitorHorses_element() {
		new EntrySystemWS.getCompetitorHorses_element();
	}

	@isTest static void testgetHorsesByIDResponse_element() {
		new EntrySystemWS.getHorsesByIDResponse_element();
	}

	@isTest static void testgetCompetitorHorsesResponse_element() {
		new EntrySystemWS.getCompetitorHorsesResponse_element();
	}

	@isTest static void testgetHorseCompetitorsResponse_element() {
		new EntrySystemWS.getHorseCompetitorsResponse_element();
	}

	@isTest static void testArrayOfHorseCompetitors() {
		new EntrySystemWS.ArrayOfHorseCompetitors();
	}

	@isTest static void testHorseCompetitors() {
		new EntrySystemWS.HorseCompetitors();
	}

	@isTest static void testgetCompetitorsByIDResponse_element() {
		new EntrySystemWS.getCompetitorsByIDResponse_element();
	}

	@isTest static void testHorse() {
		new EntrySystemWS.Horse();
	}

	@isTest static void testgetHorseCompetitors_element() {
		new EntrySystemWS.getHorseCompetitors_element();
	}

	@isTest static void testgetHorsesByID_element() {
		new EntrySystemWS.getHorsesByID_element();
	}

	@isTest static void testHorseEntrySystemData() {
		new EntrySystemWS.HorseEntrySystemData();
	}

	@isTest static void testArrayOfCompetitorEntrySystemData() {
		new EntrySystemWS.ArrayOfCompetitorEntrySystemData();
	}

	@isTest static void testgetHorsesCompetitorsResponse_element() {
		new EntrySystemWS.getHorsesCompetitorsResponse_element();
	}

	@isTest static void testArrayOfCompetitorHorses() {
		new EntrySystemWS.ArrayOfCompetitorHorses();
	}

	@isTest static void testAuthHeader() {
		new EntrySystemWS.AuthHeader();
	}

	@isTest static void testgetCompetitorsByID_element() {
		new EntrySystemWS.getCompetitorsByID_element();
	}

	@isTest static void testCompetitorEntrySystemData() {
		new EntrySystemWS.CompetitorEntrySystemData();
	}

	@isTest static void testArrayOfMessage() {
		new EntrySystemWS.ArrayOfMessage();
	}

	@isTest static void testArrayOfString() {
		new EntrySystemWS.ArrayOfString();
	}

	@isTest static void testArrayOfInt() {
		new EntrySystemWS.ArrayOfInt();
	}

	@isTest static void testHorseTrainer() {
		new EntrySystemWS.HorseTrainer();
	}

	@isTest static void testPerson() {
		new EntrySystemWS.Person();
	}

	@isTest static void testEntrySystemWSSoap() {


		Test.setMock(WebServiceMock.class, new EntrySystemWSMock());
		Test.startTest();	
		EntrySystemWS.EntrySystemWSSoap esp = new EntrySystemWS.EntrySystemWSSoap();

		esp.getHorsesByID(new EntrySystemWS.ArrayOfString(), '');
		esp.getCompetitorsHorses(new EntrySystemWS.ArrayOfInt());
		esp.getCompetitorHorses(56);
		esp.getCompetitorsByID(new EntrySystemWS.ArrayOfString(),'');
		esp.getHorsesCompetitors(new EntrySystemWS.ArrayOfString());
		esp.getHorseCompetitors('');

		Test.stopTest();

}

}