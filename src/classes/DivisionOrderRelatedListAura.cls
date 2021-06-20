public without sharing class DivisionOrderRelatedListAura {
    @AuraEnabled
    public static List<divisionOrder__c> getDivisionOrders(Id recordId) {
        List<divisionOrder__c> divisionOrderList = [
            SELECT
                Id,
                Name,
                status__c,
                account__c,
                CreatedById,
                CreatedDate,
                dateConfirmed__c,
                dateReceivedFromOperator__c,
                dateReturnedToOperator__c,
                operator__c,
                operator__r.Name,
                OwnerId,
                Owner.Name,
                priority__c,
                sharedDrivePath__c,
                CreatedBy.Name,
                LastModifiedById,
                case__r.Type,
                case__r.AccountId,
                case__r.Account.Name
            FROM divisionOrder__c
            WHERE case__c = :recordId
        ];

        return divisionOrderList;
    }

    @AuraEnabled
    public static String getCaseRecType(Id recordId) {
        Case caseRec = [SELECT Type FROM Case WHERE Id = :recordId LIMIT 1];
        return caseRec.Type;
    }
}