@isTest
public with sharing class MonthlyProductionTriggerHandlerTest {


    static testMethod void testTrigger() {
        
        Well__c wellRec = new Well__c();
        wellRec.Name = 'TestWell';
        wellRec.API10__c ='9501724908';
        insert wellRec;

        Test.startTest();
        Monthly_Production__c mpRec = new Monthly_Production__c();
        mpRec.Unique_Key__c = wellRec.API10__c+'.'+system.today().format();
        mpRec.Production_Date__c = system.today();
        mpRec.Well__c = wellRec.Id;
        Insert mpRec;
        Test.stopTest();     
    }
}