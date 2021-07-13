trigger SubtractTrigger on Subtract__c (before update, before delete)  { 

	if(Trigger.isBefore && Trigger.isUpdate){
		srpFieldHistoryUtility.srpHistoryCreate(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap, 'Subtract__c');
	}

	if(Trigger.isBefore && Trigger.isDelete){
		srpFieldHistoryUtility.srpHistoryDelete(Trigger.old, Trigger.oldMap, 'Subtract__c');
	}

}