public class ManageOpportunitiesAura {
    @AuraEnabled
    public static List<Opportunity_Case__c> getOpportunities(Id recordId) {
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

        return oppCaseList;
    }

    @AuraEnabled
    public static List<Opportunity_Case__c> getOpportunitySearchResults(List<String> oppIds,Id recordId) {
        List<Opportunity_Case__c> oppCaseList = new List<Opportunity_Case__c>();
        Map<Id, Opportunity_Case__c> oppCaseMap = new Map<Id, Opportunity_Case__c>();
        List<Id> oppCaseIds = new List<Id>();

        oppCaseList = getOpportunities(recordId);

        for (Opportunity_Case__c oc : oppCaseList) {
            oppCaseMap.put(oc.opportunity__c, oc);
        }

        if (oppCaseMap.containsKey(oppIds[0])) {
            return oppCaseList;
        }

        Opportunity[] oppLst = [
            SELECT
            Id,
            Name,
            StageName,
            Acquiring_Entity__r.Name,
            Acquiring_Entity__c,
            Type,
            Account.Name,
            Account.Id,
            AccountId,
            PSA_Date__c,
            CloseDate,
            Effective_Date__c,
            Owner.Name,
            OwnerId,
            totalPricePerAcre__c,
            totalPrice__c,
            askTotalPricePerAcre__c,
            askTotalPrice__c
            FROM Opportunity
            WHERE Id = :oppIds
        ];

        try {
            if (oppLst.size() > 0) {
                insert new Opportunity_Case__c(
                    opportunity__c = oppLst[0].Id,
                    case__c = recordId
                );
            }
            return getOpportunities(recordId);
        } catch (exception e) {
            System.debug('EXCEPTION: ' + e);
            return null;
        }
    }

    @AuraEnabled
    public static List<Opportunity_Case__c> updateRecordAssociation(
        Id recordId,
        Id oppCaseId
    ) {
        System.debug(
            'delete OppCase called with parameters recordId: ' +
            recordId +
            ' oppCaseId: ' +
            oppCaseId
        );
        Opportunity_Case__c oppCaseToDelete = new Opportunity_Case__c();
        oppCaseToDelete.Id = oppCaseId;
        try {
            System.debug('oppCaseToDelete is -----------> ' + oppCaseToDelete);
            delete oppCaseToDelete;
            return getOpportunities(recordId);
        } catch (exception e) {
            System.debug('EXCEPTION: ' + e);
            return null;
        }
    }
}