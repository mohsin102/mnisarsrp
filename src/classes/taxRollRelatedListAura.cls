public with sharing class taxRollRelatedListAura  {
	@AuraEnabled
    public static List<TaxRollInterest__c> getTaxRollOwnerInterests(Id recordId) {
		List<TaxRollInterest__c> taxRollInterests = new List<TaxRollInterest__c>();
        taxRollInterests = [SELECT	account__c, calculatedInterest__c, countyName__c, CreatedById, CreatedDate, estimatedAcreage__c, Id, interest__c, interestType__c, IsDeleted, LastActivityDate,
						 LastModifiedById, LastModifiedDate, LastReferencedDate, LastViewedDate, legalDescription__c, Name, OwnerId, permitAcresUserOverride__c, permitsWithAcreage__c, rrcLease__c,
						 rrcLeaseNumber__c, SystemModstamp, taxRollOwner__c, taxRollOwnerName__c, taxValue__c, year__c, taxRollOwner__r.ownerName__c, rrcLease__r.Name, taxRollOwner__r.account__r.Name
						 FROM TaxRollInterest__c
						 WHERE taxRollOwner__c =: recordId
						 ORDER by Name
        ];
        return taxRollInterests;
    }

	@AuraEnabled
    public static List<TaxRollInterest__c> getRRCLeaseInterests(Id recordId) {
		List<TaxRollInterest__c> taxRollInterests = new List<TaxRollInterest__c>();
        taxRollInterests = [SELECT	account__c, calculatedInterest__c, countyName__c, CreatedById, CreatedDate, estimatedAcreage__c, Id, interest__c, interestType__c, IsDeleted, LastActivityDate,
						 LastModifiedById, LastModifiedDate, LastReferencedDate, LastViewedDate, legalDescription__c, Name, OwnerId, permitAcresUserOverride__c, permitsWithAcreage__c, rrcLease__c,
						 rrcLeaseNumber__c, SystemModstamp, taxRollOwner__c, taxRollOwnerName__c, taxValue__c, year__c, taxRollOwner__r.ownerName__c, rrcLease__r.Name, taxRollOwner__r.account__r.Name
						 FROM TaxRollInterest__c
						 WHERE rrcLease__c =: recordId
						 ORDER by Name
        ];
        return taxRollInterests;
    }

}