/**
* Engine to send email to Horse Owner
* This class has method which can be called from Process flow, trigger and helper method to send email to Horse Owner
* */
global class HorseCommunicationHandler {
	
	/**
	* Method use for seding email from ProcessBuilder, it can be invoked from apex as well
	* @param taskRequests The list of TaskActionRequest having values for Interaction record
	* @return void
	* */
	@InvocableMethod(label='Send Email to Horse Owner' description='This method is responsible for sending email to Horse Owner')
	public static void sendEmail(List<HorseActionRequest> horseEmailRequests) {
		HorseCommunicationHelper.sendEmailToOwner(horseEmailRequests);
	}

	/**
	* inner class to have field values to be used for sending email to horse owner
	* */
	global class HorseActionRequest {
		@InvocableVariable public Id horseId;
		@InvocableVariable public String emailTemplateName;
	}

}