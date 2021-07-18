global with sharing class DeleteUnusedRevenueEstimates_Batch  implements Database.Batchable<sObject>{
    global final String query;
    global date dt = system.Today().addMonths(-12);
    public DeleteUnusedRevenueEstimates_Batch() {
        this.query='Select Id from revenueEstimate__c where inactive__c = false AND productionMonth__c <=: dt AND SRP_Owned__c = false';

    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,  List<sObject> scope){
        
        for(revenueEstimate__c rev : (List<revenueEstimate__c>)scope){
            rev.inactive__c = true;
            rev.inactiveNotes__c = 'Not SRP owned and older than 12 months';
        }
        update scope;
    }

    global void finish(Database.BatchableContext BC){
        //do nothing
    }
}