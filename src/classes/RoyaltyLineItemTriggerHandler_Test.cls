@isTest
public class RoyaltyLineItemTriggerHandler_Test{

    @isTest
    public static void testMedhod1(){
        
        Well__c wellRec = new Well__c();
        wellRec.Name = 'TestWell';
        wellRec.API10__c ='9501724908';
        insert wellRec;
        
        Royalty_Check__c rcRec = new Royalty_Check__c();
        rcRec.Amount__c = 100.50;
        rcRec.Check_Issue_Date__c = system.today();
        rcRec.Check_Number__c = '123123123';
        insert rcRec;

        Royalty_Line_Item__c rliRec = new Royalty_Line_Item__c();
        rliRec.Royalty_Check__c = rcRec.id;
        //rliRec.Type__c = 'Revenue';
        rliRec.Production_Month__c = system.today();
        rliRec.ownerNetValueActual__c = 123;
        rliRec.lineItemDecimal__c = 0.00012122;
        rliRec.grossVolumeActual__c = 230.50;
        rliRec.Price__c  = 200;
        rliRec.propertyName__c = 'Test';
        insert rliRec;

        Test.startTest();
        rliRec.ownerNetValueActual__c = 123;
        update rliRec;
        Test.stopTest();


    }
}