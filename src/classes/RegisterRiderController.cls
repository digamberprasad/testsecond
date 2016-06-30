public with sharing class RegisterRiderController {

	private final Contact rider;
	public String errorMessage { get; set; }
	public String ticket { get; set; }
	public String cookieValue { get; set; }
	public Boolean isValidationError { get; set; }
	public Boolean isPotentialDuplicate { get; set; }
	public List<PersonWrapper> lstPersonWrapper { get; set; }
	public FEI_Credential__mdt feiCredential { get; set; }

	public PersonWS.PersonWSSoap personWSSoap { get; set; }
	public PersonWS.Person person { get; set; }
	public PersonWS.addPersonResponse_element personResponse { get; set; }
	public PersonWS.confirmAddPersonResponse_element confirmPersonResponse { get; set; }
	
	public RegisterRiderController(ApexPages.StandardController stdController){
		this.rider = (Contact)stdController.getRecord();

		isValidationError = false;
		isPotentialDuplicate = false;

		feiCredential = BEHelper.getFEICredential();

		personWSSoap = new PersonWS.PersonWSSoap();
		person = new PersonWS.Person();
		personResponse = new PersonWS.addPersonResponse_element();
	}

	public PageReference addPerson(){
		
		personWSSoap.inputHttpHeaders_x = new Map<String, String>();
		cookieValue = FEIAuthenticationWrapper.getFEIAuthenticationCookie();

		if(cookieValue != null){
			
			FEIAuthentication.AuthenticationSoap  authen = new FEIAuthentication.AuthenticationSoap();
			personWSSoap.AuthHeader = new PersonWS.AuthHeader();
			personWSSoap.AuthHeader.UserName = feiCredential.UserName__c;

			
			person.DateOfBirth = rider.BirthDate;
			person.IsActive = true;
			
			if(rider.Gender__c == 'Male')
				person.GenderCode = 'M';
			else if(rider.Gender__c == 'Female')
				person.GenderCode = 'F';

			person.FamilyName = rider.LastName;
			person.FirstName = rider.FirstName;
			
			if(rider.Nationality__c != null)
				person.NationalityCode = rider.Nationality__c.subString(0, 3);

			if(rider.Email != null){
				person.Email = rider.Email;
				person.NoEmailConfirmation = false;
			}else{
				person.NoEmailConfirmation = true;
			}

			personWSSoap.inputHttpHeaders_x.put('Cookie', cookieValue);
			
			personResponse = personWSSoap.addPerson(person);

			system.debug('personResponse:-->' + personResponse);
		}

		if(personResponse != null){
			if(personResponse.addPersonResult){
				
				rider.FEI_Membership_Number__c = personResponse.Person.PersonFEIID;
				rider.FEI_Qualification_Grade__c = personResponse.Person.GroupCodes;
				rider.Date_Registered__c = System.today();
				rider.FEI_Registered_for_Current_Season__c = true;

				update rider;

				return new PageReference('/' + rider.Id);
			}else{
				if(personResponse.PotentialPersonDuplicates != null){

					isPotentialDuplicate = true;
					ticket = personResponse.Ticket;

					lstPersonWrapper = new List<PersonWrapper>();

					for(Integer i=0; i<personResponse.PotentialPersonDuplicates.PersonDuplicate.size(); i++){
						lstPersonWrapper.add(new PersonWrapper(personResponse.PotentialPersonDuplicates.PersonDuplicate[i], false));
					}

					return null;
					
				}else if(personResponse.Messages != null){
					errorMessage = '';
					for(Integer i=0; i<personResponse.Messages.Message.size(); i++){
						errorMessage = errorMessage + personResponse.Messages.Message[i].UID + '-' + personResponse.Messages.Message[i].Detail + ' ';
					}
					
					isValidationError = true;

					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));

					return null;
				}
			}
		}
		return null;
	}

	public PageReference confirmAddPerson(){
		
		if(cookieValue != null){
			
			FEIAuthentication.AuthenticationSoap  authen = new FEIAuthentication.AuthenticationSoap();
			personWSSoap.AuthHeader = new PersonWS.AuthHeader();
			personWSSoap.AuthHeader.UserName = feiCredential.UserName__c;
			
			personWSSoap.inputHttpHeaders_x.put('Cookie', cookieValue);
			
			confirmPersonResponse = personWSSoap.confirmAddPerson(ticket);

			if(confirmPersonResponse.confirmAddPersonResult){
				rider.FEI_Membership_Number__c = confirmPersonResponse.Person.PersonFEIID;
				rider.FEI_Qualification_Grade__c = confirmPersonResponse.Person.GroupCodes;
				rider.Date_Registered__c = System.today();
				rider.FEI_Registered_for_Current_Season__c = true;

				update rider;

				return new PageReference('/' + rider.Id);
			}

			return new PageReference('/' + rider.Id);

		}

		return new PageReference('/' + rider.Id);
	}

	public PageReference updateRider(){

		system.debug('personFEIID:-->' + Apexpages.currentPage().getParameters().get('personFEIID'));
		Integer personFEIID = Integer.valueOf(Apexpages.currentPage().getParameters().get('personFEIID'));
		String groupCodes = Apexpages.currentPage().getParameters().get('groupCodes');

		rider.FEI_Membership_Number__c = personFEIID;
		rider.FEI_Qualification_Grade__c = groupCodes;
		rider.Date_Registered__c = System.today();
		rider.FEI_Registered_for_Current_Season__c = true;

		update rider;

		return new PageReference('/' + rider.Id);
	}

	public PageReference backToRider(){
		return new PageReference('/' + rider.Id);
	}

	public class PersonWrapper{
		
		public Boolean isSelected { get; set; }
		public String ruleDescription { get; set; }
		public Integer personFEIID { get; set; }
		public String name { get; set; }
		public Date dateOfBirth { get; set; }
		public String groupCodes { get; set; }
		public String email { get; set; }

		public PersonWrapper(PersonWS.PersonDuplicate personDuplicate, Boolean isSelected){
			
			this.isSelected = isSelected;
			
			this.ruleDescription = personDuplicate.RuleDescription;
			this.personFEIID = personDuplicate.Duplicate.PersonFEIID;
			this.name = personDuplicate.Duplicate.FirstName + ' ' + personDuplicate.Duplicate.FamilyName;
			this.dateOfBirth = Date.valueOf(personDuplicate.Duplicate.DateOfBirth);
			this.groupCodes = personDuplicate.Duplicate.GroupCodes;
			this.email = personDuplicate.Duplicate.Email;
		}
	}
}