@isTest
public with sharing class OpportunityTractTriggerHelperTest {


    static testMethod void testTrigger() {
        // test the trigger and helper method
		Test.enableChangeDataCapture();
        Account a1 = new Account();
        a1.Name = 'Seller';
        a1.Type = 'Portfolio Investment';
        insert a1;

        Account a2 = new Account();
        a2.Name = 'Buyer';
        a2.Type = 'Portfolio Investment';
        insert a2;

        List<LandGridTract__c> lts = new List<LandGridTract__c>();
        LandGridTract__c lt1 = new LandGridTract__c();
        lt1.Name='Bexar 1-579e38 TX';
        lt1.County__c ='Bexar';
        lts.add(lt1);

        LandGridTract__c lt2 = new LandGridTract__c();
        lt2.Name='Bexar 1-179347 TX';
        lt2.County__c ='Bexar';
        lts.add(lt2);
        insert lts;

        Opportunity o = new Opportunity();
        o.Name = 'New Opp 1';
        o.AccountId = a1.Id;
        o.Acquiring_Entity__c = a2.Id;
        o.CloseDate = Date.today() + 30;
        o.StageName='Closed Won';
        o.Effective_Date__c=system.today();
        insert o;

        Opportunity o2 = new Opportunity();
        o2.Name = 'New Opp 1';
        o2.AccountId = a1.Id;
        o2.Acquiring_Entity__c = a2.Id;
        o2.CloseDate = Date.today() + 30;
        o2.StageName='Closed Won';
        o2.Effective_Date__c=system.today();
        o2.Type='Divestiture';
        o2.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Divestiture').getRecordTypeId();
        
        insert o2;

        Tract__c t1 = new Tract__c();
        t1.LandGridTract__c = lt1.Id;
		t1.Account__c = a1.Id;
        insert t1;

        Tract__c t2 = new Tract__c();
        t2.LandGridTract__c = lt2.Id;
		t2.Account__c = a2.Id;
        insert t2;

        Opportunity_Tract__c ot = new Opportunity_Tract__c();
        ot.Opportunity__c = o.Id;
        ot.Tract__c = t2.Id;
        insert ot;
        
        Opportunity_Tract__c ot1 = new Opportunity_Tract__c();
        ot1.Opportunity__c = o2.Id;
        ot1.Tract__c = t1.Id;
        insert ot1;
        
        ot.unitPrice__c = 10;
        update ot;
        
        Test.getEventBus().deliver();
     
    }
}