public class OpportunityTractTriggerHelper{

    public static void updateRelatedTractRecords(List<Opportunity_Tract__c> newRecords){

        Map<Id,Tract__c> tractMap = new Map<Id,Tract__c>();
        Tract__c tractRec;
        for(Opportunity_Tract__c oppTractRec: [Select Id, Opportunity__c,Tract__c,Opportunity__r.StageName,
                                              Opportunity__r.Type,Opportunity__r.Effective_Date__c,Opportunity__r.Account.Type,
                                              Opportunity__r.Acquiring_Entity__r.Type, Tract__r.Acquisition_Opportunity__c, Tract__r.Divestiture_Opportunity__c
                                               From Opportunity_Tract__c Where Id In: newRecords]){

            tractRec = new Tract__c();
            if(oppTractRec.Opportunity__r.Type == 'Acquisition' &&
                    oppTractRec.Opportunity__r.Effective_Date__c != null && 
                    (oppTractRec.Opportunity__r.StageName== 'Closed Won')){
						if(oppTractRec.Tract__r.Acquisition_Opportunity__c != oppTractRec.Opportunity__c){
							oppTractRec.Tract__r.Acquisition_Opportunity__c = oppTractRec.Opportunity__c;
							tractMap.put(oppTractRec.Tract__c,oppTractRec.Tract__r);
						}
			}
            else if(oppTractRec.Opportunity__r.Type == 'Divestiture' &&
                    oppTractRec.Opportunity__r.Effective_Date__c != null && 
                    (oppTractRec.Opportunity__r.StageName== 'Closed Won')){
						if(oppTractRec.Tract__r.Divestiture_Opportunity__c != oppTractRec.Opportunity__c){
							oppTractRec.Tract__r.Divestiture_Opportunity__c = oppTractRec.Opportunity__c;
							tractMap.put(oppTractRec.Tract__c,oppTractRec.Tract__r);
						}
                }
        }
        if(!tractMap.values().isEmpty()){
            update tractMap.values();
        }
    }

	public static void recalcInventoryAssets(List<Opportunity_Tract__ChangeEvent> newList, Map<Id, Opportunity_Tract__ChangeEvent> newMap){
		List<String> priceChange = new List<String>();
		for (Opportunity_Tract__ChangeEvent oTCE: newList) {
			EventBus.ChangeEventHeader header = oTCE.ChangeEventHeader;
			if(header.changedFields.contains('unitPrice__c')){
				System.debug('Contains price change');
				priceChange.addAll(header.recordids);
			}
			
			
			//System.debug('Received change event for ' + header.entityName +
            //        ' for the ' + header.changeType + ' operation.'); 
			//System.debug('header change type is: ' + header.getChangeType());
			//System.debug('recordIds value is: ' + header.getRecordIds());
			//System.debug('Difffields value is: ' + header.getDiffFields());
			//System.debug('nulledFields value is: ' + header.nulledfields);
			//System.debug('changedFields value is: ' + header.changedfields);
			//priceChange.add(oT.Id);
        }
		//Get list of related Inventory Assets and trigger an update so that the Rollup Helper fields on Accounting Investment (totalCostBasisInventoryAssets__c
		//and totalSalesProceedsInventoryAssets__c) will update.
		List<InventoryAsset__c> inventoryAssetUpdates = [SELECT Id FROM InventoryAsset__c 
														 WHERE assetAcquisition__c IN :priceChange
														 OR assetAcquisitionOverride__c IN :priceChange
														 OR assetSale__c IN :priceChange
														 OR assetSaleOverride__c IN :priceChange];
		if (inventoryAssetUpdates.size() > 0){
			update inventoryAssetUpdates;
		}
	}

	public static void recalcByOppTract(List<Opportunity_Tract__c> newOppTracts)
    {
        System.debug('recalc opp called');
        if (newOppTracts != null && newOppTracts.size() > 0)
        {
            Set<Id> tractIds = new Set<Id>();
            for (Opportunity_Tract__c ct : newOppTracts)
            {
				System.debug('Tract ID is: ' + ct.Tract__c + ' Opportunity Tract Id is: ' + ct.Id );
                tractIds.add(ct.Tract__c);
            }

            Map<Id,Tract__c> tractMap = TractTriggerHelper.getTractsbyIds(tractIds);


            for (Opportunity_Tract__c ot : newOppTracts)
            {
                setOppTractFields(ot,tractMap.get(ot.Tract__c));
            }
        }
    }

	    private static void setOppTractFields(Opportunity_Tract__c ot, Tract__c tract)
    {
        //ot.Commission_Amount__c = tract.Commission_Amount__c;
        ot.FMV_Per_Acre__c = tract.Value_Per_Acre__c;
        ot.OTG_Cost_Per_Acre__c = tract.OTG_Cost_Per_Acre__c;
        //ot.Other_Capitalized_Costs__c = tract.Other_Capitalized_Costs__c;
        //ot.Title_Cost__c = tract.Title_Cost__c;
        ot.Total_Cost__c = tract.Total_Cost__c;
        ot.Total_Cost_Per_Acre__c = tract.Total_Cost_Per_Acre__c;
        ot.Tract_Acres__c = tract.netAcres__c;
        ot.OTG_Cost__c = tract.OTG_Cost__c;
        ot.Notes__c = tract.Notes__c;
        ot.Gain_on_Asset__c = tract.Gain_on_Asset__c;
    }


}