public with sharing class srpFieldHistoryRelatedListAura  {
	@AuraEnabled
    public static List<boSRPFieldHistory__b> getRelatedHistory(Id recordId, String primaryObjectType) {
		List<boSRPFieldHistory__b> relatedHistory = new List<boSRPFieldHistory__b>();
        relatedHistory = [SELECT action__c,changedBy__c,CreatedById,CreatedDate,fieldLabel__c,fieldNameIndex__c,fieldName__c,historyCreatedDate__c,
						  Id,isReference__c,newId__c,newValue__c,oldId__c,oldValue__c,recordId__c,recordName__c,referenceSObjectType__c,
						  sObjectNameIndex__c,sObjectName__c, changedBy__r.Name 
						  FROM boSRPFieldHistory__b
						  WHERE sObjectNameIndex__c = :primaryObjectType
						  AND recordId__c = :recordId
						  ORDER BY sObjectNameIndex__c, recordId__c, historyCreatedDate__c  DESC
						  LIMIT 200
						  ];
        return relatedHistory;
    }
	

}