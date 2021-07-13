@isTest
public class UnitAllocationTriggerHelperTest{

    @TestSetup
    private static void makeData(){
        TestDataFactory.dataSetup();
        Account accRec = [Select Id from Account Limit 1];
        Unit__c unit = new Unit__c();
        unit.Operator__c = accRec.Id;
        insert unit;
	
        Well__c wellRec = new Well__c();
        wellRec.unit__c = unit.Id;
        wellRec.Name = 'TestWell';
        wellRec.API10__c ='9501724908';
        insert wellRec;

        Monthly_Production__c mpRec = new Monthly_Production__c();
        mpRec.Unique_Key__c = wellRec.API10__c+'.'+system.today().format();
        mpRec.Production_Date__c = system.today();
        mpRec.Well__c = wellRec.Id;
        Insert mpRec;
        

        
    }

    @isTest
    private static void testmethod1(){
        Unit__c unit = [Select Id from Unit__c Limit 1];
        Test.StartTest();
        List<unitAllocation__c> uaList = new List<unitAllocation__c>();
        for(Subtract__c subtract : [Select Id from Subtract__c Limit 50]){
            unitAllocation__c suaRec = new unitAllocation__c();
            suaRec.subtract__c = subtract.Id;
            suaRec.unit__c = unit.Id;
            uaList.add(suaRec);
        }
        insert uaList;
        Test.StopTest();
    }
}