@isTest
public class SubtractUnitAllocationController_Test{

    @TestSetup
    private static void makeData(){
        
        TestDataFactory.dataSetup();
		Account accRec = [Select Id from Account Limit 1];
        Unit__c unit = new Unit__c();
        unit.Operator__c = accRec.Id;
        insert unit;
	
        List<unitAllocation__c> uaList = new List<unitAllocation__c>();
        for(Subtract__c subtract : [Select Id from Subtract__c Limit 50]){
            unitAllocation__c suaRec = new unitAllocation__c();
            suaRec.subtract__c = subtract.Id;
            suaRec.unit__c = unit.Id;
            uaList.add(suaRec);
        }
        insert uaList;
    }

    @isTest
    private static void testmethod1(){
        Subtract__c subtract = [Select Id from Subtract__c Limit 1];
        Unit__c unit = [Select Id from Unit__c Limit 1];
        Tract__c tract = [Select id from Tract__c limit 1];
        Opportunity opp = [Select Id from Opportunity limit 1];
        
        Test.StartTest();
        SubtractUnitAllocationController.getRecords(opp.Id,'');
        SubtractUnitAllocationController.getRecords(tract.Id,'');
        SubtractUnitAllocationController.getRecords(subtract.Id,'');
        SubtractUnitAllocationController.getRecords(unit.Id,'');
        Test.StopTest();
    }
}