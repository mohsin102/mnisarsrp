({
	currentRecordChange: function (component, event, helper) {
		var detailType = component.get('v.detailType');
		var currentRecord = component.get('v.currentRecord');
		//console.log(currentRecord);
		switch(detailType){
			case 'Acquisition':
				component.set('v.relatedAccountLabel', 'Seller (Previous Owner)');
				if(currentRecord.assetAcquisition__c){
					component.set('v.hasDetail', true);
					component.set('v.effectiveDate', currentRecord.acquisitionEffectiveDate__c);
					component.set('v.closeDate', currentRecord.acquisitionCloseDate__c);
					component.set('v.opportunityName', currentRecord.acquisitionOpportunityName__c);
					component.set('v.opportunityLink', '/' + currentRecord.acquisitionOpportunityId__c);
					component.set('v.price', currentRecord.acquisitionTotalPrice__c);
					component.set('v.relatedAccountName', currentRecord.sellerPreviousOwnerName__c);
					component.set('v.relatedAccountLink', '/' + currentRecord.sellerPreviousOwnerId__c);
				}
				else{
					component.set('v.hasDetail', false);
				}
				/*if (currentRecord.assetAcquisitionOverride__c){
					component.set('v.hasDetail', true);
					component.set('v.effectiveDate', currentRecord.assetAcquisitionOverride__r.Opportunity__r.Effective_Date__c);
					component.set('v.closeDate', currentRecord.assetAcquisitionOverride__r.Opportunity__r.CloseDate);
					component.set('v.opportunityName', currentRecord.assetAcquisitionOverride__r.Opportunity__r.Name);
					component.set('v.opportunityLink', '/' + currentRecord.assetAcquisitionOverride__r.Opportunity__c);
					component.set('v.price', currentRecord.assetAcquisitionOverride__r.totalPrice__c);
					component.set('v.relatedAccountName', currentRecord.assetAcquisitionOverride__r.Opportunity__r.Account.Name);
					component.set('v.relatedAccountLink', '/' + currentRecord.assetAcquisitionOverride__r.Opportunity__r.AccountId);

				}
				else if(currentRecord.assetAcquisition__c){
					component.set('v.hasDetail', true);
					component.set('v.effectiveDate', currentRecord.assetAcquisition__r.Opportunity__r.Effective_Date__c);
					component.set('v.closeDate', currentRecord.assetAcquisition__r.Opportunity__r.CloseDate);
					component.set('v.opportunityName', currentRecord.assetAcquisition__r.Opportunity__r.Name);
					component.set('v.opportunityLink', '/' + currentRecord.assetAcquisition__r.Opportunity__c);
					component.set('v.price', currentRecord.assetAcquisition__r.totalPrice__c);
					component.set('v.relatedAccountName', currentRecord.assetAcquisition__r.Opportunity__r.Account.Name);
					component.set('v.relatedAccountLink', '/' + currentRecord.assetAcquisition__r.Opportunity__r.AccountId);
				}*/
				
				break;
			case 'Sale':
				component.set('v.relatedAccountLabel', 'Buyer (Next Owner)');
				if(currentRecord.assetSale__c){
					component.set('v.hasDetail', true);
					component.set('v.effectiveDate', currentRecord.saleEffectiveDate__c);
					component.set('v.closeDate', currentRecord.saleCloseDate__c);
					component.set('v.opportunityName', currentRecord.saleOpportunityName__c);
					component.set('v.opportunityLink', '/' + currentRecord.saleOpportunityId__c);
					component.set('v.price', currentRecord.saleTotalPrice__c);
					component.set('v.relatedAccountName', currentRecord.buyerNextOwnerName__c);
					component.set('v.relatedAccountLink', '/' + currentRecord.buyerNextOwnerId__c);
				}
				else{
					//component.set('v.hasDetail', false);
				}
				break;
		}
	}
})