trigger UnitTrigger on Unit__c (before update, before delete)  { 

	if(Trigger.isBefore && Trigger.isUpdate){
		srpFieldHistoryUtility.srpHistoryCreate(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap, 'Unit__c');
	}

	if(Trigger.isBefore && Trigger.isDelete){
		srpFieldHistoryUtility.srpHistoryDelete(Trigger.old, Trigger.oldMap, 'Unit__c');
	}


}