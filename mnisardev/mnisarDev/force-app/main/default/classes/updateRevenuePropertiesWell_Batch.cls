global class updateRevenuePropertiesWell_Batch implements Database.batchable<sObject >{
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String soqlQuery = 'SELECT Id,propertyName__c,royaltyChecks__c,API10__c  From revenueProperty__c';
        return Database.getQueryLocator(soqlQuery);
    }
    
    global void execute(Database.batchableContext info, List<revenueProperty__c > scope){ 
        String[] wells = scope[0].API10__c.split(',');
        List<revenuePropertyWellAllocation__c> rpwList = new List<revenuePropertyWellAllocation__c>();
        revenuePropertyWellAllocation__c rpw;
        List<String> wellNames = new List<String>();
        for(well__c well:[Select Id,Name from Well__C where API10__c In: wells]){
            rpw = new revenuePropertyWellAllocation__c();
            rpw.revenueProperty__c = scope[0].Id;
            rpw.well__c = well.Id;
            rpwList.add(rpw);
            wellNames.add(well.Name);
        }
        insert rpwList;
        scope[0].wells__c = String.join(wellNames,',');
        update scope;
    } 
    
    global void finish(Database.batchableContext info){  
        
    }
    
}