public with sharing class RegisterHorseController {

	private final Horse__c horse;

	public String errorMessage { get; set; }
	public String ticket { get; set; }
	public String cookieValue { get; set; }
	public Boolean isValidationError { get; set; }
	public Boolean isPotentialDuplicate { get; set; }
	public List<HorseWrapper> lstHorseWrapper { get; set; }
	public FEI_Credential__mdt feiCredential { get; set; }

	public HorseWS.HorseWSSoap horseWSSoap { get; set; }
	public HorseWS.HorseNew horseNew { get; set; }
	public HorseWS.addHorseResponse_element horseResponse { get; set; }
	public HorseWS.confirmAddHorseResponse_element confirmHorseResponse { get; set; }

	public RegisterHorseController(ApexPages.StandardController stdController) {
		this.horse = (Horse__c)stdController.getRecord();

		isValidationError = false;
		isPotentialDuplicate = false;

		feiCredential = BEHelper.getFEICredential();

		horseWSSoap = new HorseWS.HorseWSSoap();
		horseNew = new HorseWS.HorseNew();
		horseResponse = new HorseWS.addHorseResponse_element();
	}

	public PageReference addHorse(){
		horseWSSoap.inputHttpHeaders_x = new Map<String, String>();
		cookieValue = FEIAuthenticationWrapper.getFEIAuthenticationCookie();

		if(cookieValue != null){

			Contact con = [Select Id, Name, MailingAddress, MailingCity, MailingCountry, MailingPostalCode, MailingState, MailingStreet, Nationality__c 
							from Contact where Id =: horse.Primary_Owner__c];
			
			FEIAuthentication.AuthenticationSoap  authen = new FEIAuthentication.AuthenticationSoap();
			horseWSSoap.AuthHeader = new HorseWS.AuthHeader();
			horseWSSoap.AuthHeader.UserName = feiCredential.UserName__c;

			horseNew.BirthName = horse.Birth_Name__c;
			horseNew.CurrentName = horse.Name;
			horseNew.CompleteName = horse.Name;
			horseNew.IsCNSuffix = horse.Is_Commercial_Name_Suffix__c;
			
			if(horse.Issuing_NF_Code__c != null)
				horseNew.IssuingNFCode = horse.Issuing_NF_Code__c.subString(0, 3);
			
			if(horse.Sex__c == 'Gelding' || horse.Sex__c == 'Stallion')
				horseNew.GenderCode = 'M';
			else if(horse.Sex__c == 'Mare')
				horseNew.GenderCode = 'F';
			
			if(horse.Colour__c == 'Bay' || horse.Colour__c == 'Black' || horse.Colour__c == 'Chestnut' || horse.Colour__c == 'Grey')	
				horseNew.ColorCode = horse.Colour__c;
			else
				horseNew.ColorCode = 'Other';
			
			horseNew.DateBirth = horse.Date_of_Birth__c;
			horseNew.IsActive = horse.Is_Active__c;
			
			if(horse.Sex__c == 'Gelding')
				horseNew.CastratedId = 3;
			else
				horseNew.CastratedId = 2;

			horseNew.IsPony = horse.Is_Pony__c;
			horseNew.Height = Integer.valueOf(horse.Height_in_Centimetres__c);
			horseNew.Breed = horse.Breed__c;
			//horseNew.FEICode = 'FRA16747';
			horseNew.FEICodeType = 'R';
			horseNew.Microchip = horse.Microchip_Number__c;
			horseNew.NatPassport = horse.Passport_Number__c;
			horseNew.RecognitionCode = horse.Recognition_Code__c;
			horseNew.OwnerDateFrom = horse.Owner_Date_From__c;

			if(con != null){
				horseNew.OwnerAddress1 = con.MailingStreet;
				horseNew.OwnerAddress2 = '';
				horseNew.OwnerAddress3 = '';
				horseNew.OwnerCity = con.MailingCity;
				horseNew.OwnerCountryCode = con.MailingCountry;
				
				horseNew.OwnerName = con.Name;

				if(con.Nationality__c != null)
					horseNew.OwnerNationalityCode = con.Nationality__c.subString(0, 3);

				horseNew.OwnerZip = con.MailingPostalCode;
			}
				

			horseWSSoap.inputHttpHeaders_x.put('Cookie', cookieValue);
			
			try{
				horseResponse = horseWSSoap.addHorse(horseNew);
			}catch(Exception exc){

				isValidationError = true;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Mandatory field is missing!'));

				return null;
			}
			

			system.debug('horseResponse:-->' + horseResponse);
		}

		if(horseResponse != null){
			if(horseResponse.addHorseResult){
				
				horse.FEI_Registration_Number__c = horseResponse.Horse.FEICode;
				
				update horse;

				return new PageReference('/' + horse.Id);
			}else{
				if(horseResponse.PotentialHorseDuplicates != null){

					isPotentialDuplicate = true;
					ticket = horseResponse.Ticket;

					lstHorseWrapper = new List<HorseWrapper>();

					for(Integer i=0; i<horseResponse.PotentialHorseDuplicates.HorseDuplicate.size(); i++){
						lstHorseWrapper.add(new HorseWrapper(horseResponse.PotentialHorseDuplicates.HorseDuplicate[i]));
					}

					return null;
					
				}else if(horseResponse.Messages != null){
					errorMessage = '';
					for(Integer i=0; i<horseResponse.Messages.Message.size(); i++){
						errorMessage = errorMessage + horseResponse.Messages.Message[i].UID + '-' + horseResponse.Messages.Message[i].Detail + ' ';
					}
					
					isValidationError = true;

					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));

					return null;
				}
			}
		}
		return null;
	}

	public PageReference confirmAddHorse(){
		
		if(cookieValue != null){
			system.debug('ticket:-->' + ticket);
			
			FEIAuthentication.AuthenticationSoap  authen = new FEIAuthentication.AuthenticationSoap();
			horseWSSoap.AuthHeader = new HorseWS.AuthHeader();
			horseWSSoap.AuthHeader.UserName = feiCredential.UserName__c;
			
			horseWSSoap.inputHttpHeaders_x.put('Cookie', cookieValue);
			
			confirmHorseResponse = horseWSSoap.confirmAddHorse(ticket);
			system.debug('confirmHorseResponse:-->' + confirmHorseResponse);

			if(confirmHorseResponse.confirmAddHorseResult){
				horse.FEI_Registration_Number__c = confirmHorseResponse.Horse.FEICode;
				
				update horse;

				return new PageReference('/' + horse.Id);
			}

			return new PageReference('/' + horse.Id);

		}

		return new PageReference('/' + horse.Id);
	}

	public PageReference updateHorse(){

		
		String horseFEIID = Apexpages.currentPage().getParameters().get('horseFEIID');
		
		horse.FEI_Registration_Number__c = horseFEIID;
		
		update horse;

		return new PageReference('/' + horse.Id);
	}

	public PageReference backToHorse(){
		return new PageReference('/' + horse.Id);
	}

	public class HorseWrapper{
		
		public String ruleDescription { get; set; }
		public String horseFEIID { get; set; }
		public String birthName { get; set; }
		public Integer castratedId { get; set; }
		public String colorCode { get; set; }
		public String currentName { get; set; }
		public Date dateOfBirth { get; set; }
		
		public String feiCodeType { get; set; }
		public String genderCode { get; set; }
		public Boolean isActive { get; set; }
		public Boolean isPony { get; set; }
		public String issuingNFCode { get; set; }
		public String natPassport { get; set; }
		
		public Date ownerDateFrom { get; set; }
		public String ownerCity { get; set; }
		public String ownerCountryCode { get; set; }
		public String ownerName { get; set; }
		public String ownerNationalityCode { get; set; }
		public String ownerZip { get; set; }
		public Integer height { get; set; }

		public HorseWrapper(HorseWS.HorseDuplicate horseDuplicate){
			
			this.ruleDescription = horseDuplicate.RuleDescription;
			this.horseFEIID = horseDuplicate.Duplicate.FEICode;
			this.birthName = horseDuplicate.Duplicate.BirthName;
			this.castratedId = horseDuplicate.Duplicate.CastratedId;
			this.colorCode = horseDuplicate.Duplicate.ColorCode;
			this.currentName = horseDuplicate.Duplicate.CurrentName;
			this.dateOfBirth = Date.valueOf(horseDuplicate.Duplicate.DateBirth);

			this.feiCodeType = horseDuplicate.Duplicate.FeiCodeType;
			this.genderCode = horseDuplicate.Duplicate.GenderCode;
			this.isActive = horseDuplicate.Duplicate.IsActive;
			this.isPony = horseDuplicate.Duplicate.IsPony;
			this.issuingNFCode = horseDuplicate.Duplicate.IssuingNFCode;
			this.natPassport = horseDuplicate.Duplicate.NatPassport;
			/*
			this.ownerDateFrom = Date.valueOf(horseDuplicate.OwnerDateFrom);
			this.ownerCity = horseDuplicate.OwnerCity;
			this.ownerCountryCode = horseDuplicate.OwnerCountryCode;
			this.ownerName = horseDuplicate.OwnerName;
			this.ownerNationalityCode = horseDuplicate.OwnerNationalityCode;
			this.ownerZip = horseDuplicate.OwnerZip;
			*/
			this.height = horseDuplicate.Duplicate.Height;
			
		}
	}
}