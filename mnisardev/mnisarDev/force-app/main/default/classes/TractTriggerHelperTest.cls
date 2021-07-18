@isTest
public with sharing class TractTriggerHelperTest {

    static testMethod void testCaseOppTractTrigger()
    {
        List<Account> acc = TestDataFactory.createAccounts(5);
        insert acc;

        // Build records to test against
        List<Opportunity> opps = TestDataFactory.createOpportunities(5,acc[2]);
        insert opps;

        List<Tract__c> tracts = TestDataFactory.createTracts(4,acc[0]);
        insert tracts;
        List<Case> cases = TestDataFactory.createCases(4);
        insert cases;
        //List<Case_Tract__c> cts = TestDataFactory.createCaseTracts(cases,tracts);
        //insert cts;
        List<Opportunity_Tract__c> ots = TestDataFactory.createOppTracts(opps,tracts);
        insert ots;

        Test.startTest();
        // Confirm trigger calcs are working for cases and opps
        Case testCase = cases[0];
        Opportunity testOpp = opps[0];
        Tract__c testTract = tracts[0];
        Tract__c testTract2 = tracts[1];
        Tract__c testTract3 = tracts[2];
        //System.debug('CASE rollup: ' + testCase.Total_Acreage__c);
        //System.assert(testCase.Total_Acreage__c == null);
        //System.debug('OPP rollup: ' + testCase.Total_Acreage__c);
        //System.assert(testOpp.Total_Acreage__c == null);

        testTract.netAcres__c = 1;
        testTract2.netAcres__c = 2;

        update new List<SObject> {testTract,testTract2};

        //cts = [SELECT Id, Case__c, Tract__c, Tract_Acres__c,Tract__r.netAcres__c FROM Case_Tract__c];

        //for (Case_Tract__c ct: cts)
        //{
        //    System.debug('CASETRACTACRES' + ct.Tract_Acres__c + '->' + ct.Tract__r.netAcres__c);
        //}

        //System.debug('All your OTS' + ots);

        //testCase = [SELECT Id, Total_Acreage__c FROM Case WHERE Id =: testCase.Id];
        //System.debug('CASE rollup 1: ' + testCase.Total_Acreage__c);
        //System.assert(testCase.Total_Acreage__c == 3);

        // run trigger from the case tracts to recalc
        //cts[0].Tract__c = testTract3.Id;

        //update cts;
        //testCase = [SELECT Id, Total_Acreage__c FROM Case WHERE Id =: testCase.Id];
        //System.debug('CASE rollup 2: ' + testCase.Total_Acreage__c);
        //System.assert(testCase.Total_Acreage__c == 3);


        // Confirm default rollup amount for opps
        //testOpp = [SELECT Id, Total_Acreage__c FROM Opportunity WHERE Id =: testOpp.Id];
        //System.debug('OPP rollup 1: ' + testOpp.Total_Acreage__c);
        //System.assert(testOpp.Total_Acreage__c == 3);
        // ots[0].Tract__c = testTract3.Id;

        //update ots;
        //testOpp = [SELECT Id, Total_Acreage__c FROM Opportunity WHERE Id =: testOpp.Id];
        //System.debug('OPP rollup 2: ' + testOpp.Total_Acreage__c);
        //System.assert(testOpp.Total_Acreage__c == 3);

        // now force error with OT
        Opportunity_Tract__c dupe1 = new Opportunity_Tract__c();
        dupe1.Tract__c = ots[0].Tract__c;
        dupe1.Opportunity__c = ots[0].Opportunity__c;

        Opportunity_Tract__c dupe2 = new Opportunity_Tract__c();
        dupe2.Tract__c = ots[0].Tract__c;
        dupe2.Opportunity__c = ots[0].Opportunity__c;

        List<Opportunity_Tract__c> dupeOTs = new List<Opportunity_Tract__c>();
        dupeOTs.add (dupe1);
        dupeOTs.add (dupe2);

        try {
            insert dupeOTs;
        } catch(DmlException e) {
            System.debug(e);
            System.debug('a dupe has been found');
        }
        List<Tract__c> tractList = [Select Id from Tract__c];
        List<Subtract__c> subList = [Select Id from Subtract__c];
        System.assertEquals(subList.size(),tractList.size());
        //TractTriggerHelper.tractUpdating = false;
        delete testTract;
        //TractTriggerHelper.tractUpdating = false;
        delete testTract2;
        //TractTriggerHelper.tractUpdating = false;
        delete testTract3;

        Test.stopTest();





    }

}