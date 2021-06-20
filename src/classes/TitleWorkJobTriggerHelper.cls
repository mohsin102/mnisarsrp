public class TitleWorkJobTriggerHelper  {

	public static void updateTitleWorkTrackers(Map<Id,TitleWorkJob__c> newMap, Map<Id,TitleWorkJob__c> oldMap)
    {
		system.debug('------TitleWorkJobTriggerHelper');
		Map<Id, Date> trackerIds = new Map<Id, Date>();
		
		for(Id twjId : newMap.keySet()){
			if((oldMap == null || newMap.get(twjId).status__c != oldMap.get(twjId).status__c) && newMap.get(twjId).status__c != 'Not Started'){
				trackerIds.put(newMap.get(twjId).titleWorkTracker__c, newMap.get(twjId).startDate__c);
			}
		}
		List<TitleWorkTracker__c> parentTrackers = [SELECT Id, status__c, startDate__c FROM TitleWorkTracker__c WHERE Id IN :trackerIds.keySet()];
		List<TitleWorkTracker__c> updateTrackers = new List<TitleWorkTracker__c>();
		for(TitleWorkTracker__c parentTracker : parentTrackers){
			if(parentTracker.status__c == 'Not Started'){
				parentTracker.status__c = 'In Progress';
				parentTracker.startDate__c = trackerIds.get(parentTracker.Id);
				updateTrackers.add(parentTracker);
			}
		}
		
		update updateTrackers;
	}


}