public class CaseRelatedListAura {
    @AuraEnabled
    public static List<Opportunity_Case__c> getCases(Id recordId) {
        List<Opportunity_Case__c> oppCaseList = new List<Opportunity_Case__c>();
        //caseList = [SELECT Id, CaseNumber, Type, Owner.Name, Owner.Id, Status, Priority, CreatedDate, ClosedDate FROM Case WHERE opportunity__c = :recordId];
        oppCaseList = [SELECT
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
}