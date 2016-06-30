/**
* Controller to be used for Rider Registration
* @author Digamber Prasad
* */
public with sharing class RegisterRiderLightningController {
	
	/**
	* Login into FEI service and return authentication token which will be used to make subsequent calls.
	* @param String riderId
	* @return String response from the web services, possible response will be concated as string with || as seperator
	* */
	@AuraEnabled
	public static String registerRider(String riderId){
		
		List<PersonWrapper> lstPersonWrapper = new List<PersonWrapper>();
		PersonWS.PersonWSSoap personWSSoap = new PersonWS.PersonWSSoap();
		PersonWS.Person person = new PersonWS.Person();
		PersonWS.addPersonResponse_element personResponse = new PersonWS.addPersonResponse_element();
		FEI_Credential__mdt feiCredential = new FEI_Credential__mdt();

		String errorMessage = '';
		String ticket = '';
		String updatedRiderId = '';

		personWSSoap.inputHttpHeaders_x = new Map<String, String>();
		
		String cookieValue = FEIAuthenticationWrapper.getFEIAuthenticationCookie();
		
		Contact rider = [Select Id, Name, BirthDate, Gender__c, LastName, FirstName, Email, Nationality__c from Contact where Id=: riderId.subString(0, 18)];
		
		if(cookieValue != null){
			
			feiCredential = BEHelper.getFEICredential();
			
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
		}

		if(personResponse != null){
			if(personResponse.addPersonResult){
				
				rider.FEI_Membership_Number__c = personResponse.Person.PersonFEIID;
				rider.FEI_Qualification_Grade__c = personResponse.Person.GroupCodes;

				update rider;

				updatedRiderId = rider.Id;

			}else{
				if(personResponse.PotentialPersonDuplicates != null){

					ticket = personResponse.Ticket;

					lstPersonWrapper = new List<PersonWrapper>();

					for(Integer i=0; i<personResponse.PotentialPersonDuplicates.PersonDuplicate.size(); i++){
						lstPersonWrapper.add(new PersonWrapper(personResponse.PotentialPersonDuplicates.PersonDuplicate[i]));
					}
					
				}else if(personResponse.Messages != null){
					
					for(Integer i=0; i<personResponse.Messages.Message.size(); i++){
						errorMessage = errorMessage + personResponse.Messages.Message[i].UID + '-' + personResponse.Messages.Message[i].Detail + ' ';
					}
					
				}
			}
		}

		return (cookieValue + '||' + updatedRiderId + '||' + errorMessage + '||' + JSON.serialize(lstPersonWrapper) + '||' + ticket);
	}

	/**
	* Inner class to have duplicate person values
	* */
	public class PersonWrapper{
		
		@AuraEnabled
		public String ruleDescription { get; set; }
		@AuraEnabled
		public Integer personFEIID { get; set; }
		@AuraEnabled
		public String name { get; set; }
		@AuraEnabled
		public Date dateOfBirth { get; set; }
		@AuraEnabled
		public String groupCodes { get; set; }
		@AuraEnabled
		public String email { get; set; }

		/**
		* constructor
		* @param PersonWS.PersonDuplicate duplicate person record
		* */
		public PersonWrapper(PersonWS.PersonDuplicate personDuplicate){
			
			this.ruleDescription = personDuplicate.RuleDescription;
			this.personFEIID = personDuplicate.Duplicate.PersonFEIID;
			this.name = personDuplicate.Duplicate.FirstName + ' ' + personDuplicate.Duplicate.FamilyName;
			this.dateOfBirth = Date.valueOf(personDuplicate.Duplicate.DateOfBirth);
			this.groupCodes = personDuplicate.Duplicate.GroupCodes;
			this.email = personDuplicate.Duplicate.Email;
		}
	}
}