global class updateRevenuePropertiesOPName_Batch implements Database.batchable<sObject >{
    
    
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String soqlQuery = 'SELECT Id,propertyName__c,royaltyChecks__c,API10__c  From revenueProperty__c where OperatorName__c=null';
        return Database.getQueryLocator(soqlQuery);
    }
    
    global void execute(Database.batchableContext info, List<revenueProperty__c > scope){ 
        if(scope[0].royaltyChecks__c!='' && scope[0].royaltyChecks__c!=null){
            String[] rcIds = scope[0].royaltyChecks__c.split(',');
            List<Royalty_Check__c> rlist = [Select Id,Operator_Name__c from Royalty_Check__c where Id In: rcIds];
            Set<String> OpSet = new Set<String>();
            for(Royalty_Check__c rc : rlist){
                OpSet.add(rc.Operator_Name__c.toUpperCase());
            }
            if(!OpSet.isEmpty()){
                Integer counter = 0;
                List<revenueProperty__c> revenuePropertyList = new List<revenueProperty__c>();
                revenueProperty__c revenueProperty;
                for(String op: OpSet){
                    if(counter == 0){
                        revenueProperty = new revenueProperty__c();
                        revenueProperty.Id = scope[0].Id;
                        revenueProperty.propertyName__c = scope[0].propertyName__c;
                        revenueProperty.OperatorName__c = op;
                        revenueProperty.UniqueKey__c = scope[0].propertyName__c+'_-_'+op;
                        revenuePropertyList.add(revenueProperty);
                        counter++;
                    }else{
                        revenueProperty = new revenueProperty__c();
                        revenueProperty.propertyName__c = scope[0].propertyName__c;
                        revenueProperty.OperatorName__c = op;
                        revenueProperty.UniqueKey__c = scope[0].propertyName__c+'_-_'+op;
                        revenuePropertyList.add(revenueProperty);
                    }
                }
                if(!revenuePropertyList.isEmpty()){
                    database.upsert(revenuePropertyList,false);
                }
            }
        }
    } 
    
    global void finish(Database.batchableContext info){  
        
    }
    
}