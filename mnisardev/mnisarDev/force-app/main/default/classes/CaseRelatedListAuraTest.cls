@isTest 
private class CaseRelatedListAuraTest {

	@TestSetup
	private static void makeData(){
		TestDataFactory.dataSetup();
		Case testCase = [SELECT Id FROM Case LIMIT 1];
		Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
		testCase.opportunity__c = opp.Id;
		opp.Name = 'testRelatedCaseOpportunity';
		update testCase;
		update opp;
	}
	
	@isTest
	private static void testMain() {
		Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'testRelatedCaseOpportunity' LIMIT 1];
		List<Opportunity_Case__c> oppCases = CaseRelatedListAura.getCases(opp.Id);
		System.assert(oppCases.size() > 0);

	}
}