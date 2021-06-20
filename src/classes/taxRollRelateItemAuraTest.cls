@isTest 
private class taxRollRelateItemAuraTest {
	static Final String accountRelatedObject = 'Account';
	static Final String accountField = 'account__c';
	static Final String permitRelatedObject = 'diTexasPermitWithAcreage__c';
	static Final String permitField = 'diTexasPermitWithAcreage__c';

	@TestSetup
	static void setupTestData(){
		
		TestDataFactory.dataSetup();
	}
	@isTest
	private static void testTaxRollRelateItem() {
		List<taxRollOwner__c> taxRollOwners = [SELECT ID FROM taxRollOwner__c];
		List<Account> testAccounts = [SELECT ID, Name FROM Account];
		List<diTexasPermitWithAcreage__c> diPermits = [SELECT ID FROM diTexasPermitWithAcreage__c];
		List<RRCLease__c> testLeases = [SELECT ID FROM RRCLease__c];
		//List<RRC
		Integer testCount = 0;
		Id [] fixedSearchResults= new Id[2];
		fixedSearchResults[0] = testAccounts[0].Id;
		fixedSearchResults[1] = testAccounts[1].Id;
		Test.setFixedSearchResults(fixedSearchResults);
		taxRollRelateItemAura.taxRollInterestSearchResponse firstSearchResponse = taxRollRelateItemAura.getNewSearchResult('New Account', 0, testAccounts[0].Id);
		Integer count = 5;
		for(Integer i = 0; i<count; i++){
			taxRollRelateItemAura.taxRollInterestSearchResponse relatedAccountResponse = taxRollRelateItemAura.getInitialResults(taxRollOwners[i].Id, accountRelatedObject);
			taxRollRelateItemAura.taxRollInterestSearchResponse permitAccountResponse = taxRollRelateItemAura.getInitialResults(testLeases[i].Id, permitRelatedObject);
			List<TaxRollInterest__c> taxRollInterests = taxRollRelatedListAura.getTaxRollOwnerInterests(taxRollOwners[i].Id);
			List<TaxRollInterest__c> leaseTaxRollInterests = taxRollRelatedListAura.getRRCLeaseInterests(testLeases[i].Id);
			//String setAccountReturnMessage = taxRollInterestRelatedItemAura.setRelatedRecord(interest.Id, testAccounts[testCount].Id, accountField);
			//System.assertEquals(setAccountReturnMessage, 'Updated Related Record');
			//String setPermitReturnMessage = taxRollInterestRelatedItemAura.setRelatedRecord(interest.Id, diPermits[testCount].Id, permitField);
			//System.assertEquals(setPermitReturnMessage, 'Updated Related Record');
			if(testCount +1  < testAccounts.size() && testCount + 1 < diPermits.size()){
				testCount++;
			}
			else{
				testCount = 0;
			}
			
		}

	}
	
}