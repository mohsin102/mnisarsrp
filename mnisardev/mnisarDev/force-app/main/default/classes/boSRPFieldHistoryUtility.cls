public class boSRPFieldHistoryUtility {
	
	public static void boSRPHistoryCreate(List<srpFieldHistory__c> newEntries){
		List<boSRPFieldHistory__b> newHistories = new List<boSRPFieldHistory__b>();
		for(srpFieldHistory__c newEntry: newEntries){
			boSRPFieldHistory__b newHistory = new boSRPFieldHistory__b();
			newHistory.action__c = newEntry.action__c;
			if(newEntry.fieldName__c == null){
				newHistory.fieldNameIndex__c = 'NA';
			}
			else{
				newHistory.fieldNameIndex__c = newEntry.fieldName__c.left(30);
			}
			newHistory.fieldName__c = newEntry.fieldName__c;
			newHistory.recordName__c = newEntry.recordName__c;
			newHistory.sObjectName__c = newEntry.sObjectName__c;
			newHistory.referenceSObjectType__c = newEntry.referenceSObjectType__c;
			newHistory.historyCreatedDate__c = newEntry.CreatedDate;
			if(newEntry.sObjectName__c == null){
				newHistory.sObjectNameIndex__c = 'UNKNOWN';
			}
			else{
				newHistory.sObjectNameIndex__c = newEntry.sObjectName__c.left(30);
			}
			newHistory.recordId__c = newEntry.recordId__c;
			newHistory.changedBy__c = newEntry.changedBy__c;
			newHistory.fieldLabel__c = newEntry.fieldLabel__c;
			newHistory.isReference__c = String.valueOf(newEntry.isReference__c);
			newHistory.oldId__c = newEntry.oldId__c;
			newHistory.oldValue__c = newEntry.oldValue__c;
			newHistory.newId__c = newEntry.newId__c;
			newHistory.newValue__c = newEntry.newValue__c;
			newHistories.add(newHistory);
		}

		boSRPFieldHistoryHandler handler = new boSRPFieldHistoryHandler(newHistories, newEntries, false);
		//if(!Test.isRunningTest()){
			System.enqueueJob(handler);
		//}

	}
	
}