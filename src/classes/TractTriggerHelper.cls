public with sharing class TractTriggerHelper {

	//static variable value is also set to true by RHX_Project_AOI_Tract.trigger to prevent additional
	//trigger processing after updating Rollup Helper field values.
    //public static Boolean tractUpdating = false;
	//public static Set<String> rollupHelperFields = new Set<String> {'percentCovered__c', 'maxPrice__c', 'aoiNetAcres__c', 'targetPrice__c'};

	//Opportunity lock logic not implemented, commenting out this method (jdg 2-10-2020)
    /*public static void preventDelete(List<Opportunity_Tract__c> oldOppTracts, List<Opportunity_Tract__c> newOppTracts) {

        List<Opportunity_Tract__c> oppTracts = new List<Opportunity_Tract__c> ();
        if (oldOppTracts != null) {
            oppTracts.addAll(oldOppTracts);
        }
        if (newOppTracts != null) {
            oppTracts.addAll(newOppTracts);
        }

        if (oppTracts != null && oppTracts.size() > 0) {

            System.debug('newOTs' + oppTracts);

            Set<Id> oppIds = new Set<Id>();
            for (Opportunity_Tract__c ot : oppTracts) {
                if (ot.Opportunity__c != null)
                    oppIds.add(ot.Opportunity__c);
            }

            //System.debug('otIds: ' + otIds);
            List<Opportunity> opps = [SELECT Id, Locked__c FROM Opportunity WHERE Id IN: oppIds];

            Map<Id,Boolean> oppLockedMap = new Map<Id,Boolean>();
            for (Opportunity o : opps) {
                Boolean isLocked = o.Locked__c == true;
                oppLockedMap.put(o.Id,isLocked);
            }

            if (newOppTracts != null && newOppTracts.size() > 0) {
                // this is an update - can't put error on old version
                for (Opportunity_Tract__c ot : newOppTracts) {

                    if (oppLockedMap.containsKey(ot.Opportunity__c) && oppLockedMap.get(ot.Opportunity__c) == true) {
                        ot.addError('The related opportunity has been locked and opportunity tracts may not be modified.');
                    }
                }
            } else if (oldOppTracts != null && oldOppTracts.size() > 0) {
                for (Opportunity_Tract__c ot : oldOppTracts) {
                    if (oppLockedMap.containsKey(ot.Opportunity__c) && oppLockedMap.get(ot.Opportunity__c) == true) {
                        ot.addError('The related opportunity has been locked and opportunity tracts may not be modified.');
                    }
                }
            }
        }
    }*/

	//Changing duplicate to a unique text field that concatenates the two IDs and is populated via field updates.
    /*public static void preventDupes(List<Opportunity_Tract__c> newOpportunityTracts, Map<Id,Opportunity_Tract__c> oldMap) {

        // Build a list of changed tract ID or new tracts only
        List<Opportunity_Tract__c> modOTs = new List<Opportunity_Tract__c>();
        for (Opportunity_Tract__c ot : newOpportunityTracts) {
            if (oldMap == null || oldMap.containsKey(ot.Id) && (oldMap.get(ot.Id).Tract__c != ot.Tract__c)) {
                modOTs.add(ot);
            }
        }


        Set<Id> oppIds = new Set<Id>();
        Set<Id> tractIds = new Set<Id>();
        Map<String,Opportunity_Tract__c> otMap = new Map<String,Opportunity_Tract__c>();
        for (Opportunity_Tract__c ot : modOTs) {
            // This is either an INSERT (oldmap is null)
            // or an Update where the tract has changed

                oppIds.add(ot.Opportunity__c);
                tractIds.add(ot.Tract__c);
                if (otMap.containsKey(ot.Opportunity__c + ':' + ot.Tract__c)) {
                    ot.Tract__c.addError('Tract ' + ot.Tract__r.Name + ' is already in ' + ot.Opportunity__r.Name);
                } else {
                    otMap.put(ot.Opportunity__c + ':' + ot.Tract__c,ot);
                }

        }
        List<Opportunity_Tract__c> existingOTs = [SELECT Id,Opportunity__c,Tract__c,Tract__r.Name, Opportunity__r.Name
                        FROM Opportunity_Tract__c
                        WHERE
                            //Opportunity__r.Locked__c <>: TRUE AND
                            (Opportunity__c IN: oppIds OR Tract__c IN: tractIds)];

        for (Opportunity_Tract__c ot : existingOTs) {
            if (otMap.containsKey(ot.Opportunity__c + ':' + ot.Tract__c)) {
                Opportunity_Tract__c origOT = otMap.get(ot.Opportunity__c + ':' + ot.Tract__c);
                origOT.Tract__c.addError('Tract ' + ot.Tract__r.Name + ' is already in ' + ot.Opportunity__r.Name);
            }
        }


    }*/

    public static void deleteTractRelatedItems(Map<Id,Tract__c> oldMap) {

        System.debug('deleting opp/case tracts' + oldMap);

        if (oldMap != null && oldMap.size() > 0)
        {
            Set<Id> tractIds = oldMap.keySet();
            List<SObject> oppTracts = [SELECT Id FROM Opportunity_Tract__c WHERE Tract__c IN: tractIds];
            // TODO: Add this to support ignore of locked opps AND Opportunity__r.Locked__c = FALSE];
            //List<SObject> caseTracts = [SELECT Id FROM Case_Tract__c WHERE Tract__c IN: tractIds];
            System.debug('tract ids' + tractIds);
            System.debug('oppTracts' + oppTracts);
            //System.debug('caseTracts' + caseTracts);

            List<SObject> itemsToDelete = new List<SObject>();
            itemsToDelete.addAll(oppTracts);
            //itemsToDelete.addAll(caseTracts);
            //tractUpdating = true;
            delete itemsToDelete;
        }
    }
    // Static variable to prevent infinite recursion - when a tract is updating the Opp Tract / Case Tract,
    // the Opp Tract and Case Tract triggers should not fire.
    public static void recalcTractRelatedItems(Map<Id,Tract__c> newMap, Map<Id,Tract__c> oldMap)
    {
        system.debug('------TRACTTRIGGERHELPER');
		if(oldMap != null){
			Map<Id, Tract__c> acreageUpdate = new Map<Id, Tract__c>();
			for(Id tractId : newMap.keySet()){
				if(newMap.get(tractId).netAcres__c != oldMap.get(tractId).netAcres__c){
					acreageUpdate.put(tractId, newMap.get(tractId));
				}
			}
			if (acreageUpdate.size() > 0){
			System.debug('Calling batch for ' + acreageUpdate.size() + ' records.');
				Id batchInstanceId = Database.executeBatch(new batchUpdateProjectAOITracts(null, Trigger.newMap.keySet()));
			}
		}
        // After the tract(s) have been updated, find ALL parent caseTracts, ALL parent oppTracts
        // Replaces Sync Tract Info process builder
        Set<Id> tractIds = newMap.keySet();
        System.debug('tract ids' + tractIds);
        //List<Case_Tract__c> caseTracts = [SELECT Id,Tract__c FROM Case_Tract__c WHERE Tract__c IN: tractIds];
        List<Opportunity_Tract__c> oppTracts = [SELECT Id, Tract__c, FMV_Per_Acre__c, OTG_Cost_Per_Acre__c, 
												Total_Cost__c, Total_Cost_Per_Acre__c, Tract_Acres__c, OTG_Cost__c, Notes__c, Gain_on_Asset__c
												FROM Opportunity_Tract__c WHERE Tract__c IN: tractIds];

			
        //TODO: Use this to support locking: List<Opportunity_Tract__c> oppTracts = [SELECT Id, Tract__c FROM Opportunity_Tract__c WHERE Tract__c IN: tractIds AND Opportunity__r.Locked__c =: FALSE];
        List<Subtract__c> subTracts = [SELECT Id,Subtract_Gross_Acres__c, Subtract_Acres__c,Tract__c, Subtract_Quarter_Call__c, Subtract_Full_Legal_Description__c, Lot__c, Grid_Exception__c  
										FROM Subtract__c 
										WHERE Tract__c IN: tractIds];

        System.debug('oppTracts' + oppTracts);

        Map<Id,Tract__c> tractMap = getTractsbyIds(tractIds);

        System.debug('theTracts'+tractMap);
        List<SObject> itemsToUpdate = new List<SObject>();

        for (Opportunity_Tract__c ot : oppTracts)
        {
            Tract__c tract = tractMap.get(ot.Tract__c);
				
			Boolean oppTractUpdated  = setOppTractFields(ot,tract);
			System.debug('oppTractUpdated value is: ' + oppTractUpdated);
            if(oppTractUpdated){
				itemsToUpdate.add(ot);
			}
        }

		//Removing updates to Case Tracts per Quin (jdg 02-10-2020)
        /*for (Case_Tract__c ct : caseTracts)
        {
            Tract__c tract = tractMap.get(ct.Tract__c);
            setCaseTractFields(ct,tract);
            itemsToUpdate.add(ct);
        }*/

        for (Subtract__c st : subTracts)
        {

            Tract__c tract = tractMap.get(st.Tract__c);
            if (tract.Subtract_Count__c == 1) {
                // Copy one to one only!
				//Only modify if an update is needed
				if((st.Subtract_Acres__c != tract.netAcres__c)||(st.Subtract_Gross_Acres__c != tract.Gross_Acres__c)||(st.Subtract_Quarter_Call__c != tract.Quarter_Call__c)||
					(st.Subtract_Full_Legal_Description__c != tract.Full_Legal_Name__c)||(st.Lot__c != tract.Lots__c)||(st.Grid_Exception__c != tract.Grid_Exception__c)){
						st.Subtract_Acres__c = tract.netAcres__c;
						st.Subtract_Gross_Acres__c = tract.Gross_Acres__c;
						st.Subtract_Quarter_Call__c = tract.Quarter_Call__c;
						st.Subtract_Full_Legal_Description__c = tract.Full_Legal_Name__c;
						st.Lot__c = tract.Lots__c;
						st.Grid_Exception__c = tract.Grid_Exception__c;
						itemsToUpdate.add(st);
				}
            }
        }

        // Create a 1:1 subtract if it was deleted, or not created for any reason
        List<Subtract__c> newSubtracts = new List<Subtract__c>();
        for (Id tractId : tractMap.keySet()) {
            Tract__c t = tractMap.get(tractId);
            if (t.Subtract_Count__c == 0) {
                Subtract__c st = new Subtract__c(
                        Subtract_Acres__c = t.netAcres__c,
                        Subtract_Gross_Acres__c = t.Gross_Acres__c,
                        Subtract_Quarter_Call__c = t.Quarter_Call__c,
                        Subtract_Full_Legal_Description__c = t.Full_Legal_Name__c,
                        Lot__c = t.Lots__c,
                        Grid_Exception__c = t.Grid_Exception__c,
                        Tract__c = tractId
                );
                newSubtracts.add(st);
            }
        }



        System.debug('itemstoUdpate: ' + itemsToUpdate);
        System.debug('newSubtracts: ' + newSubtracts.size());
        System.debug('recalcing');
        //tractUpdating = true;
        update itemsToUpdate;
        if(newSubtracts.size()>0){
            insert newSubtracts;
        }
    }

    private static boolean setOppTractFields(Opportunity_Tract__c ot, Tract__c tract)
    {
		Boolean updated = false;
		if((ot.FMV_Per_Acre__c != tract.Value_Per_Acre__c)||(ot.OTG_Cost_Per_Acre__c != tract.OTG_Cost_Per_Acre__c)||
		   (ot.Total_Cost__c != tract.Total_Cost__c)||
		   (ot.Total_Cost_Per_Acre__c != tract.Total_Cost_Per_Acre__c)||(ot.Tract_Acres__c != tract.netAcres__c)||(ot.OTG_Cost__c != tract.OTG_Cost__c)||
		   (ot.Notes__c != tract.Notes__c)||(ot.Gain_on_Asset__c != tract.Gain_on_Asset__c)){
				updated = true;
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
		return updated;
    }

    /*public static void recalcByCaseTract(List<Case_Tract__c> newCaseTracts)
    {
        if (newCaseTracts != null && newCaseTracts.size() > 0)
        {
            Set<Id> tractIds = new Set<Id>();
            for (Case_Tract__c ct : newCaseTracts)
            {
                tractIds.add(ct.Tract__c);
            }

            Map<Id,Tract__c> tractMap = getTractsbyIds(tractIds);

            for (Case_Tract__c ct : newCaseTracts)
            {
                setCaseTractFields(ct,tractMap.get(ct.Tract__c));
            }

        }
    }*/

	/*public static void tractHistoryCreate(List<Tract__c> triggerNew, List<Tract__c> triggerOld, Map<Id, Tract__c> newMap, Map<Id, Tract__c> oldMap){
		List<tractHistory__c> newHistory = new List<tractHistory__c>();
		describerUtil describerUtility = new describerUtil();
		describerUtility.selectedObject = 'Tract__c';
		Map<String, Schema.SObjectField> fieldMap = describerUtility.getFields();
		Boolean rollupHelperOnly = true;
		for(Id updateId: newMap.keySet()){
			for(String fieldName: fieldMap.keySet()){
				if(newMap.get(updateId).get(fieldName) != oldMap.get(updateId).get(fieldName)){
					tractHistory__c newHistoryItem = new tractHistory__c();
					newHistoryItem.fieldName__c = fieldName;
					newHistoryItem.changedBy__c = UserInfo.getUserId();
					newHistoryItem.oldValue__c = String.valueOf(oldMap.get(updateId).get(fieldName));
					newHistoryItem.newValue__c = String.valueOf(newMap.get(updateId).get(fieldName));
					newHistoryItem.fieldLabel__c = String.valueOf(fieldMap.get(fieldName).getDescribe().getLabel());
					newHistoryItem.action__c = 'Update';
					newHistoryItem.tract__c = updateId;
					newHistory.add(newHistoryItem);
					if(!rollupHelperFields.contains(fieldName)){
						rollupHelperOnly = false;
					}
					System.debug('Found difference in field: ' + fieldName + ' old value is: ' + oldMap.get(updateId).get(fieldName) + ' new value is: ' + newMap.get(updateId).get(fieldName));
				}
			}
		}
		TractTriggerHelper.tractUpdating = rollupHelperOnly;
		insert newHistory;
	}*/

	/*public static void tractHistoryDelete(List<Tract__c> triggerOld, Map<Id, Tract__c> oldMap){
		List<tractHistory__c> newHistory = new List<tractHistory__c>();
		//System.debug('Tract was deleted');
		for(Id updateId: oldMap.keySet()){
			tractHistory__c newHistoryItem = new tractHistory__c();
			newHistoryItem.action__c = 'Delete';
			newHistoryItem.changedBy__c = UserInfo.getUserId();
			newHistoryItem.tract__c = updateId;
			newHistory.add(newHistoryItem);
		}
		insert newHistory;
	}*/

    public static Map<Id,Tract__c> getTractsbyIds(Set<Id> tractIds)
    {
        return new Map<Id,Tract__c>([SELECT Id,
            OTG_Cost__c, Value_Per_Acre__c, Gain_on_Asset__c,
            Total_Cost__c, Notes__c, netAcres__c, Total_Cost_Per_Acre__c, OTG_Cost_Per_Acre__c, Gross_Acres__c, Subtract_Count__c,
                Quarter_Call__c, Full_Legal_Name__c, Lots__c, Grid_Exception__c
            FROM Tract__c WHERE Id IN: tractIds]);
    }


	
    /*private static void setCaseTractFields(Case_Tract__c ct, Tract__c tract)
    {
        ct.Commission_Amount__c = tract.Commission_Amount__c;
        ct.OTG_Cost__c = tract.OTG_Cost__c;
        ct.Other_Capitalized_Costs__c = tract.Other_Capitalized_Costs__c;
        ct.Title_Cost__c = tract.Title_Cost__c;
        ct.Total_Cost__c = tract.Total_Cost__c;
        ct.Tract_Acres__c = tract.netAcres__c;
    }*/

}