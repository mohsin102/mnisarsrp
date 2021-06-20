trigger ContactInformationTrigger on contactInformation__c (after insert,after update) {
    
    ContactInformationTriggerHandler.updateInfoOnAccount(Trigger.New);
    if(Trigger.isInsert || Trigger.isUpdate){
        ContactInformationTriggerHandler.updateInfoOnAccount(Trigger.New);
    }
}