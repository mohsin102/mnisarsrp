global class createDeleteRevenueEstimatesBatch implements Database.Batchable<sObject>,Database.Stateful{
    
    global String query;
    global String operation;
    global Set<Id> objectIds;
    global Map<Id,Id> wellUnitMap;
    global String processType;
    
    global createDeleteRevenueEstimatesBatch(String operation,String processType,Set<Id> objectIds,String query,Map<Id,Id> wellUnitMap){
        
        this.query = query;
        this.operation = operation;
        this.objectIds = objectIds;
        this.wellUnitMap = wellUnitMap;
        this.processType = processType;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<sObject> scope){
        
        if(operation=='delete'){
            for(revenueEstimate__c rev : (List<revenueEstimate__c>)scope){
                rev.inactive__c = true;
                rev.inactiveNotes__c = 'Revenue Estimate Reprocessed: '+processType;
            }
            update scope;
        }else if(operation=='insert'){
            insert reprocessRevenueEstimatesController.createRevenueEstimates((List<Monthly_Production__c>)scope);
        }
    }
    
    global void finish(Database.BatchableContext BC){
        if(operation=='delete'){
            String queryStr = 'Select Id,well__c,well__r.unit__c from Monthly_Production__c where well__c In:objectIds';
            createDeleteRevenueEstimatesBatch insertJob = new createDeleteRevenueEstimatesBatch('insert',processType,wellUnitMap.keySet(),queryStr,wellUnitMap);
            database.executeBatch(insertJob,5);
        }
    }
    
}