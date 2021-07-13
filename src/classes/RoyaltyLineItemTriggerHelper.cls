Public class RoyaltyLineItemTriggerHelper {

    
    /********************
    * @description This method associates the royalty Line Items with wells based on the property Id.
    * @param List<Royalty_line_item__c>
    * @retrun void 
    ********************/
    public void associateRoyaltyLineItem(List<Royalty_Line_Item__c> newList){
        Set<String> propertyOperatorSet = new Set<String>();
        Map<String,revenueProperty__c> revenuePropertyMap = new Map<String,revenueProperty__c>();
        for(Royalty_Line_Item__c rli: newList){
            String key = rli.propertyName__c+'_-_'+rli.OperatorName__c;
            propertyOperatorSet.add(key.toUpperCase());
        }
        for(revenueProperty__c revenueProperty: [Select Id,UniqueKey__c,NumberOfAllocations__c,IsNonWellRevenueProperty__c from revenueProperty__c where uniqueKey__c in: propertyOperatorSet]){
            revenuePropertyMap.put(revenueProperty.UniqueKey__c.toUpperCase(),revenueProperty);
        }
        propertyOperatorSet.removeAll(revenuePropertyMap.keySet());
        List<revenueProperty__c> revenuePropertyList = new List<revenueProperty__c>();
        for(String propertyOperator: propertyOperatorSet){
            String[] propertyOperatorArray = propertyOperator.split('_-_');
            revenuePropertyList.add(new revenueProperty__c(
                propertyName__c	= propertyOperatorArray[0],
                OperatorName__c = propertyOperatorArray[1],
                UniqueKey__c = propertyOperator
            ));
        }
        if(!revenuePropertyList.isEmpty()){
            database.insert(revenuePropertyList,false);
            for(revenueProperty__c revenueProperty: revenuePropertyList){
                revenuePropertyMap.put(revenueProperty.UniqueKey__c,revenueProperty);
            }
        }
        revenueProperty__c revenueProperty;
        for(Royalty_Line_Item__c rli: newList){
            String key = rli.propertyName__c+'_-_'+rli.OperatorName__c;
            if(revenuePropertyMap.containsKey(key.toUpperCase())){
                revenueProperty = revenuePropertyMap.get(key.toUpperCase());
                rli.revenueProperty__c = revenueProperty.Id;
                if(revenueProperty.NumberOfAllocations__c>0){
                    rli.revenueAllocated__c = true;
                }
                if(revenueProperty.IsNonWellRevenueProperty__c == true){
                    rli.isNonWellLineItem__c = true;
					rli.revenueAllocated__c = true;
                }

            }
        }
    }

}