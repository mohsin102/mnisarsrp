global class reprocessRevenueEstimatesBatch implements Database.Batchable<sObject>,Database.Stateful{
    
    global String query;
    global String operation;
    global Set<Id> objectIds;
    global Map<Id,Id> wellUnitMap = new Map<Id,Id>();
    global date dt = system.today().addMonths(-6);
    
    
    global reprocessRevenueEstimatesBatch(String operation){
        this.operation = operation;
        if(operation =='reprocessMismatchRE'){
            this.query = 'Select Id,Monthlyproduction__r.well__c,Monthlyproduction__r.well__r.unit__c from revenueEstimate__c where isUnitSame__c = false AND inactive__c = false';
        }else if(operation =='createMissingRE'){
             this.query = 'Select Id,Well__c,Well__r.Unit__c from Monthly_Production__c where Id Not In (Select monthlyProduction__c from revenueEstimate__c Where inactive__c = false)';
        }
    } 
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<sObject> scope){
        if(operation =='reprocessMismatchRE'){
            for(revenueEstimate__c reRec:(List<revenueEstimate__c>)scope){
                wellUnitMap.put(reRec.Monthlyproduction__r.well__c,reRec.Monthlyproduction__r.well__r.unit__c);
            }
        }else if(operation =='createMissingRE'){
            insert reprocessRevenueEstimatesController.createRevenueEstimates((List<Monthly_Production__c>)scope);
        }
    }
    
    global void finish(Database.BatchableContext BC){
        if(operation =='reprocessMismatchRE'){
            String query = 'Select Id from revenueEstimate__c where monthlyProduction__r.well__c In:objectIds AND Inactive__c = false';
            Set<Id> objectIds = wellUnitMap.keySet();
            createDeleteRevenueEstimatesBatch deleteJob = new createDeleteRevenueEstimatesBatch('delete',operation,objectIds,query,wellUnitMap);
            database.executeBatch(deleteJob);
        }
    }
    
}