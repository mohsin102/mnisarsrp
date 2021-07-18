global class updateRevenuePropertiesRLI_Batch implements Database.batchable<sObject >{
    
    
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String soqlQuery = 'SELECT Id,propertyName__c,operatorName__c  From royalty_line_item__c where revenueProperty__c=null Order by propertyName__c';
        return Database.getQueryLocator(soqlQuery);
    }
    
    global void execute(Database.batchableContext info, List<royalty_line_item__c > scope){ 
        Set<String> uniqueKeySet = new Set<String>();
        String key='';
        for(royalty_line_item__c rli: scope){
            key =rli.propertyName__c+'_-_'+rli.operatorName__c;
            uniqueKeySet.add(key.toUpperCase());
        }
        Map<String,String> revenuePropertyMap = new Map<String,String>();
        for(revenueProperty__c revenueProperty: [Select Id, uniqueKey__c from revenueProperty__c where uniqueKey__c in:uniqueKeySet]){
            revenuePropertyMap.put(revenueProperty.uniqueKey__c.toupperCase(),revenueProperty.Id);
        }
        for(royalty_line_item__c rli:scope){
            key =rli.propertyName__c+'_-_'+rli.operatorName__c;
            rli.revenueProperty__c = revenuePropertyMap.get(key.toUpperCase());
        }
        update scope;

    } 
    
    global void finish(Database.batchableContext info){  
        
    }
    
}