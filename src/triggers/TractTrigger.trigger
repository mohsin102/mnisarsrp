trigger TractTrigger on Tract__c (after update, before delete, before update,after insert, before insert) {

		System.debug('Trigger on Tract isBefore value is: ' + Trigger.isBefore);
		System.debug('Trigger on Tract isAfter value is: ' + Trigger.isAfter);
		System.debug('Trigger on Tract isUpdate value is: ' + Trigger.isUpdate);
		System.debug('Trigger on Tract isDelete value is: ' + Trigger.isDelete);

		//System.debug('Trigger on Tract tractUpdating value is: ' + TractTriggerHelper.tractUpdating);
		System.debug('Current User Id is: ' + UserInfo.getUserId() + ' current user name is: ' + UserInfo.getName());
        //if (TractTriggerHelper.tractUpdating != true) {
				
            if (Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)) {
                TractTriggerHelper.recalcTractRelatedItems(Trigger.newMap, Trigger.oldMap);
            }
			if (Trigger.isBefore && Trigger.isUpdate) {
				srpFieldHistoryUtility.srpHistoryCreate(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap, 'Tract__c');
				tractUtility.updateTitleSourceResetDate(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
				Map<String, tractUtility.tractTitleSourceValue> titleSourceResult = tractUtility.getTractTitleSource(Trigger.new, Trigger.newMap);
				for(String tractId: titleSourceResult.keySet()){
					Tract__c updateTract = Trigger.newMap.get(tractId);
					//updateTract.titleSourceType__c = titleSourceResult.get(String.valueOf(tractId)).titleSource;	
					updateTract.titleSource__c = titleSourceResult.get(String.valueOf(tractId)).twj.Id;
				}
			}
			//else if (Trigger.isBefore && Trigger.isInsert){
			//	Map<String, tractUtility.tractTitleSourceValue> titleSourceResult = tractUtility.getTractTitleSource(Trigger.new);
			//	for(String tractId: titleSourceResult.keySet()){
			//		Tract__c updateTract = Trigger.newMap.get(tractId);
			//		updateTract.titleSource__c = titleSourceResult.get(String.valueOf(tractId)).titleSource;	
			//	}
			//}
			

			else if (Trigger.isBefore && Trigger.isDelete) {
                TractTriggerHelper.deleteTractRelatedItems(Trigger.oldMap);
				srpFieldHistoryUtility.srpHistoryDelete(Trigger.old, Trigger.oldMap, 'Tract__c');
            }
        //}
}