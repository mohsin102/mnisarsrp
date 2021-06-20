public with sharing class IAInformationAura  {
	
	@AuraEnabled
    public static InventoryAsset__c getInventoryAsset(Id recordId) {
		InventoryAsset__c response = [SELECT Id, Name, assetAcquisition__c, assetAcquisitionOverride__c, assetSale__c, assetSaleOverride__c, 
										assetAcquisition__r.Opportunity__r.Acquiring_Entity__c,
										assetAcquisition__r.Opportunity__r.Acquiring_Entity__r.Name,
										assetAcquisition__r.Opportunity__r.Effective_Date__c,
										assetAcquisition__r.Opportunity__r.CloseDate,
										assetAcquisition__r.totalPrice__c,
										assetAcquisition__r.Opportunity__c,
										assetAcquisition__r.Opportunity__r.Name,
										assetAcquisition__r.Opportunity__r.AccountId,
										assetAcquisition__r.Opportunity__r.Account.Name,
										assetAcquisitionOverride__r.Opportunity__r.Effective_Date__c,
										assetAcquisitionOverride__r.Opportunity__r.CloseDate,
										assetAcquisitionOverride__r.totalPrice__c,
										assetAcquisitionOverride__r.Opportunity__c,
										assetAcquisitionOverride__r.Opportunity__r.Name,
										assetAcquisitionOverride__r.Opportunity__r.AccountId,
										assetAcquisitionOverride__r.Opportunity__r.Account.Name,
										assetSale__r.Opportunity__r.Effective_Date__c,
										assetSale__r.Opportunity__r.CloseDate,
										assetSale__r.totalPrice__c,
										assetSale__r.Opportunity__c,
										assetSale__r.Opportunity__r.Name,
										assetSale__r.Opportunity__r.Acquiring_Entity__c,
										assetSale__r.Opportunity__r.Acquiring_Entity__r.Name,
										assetSaleOverride__r.Opportunity__r.Effective_Date__c,
										assetSaleOverride__r.Opportunity__r.CloseDate,
										assetSaleOverride__r.totalPrice__c,
										assetSaleOverride__r.Opportunity__c,
										assetSaleOverride__r.Opportunity__r.Name,
										assetSaleOverride__r.Opportunity__r.Acquiring_Entity__c,
										assetSaleOverride__r.Opportunity__r.Acquiring_Entity__r.Name
									   FROM InventoryAsset__c 
									   WHERE Id = :recordId
									   LIMIT 1];
        return response;
    }


}