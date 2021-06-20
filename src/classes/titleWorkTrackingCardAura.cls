public with sharing class titleWorkTrackingCardAura  {

	/*@AuraEnabled
	public static String completeTWT (TitleWorkTracker__c updateRecord){
		System.debug('completeTWT Method called with updateRecord Id: ' + updateRecord.Id);
		String response = 'SUCCESS';
		try{
			updateRecord.status__c = 'Complete';
			updateRecord.completionDate__c = system.today();
			update updateRecord;
		}
		Catch(Exception e){
			response = e.getMessage();
			system.debug('ERROR Marking Title Work Tracker Complete ' + e + '\n' + e.getMessage() + ' Line Number: ' + e.getLineNumber() + ' ' + e.getStackTraceString() + ' for record Id: ' + updateRecord.Id);
		}
		return response;
	}*/
	@AuraEnabled
	public static String updateTitleWorkComplete (sObject updateRecord, String objectType){
		System.debug('completeTWJ Method called with updateRecord Id: ' + updateRecord.Id);
		String response = 'SUCCESS';
		try{
				updateRecord.put('status__c' , 'Complete');
				updateRecord.put('completionDate__c' , system.today());
				update updateRecord;
		}
		Catch(Exception e){
			response = e.getMessage();
			system.debug('ERROR Marking Title Work Tracker Complete ' + e + '\n' + e.getMessage() + ' Line Number: ' + e.getLineNumber() + ' ' + e.getStackTraceString() + ' for record Id: ' + updateRecord.Id);
		}
		return response;
	}
	@AuraEnabled
	public static String startTitleWorkjob (sObject updateRecord, String objectType){
		System.debug('start TWJ Method called with updateRecord Id: ' + updateRecord.Id);
		String response = 'SUCCESS';
		//If updating a Title Work Job, if parent Title Work Tracker is Not Started, also start it.
		try{
			updateRecord.put('status__c' , 'In Progress');
			updateRecord.put('startDate__c' , system.today());
			update updateRecord;

		}
		Catch(Exception e){
			response = e.getMessage();
			system.debug('ERROR Marking Title Work Tracker Complete ' + e + '\n' + e.getMessage() + ' Line Number: ' + e.getLineNumber() + ' ' + e.getStackTraceString() + ' for record Id: ' + updateRecord.Id);
		}
		return response;
	}


}