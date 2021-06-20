public class OwnerInterestRevenueController {
	/**
    * @description : Method referred by OIRRelatedList Aura Component
    * @author : Jade Tran
    * @param recordId , uaId
    * @return OIRWrapper 
    **/
    
	@AuraEnabled
    public static OIRWrapper getRecords(Id recordId, Id uaId){
        List<revenueEstimate__c> oirList = new List<revenueEstimate__c>();
        OIRWrapper sWrap = new OIRWrapper();
		
        sWrap.excludedSrpRevenue = false;
        sWrap.sObjectName = recordId.getSObjectType().getDescribe().getName();
        sWrap.oirList  = oirList;
        
        //return list of OIR realted to specific Well and ua record
        oirList = [Select Name,productionMonth__c,SRP_Owned__c,ownerNetRevenueValueGas__c,ownerNetRevenueValueOil__c,
        ownerNetRevenueValue__c,Owner_Entity__c,Owner_Entity__r.Name from revenueEstimate__c 
        where monthlyProduction__r.Well__c =: recordId AND unitAllocation__c =: uaId
        AND inactive__c = false];
        
        List<wellInterestAllocation__c> wia = new List< wellInterestAllocation__c>();
        for(wellInterestAllocation__c wiaRec : [Select Id from wellInterestAllocation__c where unitAllocation__c=:uaId
                                             AND well__c =:recordId Limit 1]){
                                                 wia.add(wiaRec);
                                             }
        
        if(wia.size()>0){
            sWrap.excludedSrpRevenue = true;
            swrap.wellInterestAllocation = wia[0].Id;
        }else{
            //Get Sum of Owner Net Revenue of OIRs realted to specific Well and ua record and SRP owned = true
            AggregateResult[] groupedResults = [SELECT SUM(ownerNetRevenueValue__c) from revenueEstimate__c 
                    where monthlyProduction__r.Well__c =: recordId AND unitAllocation__c =: uaId
                    AND SRP_Owned__c = true AND inactive__c = false];
            for (AggregateResult ar : groupedResults)  {
                sWrap.ownerNetRevenueValue = Double.valueOf(ar.get('expr0'));
            }
            sWrap.excludedSrpRevenue = false;
            sWrap.oirList  = oirList;
        }
        return sWrap;
    }

    /**
    * @description : Method referred by OIRRelatedList Aura Component
    * @author : Jade Tran
    * @param Id recordId, uaId, excludedRevenue
    * @return List<well__c> 
    **/
    @AuraEnabled
    public static void saveExcludedRevenue(Id recordId, Id uaId, String excludedRevenue){
        List<revenueEstimate__c> oirList = new List<revenueEstimate__c>();
        OIRWrapper sWrap = new OIRWrapper();

        //return list of OIR that needs to be excluded from SRP Revenue
        if (excludedRevenue == 'true'){
            
            wellInterestAllocation__c wia= new wellInterestAllocation__c();
            wia.unitAllocation__c = uaId;
            wia.well__c = recordId;
            wia.UniqueId__c =  String.valueOf(wia.unitAllocation__c) + String.valueof(wia.well__c);
            insert wia;
            
            oirList = [Select Name,productionMonth__c,SRP_Owned__c,ownerNetRevenueValueGas__c,ownerNetRevenueValueOil__c,
            ownerNetRevenueValue__c,Owner_Entity__c,Owner_Entity__r.Name from revenueEstimate__c 
            where monthlyProduction__r.Well__c =: recordId AND unitAllocation__c =: uaId
            AND Inactive__c = false];
             
            for(revenueEstimate__c revRec:oirList){
                revRec.Inactive__c = true;
                revRec.excludeFromSRPRevenue__c = true;
                revRec.wellInterestAllocation__c = wia.Id;
            } 

            update oirList;

        } else{
            wellInterestAllocation__c wia = [Select Id from wellInterestAllocation__c where unitAllocation__c=:uaId
                                        AND well__c =:recordId];
            if(wia!=null){
                delete wia;
            }
            oirList = [Select Name,productionMonth__c,SRP_Owned__c,ownerNetRevenueValueGas__c,ownerNetRevenueValueOil__c,
            ownerNetRevenueValue__c,Owner_Entity__c,Owner_Entity__r.Name from revenueEstimate__c 
            where monthlyProduction__r.Well__c =: recordId AND unitAllocation__c =: uaId
            AND excludeFromSRPRevenue__c = true];
			
            for(revenueEstimate__c revRec:oirList){
                revRec.Inactive__c = false;
                revRec.excludeFromSRPRevenue__c = false;
                revRec.wellInterestAllocation__c = null;
            } 

            update oirList;
        } 
     }
    
    /**
    * @description : Method referred by oirWithWellAccordion Aura Component
    * @author : Jade Tran
    * @param Id recordId
    * @return List<well__c> 
    **/
	@AuraEnabled
    public static List<WellWrapper> getWells(Id recordId){
        
        List<WellWrapper> wellWrapList = new List<WellWrapper>();
        WellWrapper wellWrap;
        //query to get the unit related to ua
        unitAllocation__c ua = [Select Id, unit__c, Inactive__c from unitAllocation__c where Id =: recordId limit 1];
        
        Map<String,Integer> wellOirCountMap = new Map<String,Integer>();
        Integer count = 0;
        for(Well__c well : [Select Id, Name from well__c where unit__c =: ua.unit__c]){
            count = 0;
            for(AggregateResult ar:[SELECT count(Id) from revenueEstimate__c
                            Where monthlyProduction__r.well__c =: well.Id and unitAllocation__c =: recordId
                            AND inactive__c = false]){
                            
                count=Integer.valueOf(ar.get('expr0'));
            }
            wellWrap = new WellWrapper();
            wellWrap.wellName = well.Name;
            wellWrap.wellId = well.Id;
            wellWrap.inactive = ua.Inactive__c;
            wellWrap.oirCount = count;
            wellWrapList.add(wellWrap);
        }
        
        
        //Get all Well records realted to ua's Unit
        //List<Well__c> wellList = [Select Id, Name from well__c where unit__c =: ua.unit__c];
        return wellWrapList;
    }

    @AuraEnabled
    public static void excludeRevenueEstimate(List<revenueEstimate__c> oirList, Boolean excludedRevenue){
        for(revenueEstimate__c revRec : oirList){
            revRec.excludeFromSRPRevenue__c = excludedRevenue;
        }
        update oirList;
    }

	public class OIRWrapper{
        @AuraEnabled
        public List<revenueEstimate__c> oirList{get;set;}
        @AuraEnabled
        public string sObjectName{get;set;}
        @AuraEnabled
        public double ownerNetRevenueValue{get;set;}
        @AuraEnabled
        public Id wellInterestAllocation{get;set;}
		@AuraEnabled
        public Boolean excludedSrpRevenue{get;set;}
       
    }
    public class WellWrapper{
        @AuraEnabled
        public String wellName{get;set;}
        @AuraEnabled
        public String wellId{get;set;}
        @AuraEnabled
        public Integer oirCount{get;set;}
        @AuraEnabled
        public Boolean inactive{get;set;}
    }
    
    
}