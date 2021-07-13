public class AccountingTransactionTriggerHelper  {

	public static void handleReconciliationTypeUpdate(List<AccountingTransaction__c> oldList, Map<Id,AccountingTransaction__c> oldMap, List<AccountingTransaction__c> newList, Map<Id, AccountingTransaction__c> newMap){
		for (AccountingTransaction__c at: newList) {
			//Check to see if reconciliation type has changed
			if(oldMap.get(at.Id).reconciliationType__c != newMap.get(at.Id).reconciliationType__c){
				//Check to see if update is from import or not
				if(newMap.get(at.Id).updateFromImport__c){
					//If import check to see if record is locked
					if(newMap.get(at.Id).reconciliationTypeLock__c){
						//If record is locked reset value back to previous
						newMap.get(at.Id).reconciliationType__c = oldMap.get(at.Id).reconciliationType__c;
					}
				}
				//If update is not from import lock the record for future updates.
				else{
					newMap.get(at.Id).reconciliationTypeLock__c = true;
				}	
			}
			//Set updateFromImport = false on the actual record.  This field should never get committed as true.
			newMap.get(at.Id).updateFromImport__c = false;
		}
	
	}
}