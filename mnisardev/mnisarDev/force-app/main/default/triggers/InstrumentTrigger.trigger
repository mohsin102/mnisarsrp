trigger InstrumentTrigger on Instrument__c (before delete, before update) {

    
	if (Trigger.isBefore && Trigger.isUpdate) {
		srpFieldHistoryUtility.srpHistoryCreate(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap, 'Instrument__c');
	}
	else if (Trigger.isBefore && Trigger.isDelete) {
		Boolean preventDelete = InstrumentTriggerHelper.preventDelete(Trigger.oldMap);	
		if(!preventDelete){
			srpFieldHistoryUtility.srpHistoryDelete(Trigger.old, Trigger.oldMap, 'Instrument__c');
		}
    }
}