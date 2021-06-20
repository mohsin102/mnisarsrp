//Create by John Gorrell 02/24/2019 as part of Tract Reconciliation Prject

//Test coverage provided by tractReconciliationAuraTest

public with sharing class tpjQuarterCallMappingAura  {

	@AuraEnabled(Cacheable=true)
    public static List<QuarterCallMapping__c> getMappings(Id recordId) {

        List<QuarterCallMapping__c> quarterCallMappings = [SELECT area__c,CreatedById,CreatedDate,Id,IsDeleted,LastModifiedById,LastModifiedDate,Name,OwnerId,quarterCall__c,SystemModstamp,
														   titleIntegrationJob__c, titleIntegrationJob__r.Name, titleIntegrationJob__r.quarterCallLock__c 
														   FROM QuarterCallMapping__c 
														   WHERE titleIntegrationJob__c =: recordId
        ];
        return quarterCallMappings;
    }

	@AuraEnabled
	public static String updateMappings(List<QuarterCallMapping__c> mappings, Id recordId){
		String response = 'Success';
		List<String> areas = new List<String>();
		Map<String, String> quarterCallMap = new Map<String, String>();
		List<TitleOwnershipDetail__c> updateList = new List<TitleOwnershipDetail__c>();
		try{
			update mappings;
			for(QuarterCallMapping__c qCMap: mappings){
				areas.add(qCMap.area__c);
				quarterCallMap.put(qCMap.area__c, qCMap.quarterCall__c);
			}

			List<TitleOwnershipDetail__c> relatedTODs = new List<TitleOwnershipDetail__c>();
			relatedTODs = [SELECT Id, area__c FROM TitleOwnershipDetail__c WHERE targetOwnershipName__r.jobId__c = :recordId];
			for(TitleOwnershipDetail__c currentTOD : relatedTODs){
				if(quarterCallMap.containsKey(currentTOD.area__c)){
					currentTOD.quarterCall__c = quarterCallMap.get(currentTOD.area__c);
					updateList.add(currentTOD);
				}
			}
			if(updateList.size() > 0){
				update updateList;
			}
		}
		catch (Exception e) {
			 response = 'ERROR UPDATING QUARTER CALL MAPPINGS ' + e + '\n' + e.getMessage() + ' Line Number: ' + e.getLineNumber() + ' ' + e.getStackTraceString();
			 system.debug('ERROR UPDATING QUARTER CALL MAPPINGS ' + e + '\n' + e.getMessage() + ' Line Number: ' + e.getLineNumber() + ' ' + e.getStackTraceString());
		}
		return response;

	}

	@AuraEnabled
	public static String lockQuarterCallMap(Id recordId){
		String response = 'Success';
		try{
			TitleIntegrationJob__c currentJob = new TitleIntegrationJob__c();
			currentJob.Id = recordId;
			currentJob.quarterCallLock__c = true;
			update currentJob;
		}
		catch (Exception e) {
			 response = 'ERROR LOCKING QUARTER CALL MAP ' + e + '\n' + e.getMessage() + ' Line Number: ' + e.getLineNumber() + ' ' + e.getStackTraceString();
			 system.debug('ERROR LOCKING QUARTER CALL MAP ' + e + '\n' + e.getMessage() + ' Line Number: ' + e.getLineNumber() + ' ' + e.getStackTraceString());
		}
		return response;
	}

}