@isTest
public class OpportunityRelatedListAuraTest {
    static testMethod void testOpportunityRelatedList() {
        TestDataFactory.dataSetup();

        Case c = [SELECT Id FROM Case LIMIT 1];
        Opportunity o = [SELECT Id FROM Opportunity LIMIT 1];
        o.Type = 'Acquisition';
        o.PSA_Date__c = Date.today() + 15;
        o.Effective_Date__c = Date.today() + 15;
        o.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Acquisition').getRecordTypeId();
        update o;
        Opportunity_Case__c oc = [
            SELECT
                Id,
                Name,
                opportunity__c,
                opportunity__r.Name,
                opportunity__r.StageName,
                opportunity__r.Acquiring_Entity__r.Name,
                opportunity__r.Acquiring_Entity__c,
                opportunity__r.Type,
                opportunity__r.Account.Name,
                opportunity__r.AccountId,
                opportunity__r.PSA_Date__c,
                opportunity__r.CloseDate,
                opportunity__r.Effective_Date__c,
                opportunity__r.Owner.Name,
                opportunity__r.OwnerId,
                opportunity__r.totalPricePerAcre__c,
                opportunity__r.totalPrice__c,
                opportunity__r.askTotalPricePerAcre__c,
                opportunity__r.askTotalPrice__c
            FROM Opportunity_Case__c
            LIMIT 1
        ];

        System.assert(c != null);
        System.assert(o != null);
        System.assert(oc != null);

        Test.startTest();
        OpportunityRelatedListAura.getCaseOpps(c.Id);
        Test.stopTest();
    }
}