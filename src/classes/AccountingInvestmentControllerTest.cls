@isTest 
private class AccountingInvestmentControllerTest {

	@TestSetup
	private static void makeData(){
		TestDataFactory.dataSetup();
	}


	@isTest
	private static void getAccountingTransactionTest() {
		AccountingTransaction__c at = [SELECT Id, accountingIntegrationJob__c, investment__c FROM AccountingTransaction__c LIMIT 1];

		Test.startTest();
		List<AccountingTransaction__c> atList1 = AccountingInvestmentController.getAccountingTransaction(at.accountingIntegrationJob__c);
		List<AccountingTransaction__c> atList2 = AccountingInvestmentController.getAccountingTransaction(at.investment__c);
		Test.stopTest();
		System.assert(atList1.size()>0);
		System.assert(atList2.size()>0);
	}

	@isTest
	private static void getAccountingInvestmentTest() {
		
		AccountingIntegrationJob__c aij = [Select id from AccountingIntegrationJob__c WHERE Id in (SELECT accountingIntegrationJob__c FROM AccountingTransaction__c) limit 1];
		

		Test.startTest();
		List<AccountingInvestment__c> aiList = AccountingInvestmentController.getAccountingInvestment(aij.Id);
		Test.stopTest();
		System.assert(aiList.size()>0);
	}

	@isTest
	private static void getSearchResultsTest() {
		Id [] fixedResults = new Id[1];
		InventoryAsset__c ia = [SELECT Id FROM InventoryAsset__c LIMIT 1];
		fixedResults.add(ia.Id);
		String searchString = 'IA';
		Integer searchCounter = 1;
		Test.startTest();
		Test.setFixedSearchResults(fixedResults);
		AccountingInvestmentController.InventoryAssetSearchResult results = AccountingInvestmentController.getSearchResults(searchString, searchCounter);
		Test.stopTest();
		System.assert(results.inventoryAssets[0].Id == ia.Id);
	}

	@isTest
	private static void iaAssociateAtTest() {
		
		InventoryAsset__c ia = [SELECT Id FROM InventoryAsset__c LIMIT 1];
		AccountingInvestment__c ai = [SELECT Id FROM AccountingInvestment__c LIMIT 1];
		Test.startTest();
		AccountingInvestmentController.updateRecordAssociation(ai.Id, ia.Id, 'Add+');
		List<InventoryAsset__c> ias = AccountingInvestmentController.getInventoryAssets(ai.Id);
		System.assert(ias.size() == 1);
		AccountingInvestmentController.updateRecordAssociation(ai.Id, ia.Id, 'Remove-');
		ias = AccountingInvestmentController.getInventoryAssets(ai.Id);
		System.assert(ias.size() == 0);
		Test.stopTest();
		
	}
    
    @isTest
    private static void getOpportunitySearchResultsTest(){
        String[] oppIdStrLst = new String[]{};
        for(Opportunity o: [SELECT Id FROM Opportunity]){
            oppIdStrLst.add(String.valueOf(o.Id));
        }
        AccountingInvestmentController.getOpportunitySearchResults(oppIdStrLst);
    }

	/*@isTest
	private static void getOpportunityTractTest() {
		accountingInvestment__c ai = [Select id from AccountingInvestment__c limit 1];
		Opportunity opp = [Select id from Opportunity limit 1];

		Test.startTest();
		AccountingInvestmentController.opportunityTractWrapper otWrapper = AccountingInvestmentController.getOpportunityTract(ai.Id, new List<String> {opp.id});
		Test.stopTest();
		System.assert(otWrapper != null);
		
	}

	@IsTest
	private static void associateOpportunityTractsTest(){
		accountingInvestment__c ai = [Select id from AccountingInvestment__c limit 1];
		Opportunity_Tract__c ot = [Select id from Opportunity_Tract__c where accountingInvestment__c = null limit 1];

		Test.startTest();
		AccountingInvestmentController.associateOpportunityTracts(ai.Id, new List<String> {ot.id});
		Test.stopTest();

		ot = [Select id,accountingInvestment__c from Opportunity_Tract__c where accountingInvestment__c != null];
		System.assert(ot.accountingInvestment__c !=null);
	}*/
	
}