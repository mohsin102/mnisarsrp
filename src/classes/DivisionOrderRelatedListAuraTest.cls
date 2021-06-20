@isTest
private class DivisionOrderRelatedListAuraTest {
    
    @TestSetup
    private static void makeData() {
        TestDataFactory.dataSetup();
        
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        testCase.Type = 'Division Order';

        divisionOrder__c testDivOrder = [
            SELECT Id
            FROM divisionOrder__c
            LIMIT 1
        ];
        testDivOrder.case__c = testCase.Id;
        update testCase;
        update testDivOrder;
    }

    @isTest
    private static void testMain() {
        Case cse = [
            SELECT Id
            FROM Case
            LIMIT 1
        ];
        List<divisionOrder__c> caseDivOrders = DivisionOrderRelatedListAura.getDivisionOrders(cse.Id);
        System.assert(caseDivOrders.size() > 0);
        String caseType = DivisionOrderRelatedListAura.getCaseRecType(cse.Id);
        System.assertEquals('Division Order', caseType);
    }
}