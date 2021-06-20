trigger MonthlyProductionTrigger on Monthly_Production__c(after insert){

    if(Trigger.isInsert && Trigger.isAfter){

        MonthlyProductionTriggerHelper.createOwnerInterestRevenue(Trigger.New);
    }
}