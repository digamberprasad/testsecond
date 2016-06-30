/**
* Helper class to send email to Horse Owner
* This class has method which can be called from HorseCommunicationHandler
* */
public class HorseCommunicationHelper {
	
	/**
	* Method which send email to Horse Owner
	* @param horseEmailRequests The list of HorseActionRequest
	* @return void
	* */
	public static void sendEmailToOwner(List<HorseCommunicationHandler.HorseActionRequest> horseEmailRequests){

		Set<Id> setHorseId = new Set<Id>();
		Set<Id> setOwnerId = new Set<Id>();
		Set<String> setEmailTemplateName = new Set<String>();
		Map<Id, set<Id>> mapHorseOwner = new Map<Id, set<Id>>();

		for(HorseCommunicationHandler.HorseActionRequest horseActionRequest : horseEmailRequests){
			setHorseId.add(horseActionRequest.horseId);
			setEmailTemplateName.add(horseActionRequest.emailTemplateName);
		}

		for(Horse_Owner__c horseOwner : [Select Id, Horse__c, Group__c, Owner__c, Status__c from Horse_Owner__c where Horse__c in: setHorseId and Status__c='Current']){
			if(horseOwner.Owner__c != null){
				
				setOwnerId.add(horseOwner.Owner__c);

				if(mapHorseOwner.containsKey(horseOwner.Horse__c)){
					Set<Id> tempSetOwnerId = mapHorseOwner.get(horseOwner.Horse__c);
					tempSetOwnerId.add(horseOwner.Owner__c);
					mapHorseOwner.put(horseOwner.Horse__c, tempSetOwnerId);
				}else{
					mapHorseOwner.put(horseOwner.Horse__c, new Set<Id> { horseOwner.Owner__c });
				}
			}
		}

		List<EmailTemplate> lstEmailTemplate = [SELECT DeveloperName, Id, IsActive, Name FROM EmailTemplate where Name in: setEmailTemplateName];
		List<Horse__c> lstHorse = [Select Id, Name, Horse_Registration_Number__c from Horse__c where Id in: setHorseId];

		for(Contact horseOwner : [Select Id, FirstName, Name, Email from Contact where Id in: setOwnerId]){

			System.debug('lstEmailTemplate[0].Id:-->' + lstEmailTemplate[0].Id);
			System.debug('horseOwner.Id:-->' + horseOwner.Id);
			System.debug('lstHorse[0].Id:-->' + lstHorse[0].Id);

			Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
			msg.setTemplateId(lstEmailTemplate[0].Id);
			//msg.setCcAddresses(new String[] {'digamber.prasad@makepositive.com'});
			msg.setTargetObjectId(horseOwner.Id);
			msg.setWhatId(lstHorse[0].Id);
			msg.setSaveAsActivity(false);
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { msg });
		}


		System.debug('Inside sendEmailToOwner...');
		System.debug('horseEmailRequests.horseId:-->' + horseEmailRequests[0].horseId);
		System.debug('horseEmailRequests.emailTemplateName:-->' + horseEmailRequests[0].emailTemplateName);
	}
}