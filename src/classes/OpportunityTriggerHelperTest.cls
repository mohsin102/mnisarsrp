@isTest
public with sharing class OpportunityTriggerHelperTest {

    @TestSetup
    static void makeData(){
        Id divRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Divestiture').getRecordTypeId();
		Id acqRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Acquisition').getRecordTypeId();

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

        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity o = new Opportunity();
        o.Name = 'New Opp 1';
        o.RecordTypeId = acqRecordTypeId;
		o.Type = 'Acquisition';
		o.AccountId = a1.Id;
        o.Acquiring_Entity__c = a2.Id;
        o.CloseDate = Date.today() + 30;
        o.StageName = 'Pending';
        oppList.add(o);

        Opportunity o2 = new Opportunity();
        o2.Name = 'New Opp 1';
		o2.RecordTypeId = divRecordTypeId;
		o2.Type = 'Divestiture';
        o2.AccountId = a1.Id;
        o2.Acquiring_Entity__c = a2.Id;
        o2.CloseDate = Date.today() + 30;
        o2.StageName = 'Pending';
        oppList.add(o2);
        insert oppList;

        List<Tract__c> tList = new List<Tract__c>();
        Tract__c t1 = new Tract__c();
        t1.LandGridTract__c = lt1.Id;
		t1.Account__c = a1.Id;
        tList.add(t1);

        Tract__c t2 = new Tract__c();
        t2.LandGridTract__c = lt2.Id;
		t2.Account__c = a2.Id;
        tList.add(t2);
        insert tList;

        List<Opportunity_Tract__c> otList = new List<Opportunity_Tract__c>();
        Opportunity_Tract__c ot = new Opportunity_Tract__c();
        ot.Opportunity__c = o.Id;
        ot.Tract__c = t1.Id;
        otList.add(ot);

		Opportunity_Tract__c ot2 = new Opportunity_Tract__c();
        ot2.Opportunity__c = o2.Id;
        ot2.Tract__c = t2.Id;
        otList.add(ot2);
        insert otList;

        
    }

    static testMethod void testTrigger1() {
        // test the trigger and helper method

		Id divRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Divestiture').getRecordTypeId();
		Id acqRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Acquisition').getRecordTypeId();

        Account a1 = [Select Id from Account where name='Seller'];
        

        Account a2 = [Select Id from Account where name='Buyer'];

        LandGridTract__c lt1 = [Select Id from LandGridTract__c where name='Bexar 1-579e38 TX'];

        LandGridTract__c lt2 = [Select Id from LandGridTract__c where name='Bexar 1-179347 TX'];

        Opportunity o = new Opportunity();
        o.Name = 'New Opp 1';
        o.RecordTypeId = acqRecordTypeId;
		o.Type = 'Acquisition';
		o.AccountId = a1.Id;
        o.Acquiring_Entity__c = a2.Id;
        o.CloseDate = Date.today() + 30;
        o.StageName = 'Pending';
        insert o;

        Opportunity o2 = new Opportunity();
        o2.Name = 'New Opp 1';
		o2.RecordTypeId = divRecordTypeId;
		o2.Type = 'Divestiture';
        o2.AccountId = a1.Id;
        o2.Acquiring_Entity__c = a2.Id;
        o2.CloseDate = Date.today() + 30;
        o2.StageName = 'Pending';
        insert o2;

    /*    Tract__c t1 = new Tract__c();
        t1.LandGridTract__c = lt1.Id;
		t1.Account__c = a1.Id;
        insert t1;

        Tract__c t2 = new Tract__c();
        t2.LandGridTract__c = lt2.Id;
		t2.Account__c = a2.Id;
        insert t2;

        Opportunity_Tract__c ot = new Opportunity_Tract__c();
        ot.Opportunity__c = o.Id;
        ot.Tract__c = t1.Id;
        insert ot;

		Opportunity_Tract__c ot2 = new Opportunity_Tract__c();
        ot2.Opportunity__c = o2.Id;
        ot2.Tract__c = t2.Id;
        insert ot2; */

    }

    static testMethod void testTrigger2() {
        // test the trigger and helper method

		Id divRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Divestiture').getRecordTypeId();
		Id acqRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Acquisition').getRecordTypeId();

        Account a1 = [Select Id from Account where name='Seller'];
        

        Account a2 = [Select Id from Account where name='Buyer'];

        LandGridTract__c lt1 = [Select Id from LandGridTract__c where name='Bexar 1-579e38 TX'];

        LandGridTract__c lt2 = [Select Id from LandGridTract__c where name='Bexar 1-179347 TX'];

        Opportunity o = [Select Id from Opportunity where name='New Opp 1' AND Type = 'Acquisition'];

        Opportunity o2 = [Select Id from Opportunity where name='New Opp 1' AND Type = 'Divestiture'];

        Tract__c t1 = [Select Id from Tract__c where LandGridTract__c =:lt1.Id And  Account__c =: a1.Id];

        Tract__c t2 = [Select Id from Tract__c where LandGridTract__c =:lt2.Id And  Account__c =: a2.Id];

        Opportunity_Tract__c ot = [Select Id from Opportunity_Tract__c where Opportunity__c=:o.Id AND Tract__c=: t1.Id];

		Opportunity_Tract__c ot2 = [Select Id from Opportunity_Tract__c where Opportunity__c=:o2.Id AND Tract__c=: t2.Id];



        o.Type='Divestiture';
		o.RecordTypeId = divRecordTypeId;
        o.StageName='Closed Won';
        o.Effective_Date__c=system.today();
        update o;
        
        
        o.Effective_date__c = system.today().addDays(-1);
        o.Type = 'Acquisition';
        o.RecordTypeId = acqRecordTypeId;
        o.StageName='Closed Won';
        update o ;

		o2.Effective_date__c = system.today().addDays(-1);
        o2.Type = 'Acquisition';
        o2.RecordTypeId = acqRecordTypeId;
        o2.StageName='Closed Won';
        update o2 ;
        List<Tract__c> tList =[Select Id, Account__c from Tract__c Where Id =: t1.Id];
        system.assertEquals(tList[0].Account__c, a2.Id);

		o2.Type='Divestiture';
		o2.RecordTypeId = divRecordTypeId;
        o2.StageName='Closed Won';
        o2.Effective_Date__c=system.today();
        update o2;
        tList =[Select Id, Account__c from Tract__c Where Id =: t2.Id];
        system.assertEquals(tList[0].Account__c, a2.Id);

        Project_Cohort__c pc = new Project_Cohort__c();
        pc.Account__c = a1.Id;
        pc.Project__c = 'Ford';
        insert pc;

        Project_Cohort__c pc2 = new Project_Cohort__c();
        pc2.Account__c = a1.Id;
        pc2.Project__c = 'Ford';
        try {
            insert pc2;
        } catch (Exception e) {
            System.debug('dupe expected.');
        }

        try {
            //TractTriggerHelper.tractUpdating = false;
            delete o2;
        } catch (Exception e) {
            System.debug('error deleting expected.');
        }

    }
}