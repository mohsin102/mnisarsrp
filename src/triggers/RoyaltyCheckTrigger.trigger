trigger RoyaltyCheckTrigger on Royalty_Check__c (Before Insert,before update,after Insert,after Update) {
    
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            RoyaltyCheckTriggerHandler.updateCheckInfo(Trigger.New);
            RoyaltyCheckTriggerHandler.UpdatePayorNPayee(Trigger.New);
        }else if(Trigger.isUpdate){
            RoyaltyCheckTriggerHandler.updateCheckInfo(Trigger.New);
        }
    }
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            //Do  Nothing
        }else if(Trigger.isUpdate){
            RoyaltyCheckTriggerHandler.updateAccountMapping(Trigger.New,Trigger.OldMap);
        }
    }
}