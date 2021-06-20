public class MonthlyProductionTriggerHelper{


    
    public static void createOwnerInterestRevenue(List<Monthly_Production__c> newRecords){
        
        Map<Id,Id> mpUnitMap = new Map<Id,Id>();
        for(Monthly_Production__c mpRec : [Select id, Well__r.Unit__c from Monthly_Production__c where Id In: newRecords]){
            mpUnitMap.put(mpRec.Id,mpRec.Well__r.Unit__c);
        }
        
        if(mpUnitMap.size()>0){
            createOwnerInterestRevenueBatch oirBatch = new createOwnerInterestRevenueBatch('Monthly_Production__c',mpUnitMap);
            Database.executeBatch(oirBatch,50);
        }
    }
}