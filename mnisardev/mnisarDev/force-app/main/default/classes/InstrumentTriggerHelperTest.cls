@isTest
public with sharing class InstrumentTriggerHelperTest {


    static testMethod void testTrigger() {
        // test the trigger and helper method

        Account a1 = new Account();
        a1.Name = 'Seller';
        insert a1;

        Account a2 = new Account();
        a2.Name = 'Buyer';
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

        Tract__c t1 = new Tract__c();
        t1.LandGridTract__c = lt1.Id;
		t1.Account__c = a1.Id;
        insert t1;

        Tract__c t2 = new Tract__c();
        t2.LandGridTract__c = lt2.Id;
		t2.Account__c = a2.Id;
        insert t2;

        Instrument__c inst1 = new Instrument__c(termMeasure__c=null, extensionTermMeasure__c = null);
        Instrument__c inst2 = new Instrument__c(termMeasure__c=null, extensionTermMeasure__c = null);
        insert inst1;
        insert inst2;

        Subtract__c st1 = new Subtract__c();
        Subtract__c st2 = new Subtract__c();
        st1.Tract__c = t1.Id;
        st1.Instrument__c = inst1.Id;
        insert st1;

        Test.startTest();
        delete inst2;
        try {
            delete inst1;
        }
        catch (Exception e)
        {
            System.assert(e != null);
        }

        Test.stopTest();


    }
}