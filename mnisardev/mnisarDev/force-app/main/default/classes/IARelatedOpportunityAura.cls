public class IARelatedOpportunityAura  {

	@AuraEnabled
	public static IARelatedOpportunity getRelatedOpp(Id recordId, String relatedField){
		IARelatedOpportunity response = new IARelatedOpportunity();
		String referenceField = relatedField.replace('__c', '__r');
		InventoryAsset__c currentRecord = [SELECT Id, Name, assetAcquisition__c, assetAcquisitionOverride__c, assetSale__c, assetSaleOverride__c,
											   assetAcquisition__r.Name, assetAcquisition__r.unitPrice__c, assetAcquisition__r.totalPrice__c,
											   assetAcquisition__r.Opportunity__c, assetAcquisition__r.Opportunity__r.Name,
											   assetAcquisition__r.Opportunity__r.AccountId, assetAcquisition__r.Opportunity__r.Account.Name,
											   assetAcquisition__r.Opportunity__r.Acquiring_Entity__c, assetAcquisition__r.Opportunity__r.Acquiring_Entity__r.Name,
											   assetAcquisition__r.Opportunity__r.Effective_Date__c, assetAcquisition__r.Opportunity__r.CloseDate,
											   assetAcquisition__r.Opportunity__r.Organizational_Transfer__c,
											   assetAcquisitionOverride__r.Name, assetAcquisitionOverride__r.unitPrice__c, assetAcquisitionOverride__r.totalPrice__c,
											   assetAcquisitionOverride__r.Opportunity__c, assetAcquisitionOverride__r.Opportunity__r.Name,
											   assetAcquisitionOverride__r.Opportunity__r.AccountId, assetAcquisitionOverride__r.Opportunity__r.Account.Name,
											   assetAcquisitionOverride__r.Opportunity__r.Acquiring_Entity__c, assetAcquisitionOverride__r.Opportunity__r.Acquiring_Entity__r.Name,
											   assetAcquisitionOverride__r.Opportunity__r.Effective_Date__c, assetAcquisitionOverride__r.Opportunity__r.CloseDate,
											   assetAcquisitionOverride__r.Opportunity__r.Organizational_Transfer__c,
											   assetSale__r.Name, assetSale__r.unitPrice__c, assetSale__r.totalPrice__c,
											   assetSale__r.Opportunity__c, assetSale__r.Opportunity__r.Name,
											   assetSale__r.Opportunity__r.AccountId, assetSale__r.Opportunity__r.Account.Name,
											   assetSale__r.Opportunity__r.Acquiring_Entity__c, assetSale__r.Opportunity__r.Acquiring_Entity__r.Name,
											   assetSale__r.Opportunity__r.Effective_Date__c, assetSale__r.Opportunity__r.CloseDate,
											   assetSale__r.Opportunity__r.Organizational_Transfer__c,
											   assetSaleOverride__r.Name, assetSaleOverride__r.unitPrice__c, assetSaleOverride__r.totalPrice__c,
											   assetSaleOverride__r.Opportunity__c, assetSaleOverride__r.Opportunity__r.Name,
											   assetSaleOverride__r.Opportunity__r.AccountId, assetSaleOverride__r.Opportunity__r.Account.Name,
											   assetSaleOverride__r.Opportunity__r.Acquiring_Entity__c, assetSaleOverride__r.Opportunity__r.Acquiring_Entity__r.Name,
											   assetSaleOverride__r.Opportunity__r.Effective_Date__c, assetSaleOverride__r.Opportunity__r.CloseDate,
											   assetSaleOverride__r.Opportunity__r.Organizational_Transfer__c
										   FROM InventoryAsset__c 
										   WHERE Id = :recordId 
										   LIMIT 1];

		/*response.oppId = currentRecord.get(referenceField).get('Opportunity__c');
		response.oppName = currentRecord.get(Schema.InventoryAsset__c.referenceField).Opportunity__r.Name;
		response.oppTractId = currentRecord.get(Schema.InventoryAsset__c.relatedField);
		response.oppTractName = currentRecord.get(Schema.InventoryAsset__c.referenceField).Name;
		response.acqEntityId = currentRecord.get(Schema.InventoryAsset__c.referenceField).Opportunity__r.Acquiring_Entity__r.Id;
		response.acqEntityName = currentRecord.get(Schema.InventoryAsset__c.referenceField).Opportunity__r.Acquiring_Entity__r.Name;
		response.sellEntityId = currentRecord.get(Schema.InventoryAsset__c.referenceField).Opportunity__r.AccountId;
		response.sellEntityName = currentRecord.get(Schema.InventoryAsset__c.referenceField).Opportunity__r.Account.Name;
		response.effectiveDate = currentRecord.get(Schema.InventoryAsset__c.referenceField).Opportunity__r.Effective_Date__c;
		response.closeDate = currentRecord.get(Schema.InventoryAsset__c.referenceField).Opportunity__r.CloseDate;
		response.unitPrice = currentRecord.get(Schema.InventoryAsset__c.referenceField).unitPrice__c;
		response.totalPrice = currentRecord.get(Schema.InventoryAsset__c.referenceField).totalPrice__c;*/
		
		switch on relatedField {
			when 'assetAcquisition__c' {
				response.oppId = currentRecord.assetAcquisition__r.Opportunity__c;
				response.oppName = currentRecord.assetAcquisition__r.Opportunity__r.Name;
				response.oppTractId = currentRecord.assetAcquisition__c;
				response.oppTractName = currentRecord.assetAcquisition__r.Name;
				response.acqEntityId = currentRecord.assetAcquisition__r.Opportunity__r.Acquiring_Entity__r.Id;
				response.acqEntityName = currentRecord.assetAcquisition__r.Opportunity__r.Acquiring_Entity__r.Name;
				response.sellEntityId = currentRecord.assetAcquisition__r.Opportunity__r.AccountId;
				response.sellEntityName = currentRecord.assetAcquisition__r.Opportunity__r.Account.Name;
				response.effectiveDate = currentRecord.assetAcquisition__r.Opportunity__r.Effective_Date__c;
				response.closeDate = currentRecord.assetAcquisition__r.Opportunity__r.CloseDate;
				response.unitPrice = currentRecord.assetAcquisition__r.unitPrice__c == null?0:currentRecord.assetAcquisition__r.unitPrice__c;
				response.totalPrice = currentRecord.assetAcquisition__r.totalPrice__c == null?0:currentRecord.assetAcquisition__r.totalPrice__c;
				response.organizationalTransfer = currentRecord.assetAcquisition__r.Opportunity__r.Organizational_Transfer__c;
				if(currentRecord.assetAcquisitionOverride__c != null || currentRecord.assetAcquisition__c == null){
					response.inactive = true;
				}
			}	
			when 'assetAcquisitionOverride__c' {
				response.oppId = currentRecord.assetAcquisitionOverride__r.Opportunity__c;
				response.oppName = currentRecord.assetAcquisitionOverride__r.Opportunity__r.Name;
				response.oppTractId = currentRecord.assetAcquisitionOverride__c;
				response.oppTractName = currentRecord.assetAcquisitionOverride__r.Name;
				response.acqEntityId = currentRecord.assetAcquisitionOverride__r.Opportunity__r.Acquiring_Entity__r.Id;
				response.acqEntityName = currentRecord.assetAcquisitionOverride__r.Opportunity__r.Acquiring_Entity__r.Name;
				response.sellEntityId = currentRecord.assetAcquisitionOverride__r.Opportunity__r.AccountId;
				response.sellEntityName = currentRecord.assetAcquisitionOverride__r.Opportunity__r.Account.Name;
				response.effectiveDate = currentRecord.assetAcquisitionOverride__r.Opportunity__r.Effective_Date__c;
				response.closeDate = currentRecord.assetAcquisitionOverride__r.Opportunity__r.CloseDate;
				response.unitPrice = currentRecord.assetAcquisitionOverride__r.unitPrice__c == null?0:currentRecord.assetAcquisitionOverride__r.unitPrice__c;
				response.totalPrice = currentRecord.assetAcquisitionOverride__r.totalPrice__c == null?0:currentRecord.assetAcquisitionOverride__r.totalPrice__c;
				response.organizationalTransfer = currentRecord.assetAcquisitionOverride__r.Opportunity__r.Organizational_Transfer__c;
				if(currentRecord.assetAcquisitionOverride__c == null){
					response.inactive = true;
				}
			}
			when 'assetSale__c' {
				response.oppId = currentRecord.assetSale__r.Opportunity__c;
				response.oppName = currentRecord.assetSale__r.Opportunity__r.Name;
				response.oppTractId = currentRecord.assetSale__c;
				response.oppTractName = currentRecord.assetSale__r.Name;
				response.acqEntityId = currentRecord.assetSale__r.Opportunity__r.Acquiring_Entity__r.Id;
				response.acqEntityName = currentRecord.assetSale__r.Opportunity__r.Acquiring_Entity__r.Name;
				response.sellEntityId = currentRecord.assetSale__r.Opportunity__r.AccountId;
				response.sellEntityName = currentRecord.assetSale__r.Opportunity__r.Account.Name;
				response.effectiveDate = currentRecord.assetSale__r.Opportunity__r.Effective_Date__c;
				response.closeDate = currentRecord.assetSale__r.Opportunity__r.CloseDate;
				response.unitPrice = currentRecord.assetSale__r.unitPrice__c == null?0:currentRecord.assetSale__r.unitPrice__c;
				response.totalPrice = currentRecord.assetSale__r.totalPrice__c == null?0:currentRecord.assetSale__r.totalPrice__c;
				response.organizationalTransfer = currentRecord.assetSale__r.Opportunity__r.Organizational_Transfer__c;
				if(currentRecord.assetSaleOverride__c != null  || currentRecord.assetSale__c == null){
					response.inactive = true;
				}
			}
			when 'assetSaleOverride__c' {
				response.oppId = currentRecord.assetSaleOverride__r.Opportunity__c;
				response.oppName = currentRecord.assetSaleOverride__r.Opportunity__r.Name;
				response.oppTractId = currentRecord.assetSaleOverride__c;
				response.oppTractName = currentRecord.assetSaleOverride__r.Name;
				response.acqEntityId = currentRecord.assetSaleOverride__r.Opportunity__r.Acquiring_Entity__r.Id;
				response.acqEntityName = currentRecord.assetSaleOverride__r.Opportunity__r.Acquiring_Entity__r.Name;
				response.sellEntityId = currentRecord.assetSaleOverride__r.Opportunity__r.AccountId;
				response.sellEntityName = currentRecord.assetSaleOverride__r.Opportunity__r.Account.Name;
				response.effectiveDate = currentRecord.assetSaleOverride__r.Opportunity__r.Effective_Date__c;
				response.closeDate = currentRecord.assetSaleOverride__r.Opportunity__r.CloseDate;
				response.unitPrice = currentRecord.assetSaleOverride__r.unitPrice__c == null?0:currentRecord.assetSaleOverride__r.unitPrice__c;
				response.totalPrice = currentRecord.assetSaleOverride__r.totalPrice__c == null?0:currentRecord.assetSaleOverride__r.totalPrice__c;
				response.organizationalTransfer = currentRecord.assetSaleOverride__r.Opportunity__r.Organizational_Transfer__c;
				if(currentRecord.assetSaleOverride__c == null){
					response.inactive = true;
				}
			}
		}
		return response;

	}

	public class IARelatedOpportunity{
		@AuraEnabled public String oppName {get;set;}
		@AuraEnabled public String oppId {get;set;}
		@AuraEnabled public String oppTractName {get;set;}
		@AuraEnabled public String oppTractId {get;set;}
		@AuraEnabled public String acqEntityName {get;set;}
		@AuraEnabled public String acqEntityId {get;set;}
		@AuraEnabled public String sellEntityName {get;set;}
		@AuraEnabled public String sellEntityId {get;set;}
		@AuraEnabled public date effectiveDate {get;set;}
		@AuraEnabled public date closeDate {get; set;}
		@AuraEnabled public Double unitPrice {get; set;}
		@AuraEnabled public Double totalPrice {get; set;}
		@AuraEnabled public Boolean inactive{get; set;}
		@AuraEnabled public Boolean organizationalTransfer{get;set;}

		public IARelatedOpportunity(){
			oppName = '';
			oppId = '';
			oppTractName = '';
			oppTractId = '';
			acqEntityName = '';
			acqEntityId = '';
			sellEntityName = '';
			sellEntityId = '';
			unitPrice = 0.00;
			totalPrice = 0.00;
			inactive = false;
			organizationalTransfer = false;
		}
	}


}