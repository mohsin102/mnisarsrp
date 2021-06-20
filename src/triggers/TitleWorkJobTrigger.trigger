trigger TitleWorkJobTrigger on TitleWorkJob__c (after insert, before update)  { 
	if(Trigger.isAfter && Trigger.isInsert){
		TitleWorkJobTriggerHelper.updateTitleWorkTrackers(Trigger.newMap, null);
	}
	if(Trigger.isBefore && Trigger.isUpdate){
		TitleWorkJobTriggerHelper.updateTitleWorkTrackers(Trigger.newMap, Trigger.oldMap);
	}

}