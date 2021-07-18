trigger AccountingTransactionTrigger on AccountingTransaction__c (before update)  { 
	if(Trigger.isBefore && Trigger.isUpdate){

	//test 
		AccountingTransactionTriggerHelper.handleReconciliationTypeUpdate(Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
	}


}