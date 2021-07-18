global class updateRevenueProperties_Batch implements Database.batchable<sObject >{
    
    
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String soqlQuery = 'SELECT Id,royalty_check__c,propertyName__c From Royalty_line_item__c order by propertyName__c';
        return Database.getQueryLocator(soqlQuery);
    }
    
    global void execute(Database.batchableContext info, List<Royalty_line_item__c > scope){ 
        
        Map<String,Set<String>> propertyRCMap = new Map<String,Set<String>>();
        for(Royalty_line_item__c rli: scope){
            if(propertyRCMap.containsKey(rli.propertyName__c)){
                propertyRCMap.get(rli.propertyName__c.toUpperCase()).add(rli.royalty_check__c);
            }else{
                propertyRCMap.put(rli.propertyName__c.toUpperCase(),new Set<String>{rli.royalty_check__c});
            }
        }
        Set<String> rcIds;
        List<revenueProperty__c> revenuePropertyList = new List<revenueProperty__c>();
        for(revenueProperty__c revenueProperty : [Select id,propertyName__c,royaltyChecks__c 
                                                  from revenueProperty__c where propertyName__c In: propertyRCMap.keyset()]){
                                                      
                                                      rcIds = revenueProperty.royaltyChecks__c!=null?new Set<String>(revenueProperty.royaltyChecks__c.split(',')):new Set<String>();
                                                      if(propertyRCMap.get(revenueProperty.propertyName__c.toUpperCase())!=null){
                                                          rcIds.addAll(propertyRCMap.get(revenueProperty.propertyName__c.toUpperCase()));
                                                      }
                                                      
                                                      revenueProperty.royaltyChecks__c = String.join(new List<String>(rcIds),',');
                                                      revenuePropertyList.add(revenueProperty);
                                                  }
        
        update revenuePropertyList;
    } 
    
    global void finish(Database.batchableContext info){  
        
    }
    
}