@isTest
public class ManageCasesAuraTest{
    
    @TestSetup static void makeData(){
		TestDataFactory.dataSetup();
		Case caseRec = [SELECT Id, Subject FROM Case LIMIT 1];
        caseRec.Subject = 'test case 1';
		Opportunity oppRec = [SELECT Id FROM Opportunity LIMIT 1];
		oppRec.Name = 'testRelatedCaseOpportunity';
        
		update caseRec;
		update oppRec;

        Opportunity_Case__c oc = new Opportunity_Case__c();
        oc.opportunity__c = oppRec.Id;
        oc.case__c = caseRec.Id;
        insert oc;
	}
	
	@isTest static void testGetCases() {
		Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'testRelatedCaseOpportunity' LIMIT 1];
		List<Opportunity_Case__c> oppCases = ManageCasesAura.getCases(opp.Id);
		System.assert(oppCases.size() > 0, 'No Opp Cases returned or returned NULL in ManageCasesAuraTest.testGetCases');
	}
    
    @isTest static void testGetCaseSearchResults() {
		List<String> caseIdLst0 = new List<String>();
        List<String> caseIdLst1 = new List<String>();
        
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'testRelatedCaseOpportunity' LIMIT 1];
        Case cse = [SELECT Id, Subject FROM Case WHERE Subject = 'test case 1' LIMIT 1];
        //scenario 1 - case already in the related list
        caseIdLst0.add(String.valueOf(cse.Id));
		List<Opportunity_Case__c> oppCases0 = ManageCasesAura.getCaseSearchResults(caseIdLst0, opp.Id);
		System.assert(oppCases0.size() > 0, 'No Opp Cases returned or returned NULL in ManageCasesAuraTest.testGetCaseSearchResults');
        //scenario 2 - case not already in the related list
        Case[] newCSE = TestDataFactory.createCases(1);
        newCSE[0].Subject = 'test case 2';
        insert newCSE;
        newCSE = [SELECT Id, Subject FROM Case WHERE Subject = 'test case 2' LIMIT 1];
        caseIdLst1.add(String.valueOf(newCSE[0].Id));
        List<Opportunity_Case__c> oppCases1 = ManageCasesAura.getCaseSearchResults(caseIdLst1, opp.Id);
		System.assert(oppCases1.size() > 0, 'No Opp Cases returned or returned NULL in ManageCasesAuraTest.testGetCaseSearchResults');
	}

    @isTest static void testUpdateRecordAssociation() {
		Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'testRelatedCaseOpportunity' LIMIT 1];
        Case[] cse = [SELECT Id, Subject FROM Case WHERE Subject = 'test case 1'];
        Opportunity_Case__c oc = [SELECT Id FROM Opportunity_Case__c LIMIT 1];
		List<Opportunity_Case__c> oppCases = ManageCasesAura.updateRecordAssociation(opp.Id, oc.Id);
		System.assert(oppCases.size() > 0, 'No Opp Cases returned or returned NULL in ManageCasesAuraTest.testUpdateRecordAssociation');
	}
}