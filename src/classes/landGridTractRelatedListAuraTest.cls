@isTest 
private class landGridTractRelatedListAuraTest {

	@TestSetup
	static void setupTestData(){
		TestDataFactory.dataSetup();
	}
	@isTest
	private static void testName() {
		List<TitleWorkJob__c> twjs = [SELECT ID, landGridTract__c FROM TitleWorkJob__c];
		for(TitleWorkJob__c twj:twjs){
			List<TitleWorkJob__c> relatedTWJs = landGridTractRelatedListAura.getTitleWorkJobs(twj.landGridTract__c);
			//System.assertEquals(relatedTWJs.size(), 1);	
			List<Tract__c> relatedTracts = landGridTractRelatedListAura.getTracts(twj.landGridTract__c);
		}

	}
	
}