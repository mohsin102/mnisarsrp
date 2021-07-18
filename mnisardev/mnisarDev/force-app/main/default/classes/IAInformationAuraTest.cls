@isTest 
private class IAInformationAuraTest {

	@TestSetup
	static void setupTestData(){
		TestDataFactory.dataSetup();
	}

	@isTest
	private static void testName() {
		List<InventoryAsset__c> inventoryAssets = [SELECT ID FROM InventoryAsset__c];
		InventoryAsset__c testAsset = IAInformationAura.getInventoryAsset(inventoryAssets[0].Id);
		
	}
}