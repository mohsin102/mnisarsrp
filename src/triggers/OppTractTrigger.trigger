trigger OppTractTrigger on Opportunity_Tract__c (before insert, before update, after insert) {
        //if (TractTriggerHelper.tractUpdating != true) {

		//Opportunity lock logic not implemented, commenting out this method (jdg 2-10-2020)
        //TractTriggerHelper.preventDelete(Trigger.old, Trigger.new);

        /*if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
                TractTriggerHelper.preventDupes(Trigger.new, Trigger.oldMap);
        }*/

        if (Trigger.isBefore && (Trigger.isInsert||Trigger.isUpdate)) {
                OpportunityTractTriggerHelper.recalcByOppTract(Trigger.new);
        }
        if(Trigger.isInsert && Trigger.isAfter){
            OpportunityTractTriggerHelper.updateRelatedTractRecords(Trigger.New);
        }
        //}
		//if(Trigger.isInsert && Trigger.isAfter){
        //OpportunityTractTriggerHelper.updateRelatedTractRecords(Trigger.New);
}