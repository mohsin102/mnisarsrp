public class srpFieldHistoryConversion  {

	private List<srpFieldHistory__c> conversionList {get; set;}
	private List<CronTrigger>currentSchedule {get; set;}
	private CronTrigger nextSchedule {get; set;}
	private Integer totalFieldHistoryCount {get; set;}
	private SRPFieldHistoryConversionSettings__c conversionSettings{get; set;}
	private String nextRunTime {get; set;}

	public srpFieldHistoryConversion(){
		this.conversionList = new List<srpFieldHistory__c>();
		//Kill existing schedule and calculate next run time
		conversionSettings = SRPFieldHistoryConversionSettings__c.getOrgDefaults();
		Integer addMinutes = Integer.valueOf(conversionSettings.minutesBetweenRuns__c);
		Integer conversionSize = Integer.valueOf(conversionSettings.conversionSize__c);
		string queryString = 'SELECT Count() FROM srpFieldHistory__c';
		totalFieldHistoryCount = Database.countQuery(queryString);
		System.debug('Total History Item Count is: ' + totalFieldHistoryCount);
		if(conversionSettings.cronTriggerId__c != null){
			currentSchedule = [SELECT ID FROM CronTrigger WHERE ID = :conversionSettings.cronTriggerId__c];
			if(currentSchedule.size()>0){
				System.abortJob(conversionSettings.cronTriggerId__c);
			}
		}
		if(totalFieldHistoryCount > conversionSettings.conversionSize__c){
			nextRunTime = '0 ' + String.valueOf(System.now().addMinutes(addMinutes).minute()) + ' ' + String.valueOf(System.now().addMinutes(addMinutes).hour() + ' ' + String.valueOf(System.now().addMinutes(addMinutes).day()) + ' ' + String.valueOf(System.now().addMinutes(addMinutes).month()) + ' ? ' + String.valueOf(System.now().addMinutes(addMinutes).year())  );
		}
		else{
			Integer daysToAdd = System.now().hour() < conversionSettings.defaultStartTime__c?0:1;
			nextRunTime = '0 00 ' + String.valueOf(Integer.valueOf(conversionSettings.defaultStartTime__c)) +' '+ String.valueOf(System.now().addDays(daysToAdd).day()) + ' ' + String.valueOf(System.now().addDays(daysToAdd).month()) + ' ? ' + String.valueOf(System.now().addDays(daysToAdd).year());
		}
		System.debug('nextRunTime value is: ' + nextRunTime);
			
			
		srpFieldHistoryConversionSchedule conversionHandler = new srpFieldHistoryConversionSchedule(); //Schedule apex class name
		conversionSettings.cronTriggerId__c = system.schedule('SRP Field History Conversion', nextRunTime, conversionHandler);
		update conversionSettings;
		//Do the work
		List<srpFieldHistory__c> initialList = [SELECT action__c,changedBy__c,conversionErrorCount__c,CreatedById,CreatedDate,fieldLabel__c,fieldName__c,Id,IsDeleted,isReference__c,
												       lastConversionErrorFields__c,lastConversionErrorMessage__c,lastConversionErrorStatus__c,LastModifiedById,LastModifiedDate,LastReferencedDate,
												       LastViewedDate,Name,newId__c,newValue__c,oldId__c,oldValue__c,OwnerId,recordId__c,recordName__c,referenceSObjectType__c,sObjectName__c 
												  FROM srpFieldHistory__c
												  ORDER BY CreatedDate DESC NULLS FIRST LIMIT :conversionSize];
		Boolean errorExists = false;
		for(srpFieldHistory__c fieldHistory: initialList){
			if(fieldHistory.conversionErrorCount__c < 5 || fieldHistory.conversionErrorCount__c == null){
				this.conversionList.add(fieldHistory);
			}
			else{
				errorExists = true;
			}
		}
		if(errorExists){
			Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
			message.toAddresses = conversionSettings.emailDistribution__c.split(';');
			message.optOutPolicy = 'FILTER';
			message.subject = 'Unable to Convert SRP Field History Record';
			message.plainTextBody = 'There is a record in srpFieldHistory__c that has failed conversion 5 times. \n Please use the following query to locate the error records:'+
									' \n\nSELECT action__c,changedBy__c,conversionErrorCount__c,CreatedById,CreatedDate,fieldLabel__c,fieldName__c,Id,IsDeleted,isReference__c,' +
									'lastConversionErrorFields__c,lastConversionErrorMessage__c,lastConversionErrorStatus__c,LastModifiedById,LastModifiedDate,LastReferencedDate,'+
									'LastViewedDate,Name,newId__c,newValue__c,oldId__c,oldValue__c,OwnerId,recordId__c,recordName__c,referenceSObjectType__c,sObjectName__c '+
									'FROM srpFieldHistory__c'+
									' WHERE conversionErrorCount__c != null'+
									' AND conversionErrorCount__c >= 5'+
									' ORDER BY CreatedDate DESC NULLS FIRST LIMIT 200';
			Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
			Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

			if (results[0].success) {
				System.debug('The email was sent successfully.');
			} else {
				System.debug('The email failed to send: ' + results[0].errors[0].message);
			}
		}
		boSRPFieldHistoryUtility.boSRPHistoryCreate(this.conversionList);

	}
}