public with sharing class OpportunityTriggerHelper {
    
    /*/* Removing code to prevent delete per Quin.  This check was intended to work with transaction logic that was 
		 never implemented. (jdg 02-10-2020)
	public static void PreventDelete(List<Opportunity> oldOpps, Map<Id,Opportunity> oldMap)
    {
        if (oldOpps != null) {
            Map<Id,Opportunity> lockedOppMap = new Map<Id,Opportunity>([SELECT Id FROM Opportunity WHERE Locked__c = TRUE AND Id IN: oldMap.keySet()]);
            for (Opportunity o : oldOpps) {
                if (lockedOppMap.containsKey(o.Id)) {
                    o.addError('Opportunity is locked and may not be deleted');
                }
            }
        }
    }*/
    
    public static void UpdateRelatedTracts(List<Opportunity> oldOpps, Map<Id,Opportunity> oldMap, List<Opportunity> newOpps, Map<Id, Opportunity> newMap)
    {
        // Track opps closed in this pass
        Map<Id,Opportunity> closedMap = new Map<Id,Opportunity>();
        // See if we need to do anything first
        for (Opportunity o: newOpps) {
            // Do this only if this is a new Opportunity or Stage has changed in an update
            if (oldOpps == null || (oldOpps != null && (o.StageName != oldMap.get(o.Id).StageName || o.Type != oldMap.get(o.Id).Type))) {
                // If this was CLOSED and new or changed
                if (o.StageName == 'Closed Won') { 
                    // Mark the item for processing
                    if (!closedMap.containsKey(o.Id))
                    {
                        closedMap.put(o.Id,o);
                    }
                }
            }
        }
            // Now find related items based on the Closed Won opportunities above and assign owner, then set status to Purchased.
            Map<Id,Tract__c> tractMap = new Map<Id,Tract__c>();
            List<Opportunity_Tract__c> oppTracts = [SELECT Id,Name,Opportunity__c,Tract__r.Id, Opportunity__r.Acquiring_Entity__c,
													Tract__r.Account__c
                                                    FROM Opportunity_Tract__c WHERE Opportunity__c IN: closedMap.keySet()];
            for (Opportunity_Tract__c t : oppTracts) {
				//Define new values
				//String srpStatus = 'Purchased';
				String buyerAccount = closedMap.get(t.Opportunity__c).Acquiring_Entity__c;
                
				// Replace the owner on the tract
                if(t.Tract__r.Account__c != buyerAccount){
					t.Tract__r.Account__c = buyerAccount;
					tractMap.put(t.Tract__r.Id, t.Tract__r);

				}
            }   
			
			if(oldOpps != null){
				updateTractRecords(newOpps, oldOpps, newMap, oldMap, tractMap);
			}  
			
            if(!tractMap.values().isEmpty()){
				update tractMap.values();
			}
    }

    public static void updateTractRecords(List<Opportunity> newOpps, List<Opportunity> oldOpps, Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap, Map<Id,Tract__c> tractMap){
        
        Set<Id> updatedOpps = new Set<Id>();
        for(Opportunity opp: newOpps){
			System.debug('Id: ' + opp.Id + ' old Effective: ' + oldMap.get(opp.Id).Effective_Date__c + ' new Effective: ' + opp.Effective_Date__c + ' old Stage: ' + oldMap.get(opp.Id).StageName + ' New Stage: ' + opp.StageName);  
            //If update and Effective Date has changed or StageName has changed.
			//Effective Date is populated and Stage is Closed Won
			if((opp.Effective_Date__c != null) && ((opp.StageName == 'Closed Won'))) {
				//Effective Date or Stage Name is changed
				if((oldMap.get(opp.Id).Effective_Date__c != opp.Effective_Date__c)||(oldMap.get(opp.Id).StageName != opp.StageName)||(oldMap.get(opp.Id).Type != opp.Type)) {
                    updatedOpps.add(opp.Id);
				}
            }
        }
        if(!updatedOpps.isEmpty()){
            updateTractRecords(updatedOpps, oldMap, newMap, tractMap);
        }
    }
    
    public static void updateTractRecords(Set<Id> opportunityIds,Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap, Map<Id,Tract__c> tractMap){
        
		System.debug('updateTractRecords called.');
		for(Id oppId: opportunityIds){
			System.debug(oppId);
		}
		
        //Map<Id,Tract__c> tractMap = new Map<Id,Tract__c>();
        Tract__c tractRec;
        for(Opportunity_Tract__c oppTractRec  : [Select Id, Opportunity__c,Tract__c,Opportunity__r.StageName, Tract__r.Id, 
												 Tract__r.Acquisition_Opportunity__c, Tract__r.Divestiture_Opportunity__c,
                                                 Opportunity__r.Type,Opportunity__r.Effective_Date__c,Opportunity__r.Account.Type
                                                 From Opportunity_Tract__c Where Opportunity__c In: opportunityIds]){
													 //If the Opportunity type has changed, prepare to clear the related fields
													 if(oldMap.get(oppTractRec.Opportunity__c).Type != newMap.get(oppTractRec.Opportunity__c).Type){
														if(oldMap.get(oppTractRec.Opportunity__c).Type == 'Acquisition' && oppTractRec.Tract__r.Acquisition_Opportunity__c == oldMap.get(oppTractRec.Opportunity__c).Id){
															if(tractMap.containsKey(oppTractRec.Tract__r.Id)){
																tractMap.get(oppTractRec.Tract__r.Id).Acquisition_Opportunity__c = Null;
															}
															else{
																oppTractRec.Tract__r.Acquisition_Opportunity__c = Null;
																tractMap.put(oppTractRec.Tract__r.Id, oppTractRec.Tract__r);
															}
														}
														if(oldMap.get(oppTractRec.Opportunity__c).Type == 'Divestiture' && oppTractRec.Tract__r.Divestiture_Opportunity__c == oldMap.get(oppTractRec.Opportunity__c).Id){
															if(tractMap.containsKey(oppTractRec.Tract__r.Id)){
																tractMap.get(oppTractRec.Tract__r.Id).Divestiture_Opportunity__c = Null;
															}
															else{
																oppTractRec.Tract__r.Divestiture_Opportunity__c = Null;
																tractMap.put(oppTractRec.Tract__r.Id, oppTractRec.Tract__r);
															}
														}

													 }


                                                     if(oppTractRec.Opportunity__r.Type == 'Acquisition'){
														if (oppTractRec.Tract__r.Acquisition_Opportunity__c != oppTractRec.Opportunity__c){
															if(tractMap.containsKey(oppTractRec.Tract__r.Id)){
																tractMap.get(oppTractRec.Tract__r.Id).Acquisition_Opportunity__c = oppTractRec.Opportunity__c;
															}
															else{
																oppTractRec.Tract__r.Acquisition_Opportunity__c = oppTractRec.Opportunity__c;
																tractMap.put(oppTractRec.Tract__r.Id, oppTractRec.Tract__r);
															}
														}
													 }
													 else if(oppTractRec.Opportunity__r.Type == 'Divestiture'){
														if (oppTractRec.Tract__r.Divestiture_Opportunity__c != oppTractRec.Opportunity__c){
															if(tractMap.containsKey(oppTractRec.Tract__r.Id)){
																tractMap.get(oppTractRec.Tract__r.Id).Divestiture_Opportunity__c = oppTractRec.Opportunity__c;
															}
															else{
																oppTractRec.Tract__r.Divestiture_Opportunity__c = oppTractRec.Opportunity__c;
																tractMap.put(oppTractRec.Tract__r.Id, oppTractRec.Tract__r);
															}
														}
													 }
                                                 }
    }
    
    public static void updateOwnerEntityOnRevenueEstimates(List<Opportunity> newList,Map<Id,Opportunity> oldMap){

        List<revenueEstimate__c> revenueEstimateList = new List<revenueEstimate__c>();
        Set<Id> updatedOppIds = new Set<Id>();
        for(Opportunity opp: newList){
            if(oldMap!=null && oldMap.get(opp.Id)!=null){
                if(opp.StageName != oldMap.get(opp.Id).StageName || opp.Effective_Date__c != oldMap.get(opp.Id).Effective_Date__c){
                    updatedOppIds.add(opp.Id);
                }
            }
        }
        Set<Id> tractIds = new Set<Id>();
        for(Opportunity_Tract__c otRec : [Select Id, Tract__c from Opportunity_Tract__c where Opportunity__c In: updatedOppIds]){
            tractIds.add(otRec.Tract__c);
        }

        UpdateOwnerEntity b = new UpdateOwnerEntity(updatedOppIds);
        //database.executeBatch(b,1);
    }

}