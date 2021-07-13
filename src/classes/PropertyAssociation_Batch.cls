public class PropertyAssociation_Batch implements Database.batchable<sObject >, Database.AllowsCallouts{
	public String[] rcIds;
    public PropertyAssociation_Batch(String[] rcIds){
        this.rcIds = rcIds;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        String soqlQuery = 'Select Id from Royalty_Check__c where Id In: rcIds AND Source__c=\'CDEX\'';
        return Database.getQueryLocator(soqlQuery);
    }
    
    public void execute(Database.batchableContext info, List<sObject> scope){ 
        
        CDEXCalloutHelper.reprocessCdexCheck(scope[0].Id);
   } 
    
   public void finish(Database.batchableContext info){  
       
   }
    
}