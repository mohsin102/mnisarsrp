@isTest
public class WellInterestAllocationListControllerTest {
    public static testmethod void myUnitTest(){
        List<Account> acc = TestDataFactory.createAccounts(1);
        insert acc;
        
        LandGridTract__c landtrct = new LandGridTract__c();
        landtrct.Name='TestLandGridTract';
        insert landtrct;
        
        Tract__c trct = new Tract__c();
        trct.LandGridTract__c=landtrct.Id;
        trct.Instrument_Type__c='OGL';
		trct.netAcreageUnits__c = 'NMA';
        trct.Account__c = acc[0].Id;
        insert trct;
        
        Instrument__c instrumnt = new Instrument__c(termMeasure__c=null, extensionTermMeasure__c = null);
        insert instrumnt;
        
        Subtract__c subtrct = new Subtract__c();
        subtrct.Tract__c=trct.Id;
        subtrct.Instrument__c=instrumnt.Id;
        insert subtrct;
        
        Well__c wellRec = new Well__c();
        wellRec.Name = 'TestWell';
        wellRec.API10__c ='9501724908';
        insert wellRec;
        
        
        Monthly_Production__c mpRec = new Monthly_Production__c();
        mpRec.Unique_Key__c = wellRec.API10__c+'.'+system.today().format();
        mpRec.Production_Date__c = system.today();
        mpRec.Well__c = wellRec.Id;
        Insert mpRec;
        
        test.startTest();
        WellInterestAllocationListController.getAllWellUnits(acc[0].Id);
        WellInterestAllocationListController.getAllAccountsTracts(acc[0].Id);
        WellInterestAllocationListController.getAllMonthlyProduction(wellRec.Id);
        WellInterestAllocationListController.getSubtracts(trct.Id);
        test.stopTest();
        
    }
}