public class AccountRelatedListAura {
	@AuraEnabled
    public static List<SObject> getData(String recordId, Integer recordOffset, String relatedObject){
	 //Package testing
        //system.debug(inputStr);
        //inputWrapper input = (inputWrapper)JSON.deserialize(inputStr,inputWrapper.class);
		switch on relatedObject{
			when 'Tract__c'{
				return [Select Id,Name,Full_Legal_Name__c,Instrument_Type__c,Notes__c,titleSourceType__c,
				depth__c,percentCovered__c,targetPrice__c,maxPrice__c,targetPPA__c,maxPPA__c,netAcreageUnits__c,
				OTG_Cost_Per_Acre__c, OTG_Cost__c, Total_Cost_Per_Acre__c, Total_Cost__c, rptPercentCovered__c, 
				netAcres__c
				from Tract__c where Account__c =:recordId
				Limit 50 Offset :recordOffset];
			}
			when 'unitAllocation__c'{
				return[Select id,Name,unit__c,unit__r.Name,Subtract__c,Subtract__r.name,uaSubtractGrossAcres__c,unitGrossAcres__c,allocationPercentage__c,unitNRI__c,Subtract__r.Tract__r.Name,
                       Subtract__r.Tract__c,Subtract__r.Tract__r.Account__c,unit__r.GIS_Unit_Name__c,unit__r.Unit_Type__c,
                       Subtract__r.Tract__r.Account__r.Name 
					   from unitAllocation__c 
					   where subtract__r.Tract__r.Account__c =: recordId 
					   and Inactive__c = false
					   Limit 50 Offset :recordOffset];
			}
			when else{
				throw new AuraHandledException('Related Object Query not defined');
			}
		}
		
		
    }
    @AuraEnabled
    public static integer getTotalTractCount(Id recordId, String relatedObject){
        integer  count;
		switch on relatedObject{
			when 'Tract__c'{
				count= database.countQuery('SELECT count() from Tract__c WHERE Account__c = \'' + recordId + '\'');
			}
			when 'unitAllocation__c'{
				count= database.countQuery('SELECT count() from unitAllocation__c WHERE Inactive__c = false and subtract__r.Tract__r.Account__c =\'' + recordId + '\'');
			}
		}
		return count;
        //List<Tract__c> tractList =  [Select Id,Name,Full_Legal_Name__c,Instrument_Type__c,Notes__c,titleSourceType__c,
        //        depth__c,percentCovered__c,targetPrice__c,maxPrice__c,targetPPA__c,maxPPA__c,netAcreageUnits__c
        //        from Tract__c where Account__c =:recordId];
        //return tractList.size();
    }
    /*public class inputWrapper{
        
        @AuraEnabled
        public String recordId{get;set;}
        @AuraEnabled
        public Integer recordOffset{get;set;}
    }*/

}
