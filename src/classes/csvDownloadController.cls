public class csvDownloadController {
	@AuraEnabled
	public static list <contact> fetchContact(){
      
		List <contact> returnConList = new List < contact > ();
        
		for(contact con: [SELECT firstName, LastName, Department, MobilePhone From contact LIMIT 1000]) {
				returnConList.add(con);
			}
			return returnConList;
	}
	
	@AuraEnabled
	public static List<Royalty_Line_Item__c> getAccountWellRevenue(String recordId){
		//List<Subtract__c> accountSubtracts = [SELECT ID FROM Subtract__c WHERE Tract__c IN (SELECT Id FROM Tract__c WHERE Account__c = :recordId)];
		Set<Id> subtractIds = new Set<Id>();
		for(Subtract__c subtract: [SELECT ID FROM Subtract__c WHERE Tract__c IN (SELECT Id FROM Tract__c WHERE Account__c = :recordId)]){
			subtractIds.add(subtract.Id);
		}
		Set<Id> wellIds = new Set<Id>();
		for(Well__c well: [SELECT ID FROM Well__c WHERE Unit__c IN (SELECT Unit__c FROM unitAllocation__c WHERE Subtract__c IN :subtractIds)]){
			wellIds.add(well.Id);
		}
		Set<Id> revenuePropertyIds = new Set<Id>();
		List<RevenuePropertyWellAllocation__c> revenuePropertyWellAllocations = [SELECT Id, revenueProperty__c, splitPercent__c, well__c FROM RevenuePropertyWellAllocation__c WHERE well__c IN :wellIds];
		Map<Id, List<revenuePropertyWellAllocation__c>> revenuePropertyMap = new Map<Id, List<revenuePropertyWellAllocation__c>>();
		for(RevenuePropertyWellAllocation__c revenuePropertyWellAllocation: revenuePropertyWellAllocations){
			revenuePropertyIds.add(revenuePropertyWellAllocation.revenueProperty__c);
			if(revenuePropertyMap.get(revenuePropertyWellAllocation.revenueProperty__c) != null){
				revenuePropertyMap.get(revenuePropertyWellAllocation.revenueProperty__c).add(revenuePropertyWellAllocation);
			}
			else{
				List<revenuePropertyWellAllocation__c> tempList = new List<revenuePropertyWellAllocation__c>();
				tempList.add(revenuePropertyWellAllocation);
				revenuePropertyMap.put(revenuePropertyWellAllocation.revenueProperty__c, tempList);
			}
		}
		System.debug(revenuePropertyIds);
		List<Royalty_Line_Item__c> royaltyCheckLineItems = [SELECT adjustmentCode__c,CreatedById,CreatedDate,detailId__c,grossAdjustmentsActual__c,grossNetActual__c,grossTaxesActual__c,grossValueActual__c,
															grossValueAfterAdjustments__c,grossValue__c,grossVolumeActual__c,Id,interestType__c,IsDeleted,isLastProductionMonth__c,isNonWellLineItem__c,
															LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,lineItemDecimal__c,line_Item_Net_Val__c,Name,net_Adjustments__c,
															net_Taxes__c,net_Value__c,notes__c,operatorName__c,ownerAdjustmentsActual__c,ownerNetValueActual__c,ownerTaxesActual__c,ownerValueActual__c,
															ownerVolumeActual__c,price__c,productCode__c,productionMonthCalc__c,production_Month__c,product_Category__c,product__c,propertyName__c,
															property_Id__c,revenueAllocated__c,revenueProperty__c,royalty_Check__c,source__c,SystemModstamp,totalAllocatedAmount__c,type__c,
															wellNames__c,well__c 
															FROM Royalty_Line_Item__c
															WHERE revenueProperty__c IN: revenuePropertyIds
															ORDER BY CreatedDate DESC 
															LIMIT 40000];

		return royaltyCheckLineItems;
		
	}

	public static Set<Id> getAccountRevenuePropertyIds(String recordId){
	//public static List<Royalty_Line_Item__c> getAccountWellRevenue(String recordId){
		//List<Subtract__c> accountSubtracts = [SELECT ID FROM Subtract__c WHERE Tract__c IN (SELECT Id FROM Tract__c WHERE Account__c = :recordId)];
		Set<Id> subtractIds = new Set<Id>();
		for(Subtract__c subtract: [SELECT ID FROM Subtract__c WHERE Tract__c IN (SELECT Id FROM Tract__c WHERE Account__c = :recordId)]){
			subtractIds.add(subtract.Id);
		}
		Set<Id> wellIds = new Set<Id>();
		for(Well__c well: [SELECT ID FROM Well__c WHERE Unit__c IN (SELECT Unit__c FROM unitAllocation__c WHERE Subtract__c IN :subtractIds)]){
			wellIds.add(well.Id);
		}
		Set<Id> revenuePropertyIds = new Set<Id>();
		List<RevenuePropertyWellAllocation__c> revenuePropertyWellAllocations = [SELECT Id, revenueProperty__c, splitPercent__c, well__c FROM RevenuePropertyWellAllocation__c WHERE well__c IN :wellIds];
		Map<Id, List<revenuePropertyWellAllocation__c>> revenuePropertyMap = new Map<Id, List<revenuePropertyWellAllocation__c>>();
		for(RevenuePropertyWellAllocation__c revenuePropertyWellAllocation: revenuePropertyWellAllocations){
			revenuePropertyIds.add(revenuePropertyWellAllocation.revenueProperty__c);
			/*if(revenuePropertyMap.get(revenuePropertyWellAllocation.revenueProperty__c) != null){
				revenuePropertyMap.get(revenuePropertyWellAllocation.revenueProperty__c).add(revenuePropertyWellAllocation);
			}
			else{
				List<revenuePropertyWellAllocation__c> tempList = new List<revenuePropertyWellAllocation__c>();
				tempList.add(revenuePropertyWellAllocation);
				revenuePropertyMap.put(revenuePropertyWellAllocation.revenueProperty__c, tempList);
			}*/
		}
		System.debug(revenuePropertyIds);
		/*List<Royalty_Line_Item__c> royaltyCheckLineItems = [SELECT adjustmentCode__c,CreatedById,CreatedDate,detailId__c,grossAdjustmentsActual__c,grossNetActual__c,grossTaxesActual__c,grossValueActual__c,
															grossValueAfterAdjustments__c,grossValue__c,grossVolumeActual__c,Id,interestType__c,IsDeleted,isLastProductionMonth__c,isNonWellLineItem__c,
															LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,lineItemDecimal__c,line_Item_Net_Val__c,Name,net_Adjustments__c,
															net_Taxes__c,net_Value__c,notes__c,operatorName__c,ownerAdjustmentsActual__c,ownerNetValueActual__c,ownerTaxesActual__c,ownerValueActual__c,
															ownerVolumeActual__c,price__c,productCode__c,productionMonthCalc__c,production_Month__c,product_Category__c,product__c,propertyName__c,
															property_Id__c,revenueAllocated__c,revenueProperty__c,royalty_Check__c,source__c,SystemModstamp,totalAllocatedAmount__c,type__c,
															wellNames__c,well__c 
															FROM Royalty_Line_Item__c
															WHERE revenueProperty__c IN: revenuePropertyIds
															ORDER BY CreatedDate DESC 
															LIMIT 40000];
															*/
		//return royaltyCheckLineItems;
		return revenuePropertyIds;
	}

}