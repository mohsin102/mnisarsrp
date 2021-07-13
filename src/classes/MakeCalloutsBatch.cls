global class MakeCalloutsBatch implements Database.batchable<sObject >,Database.AllowsCallouts{
	global List<energyLinkBucket__c> linkList = new List<energyLinkBucket__c>();
    
    global MakeCalloutsBatch(List<energyLinkBucket__c> linkList){
        this.linkList = linkList;
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String soqlQuery = 'SELECT Id,checkUrl__c, checkId__c From energyLinkBucket__c where Id In:linkList';
        return Database.getQueryLocator(soqlQuery);
    }
    
    global void execute(Database.batchableContext info, List<energyLinkBucket__c > scope){ 
        for(energyLinkBucket__c eRec : scope){
            try{
            	CDEXCalloutHelper.getCheckBody(eRec.checkUrl__c,eRec.checkId__c);
				eRec.reprocess__c = false;
            }catch(Exception e){
                log__c logRec = new log__c();
                logRec.Process__c = 'Cdex Check Import';
                logRec.Status__c = 'ERROR';
                logRec.Error_Message__c = e.getMessage();
                logRec.Additional_Details__c = 'Check Url: '+eRec.checkUrl__c;
                logRec.Stack_Trace__c = e.getStackTraceString();
                insert logRec;
            }
        }
		update scope;
   } 
    
   global void finish(Database.batchableContext info){  
       
   }
    
}