//Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap
trigger TitleOwnershipDetailTrigger on TitleOwnershipDetail__c (before insert, before update)  { 

    if (Trigger.isBefore){
        titleOwnershipDetailUtility.calculateInstrumentType(Trigger.new, Trigger.newMap);
    }

}