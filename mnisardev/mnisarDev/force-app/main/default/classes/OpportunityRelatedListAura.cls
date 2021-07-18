public class OpportunityRelatedListAura {

    @AuraEnabled
    public static List<Opportunity_Case__c> getCaseOpps(Id recordId) {
        System.debug('recordId -----------------------> ' + recordId);
        List<Opportunity_Case__c> oppCaseList = new List<Opportunity_Case__c>();
        oppCaseList = [
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
                opportunity__r.Account.Id,
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
            WHERE case__c = :recordId
        ];
        System.debug('ocRecs -----------------------> ' + oppCaseList);
        return oppCaseList;
    }
}