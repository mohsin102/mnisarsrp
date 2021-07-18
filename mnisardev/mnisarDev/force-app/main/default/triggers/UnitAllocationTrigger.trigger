trigger UnitAllocationTrigger on unitAllocation__c (after insert, before update, before delete) {
	
	if(Trigger.isBefore && Trigger.isUpdate){
		srpFieldHistoryUtility.srpHistoryCreate(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap, 'unitAllocation__c');
	}

	if(Trigger.isBefore && Trigger.isDelete){
		srpFieldHistoryUtility.srpHistoryDelete(Trigger.old, Trigger.oldMap, 'unitAllocation__c');
	}

    if(Trigger.isAfter && Trigger.isInsert ){
        UnitAllocationTriggerHelper.createOwnerInterestRevenue(Trigger.New);
    }
    
}