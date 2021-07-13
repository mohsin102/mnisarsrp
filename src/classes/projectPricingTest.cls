//Test class created by John Gorrell 01/07/2020

//Provides code coverage for the following classes:
//oppProjectAOIPricingAura
//srpFieldHistoryUtility
//ProjectAOITrigger
//tractProjectAOIListAura

@isTest 
private class projectPricingTest {
	



	@TestSetup
	static void setupTestData(){
		TestDataFactory.dataSetup();
	}

	static testmethod void mainMethod(){
	Opportunity opp = [SELECT ID FROM Opportunity LIMIT 1];
	oppProjectAOIPricingAura.oppProjectPricing pricing = oppProjectAOIPricingAura.getOppPricing2(opp.Id);
	List<Project_AOI__c> projectAOIs = [SELECT ID FROM Project_AOI__c];
	List<Project_AOI_Tract__c> relatedProjectAOITracts = [SELECT ID FROM Project_AOI_Tract__c WHERE projectAoi__c = :projectAOIs[1].Id];
	if (projectAOIs.size() > 1){
		projectAOIs[0].parentAOI__c = projectAOIs[1].Id;
		update projectAOIs[0];
		projectAOIs[1].aoiMaxOtgPrice__c = 100;
		update projectAOIs[1];
		delete relatedProjectAOITracts;
		delete projectAOIs[1];
	}
	Tract__c tract = [SELECT ID FROM Tract__c LIMIT 1];
	tractProjectAOIListAura.projectTractsResult tractProjectAOIResult = tractProjectAOIListAura.getTractProjectAOIs(tract.Id);

	}
}