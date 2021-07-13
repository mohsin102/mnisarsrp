public class ManageCasesAura {
    @AuraEnabled
    public static List<Opportunity_Case__c> getCases(Id recordId) {
        List<Opportunity_Case__c> oppCaseList = new List<Opportunity_Case__c>();

        oppCaseList = [
            SELECT
                Id,
                case__c,
                case__r.Subject,
                case__r.CaseNumber,
                case__r.Type,
                case__r.Owner.Name,
                case__r.Owner.Id,
                case__r.Status,
                case__r.Priority,
                case__r.CreatedDate,
                case__r.ClosedDate
            FROM Opportunity_Case__c
            WHERE Opportunity__c = :recordId
        ];
        return oppCaseList;
    }
    @AuraEnabled
    public static List<Opportunity_Case__c> getCaseSearchResults(
        List<String> caseIds,
        Id recordId
    ) {
        List<Opportunity_Case__c> oppCaseList = new List<Opportunity_Case__c>();
        Map<Id, Opportunity_Case__c> oppCaseMap = new Map<Id, Opportunity_Case__c>();
        List<Id> oppCaseIds = new List<Id>();

        oppCaseList = getCases(recordId);
		
        for (Opportunity_Case__c oc : oppCaseList) {
            oppCaseMap.put(oc.case__c, oc);
        }

        if (oppCaseMap.containsKey(caseIds[0])) {
            return oppCaseList;
        }

        Case[] cseLst = [
            SELECT
                Id,
                CaseNumber,
                Subject,
                Type,
                Owner.Name,
                Owner.Id,
                Status,
                Priority,
                CreatedDate,
                ClosedDate
            FROM Case
            WHERE Id = :caseIds
        ];

        try {
            if (cseLst.size() > 0) {
                insert new Opportunity_Case__c(
                    case__c = cseLst[0].Id,
                    opportunity__c = recordId
                );
            }
            return getCases(recordId);
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
            return getCases(recordId);
        } catch (exception e) {
            System.debug('EXCEPTION: ' + e);
            return null;
        }
    }
}