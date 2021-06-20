trigger RoyaltyLineItemTrigger on Royalty_Line_Item__c (before insert) {
    

    if(Trigger.isInsert){
        RoyaltyLineItemTriggerHelper triggerhlper = new RoyaltyLineItemTriggerHelper();
        triggerhlper.associateRoyaltyLineItem(Trigger.New);
    }
}