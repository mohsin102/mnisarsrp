public class tractUtility  {
	
	static final List<TitleSourceSettings__mdt> titleSourceSettings = [SELECT Label, DeveloperName FROM TitleSourceSettings__mdt];

	public static void updateTitleSourceResetDate(List<Tract__c> triggerNew, List<Tract__c> triggerOld, Map<Id, Tract__c> newMap, Map<Id, Tract__c> oldMap){
		System.debug('reset title source date called');
		Set<String> titleSourceFieldSet = new Set<String>();
		describerUtil describerUtility = new describerUtil();
		describerUtility.selectedObject = 'Tract__c';
		Map<String, Schema.SObjectField> fieldMap = describerUtility.getFields();
		for(TitleSourceSettings__mdt tss : titleSourceSettings){
			titleSourceFieldSet.add(tss.Label.toLowerCase());
			System.debug('fieldList includes: ' + tss.Label);
		}
		for(Id updateId: newMap.keySet()){
			for(String fieldName: fieldMap.keySet()){
				//System.debug('Field Type is: ' + fieldMap.get(fieldName).getDescribe().getType());
				System.debug('Field Name is: ' + fieldName  );
				
				//System.debug('Reference Target Field value: ' + fieldMap.get(fieldName).getDescribe().getReferenceTargetField());
				
				System.debug('if check newMap.get(updateId).get(fieldName) != oldMap.get(updateId).get(fieldName) value is: ' + (newMap.get(updateId).get(fieldName) != oldMap.get(updateId).get(fieldName)));
				System.debug('if check titleSourceFieldSet.contains(fieldName) value is: ' + titleSourceFieldSet.contains(fieldName));
				if((newMap.get(updateId).get(fieldName) != oldMap.get(updateId).get(fieldName))  && titleSourceFieldSet.contains(fieldName) ){
					System.debug('Setting reset date to ' + newMap.get(updateId).LastModifiedDate);
					newMap.get(updateId).titleSourceResetDate__c = Datetime.now();
				}
			}
		}
		
	}

	public static Map<String, tractTitleSourceValue> getTractTitleSource(List<Tract__c> inputTracts, Map<Id, Tract__c> newMap){
		System.debug('getTractTitleSource called');
		List<String> queryIds = new List<Id>();
		Map<String, tractTitleSourceValue> returnMap = new Map<String, tractTitleSourceValue>();
		Map<String, Datetime> lastTractClearDate = new Map<String, Datetime>();
		for(Tract__c inputTract: inputTracts){
			queryIds.add(inputTract.Id);
			tractTitleSourceValue newValue = new tractTitleSourceValue();
			newValue.tractId = inputTract.Id;
			returnMap.put(inputTract.Id, newValue);
			if(newMap.get(inputTract.Id).titleSourceResetDate__c != null){
				lastTractClearDate.put(inputTract.Id, newMap.get(inputTract.Id).titleSourceResetDate__c);
			}
		}
		/*for(String tractId: queryIds){
			System.debug('Tract Ids include: ' + tractId);
		}
		List<srpFieldHistory__c> fieldHistories = new List<srpFieldHistory__c>();
		List<String> fieldList = new List<String>();
		for(TitleSourceSettings__mdt tss : titleSourceSettings){
			fieldList.add(tss.Label);
			System.debug('fieldList includes: ' + tss.Label);
		}
		//System.debug(fieldList);
		fieldHistories = [SELECT CreatedDate, recordId__c, sObjectName__c, fieldName__c 
						  FROM srpFieldHistory__c 
						  WHERE sObjectName__c = 'Tract__c'
						  AND fieldName__c IN :fieldList
						  AND recordId__c IN :queryIds];*/
		List<tractReconciliation__c> tractReconciliations = new List<tractReconciliation__c>();
		tractReconciliations = [SELECT CreatedDate,targetOwnershipTract__c,Tract__c, targetOwnershipTract__r.targetOwnershipName__r.jobId__r.titleWorkJob__r.type__c, 
									targetOwnershipTract__r.targetOwnershipName__r.jobId__r.titleWorkJob__c, LastModifiedDate,
									targetOwnershipTract__r.targetOwnershipName__r.jobId__r.titleWorkJob__r.completionDate__c
								FROM tractReconciliation__c
								WHERE Tract__c IN :queryIds];
		//Build map to determine last time the Tract had a field update that should reset the Title Source field.
		/*for(srpFieldHistory__c fieldHistory : fieldHistories){
			if(lastTractClearDate.containsKey(fieldHistory.recordId__c)){
				if(fieldHistory.CreatedDate > lastTractClearDate.get(fieldHistory.recordId__c)){
					lastTractClearDate.put(fieldHistory.recordId__c, fieldHistory.CreatedDate);
				}			
			}
			else{
				lastTractClearDate.put(fieldHistory.recordId__c, fieldHistory.CreatedDate);
			}
		}*/

		//Loop through related reconciliations and create map with the latest Title Source values for the Tract.
		for(tractReconciliation__c tractReconciliation : tractReconciliations){
			tractTitleSourceValue newValue = new tractTitleSourceValue();
			newValue.createdDate = tractReconciliation.CreatedDate;
			newValue.twj.Id = tractReconciliation.targetOwnershipTract__r.targetOwnershipName__r.jobId__r.titleWorkJob__c;
			newValue.twj.completionDate__c = tractReconciliation.targetOwnershipTract__r.targetOwnershipName__r.jobId__r.titleWorkJob__r.completionDate__c;
			newValue.twj.type__c = tractReconciliation.targetOwnershipTract__r.targetOwnershipName__r.jobId__r.titleWorkJob__r.type__c;
			newValue.titleSource = tractReconciliation.targetOwnershipTract__r.targetOwnershipName__r.jobId__r.titleWorkJob__r.type__c;
			newValue.tractId = tractReconciliation.tract__c;
			//Tract has a clear date - only inlcude reconciliation Title Source if date is greater than last clear date
			if(lastTractClearDate.containsKey(tractReconciliation.Tract__c)){
				//System.debug('Tract has a clear date of : ' + lastTractClearDate.get(tractReconciliation.Tract__c));
				System.debug('Last Tract Clear Date value is: ' + lastTractClearDate.get(tractReconciliation.Tract__c) + ' tractReconciliation Last Modified Date is: ' + tractReconciliation.LastModifiedDate +
							 ' if statement evaluates to: ' + String.valueOf(lastTractClearDate.get(tractReconciliation.Tract__c) < tractReconciliation.LastModifiedDate));
					
				if(lastTractClearDate.get(tractReconciliation.Tract__c) <= tractReconciliation.LastModifiedDate){
					if(returnMap.containsKey(tractReconciliation.Tract__c)){
						returnMap.put(tractReconciliation.Tract__c, getHighestTitleSourceValue(returnMap.get(tractReconciliation.Tract__c),newValue)); 
					}
					else{
						returnMap.put(tractReconciliation.Tract__c, newValue); 
					}
				}
			}
			//Tract does not have a clear date - include any reconciliation Title Source data
			else{
				System.debug('No clear date');
				if(returnMap.containsKey(tractReconciliation.Tract__c)){
					System.debug('Adjusting existing item in return map');
					returnMap.put(tractReconciliation.Tract__c, getHighestTitleSourceValue(returnMap.get(tractReconciliation.Tract__c),newValue)); 
				}
				else{
					System.debug('Adding new item to return map with newValue type : ' + newValue.twj.type__c);
					returnMap.put(tractReconciliation.Tract__c, newValue); 
				} 
			}
		}

		return returnMap;
	}

		

	private static tractTitleSourceValue getHighestTitleSourceValue(tractTitleSourceValue oldValue, tractTitleSourceValue newValue){
		if(oldValue.twj.type__c == 'Attorney Review' && newValue.twj.type__c == 'Attorney Review'){
			if(newValue.twj.completionDate__c > oldValue.twj.completionDate__c){
				return newValue;
			}
			else{
				return oldValue;
			}
		}
		else if(oldValue.twj.type__c == 'Attorney Review'){
			return oldValue;
		}
		else if(newValue.twj.type__c == 'Attorney Review'){
			return newValue;
		}
		else if(oldValue.twj.type__c == 'Integration Review' && newValue.twj.type__c == 'Integration Review'){
			if(newValue.twj.completionDate__c > oldValue.twj.completionDate__c){
				return newValue;
			}
			else{
				return oldValue;
			}
		}
		else if(oldValue.twj.type__c == 'Integration Review'){
			return oldValue;
		}
		else if(newValue.twj.type__c == 'Integration Review'){
			return newValue;
		}
		else if(oldValue.twj.type__c == 'Landman' && newValue.twj.type__c == 'Landman'){
			if(newValue.twj.completionDate__c > oldValue.twj.completionDate__c){
				return newValue;
			}
			else{
				return oldValue;
			}
		}
		else if(oldValue.twj.type__c == 'Landman'){
			return oldValue;
		}
		else if(newValue.twj.type__c == 'Landman'){
			return newValue;
		}
		else{
			return newValue;
		}
	}


	public class tractTitleSourceValue{
		public String tractId {get; set;}
		public TitleWorkJob__c twj {get; set;}
		public String titleSource {get; set;}
		public Datetime createdDate {get; set;}

		public tractTitleSourceValue(){
			twj = new TitleWorkJob__c();
			tractId = '';
			titleSource = '';
		}
	}
}