//Created by John Gorrell December 2019
//Code coverage provided by projectPricingTest.cls


trigger ProjectAOITrigger on Project_AOI__c (before insert, before update, before delete, after insert, after update, after delete)  {

	if(Trigger.isBefore && (Trigger.isUpdate  || Trigger.isInsert || Trigger.isDelete)){ 
		projectAOITriggerHelper.setParentFlags(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
	}

	if(Trigger.isAfter && (Trigger.isUpdate  || Trigger.isInsert)){ 
		Id batchInstanceId = Database.executeBatch(new batchUpdateProjectAOITracts(Trigger.newMap.keySet(), null));
	}	

	//store history after update or delete

	if(Trigger.isBefore && Trigger.isUpdate){
		srpFieldHistoryUtility.srpHistoryCreate(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap, 'Project_AOI__c');
	}

	if(Trigger.isBefore && Trigger.isDelete){
		srpFieldHistoryUtility.srpHistoryDelete(Trigger.old, Trigger.oldMap, 'Project_AOI__c');
	}

}