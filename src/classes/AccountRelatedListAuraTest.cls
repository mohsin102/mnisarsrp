@isTest 
private class AccountRelatedListAuraTest {

	@TestSetup
	static void setupTestData(){
		TestDataFactory.dataSetup();
	}

    static testMethod void mainTestMethod() {

		List<Account> accounts = [SELECT ID FROM Account];
		for(Account a: accounts){
			List<Tract__c> accountTracts = AccountRelatedListAura.getData(a.Id, 0, 'Tract__c');
			List<unitAllocation__c> accountUnitAllocations = AccountRelatedListAura.getData(a.Id, 0, 'unitAllocation__c');
			Integer totalAccountTracts = AccountRelatedListAura.getTotalTractCount(a.Id, 'Tract__c');
			Integer totalAccountUnitAllocations = AccountRelatedListAura.getTotalTractCount(a.Id, 'unitAllocation__c');
		}

	}
}