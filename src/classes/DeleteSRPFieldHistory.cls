public class DeleteSRPFieldHistory  {

	private List<boSRPFieldHistory__b> deleteList {get; set;}
	private List<CronTrigger>currentSchedule {get; set;}
	private Boolean runAgain {get; set;}
	private SRPFieldHistoryConversionSettings__c conversionSettings{get; set;}
	private String nextRunTime {get; set;}

	public DeleteSRPFieldHistory(){
		this.deleteList = new List<boSRPFieldHistory__b>();
		this.runAgain = true;
		//Kill existing schedule and calculate next run time
		conversionSettings = SRPFieldHistoryConversionSettings__c.getOrgDefaults();
		Integer addMinutes = Integer.valueOf(conversionSettings.minutesBetweenRuns__c);
		Integer deleteSize = Integer.valueOf(conversionSettings.deleteSize__c);
		String sObjectNameIndex = conversionSettings.deleteSObjectNameIndex__c;
		this.deleteList.addAll([SELECT action__c,fieldNameIndex__c,historyCreatedDate__c,recordId__c,sObjectNameIndex__c FROM boSRPFieldHistory__b WHERE sObjectNameIndex__c = :sObjectNameIndex LIMIT :deleteSize]);
		if(this.deleteList.size() < deleteSize && !Test.isRunningTest()){
			this.runAgain = false;
		}
		Database.deleteImmediate(this.deleteList);

		if(conversionSettings.deleteCronTriggerId__c != null){
			currentSchedule = [SELECT ID FROM CronTrigger WHERE ID = :conversionSettings.deleteCronTriggerId__c];
			if(currentSchedule.size()>0){
				System.abortJob(conversionSettings.deleteCronTriggerId__c);
			}
		}
		
		
		

		if(runAgain){
			nextRunTime = '0 ' + String.valueOf(System.now().addMinutes(addMinutes).minute()) + ' ' + String.valueOf(System.now().addMinutes(addMinutes).hour() + ' ' + String.valueOf(System.now().addMinutes(addMinutes).day()) + ' ' + String.valueOf(System.now().addMinutes(addMinutes).month()) + ' ? ' + String.valueOf(System.now().addMinutes(addMinutes).year())  );
			srpFieldHistoryDeleteSchedule deleteHandler = new srpFieldHistoryDeleteSchedule(); //Schedule apex class name
			conversionSettings.deleteCronTriggerId__c = system.schedule('SRP Field History Delete', nextRunTime, deleteHandler);
			
		}
		else{
			conversionSettings.deleteCronTriggerId__c = '';
		}
		update conversionSettings;

	}
}