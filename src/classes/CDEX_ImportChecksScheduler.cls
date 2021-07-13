global class CDEX_ImportChecksScheduler implements Schedulable,Database.AllowsCallouts {
    global void execute(SchedulableContext SC) {
        
        
        List<energyLinkBucket__c> linkList = new List<energyLinkBucket__c>();
        Integer counter = 0;
        for(energyLinkBucket__c  eRec : [Select Id,checkURL__c from energyLinkBucket__c where createdDate>=:system.today() OR reprocess__c = TRUE]){
            if(counter<90){
                linkList.add(eRec);
                counter++;
            }else{
                MakeCalloutsBatch btch = new MakeCalloutsBatch(linkList);
                database.executeBatch(btch,1);
                linkList.clear();
                linkList.add(eRec);
                counter = 0;
            }
        }
        if(linkList.size()>0){
            MakeCalloutsBatch btch = new MakeCalloutsBatch(linkList);
            database.executeBatch(btch,1);
        }
    }
}