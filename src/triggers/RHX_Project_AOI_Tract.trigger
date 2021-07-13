trigger RHX_Project_AOI_Tract on Project_AOI_Tract__c
    (after delete, after insert, after undelete, after update, before delete) {
  	 //TractTriggerHelper.tractUpdating = true;
	 Type rollClass = System.Type.forName('rh2', 'ParentUtil');
	 if(rollClass != null) {
		rh2.ParentUtil pu = (rh2.ParentUtil) rollClass.newInstance();
		if (trigger.isAfter) {
			pu.performTriggerRollups(trigger.oldMap, trigger.newMap, new String[]{'Project_AOI_Tract__c'}, null);
    	}
    }
}