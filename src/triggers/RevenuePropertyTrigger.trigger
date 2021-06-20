trigger RevenuePropertyTrigger on revenueProperty__c (after update) {
    
    /*if(trigger.isAfter && trigger.isUpdate){
        if(Trigger.New.size()==1){
            for(revenueProperty__c revenueProperty: Trigger.New){
                revenueProperty__c oldRevenueProperty = Trigger.OldMap.get(revenueProperty.Id);
                if(revenueProperty.API10__c != oldRevenueProperty.API10__c){
                    //Re-Associate CSV Checks
                    PropertyAssociation_Controller.revenuePropertyWrapper config = new PropertyAssociation_Controller.revenuePropertyWrapper();
                    config.propertyName = revenueProperty.propertyName__c;  
                    config.oldValue = oldRevenueProperty.API10__c != null ?oldRevenueProperty.API10__c.split(','):new list<String>{'NONWELLITEM'};
                    config.newValue = revenueProperty.API10__c.split(',');
                    PropertyAssociation_Controller.reAssociateCSVChecks(System.JSON.serialize(config));
                    //Re-Associate CDEX Checks
                    PropertyAssociation_Batch bch = new PropertyAssociation_Batch(revenueProperty.royaltyChecks__c.split(','));
                    database.executeBatch(bch, 1);
                }
            }
        }
    }*/
}