@isTest(SeeAllData=true)
public class RHX_TEST_Project_AOI_Tract {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Project_AOI_Tract__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Project_AOI_Tract__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}