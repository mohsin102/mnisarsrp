trigger RevenueEstimateTrigger on revenueEstimate__c (After Insert, before update, before delete) {
	
	/*if(Trigger.isBefore && Trigger.isUpdate){
		srpFieldHistoryUtility.srpHistoryCreate(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap, 'revenueEstimate__c');
	}

	if(Trigger.isBefore && Trigger.isDelete){
		srpFieldHistoryUtility.srpHistoryDelete(Trigger.old, Trigger.oldMap, 'revenueEstimate__c');
	}*/

	if(Trigger.isAfter && Trigger.isInsert){
		RevenueEstimateTriggerHelper.updateOwnerEntity(Trigger.New);
	}
}