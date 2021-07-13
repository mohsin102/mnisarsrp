@isTest 
private class IARelatedOpportunityAuraTest {

	@TestSetup
	static void setupTestData(){
		TestDataFactory.dataSetup();
	}

    static testMethod void mainTestMethod() {

		List<InventoryAsset__c> inventoryAssets = [SELECT ID FROM InventoryAsset__c];
		IARelatedOpportunityAura.IARelatedOpportunity assetAcquisition = IARelatedOpportunityAura.getRelatedOpp(inventoryAssets[0].Id, 'assetAcquisition__c');
		IARelatedOpportunityAura.IARelatedOpportunity assetAcquisitionOverride = IARelatedOpportunityAura.getRelatedOpp(inventoryAssets[0].Id, 'assetAcquisitionOverride__c');
		IARelatedOpportunityAura.IARelatedOpportunity assetSale = IARelatedOpportunityAura.getRelatedOpp(inventoryAssets[0].Id, 'assetSale__c');
		IARelatedOpportunityAura.IARelatedOpportunity assetSaleOverride = IARelatedOpportunityAura.getRelatedOpp(inventoryAssets[0].Id, 'assetSaleOverride__c');

	}
}