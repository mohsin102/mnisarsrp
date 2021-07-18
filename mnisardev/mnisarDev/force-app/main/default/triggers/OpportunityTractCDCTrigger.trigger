trigger OpportunityTractCDCTrigger on Opportunity_Tract__ChangeEvent (after insert)  { 

	OpportunityTractTriggerHelper.recalcInventoryAssets(Trigger.new, Trigger.newMap);

	/*EventBus.ChangeEventHeader header = event.ChangeEventHeader;
	String changeEntity = header.entityName;
	String changeOperation = header.changeType;
	string changedFields = header.changedFields;

	System.debug('changeEntity value is: ' + changeEntity);
	System.debug('changeOperation value is: ' + changeOperation);
	System.debug('changeFields value is: ' + changeFields);*/
}