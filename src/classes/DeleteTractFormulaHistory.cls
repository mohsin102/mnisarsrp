public class DeleteTractFormulaHistory  {
	
	private List<boSRPFieldHistory__b> deleteList {get; set;}
	private List<CronTrigger>currentSchedule {get; set;}
	private Boolean runAgain {get; set;}
	private SRPFieldHistoryConversionSettings__c conversionSettings{get; set;}
	private String nextRunTime {get; set;}
	private List<Tract__c> targetedTracts {get; set;}
	private Id beginTractId {get; set;}
	private List<Id> tractIdList {get; set;}
	private List<String> formulaFieldNames {get; set;}

	public DeleteTractFormulaHistory(){
		
		
		this.deleteList = new List<boSRPFieldHistory__b>();
		this.formulaFieldNames = new List<String>();
		this.targetedTracts = new List<Tract__c>();
		this.currentSchedule = new List<CronTrigger>();
		this.tractIdList = new List<Id>();

		this.runAgain = true;
		try{
			//Kill existing schedule and calculate next run time
			conversionSettings = SRPFieldHistoryConversionSettings__c.getOrgDefaults();
			Integer addMinutes = Integer.valueOf(conversionSettings.minutesBetweenRuns__c);
			Integer deleteSize = Integer.valueOf(conversionSettings.deleteSize__c);
			String sObjectNameIndex = conversionSettings.deleteSObjectNameIndex__c;
			describerUtil describerUtility = new describerUtil();
			Integer relatedRecordCount = Integer.valueOf(conversionSettings.referenceIdGroupSize__c);
			describerUtility.selectedObject = conversionSettings.deleteSObjectNameIndex__c;
			Map<String, Schema.SObjectField> fieldMap = describerUtility.getFields();
			this.beginTractId = conversionSettings.beginDeleteId__c;
		
			for(String fieldName: fieldMap.keySet()){
				//System.debug('Field Name is: '+  fieldName + ' isCalculated value is: ' + fieldMap.get(fieldName).getDescribe().isCalculated());
				if(fieldMap.get(fieldName).getDescribe().isCalculated()){
					//System.debug('Field ' + fieldName + ' is a formula field');
					this.formulaFieldNames.add(fieldName);
				}
				else{
					//System.debug('Field ' + fieldName + ' is NOT a formula field');
				}
			}
			this.targetedTracts.addAll([SELECT Id FROM Tract__c WHERE Id >= :beginTractId ORDER BY Id LIMIT 51]);

			for(Integer i = 0; i < relatedRecordCount; i++){
				if(targetedTracts.size() > i){
					this.tractIdList.add(targetedTracts[i].Id);
				}
			}
			this.deleteList.addAll([SELECT action__c,fieldNameIndex__c,historyCreatedDate__c,recordId__c,sObjectNameIndex__c FROM boSRPFieldHistory__b WHERE sObjectNameIndex__c = :sObjectNameIndex AND recordId__c IN :tractIdList LIMIT :deleteSize]);
			System.debug('Initial deleteList size is: ' + deleteList.size());
			//System.debug('Targeted Tract size is: ' + this.targetedTracts.size());
			//If all records were checked and at end of list of tracts, don't run again.
			if(this.deleteList.size() < deleteSize && !Test.isRunningTest() && this.tractIdList.size() < relatedRecordCount){
				this.runAgain = false;
			}
			//If all history records for the current list were checked, increment the group size up to 50 and start the next run with the next tract record.
			else if(this.deleteList.size() < deleteSize && !Test.isRunningTest() && this.tractIdList.size() == relatedRecordCount){
				conversionSettings.beginDeleteId__c = targetedTracts[relatedRecordCount].Id;	
				conversionSettings.referenceIdGroupSize__c = conversionSettings.referenceIdGroupSize__c + 1;
				if(conversionSettings.referenceIdGroupSize__c >= 50){
					conversionSettings.referenceIdGroupSize__c = 50;
				}
			}
			//If delete list and maximum size are equal - special handling
			else if(this.deleteList.size() == deleteSize && !Test.isRunningTest()){
				
				//If the current size is already 1, not able to check all records.  Leave the setting at 1 and check the next record.
				if (conversionSettings.referenceIdGroupSize__c <= 1){
					conversionSettings.referenceIdGroupSize__c = 1;
					System.debug('next target is: ' + targetedTracts[tractIdList.size()].Id + ' tractIdList size is: ' + tractIdList.size());
					conversionSettings.beginDeleteid__c = targetedTracts[tractIdList.size()].Id;
				}
				//If the current size is larger than one, decrement the group size and start with the same record. 
				else{
					conversionSettings.referenceIdGroupSize__c = conversionSettings.referenceIdGroupSize__c - 1;
					//conversionSettings.beginDeleteid__c = targetedTracts[tractIdList.size()-1].Id;
				}
			}
			for(Integer i = 0; i < this.deleteList.size(); ){
			//for(boSRPFieldHistory__b currentHistory: deleteList){
				//System.debug('current value of i is: ' + i + ' fieldNameIndex__c value is: ' + this.deleteList[i].fieldNameIndex__c + ' formulaFieldNames not contains field value is: ' + !this.formulaFieldNames.contains(this.deleteList[i].fieldNameIndex__c));
				if(!this.formulaFieldNames.contains(this.deleteList[i].fieldNameIndex__c)){
					this.deleteList.remove(i);
				}
				else{
					i++;
				}
			}
			System.debug('Final deletelist size is: ' + this.deleteList.size());
			Database.deleteImmediate(this.deleteList);
			update conversionSettings;
			if(conversionSettings.deleteCronTriggerId__c != null){
				currentSchedule = [SELECT ID FROM CronTrigger WHERE ID = :conversionSettings.deleteCronTriggerId__c];
				if(currentSchedule.size()>0){
					System.abortJob(conversionSettings.deleteCronTriggerId__c);
				}
			}
		
		
		

			if(runAgain){
				nextRunTime = '0 ' + String.valueOf(System.now().addMinutes(addMinutes).minute()) + ' ' + String.valueOf(System.now().addMinutes(addMinutes).hour() + ' ' + String.valueOf(System.now().addMinutes(addMinutes).day()) + ' ' + String.valueOf(System.now().addMinutes(addMinutes).month()) + ' ? ' + String.valueOf(System.now().addMinutes(addMinutes).year())  );
				DeleteTractFormulaHistorySchedule deleteHandler = new DeleteTractFormulaHistorySchedule(); //Schedule apex class name
				conversionSettings.deleteCronTriggerId__c = system.schedule('SRP Tract Formula Field History Delete', nextRunTime, deleteHandler);
				System.debug('SRP Tract Formula Field History Delete Scheduled Job Id is: ' + conversionSettings.deleteCronTriggerId__c);
			
			}
			else{
				conversionSettings.deleteCronTriggerId__c = '';
			}
			update conversionSettings;
		}

		catch (Exception e) {
            Log__c log = new Log__c();                                                    
            log.Process__c = 'Delete Tract Formula History';
            log.Status__c = 'Error';
            log.Error_Message__c = e.getMessage();
            log.Stack_Trace__c = e.getStackTraceString();
            upsert log;
            System.debug('Exception: ' + e.getTypeName() + ', ' + e.getMessage());
            
        }

	}
}