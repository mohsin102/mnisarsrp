@isTest
private with sharing class DeleteUnusedRevenueEstimates_Test {
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
        mpRec.Production_Date__c = system.today().addMonths(-13);
        mpRec.Well__c = wellRec.Id;
        Insert mpRec;

        List<unitAllocation__c> uaList = new List<unitAllocation__c>();
        for(Subtract__c subtract : [Select Id from Subtract__c Limit 50]){
            unitAllocation__c suaRec = new unitAllocation__c();
            suaRec.subtract__c = subtract.Id;
            suaRec.unit__c = unit.Id;
            uaList.add(suaRec);
        }
        insert uaList;

        RevenueEstimate__c re = new RevenueEstimate__c(unitAllocation__c = uaList[0].Id,MonthlyProduction__c=mpRec.Id,SRP_Owned__c=false);
        insert re;
    }

    @isTest
    private static void executeBatchTest(){
        Test.StartTest();
        DeleteUnusedRevenueEstimates_Batch e = new DeleteUnusedRevenueEstimates_Batch();
        database.executeBatch(e,1000);
        Test.StopTest();
    }

    @isTest
    private static void executeScheduleTest(){
        Test.StartTest();
        DeleteUnusedRevenueEstimates_Schedule sh1 = new DeleteUnusedRevenueEstimates_Schedule();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1);
        Test.StopTest();
    }

}