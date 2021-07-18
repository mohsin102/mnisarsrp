trigger accountTrigger on Account (before update, before delete)  {
	//store history after update or delete

	if(Trigger.isBefore && Trigger.isUpdate){
		srpFieldHistoryUtility.srpHistoryCreate(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap, 'Account');
		for(Account a: Trigger.new){
			if(a.OwnerId != Trigger.oldMap.get(a.Id).ownerId){
				a.accountOwnerChangeDate__c = Date.valueOf(System.today());
			}
		}
	}

	if(Trigger.isBefore && Trigger.isDelete){
		srpFieldHistoryUtility.srpHistoryDelete(Trigger.old, Trigger.oldMap, 'Account');
	}

}