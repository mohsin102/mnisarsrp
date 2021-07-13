//Test class provides coverage for the following classes

//homeTitleWorkTrackerAura
//lgtTitleWorkTrackerAura
//newTitleWorkTrackerModalAura
//titleWorkTrackerAura
//titleWorkTrackingCardAura
//landGridTractRelatedListAura 
//lookupUtility


@isTest 
private class titleWorkAuraTest {

	@TestSetup
	static void setupTestData(){
		TestDataFactory.dataSetup();
	}

	@isTest
	private static void titleTrackerTest() {
		List<AuraSelectOption> workJobTypes = newTitleWorkTrackerModalAura.getWorkJobTypes(null);
		List<LookupSearchResult> currentUser = newTitleWorkTrackerModalAura.fetchUser();
		List<LandGridTract__c> lgts = [SELECT ID FROM LandGridTract__c];
		List<Id> fixedSearchResults = new List<Id>();
		for(LandGridTract__c lgt: lgts){
			fixedSearchResults.add(lgt.Id);
		} 
		Test.setFixedSearchResults(fixedSearchResults);
		List<LookupSearchResult> landGridTracts = newTitleWorkTrackerModalAura.searchLandGridTracts('Howard', new List<String>());
		fixedSearchResults.clear();
		List<Project_AOI__c> projectAOIs = [SELECT ID FROM Project_AOI__c];
		for(Project_AOI__c projectAOI: projectAOIs){
			fixedSearchResults.add(projectAOI.Id);
		}
		Test.setFixedSearchResults(fixedSearchResults);
		List<LookupSearchResult> lookupProjectAOIs = newTitleWorkTrackerModalAura.searchProjectAOIs('Test', new List<String>());
		fixedSearchResults.clear();
		List<User> users = [SELECT ID FROM User LIMIT 20];
		for(User u: users){
			fixedSearchResults.add(u.Id);
		}
		Test.setFixedSearchResults(fixedSearchResults);
		List<LookupSearchResult> lookupUsers = newTitleWorkTrackerModalAura.searchUsers('Testing', new List<String>());
		newTitleWorkTrackerModalAura.createTitleTrackerResponse trackerResponse = newTitleWorkTrackerModalAura.createTitleWorkTracker(null, String.valueOf(lgts[0].Id), null, workJobTypes[0].value, String.valueOf(currentUser[0].getId()), System.today(), true, 'Not Started', null);
		newTitleWorkTrackerModalAura.createTitleTrackerResponse trackerResponse2 = newTitleWorkTrackerModalAura.createTitleWorkTracker(null, String.valueOf(lgts[0].Id), null, workJobTypes[0].value, String.valueOf(currentUser[0].getId()), System.today(), true, 'Not Started', null);
		newTitleWorkTrackerModalAura.createTitleTrackerResponse trackerResponse3 = newTitleWorkTrackerModalAura.createTitleWorkTracker(String.valueOf(trackerResponse.titleWorkTracker.Id), String.valueOf(lgts[0].Id), '', workJobTypes[0].value, String.valueOf(currentUser[0].getId()), System.today(), false, 'Not Started', null);
		titleWorkTrackerAura.titleTrackerResponse titleTrackerResponse = titleWorkTrackerAura.getTitleTracker(trackerResponse.titleWorkTracker.Id);
		List<TitleWorkJob__c> titleWorkJobs = titleWorkTrackerAura.getTitleWorkJobs(lgts[0].Id);
		lgtTitleWorkTrackerAura.titleTrackerResponse lgtTitleTrackerResponse = lgtTitleWorkTrackerAura.getTitleTrackers(lgts[0].Id);
		List<TitleWorkJob__c> lgtTitleWorkJobs = lgtTitleWorkTrackerAura.getTitleWorkJobs(lgts[0].Id);
		List<TitleWorkJob__c> homeTitleWorkJobs = homeTitleWorkTrackerAura.getTitleWorkJobs(lgts[0].Id);
		homeTitleWorkTrackerAura.titleTrackerResponse homeTrackerResponse = homeTitleWorkTrackerAura.getTitleTrackers('In Progress');
		String updateTrackerResponseComplete = titleWorkTrackingCardAura.updateTitleWorkComplete(trackerResponse.titleWorkTracker, 'TitleWorkTracker__c');
		String updateLGTResponseComplete = titleWorkTrackingCardAura.updateTitleWorkComplete(lgts[0], 'LandGridTract__c');
		homeTitleWorkTrackerAura.titleTrackerResponse homeTrackerResponse2 = homeTitleWorkTrackerAura.getTitleTrackers('Complete');
		List<TitleWorkTracker__c> twts = landGridTractRelatedListAura.getTitleWorkTrackers(lgts[0].Id);
		List<TitleWorkJob__c> twjs = [SELECT ID, landGridTract__c FROM TitleWorkJob__c];
		for(TitleWorkJob__c twj:twjs){
			List<TitleWorkJob__c> relatedTWJs = landGridTractRelatedListAura.getTitleWorkJobs(twj.landGridTract__c);
			//System.assertEquals(relatedTWJs.size(), 1);	
			List<Tract__c> relatedTracts = landGridTractRelatedListAura.getTracts(twj.landGridTract__c);
		}
        
        Test.setFixedSearchResults(fixedSearchResults);
		List<LookupSearchResult> acctSearchRes = lookupUtility.searchAccounts('New Account', new List<String>());
		fixedSearchResults.clear();     
	}
	
}