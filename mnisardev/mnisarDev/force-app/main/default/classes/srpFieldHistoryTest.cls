//Provides test coverage for multiple classes including:
	//srpFieldHistoryConversion
	//srpFieldHistoryConversionSchedule
	//srpFieldHistoryDeleteSchedule
	//srpFieldHistoryUtility
	//SRPFieldHistoryTrigger
	//DeleteSRPFieldHistory
	//srpFieldHistoryRelatedListAura
@isTest 
private class srpFieldHistoryTest {

	@TestSetup
	static void tractReconciliationTestData(){
		TestDataFactory.dataSetup();
	}

	@isTest
	private static void mainMethod() {
		SRPFieldHistoryConversionSettings__c conversionSettings = SRPFieldHistoryConversionSettings__c.getOrgDefaults();
		List<Tract__c> allTracts = [SELECT ID FROM Tract__c];
		conversionSettings.deleteSize__c = 40000;
		conversionSettings.beginDeleteId__c = allTracts[0].Id;
		conversionSettings.referenceIdGroupSize__c = 5;
		Account a = new Account(Name = 'New Test Account');
		insert a;
		List<CronTrigger> currentTrigger = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'SRP Field History Conversion'];
		if(currentTrigger.size() > 0){
			System.abortJob(currentTrigger[0].Id);
		}
		currentTrigger = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'SRP Field History Delete'];
		if(currentTrigger.size() > 0){
			System.abortJob(currentTrigger[0].Id);
		}
		currentTrigger = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'SRP Tract Formula Field History Delete'];
		if(currentTrigger.size() > 0){
			System.abortJob(currentTrigger[0].Id);
		}
		System.debug('Count of Tracts is: ' + allTracts.size());
		for(Tract__c tract: allTracts){
			tract.netAcres__c = 5;
			tract.Account__c = a.Id; 
		}
		update allTracts;
		List<Tract__c> newTract = TestDataFactory.createTracts(1, a);
		insert newTract;
		delete newTract;
		List<srpFieldHistory__c> originalRegularHistory = [SELECT ID FROM srpFieldHistory__c];
		originalRegularHistory[0].conversionErrorCount__c = 5;
		update originalRegularHistory;
		Test.startTest();
		srpFieldHistoryConversion conversion = new srpFieldHistoryConversion();
		conversionSettings.conversionSize__c = 1000;
		update conversionSettings;
		currentTrigger = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'SRP Field History Conversion'];
		if(currentTrigger.size() > 0){
			System.abortJob(currentTrigger[0].Id);
		}
		srpFieldHistoryConversion newConversion = new srpFieldHistoryConversion();
		//DeleteTractFormulaHistorySchedule deleteHandler = new DeleteTractFormulaHistorySchedule();
		DeleteTractFormulaHistory newTractDeletion = new DeleteTractFormulaHistory();
		DeleteSRPFieldHistory newDeletion = new DeleteSRPFieldHistory();
		
		Test.stopTest();
		List<srpFieldHistory__c> regularHistory = [SELECT ID FROM srpFieldHistory__c];
		List<boSRPFieldHistory__b> bigObjectHistory = [SELECT action__c,CreatedById,CreatedDate,fieldNameIndex__c,historyCreatedDate__c,Id,recordId__c,sObjectNameIndex__c,sObjectName__c FROM boSRPFieldHistory__b];
		List<boSRPFieldHistory__b> componentHistory = srpFieldHistoryRelatedListAura.getRelatedHistory(allTracts[0].Id, 'Tract__c');
		System.debug('regularHistory size is: ' + regularHistory.size() + ' bigObjectHistory size is: ' + bigObjectHistory.size());
		
	}
	



}