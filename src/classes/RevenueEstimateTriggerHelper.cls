public class RevenueEstimateTriggerHelper {


    public static void updateOwnerEntity(List<revenueEstimate__c> newList){

        Set<Id> tractIds = new Set<Id>();
        for(revenueEstimate__c revRec : [Select unitAllocation__r.subtract__r.Tract__c from revenueEstimate__c where Id In: newList]){
            tractIds.add(revRec.unitAllocation__r.subtract__r.Tract__c);
        }
        Map<Id,List<oWrapper>> tractOppMap = new Map<Id,List<oWrapper>>();
        oWrapper opp;
        List<oWrapper> oppList;
        for(Opportunity_Tract__c otRec : [Select Id, Tract__c,Opportunity__c,Opportunity__r.StageName,Opportunity__r.CreatedDate,
                    Opportunity__r.Effective_Date__c,Opportunity__r.Acquiring_Entity__r.Type,Opportunity__r.Acquiring_Entity__c
                    from Opportunity_Tract__c where Tract__c In: tractIds order by Opportunity__r.CreatedDate asc]){
            
            opp = new oWrapper();
            opp.StageName = otRec.Opportunity__r.StageName;
            opp.EffectiveDate= otRec.Opportunity__r.Effective_Date__c;
            opp.AcquiringEntity = otRec.Opportunity__r.Acquiring_Entity__c;
            opp.AcquiringEntityType = otRec.Opportunity__r.Acquiring_Entity__r.Type;
            opp.CreatedDate= otRec.Opportunity__r.CreatedDate;

            if(tractOppMap.containsKey(otRec.Tract__c)){
                tractOppMap.get(otRec.Tract__c).add(opp);
            }else{
                oppList = new List<oWrapper>();
                oppList.add(opp);
                tractOppMap.put(otRec.Tract__c,oppList);
            }
        }
        Map<Id,revenueEstimate__c> revMap = new Map<Id,revenueEstimate__c>();
        Boolean check;
        Date prevMonth;
        //Integer oppCounter;
        //Integer oppListSize;
        for(revenueEstimate__c revRec :[Select Id,unitAllocation__r.subtract__r.Tract__c,productionMonth__c from revenueEstimate__c 
                where unitAllocation__r.subtract__r.Tract__c In:tractOppMap.keySet() AND inactive__c = false order by productionMonth__c asc]){
            check = false;
            prevMonth = null;
            //oppCounter = 1;
           // oppListSize = tractOppMap.get(revRec.unitAllocation__r.subtract__r.Tract__c).size();
            for(oWrapper oppRec: tractOppMap.get(revRec.unitAllocation__r.subtract__r.Tract__c)){

                if((oppRec.StageName=='Closed Won') &&  oppRec.AcquiringEntityType =='Portfolio Investment' && revRec.productionMonth__c >= oppRec.EffectiveDate){
                    revRec.srp_owned__c = true;
                    revRec.owner_entity__c = oppRec.AcquiringEntity;
                    check = true;
                }
                if(((oppRec.StageName!='Closed Won') ||  oppRec.AcquiringEntityType !='Portfolio Investment') && revRec.productionMonth__c >= oppRec.EffectiveDate){
                    revRec.srp_owned__c = false;
                    revRec.owner_entity__c = null;
                    check = true;
                }
                //jdg 04-27-2021 Commenting out as this should already be done above

				/*if(oppCounter == oppListSize){
                    if((oppRec.StageName=='Closed Review'||oppRec.StageName=='Closed Complete') &&  oppRec.AcquiringEntityType =='Portfolio Investment' && revRec.productionMonth__c >= oppRec.EffectiveDate){
                        revRec.srp_owned__c = true;
                        revRec.owner_entity__c = oppRec.AcquiringEntity;
                        check = true;
                    }
                }
                oppCounter++;*/
            }
            if(check == false){
                    revRec.srp_owned__c = false;
                    revRec.owner_entity__c = null;
            }
            if(revRec.srp_owned__c){
                revMap.put(revRec.Id,revRec);
            }
        }
        if(revMap.values().size()>0){
           update revMap.values();
        }
    }

    public class oWrapper{
        
        public String StageName;
        public Date EffectiveDate;
        public Id AcquiringEntity;
        public String AcquiringEntityType ;
        public DateTime CreatedDate;
    }
    
    public static void updateWellInterestAllocation(List<revenueEstimate__c> reList){
        Set<String> uniqueIds = new Set<String>();
        for(revenueEstimate__c reRec : reList){
            uniqueIds.add(reRec.WellUnitAllocationExtId__c);
        }
        Map<String,Id> wiaMap = new Map<String,Id>();
        for(wellInterestAllocation__c wia: [Select Id,UniqueId__c  from wellInterestAllocation__c where UniqueId__c  in: uniqueIds]){
            wiaMap.put(wia.UniqueId__c,wia.Id);
        }
        for(revenueEstimate__c reRec : reList){
            if(wiaMap.containsKey(reRec.WellUnitAllocationExtId__c)){
                reRec.wellInterestAllocation__c = wiaMap.get(reRec.WellUnitAllocationExtId__c);
                reRec.Inactive__c = true;
                reRec.excludeFromSRPRevenue__c = true;
            }
        }
    }
}