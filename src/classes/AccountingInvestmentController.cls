public class AccountingInvestmentController {
 // test July 13, 2021
	
	// changeto in branch from git interface 
    @AuraEnabled
    public static  List<AccountingTransaction__c> getAccountingTransaction(Id recordId){
        List<AccountingTransaction__c> accountingTransactionList = new List<AccountingTransaction__c>();
        if(Schema.AccountingIntegrationJob__c.SObjectType == recordId.getSobjectType()){
            accountingTransactionList = [Select Id,Name,tradeDate__c,settleDate__c,costProceeds__c,
                                    transactionNumber__c, investment__c, investment__r.Name, transactionDescription__c,description__c,
                                    investmentTypeDescription__c, reconciliationType__c, quantity__c from AccountingTransaction__c
                                    Where accountingIntegrationJob__c =: recordId];
        }else if(Schema.AccountingInvestment__c.SObjectType == recordId.getSobjectType()){
            accountingTransactionList = [Select Id,Name,tradeDate__c,settleDate__c,costProceeds__c,
                                    transactionNumber__c, investment__c, investment__r.Name, transactionDescription__c,description__c,
                                    investmentTypeDescription__c, reconciliationType__c, quantity__c from AccountingTransaction__c
									 where investment__c =: recordId];
        }
        return accountingTransactionList;
    }

    
	@AuraEnabled
	public static List<AccountingInvestment__c> getAccountingInvestment(Id recordId){
				Set<Id> aiIds = new Set<Id>();
			   for(AccountingTransaction__c txn : [Select id, investment__c from AccountingTransaction__c
												Where accountingIntegrationJob__c =: recordId]){
               aiIds.add(txn.investment__c);
            
		}

		List<AccountingInvestment__c> accountingInvestmentList = [Select Id, Name, CreatedDate, LastModifiedDate, investmentID__c, totalCostProceedsAccounting__c
																	from AccountingInvestment__c where id in :aiIds];

		return accountingInvestmentList;
	}

	@AuraEnabled
    public static InventoryAssetSearchResult getSearchResults(String searchString, Integer searchCounter){
        InventoryAssetSearchResult response = new InventoryAssetSearchResult();
		response.searchCounter = searchCounter;
		List<InventoryAsset__c> inventoryAssets = new List<InventoryAsset__c>();
        //Escape special characters for SOSL search - order of replacement matters - if you replace all backslashes late, you will end up with double backslashes.
        //searchString = searchString.replaceAll('[|,|.|\\,||"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]', '-');
        searchString = searchString.replace('\\', '\\');
        searchString = String.escapeSingleQuotes(searchString);
        searchString = searchString.replace('-', '\\-');
        searchString = searchString.replace('+', '\\+');
        searchString = searchString.replace('&', '\\&');
        searchString = searchString.replace('|', '\\|');
        searchString = searchString.replace('!', '\\!');
        searchString = searchString.replace('{', '\\{');
        searchString = searchString.replace('}', '\\}');
        searchString = searchString.replace('[', '\\[');
        searchString = searchString.replace(']', '\\]');
        searchString = searchString.replace('(', '\\(');
        searchString = searchString.replace(')', '\\)');
        searchString = searchString.replace('^', '\\^');
        searchString = searchString.replace('~', '\\~');
        searchString = searchString.replace('*', '\\*');
        searchString = searchString.replace(':', '\\:');
        searchString = searchString.replace('\"', '\\"');
        
        String searchQuery = 'FIND {' + searchString + '} IN ALL FIELDS RETURNING InventoryAsset__c (Name,accountingInvestment__c,acquisitionOpportunityId__c,'+
													'acquisitionOpportunityName__c,acquisitionUnitPrice__c, acquisitionTotalPrice__c,acquisitionCloseDate__c,'+
													'acquisitionEffectiveDate__c,buyerNextOwnerId__c,buyerNextOwnerName__c,inventoryOwnerId__c,inventoryOwnerName__c,'+
													'saleCloseDate__c,saleEffectiveDate__c,saleOpportunityId__c,saleOpportunityName__c,saleTotalPrice__c,'+
													'sellerPreviousOwnerId__c,sellerPreviousOwnerName__c, saleUnitPrice__c  ORDER BY Name) LIMIT 50';
        
        List<List<SObject>>searchList = Search.query(searchQuery);
        for(SObject currentSObject:searchList[0]){
            InventoryAsset__c currentInventoryAsset = (InventoryAsset__c)currentSObject;
            inventoryAssets.add(currentInventoryAsset);
        }
		response.inventoryAssets = inventoryAssets;
        return response;
    }

	@AuraEnabled
	public static OpportunitySearchResult getOpportunitySearchResults(List<String> opportunityIds){
		OpportunitySearchResult response = new OpportunitySearchResult();
		List<Id> oppTractIds = new List<Id>();
		response.oppTracts = [Select Id, Name, Opportunity__c,Opportunity__r.Name,
                                            Tract__c,Tract__r.Name,OTG_Cost_Per_Acre__c,Total_Cost_Per_Acre__c,
                                            Total_Cost__c, Instrument_Type__c,Opportunity__r.CloseDate
                                            from Opportunity_Tract__C where Opportunity__c In: opportunityIds];
		for(Opportunity_Tract__c oppTract: response.oppTracts){
			oppTractIds.add(oppTract.Id);
		}
		response.inventoryAssets = [SELECT acquisitionOpportunityId__c,acquisitionOpportunityName__c,acquisitionUnitPrice__c, acquisitionTotalPrice__c,acquisitionCloseDate__c,
										acquisitionEffectiveDate__c,buyerNextOwnerId__c,buyerNextOwnerName__c,inventoryOwnerId__c,inventoryOwnerName__c,
										saleCloseDate__c,saleEffectiveDate__c,saleOpportunityId__c,saleOpportunityName__c,saleTotalPrice__c,
										sellerPreviousOwnerId__c,sellerPreviousOwnerName__c, Name, saleUnitPrice__c, accountingInvestment__c
									FROM InventoryAsset__c 
									WHERE assetAcquisition__c IN :oppTractIds
									OR assetAcquisitionOverride__c IN :oppTractIds
									OR assetSale__c IN :oppTractIds
									OR assetSaleOverride__c IN :oppTractIds];
		response.opps = [Select Id,Name from Opportunity Where Id In: opportunityIds];
		return response;
	}

	@AuraEnabled
    public static List<InventoryAsset__c> getInventoryAssets(Id recordId){
        List<InventoryAsset__c> response = [SELECT acquisitionOpportunityId__c,acquisitionOpportunityName__c,acquisitionUnitPrice__c, acquisitionTotalPrice__c,acquisitionCloseDate__c,
													acquisitionEffectiveDate__c,buyerNextOwnerId__c,buyerNextOwnerName__c,inventoryOwnerId__c,inventoryOwnerName__c,
													saleCloseDate__c,saleEffectiveDate__c,saleOpportunityId__c,saleOpportunityName__c,saleTotalPrice__c,
													sellerPreviousOwnerId__c,sellerPreviousOwnerName__c, Name, saleUnitPrice__c
												FROM InventoryAsset__c 
												WHERE accountingInvestment__c =:recordId];
        return response;                      
    }

	@AuraEnabled
    public static InventoryAsset__c getInventoryAsset(Id recordId){
        InventoryAsset__c response = [SELECT acquisitionOpportunityId__c,acquisitionOpportunityName__c,acquisitionUnitPrice__c, acquisitionTotalPrice__c,acquisitionCloseDate__c,
													acquisitionEffectiveDate__c,buyerNextOwnerId__c,buyerNextOwnerName__c,inventoryOwnerId__c,inventoryOwnerName__c,
													saleCloseDate__c,saleEffectiveDate__c,saleOpportunityId__c,saleOpportunityName__c,saleTotalPrice__c,
													sellerPreviousOwnerId__c,sellerPreviousOwnerName__c, Name, saleUnitPrice__c, assetAcquisition__c, assetSale__c
												FROM InventoryAsset__c 
												WHERE Id =:recordId
												LIMIT 1];
        return response;                      
    }
    
   /* @AuraEnabled
    public static opportunityTractWrapper getOpportunityTract(String recordId,List<String> opportunityIds){
        Set<Id> oppTractId = new Set<Id>();
        opportunityTractWrapper opportunityTractWrap = new opportunityTractWrapper();

        for(Opportunity_Tract__c oppTract : [Select Id, Name, Opportunity__c,Opportunity__r.Name,
                                            Tract__c,Tract__r.Name,OTG_Cost_Per_Acre__c,Total_Cost_Per_Acre__c,
                                            Total_Cost__c, Instrument_Type__c,Opportunity__r.CloseDate
                                            from Opportunity_Tract__c where accountingInvestment__c=:recordId]){
            oppTractId.add(oppTract.Id);
        }
        opportunityTractWrap.oppTracts = [Select Id, Name, Opportunity__c,Opportunity__r.Name,
                                            Tract__c,Tract__r.Name,OTG_Cost_Per_Acre__c,Total_Cost_Per_Acre__c,
                                            Total_Cost__c, Instrument_Type__c,Opportunity__r.CloseDate
                                            from Opportunity_Tract__C where Opportunity__c In: opportunityIds];
        opportunityTractWrap.selectedOppTracts = new List<Opportunity_Tract__c>();                                    
        
		for(Opportunity_Tract__c oppTract : opportunityTractWrap.oppTracts){
            if(!oppTractId.isEmpty() && oppTractId.contains(oppTract.Id)){
                opportunityTractWrap.selectedOppTracts.add(oppTract);
            }                               
        }
        opportunityTractWrap.opps = [Select Id,Name from Opportunity Where Id In: opportunityIds];
        return opportunityTractWrap;
    }
    @AuraEnabled
    public static void associateOpportunityTracts(Id recordId,List<String> oppTractIds){

        set<String> selectedOppTracts = new Set<String>(oppTractIds);
        List<Opportunity_Tract__c> otList = new List<Opportunity_Tract__c>();
        for(String otId :selectedOppTracts ){
            system.debug(otId);
            system.debug(recordId);
            otList.add(new Opportunity_Tract__c(Id=otId,accountingInvestment__c = recordId));
        }
        if(!otList.isEmpty()){
            update otList;
        }
    }*/

	@AuraEnabled
    public static void updateRecordAssociation(Id recordId,Id inventoryAssetId, String change){
		System.debug('udpateAssociation called with parameters recordId: ' + recordId + ' inventoryAssetId: ' + inventoryAssetId + ' change: ' + change);
		InventoryAsset__c currentInventoryAsset = new InventoryAsset__c();
		currentInventoryAsset.Id = inventoryAssetId;
        switch on change{
			when 'Remove-'{
				currentInventoryAsset.accountingInvestment__c = null;
			}
			when 'Add+'{
				currentInventoryAsset.accountingInvestment__c = recordId;
			}
		}
		update currentInventoryAsset;
    }

	public class InventoryAssetSearchResult{
		@AuraEnabled
		public List<InventoryAsset__c> inventoryAssets {get;set;}
		@AuraEnabled
		public Integer searchCounter {get;set;}

		public InventoryAssetSearchResult(){
			inventoryAssets = new List<InventoryAsset__c>();
			searchCounter = 0;
		}
	}
    
    public class opportunityTractWrapper{
        
        @AuraEnabled
        public List<Opportunity_Tract__c> oppTracts{get;set;}
        @AuraEnabled
        public List<Opportunity_Tract__c> selectedOppTracts{get;set;}
        @AuraEnabled
        public List<Opportunity> opps{get;set;}
        
    }

	public class OpportunitySearchResult{
		@AuraEnabled
		public List<InventoryAsset__c> inventoryAssets{get;set;}
		@AuraEnabled
		public List<Opportunity> opps{get;set;}
		@AuraEnabled
        public List<Opportunity_Tract__c> oppTracts{get;set;}

		public OpportunitySearchResult(){
			inventoryAssets = new List<InventoryAsset__c>();
			opps = new List<Opportunity>();
			oppTracts = new List<Opportunity_Tract__c>();
		}

	}
}
