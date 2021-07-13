trigger OpportunityTrigger on Opportunity (after insert, after update) {
 
        //if (TractTriggerHelper.tractUpdating != true) {
            //if (Trigger.isDelete) {
            //    OpportunityTriggerHelper.PreventDelete(Trigger.old,Trigger.oldMap);
            //}
    
            //if (Trigger.isBefore && Trigger.isUpdate) {
                //OpportunityTriggerHelper.SkipValidation(Trigger.new);
            //}
    
            // Update all related tracts to new owner on save
            if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
                OpportunityTriggerHelper.UpdateRelatedTracts(Trigger.old, Trigger.oldMap,Trigger.new, Trigger.newMap);
                
                
                if(Trigger.isUpdate){
                	  OpportunityTriggerHelper.updateOwnerEntityOnRevenueEstimates(Trigger.new,Trigger.oldMap);
                } 
            }
    
            // Update Opportunity, do calcs, field copies, etc.
            //if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
            //    OpportunityTriggerHelper.SetAmount(Trigger.new);
            //}
            
    
        //}
    }