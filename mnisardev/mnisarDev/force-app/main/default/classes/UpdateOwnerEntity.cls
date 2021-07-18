global class UpdateOwnerEntity implements Database.Batchable<sObject>{

    global Set<Id> updatedOppIds = new Set<Id>();

    global UpdateOwnerEntity(Set<Id> updatedOppIds){
        this.updatedOppIds = updatedOppIds;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query ='';
        if(updatedOppIds.size()>0){
            Set<Id> tractIds = new Set<Id>();
            for(Opportunity_Tract__c otRec : [Select Id, Tract__c from Opportunity_Tract__c where Opportunity__c In: updatedOppIds]){
                tractIds.add(otRec.Tract__c);
            }
            query = 'Select Id from Tract__c where Id In: tractIds';
        }else{
            query = 'Select Id from Tract__c';
        }
        return Database.getQueryLocator(query);
    }

   global void execute(Database.BatchableContext BC, List<sobject> scope){
         
        Set<Id> tractIds = new Set<Id>();
        for(Tract__c tRec : (List<Tract__c>)scope){
            tractIds.add(tRec.Id);
        }

        Map<Id,List<oppWrapper>> tractOppMap = new Map<Id,List<oppWrapper>>();
        oppWrapper opp;
        List<oppWrapper> oppList;
        for(Opportunity_Tract__c otRec : [Select Id, Tract__c,Opportunity__c,Opportunity__r.StageName,Opportunity__r.CreatedDate,
                    Opportunity__r.Effective_Date__c,Opportunity__r.Acquiring_Entity__r.Type,Opportunity__r.Acquiring_Entity__c
                    from Opportunity_Tract__c where Tract__c In: tractIds order by Opportunity__r.CloseDate asc]){
            
            opp = new oppWrapper();
            opp.StageName = otRec.Opportunity__r.StageName;
            opp.EffectiveDate= otRec.Opportunity__r.Effective_Date__c;
            opp.AcquiringEntity = otRec.Opportunity__r.Acquiring_Entity__c;
            opp.AcquiringEntityType = otRec.Opportunity__r.Acquiring_Entity__r.Type;
            opp.CreatedDate= otRec.Opportunity__r.CreatedDate;

            if(tractOppMap.containsKey(otRec.Tract__c)){
                tractOppMap.get(otRec.Tract__c).add(opp);
            }else{
                oppList = new List<oppWrapper>();
                oppList.add(opp);
                tractOppMap.put(otRec.Tract__c,oppList);
            }
        }
        Map<Id,revenueEstimate__c> revMap = new Map<Id,revenueEstimate__c>();
        Boolean check;
        Date prevMonth;
        Integer oppCounter;
        Integer oppListSize;
        for(revenueEstimate__c revRec :[Select Id,unitAllocation__r.subtract__r.Tract__c,productionMonth__c from revenueEstimate__c 
                where unitAllocation__r.subtract__r.Tract__c In:tractOppMap.keySet() order by unitAllocation__r.subtract__r.Tract__c asc]){
            check = false;
            prevMonth = null;
            oppCounter = 1;
            oppListSize = tractOppMap.get(revRec.unitAllocation__r.subtract__r.Tract__c).size();
            for(oppWrapper oppRec: tractOppMap.get(revRec.unitAllocation__r.subtract__r.Tract__c)){

                
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
                //Commenting BackDated Opportunity logic
                /*if(oppCounter == oppListSize){
                    if((oppRec.StageName=='Closed Review'||oppRec.StageName=='Closed Complete') &&  oppRec.AcquiringEntityType =='Portfolio Investment' && revRec.productionMonth__c >= oppRec.EffectiveDate){
                        revRec.srp_owned__c = true;
                        revRec.owner_entity__c = oppRec.AcquiringEntity;
                        check = true;
                    }
                }*/
                oppCounter++;
            }
            if(check == false){
                    revRec.srp_owned__c = false;
                    revRec.owner_entity__c = null;
            }
            revMap.put(revRec.Id,revRec);
        }
        if(revMap.values().size()>0){
            update revMap.values();
        }
   }

   global void finish(Database.BatchableContext BC){

   }
    
    public class oppWrapper{
        
        public String StageName;
        public Date EffectiveDate;
        public Id AcquiringEntity;
        public String AcquiringEntityType ;
        public DateTime CreatedDate;
    }

}