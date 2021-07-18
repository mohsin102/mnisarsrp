@isTest
    public class ManageOpportunitiesAuraTest{
        
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
        
        @isTest static void testGetOpportunities() {
            Case[] cse = [SELECT Id, Subject FROM Case];
            List<Opportunity_Case__c> oppCases = ManageOpportunitiesAura.getOpportunities(cse[0].Id);
            System.assert(oppCases.size() > 0, 'No Opp Cases returned or returned NULL in ManageOpportunitiesAuraTest.testGetOpportunities');
        }
        
        @isTest static void testGetOpportunitySearchResults() {
            List<String> oppIdLst0 = new List<String>();
            List<String> oppIdLst1 = new List<String>();
            
            //scenario 1 - opp already in the related list
            Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'testRelatedCaseOpportunity' LIMIT 1];
            Case[] cse = [SELECT Id, Subject FROM Case];
            oppIdLst0.add(String.valueOf(opp.Id));
            List<Opportunity_Case__c> oppCases0 = ManageOpportunitiesAura.getOpportunitySearchResults(oppIdLst0, cse[1].Id);
            System.assert(oppCases0.size() > 0, 'No Opp Cases returned or returned NULL in ManageOpportunitiesAuraTest.testGetCaseSearchResults');
            
            
            //scenario 2 - opp not already in the related list
            Account[] newAcct = TestDataFactory.createAccounts(1);
            newAcct[0].Name = 'Test Account 42';
            insert newAcct;
            newAcct = [SELECT Id FROM Account WHERE Name = 'Test Account 42' LIMIT 1];
            Opportunity[] newOpp = TestDataFactory.createOpportunities(3, newAcct[0]);
            newOpp[2].Name = 'testRelatedCaseOpportunity';
            insert newOpp;
            newOpp = [SELECT Id FROM Opportunity WHERE Name = 'testRelatedCaseOpportunity' LIMIT 1];
            oppIdLst1.add(String.valueOf(newOpp[0].Id));
            List<Opportunity_Case__c> oppCases1 = ManageOpportunitiesAura.getOpportunitySearchResults(oppIdLst1, cse[2].Id);
            System.assert(oppCases1.size() > 0, 'No Opp Cases returned or returned NULL in ManageOpportunitiesAuraTest.testGetCaseSearchResults');
        }
    
        @isTest static void testUpdateRecordAssociation() {
            Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'testRelatedCaseOpportunity' LIMIT 1];
            Case[] cse = [SELECT Id, Subject FROM Case WHERE Subject = 'test case 1'];
            Opportunity_Case__c oc = [SELECT Id FROM Opportunity_Case__c LIMIT 1];
            List<Opportunity_Case__c> oppCases = ManageOpportunitiesAura.updateRecordAssociation(cse[0].Id, oc.Id);
            System.assert(oppCases.size() > 0, 'No Opp Cases returned or returned NULL in ManageOpportunitiesAuraTest.testUpdateRecordAssociation');
        }
    }