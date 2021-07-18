//Created by John Gorrell December 2019
//Code coverage provided by projectPricingTest.cls

public class srpFieldHistoryUtility  {
	
	List<String> whitelist = new List<String>();
	List<String> blacklist = new List<String>();
	Boolean excludeFormulaFields = false;


	public static void srpHistoryCreate(List<SObject> triggerNew, List<SObject> triggerOld, Map<Id, SObject> newMap, Map<Id, SObject> oldMap, String sObjectTypeName){
		List<srpFieldHistory__c> newHistory = new List<srpFieldHistory__c>();
		describerUtil describerUtility = new describerUtil();
		describerUtility.selectedObject = sObjectTypeName;
		Map<String, Schema.SObjectField> fieldMap = describerUtility.getFields();
		Map<String, Set<Id>> lookupMap = new Map<String, Set<Id>>();
		Map<Id, String> lookupNames = new Map<Id, String>();
		List<SRPFieldHistorySetting__mdt> fieldSettings = [SELECT blacklist__c, excludeFormulaFields__c, objectAPIName__c, whitelist__c FROM SRPFieldHistorySetting__mdt WHERE objectAPIName__c = :sObjectTypeName LIMIT 1];
		List<String> whitelist = new List<String>();
		List<String> blacklist = new List<String>();
		Boolean excludeFormulaFields = false;

		if(fieldSettings.size() > 0){
			System.debug('Setting field settings');
			if(fieldSettings[0].whitelist__c != null){
				whitelist = fieldSettings[0].whitelist__c.split('\\|');
			}
			if(fieldSettings[0].blacklist__c != null){
				blacklist = fieldSettings[0].blacklist__c.split('\\|');
			}
			excludeFormulaFields = fieldSettings[0].excludeFormulaFields__c;
			System.debug('Whitelist size is: ' + whitelist.size() + ' blacklist size is: ' + blacklist.size() + ' excludeFormulaFields value is: ' + excludeFormulaFields);
		}

		for(Id updateId: newMap.keySet()){
			for(String fieldName: fieldMap.keySet()){
				if(checkFieldHistory(whitelist, blacklist, excludeFormulaFields, fieldMap.get(fieldName))) {
					System.debug('new value is: ' + newMap.get(updateId).get(fieldName) + ' old value is: ' + oldMap.get(updateId).get(fieldName));
					if(newMap.get(updateId).get(fieldName) != oldMap.get(updateId).get(fieldName)){
						srpFieldHistory__c newHistoryItem = new srpFieldHistory__c();
						newHistoryItem.fieldName__c = fieldName;
						newHistoryItem.recordName__c = String.valueOf(newMap.get(UpdateId).get('Name'));
						newHistoryItem.sObjectName__c = sObjectTypeName;
						newHistoryItem.recordId__c = updateId;
						newHistoryItem.changedBy__c = UserInfo.getUserId();
						newHistoryItem.fieldLabel__c = String.valueOf(fieldMap.get(fieldName).getDescribe().getLabel());
						newHistoryItem.action__c = 'Update';
						System.debug('Field Name is: ' + fieldName + ' Field Type is: ' + fieldMap.get(fieldName).getDescribe().getType() + ' Field is a formula field: ' + fieldMap.get(fieldName).getDescribe().isCalculated());
						if(String.valueOf(fieldMap.get(fieldName).getDescribe().getType()) == 'ID'  || String.valueOf(fieldMap.get(fieldName).getDescribe().getType()) == 'REFERENCE'){
							String referenceSObjectTypeName = '';
							if(newMap.get(updateId).get(fieldName) != null){
								referenceSObjectTypeName = String.valueOf(Id.valueOf(String.valueOf(newMap.get(updateId).get(fieldName))).getSObjectType());	
							}
							else if (oldMap.get(updateId).get(fieldName) != null){
								referenceSObjectTypeName = String.valueOf(Id.valueOf(String.valueOf(oldMap.get(updateId).get(fieldName))).getSObjectType());	
							}
							else{
								referenceSObjectTypeName = 'Unknown';
							}
							//System.debug('lookup reference sobject type is: ' + referenceSObjectTypeName);
							newHistoryItem.isReference__c = true;
							newHistoryItem.oldId__c = String.valueOf(oldMap.get(updateId).get(fieldName));
							newHistoryItem.newId__c = String.valueOf(newMap.get(updateId).get(fieldName));
							newHistoryItem.referenceSObjectType__c = referenceSObjectTypeName;
							if(lookupMap.containsKey(referenceSObjectTypeName)){
								Set<Id> currentIdList = lookupMap.get(referenceSObjectTypeName);
								if(String.valueOf(oldMap.get(updateId).get(fieldName)) != NULL){
									currentIdList.add(String.valueOf(oldMap.get(updateId).get(fieldName)));
								}
								if(String.valueOf(newMap.get(updateId).get(fieldName)) != NULL){
									currentIdList.add(String.valueOf(newMap.get(updateId).get(fieldName)));
								}
							}
							else{
								Set<Id> newIdList = new Set<Id>();
								if(String.valueOf(oldMap.get(updateId).get(fieldName)) != NULL){
									newIdList.add(String.valueOf(oldMap.get(updateId).get(fieldName)));
								}
								if(String.valueOf(newMap.get(updateId).get(fieldName)) != NULL){
									newIdList.add(String.valueOf(newMap.get(updateId).get(fieldName)));
								}
								lookupMap.put(referenceSObjectTypeName, newIdList);
							}
						}
						else{
							newHistoryItem.oldValue__c = String.valueOf(oldMap.get(updateId).get(fieldName));
							newHistoryItem.newValue__c = String.valueOf(newMap.get(updateId).get(fieldName));
						}
						newHistory.add(newHistoryItem);
						//System.debug('isLookupId value: ' + fieldMap.get(fieldName).getDescribe().isIdLookup());
						//System.debug('Found difference in field: ' + fieldName + ' old value is: ' + oldMap.get(updateId).get(fieldName) + ' new value is: ' + newMap.get(updateId).get(fieldName));
					}
				}
			}
		}

		//Once list of new history items is created and maps of Id fields that need names, query for all names, assign new and old values as appropriate
		
		//First dynamically build and retrieve list of ids and names from various objects.
		//Then combine them into a map of id - name pairs
		for(String lookupItemList: lookupMap.keySet()){
			//System.debug('Lookup Item List includes SObject Type: ' + lookupItemList);
			String idList = '\'';
			for(Id lookupId: lookupMap.get(lookupItemList)){
				idList = idList + lookupId + '\',\'';
			}
			idList = idList.left(idList.length()-2);
			String queryString = 'SELECT Id, Name FROM ' + lookupItemList + ' WHERE ID IN (' + idList + ')';
			List<SObject> lookupItems = Database.query(queryString);
			for(SObject currentItem: lookupItems){
				lookupNames.put(Id.valueOf(String.valueOf(currentItem.get('Id'))), String.valueOf(currentItem.get('Name')));
			}
			//for(Id itemId: lookupNames.keySet()){
			//	System.debug('Id value is: ' + itemId + ' Name value is: ' + lookupNames.get(itemId));
			//}
			//System.debug('Query String is: ' + queryString);
		}

		//Cycle through newHistory items and assign values for names where appropriate
		for(srpFieldHistory__c currentHistoryItem : newHistory){
			if(currentHistoryItem.isReference__c){
				if(currentHistoryItem.oldId__c != NULL && lookupNames.containsKey(currentHistoryItem.oldId__c)){
					currentHistoryItem.oldValue__c = lookupNames.get(currentHistoryItem.oldId__c);
				}
				if(currentHistoryItem.newId__c != NULL && lookupNames.containsKey(currentHistoryItem.newId__c)){
					currentHistoryItem.newValue__c = lookupNames.get(currentHistoryItem.newId__c);
				}
			}
		}

		insert newHistory;
	}
	
	private static Boolean checkFieldHistory (List<String> whitelist, List<String> blacklist, Boolean excludeFormulaFields, Schema.SObjectField currentField){
		Boolean response = false;
		Boolean isFormula = currentField.getDescribe().isCalculated();
		String fieldName = currentField.getDescribe().getName();
		System.debug('Current fieldName is: ' + fieldName + ' whitelist size is: ' + whitelist.size() + ' blacklist size is: ' + blacklist.size() + ' excludeFormulaFields value is: ' + excludeFormulaFields);
		//Option one - no custom setting or all fields included
		if(blacklist.contains(fieldName)){
			System.debug('returning false from option 1');
			return response;
		}
		if(whitelist.contains(fieldName)){
			response = true;
			return response;
		}
		if(isFormula && excludeFormulaFields){
			return response;
		}
		if(whitelist.size() == 0){
			System.debug('setting return true from no whitelist');
			response = true;
		}
		System.debug('Returning ' + response + ' from final return');
		return response;
	}

	public static void srpHistoryDelete(List<SObject> triggerOld, Map<Id, SObject> oldMap, String sObjectTypeName){
		List<srpFieldHistory__c> newHistory = new List<srpFieldHistory__c>();
		//System.debug('Tract was deleted');
		for(Id updateId: oldMap.keySet()){
			srpFieldHistory__c newHistoryItem = new srpFieldHistory__c();
			newHistoryItem.action__c = 'Delete';
			newHistoryItem.changedBy__c = UserInfo.getUserId();
			newHistoryItem.recordId__c = updateId;
			newHistoryItem.sObjectName__c = sObjectTypeName;
			newHistory.add(newHistoryItem);
		}
		insert newHistory;
	}
	
}