@isTest
public class WellUnitUtil_Test{

    @TestSetup
    private static void makeData(){
        TestDataFactory.dataSetup();
        Account accRec = [Select Id from Account Limit 1];
        Unit__c unit = new Unit__c();
        unit.Operator__c = accRec.Id;
        insert unit;
	
        List<Well__c> wells = new List<Well__c>();
        wells.add(new Well__c(
                unit__c = unit.id,
                Current_Operator_Name__c = 'Surge',
                API10__c = '422273655',
                Name = 'My Well #1A',
                Hole_Direction__c = 'Horizontal',
                Last_Activity_Date__c = Date.parse('1/1/18'),
                Last_Production_Date__c = Date.parse('2/1/18'),
                Last_Activity_Type__c = 'Spud',
                //Is_Paying__c = false,
                Is_Permit__c = true
        ));

        wells.add(new Well__c(
                unit__c = unit.id,
                Current_Operator_Name__c = 'Surge',
                API10__c = '422273656',
                Name = 'My Well #2A',
                Hole_Direction__c = 'Horizontal',
                Last_Activity_Date__c = Date.parse('1/1/18'),
                Last_Production_Date__c = Date.parse('2/1/18'),
                Last_Activity_Type__c = 'Spud',
                //Is_Paying__c = true,
                Is_Permit__c = false
        ));

        wells.add(new Well__c(
                unit__c = unit.id,
                Current_Operator_Name__c = 'Surge',
                API10__c = '422273657',
                Name = 'My Well #3A',
                Hole_Direction__c = 'Vertical',
                Last_Activity_Date__c = Date.parse('1/1/18'),
                Last_Production_Date__c = Date.parse('2/1/18'),
                Last_Activity_Type__c = 'Spud',
                //Is_Paying__c = true,
                Is_Permit__c = false
        ));


        wells.add(new Well__c(
                unit__c = unit.id,
                Current_Operator_Name__c = 'Surge',
                API10__c = '422273658',
                Name = 'My Well #4A',
                Hole_Direction__c = 'Horizontal',
                Last_Activity_Date__c = Date.parse('2/1/18'),
                Last_Activity_Type__c = 'Spud',
                Last_Production_Date__c = Date.parse('2/1/18'),
                //Is_Paying__c = false,
                Is_Permit__c = false
        ));

        wells.add(new Well__c(
                unit__c = unit.id,
                Current_Operator_Name__c = 'Surge',
                API10__c = '422273659',
                Name = 'My Well #5A',
                Hole_Direction__c = 'Horizontal',
                Last_Activity_Date__c = Date.parse('3/1/18'),
                Last_Production_Date__c = Date.parse('2/1/18'),
                Last_Activity_Type__c = 'Permit',
               // Is_Paying__c = false,
                Is_Permit__c = false
        ));

        wells.add(new Well__c(
                unit__c = unit.id,
                Current_Operator_Name__c = 'Surge',
                API10__c = '422273610',
                Name = 'My Well #6A',
                Hole_Direction__c = 'Horizontal',
                Last_Activity_Date__c = Date.parse('4/1/18'),
                Last_Production_Date__c = Date.parse('2/1/18'),
                Last_Activity_Type__c = 'Spud',
                //Is_Paying__c = true,
                Is_Permit__c = true
        ));

        insert wells;

        List<Monthly_Production__c> mpList = new List<Monthly_Production__c>();
        for(Well__c well :wells){
        Monthly_Production__c mpRec = new Monthly_Production__c();
        mpRec.Unique_Key__c = well.API10__c+'.'+system.today().format();
        mpRec.Production_Date__c = system.today();
        mpRec.Well__c = well.Id;
            mpList.add(mpRec);
        }
        Insert mpList;

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
        
        Opportunity opp = [Select Id from Opportunity Limit 1];
        Tract__c Tract = [Select Id from Tract__c Limit 1];
        Subtract__c subtract = [Select Id from Subtract__c Limit 1];
		Unit__c unit = [Select Id from Unit__c Limit 1];
		Account acct = [Select Id from Account Limit 1];
        
        Test.StartTest();
        WellUnitUtil.getWellInfo(opp.Id);
        WellUnitUtil.getWellInfo(Tract.Id);
        WellUnitUtil.getWellInfo(subtract.id);
		WellUnitUtil.getWellInfo(unit.id);
		WellUnitUtil.getWellInfo(acct.id);
        Test.StopTest();
    }
}