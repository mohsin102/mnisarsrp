@isTest
public class mapControllerV2Test {

	@TestSetup
	static void setupTestData(){
		TestDataFactory.dataSetup();
	}

    static testMethod void testmapControllerV2() {
        //TestDataFactory.dataSetup();

		List<Tract__c> tracts = [SELECT ID FROM Tract__c LIMIT 3];
		//List<Opportunity> opps = [SELECT ID FROM Opportunity LIMIT 1];
		//List<Subtract__c> subtracts = [SELECT ID FROM Subtract__c LIMIT 1];
		//List<Well__c> wells = [SELECT ID FROM Well__c LIMIT 1];
		//List<Account> accounts = [SELECT ID FROM Account LIMIT 1];
		//List<GIS_Update_Request__c> gisUpdateRequests = [SELECT ID FROM GIS_Update_Request__c LIMIT 1];
		//List<Unit__c> units = [SELECT ID FROM Unit__c LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class,new ArcgisMock());
        mapControllerV2.getMaps(tracts[0].Id,'Tract__c');
        // Call again immediately to test caching of token
        mapControllerV2.getMaps(tracts[1].Id,'Tract__c');
        mapControllerV2.getMaps(tracts[2].Id,'Tract__c');
        //mapControllerV2.getMaps(opps[0].Id,'Opportunity');
		//mapControllerV2.getMaps(subtracts[0].Id, 'Subtract__c');
		//mapControllerV2.getMaps(wells[0].Id, 'Well__c');
		//mapControllerV2.getMaps(accounts[0].Id, 'Account');
		//mapControllerV2.getMaps(gisUpdateRequests[0].Id, 'GIS_Update_Request__c');
		//mapControllerV2.getMaps(units[0].Id, 'Unit__c');
        //mapControllerV2.getMaps(cases[2].Id,'Case');

        //Test.setMock(HttpCalloutMock.class,new ArcgisWellMock());
        //mapControllerV2.getWellPermitInfo(tracts[0].Id,'Tract__c','Tract');

        Test.stopTest();

    }

	static testMethod void testmapControllerV22() {
        //TestDataFactory.dataSetup();

		//List<Tract__c> tracts = [SELECT ID FROM Tract__c LIMIT 3];
		//List<Opportunity> opps = [SELECT ID FROM Opportunity LIMIT 1];
		//List<Subtract__c> subtracts = [SELECT ID FROM Subtract__c LIMIT 1];
		List<Well__c> wells = [SELECT ID FROM Well__c LIMIT 1];
		List<Account> accounts = [SELECT ID FROM Account LIMIT 1];
		//List<GIS_Update_Request__c> gisUpdateRequests = [SELECT ID FROM GIS_Update_Request__c LIMIT 1];
		//List<Unit__c> units = [SELECT ID FROM Unit__c LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class,new ArcgisMock());
        //mapControllerV2.getMaps(tracts[0].Id,'Tract__c');
        // Call again immediately to test caching of token
        //mapControllerV2.getMaps(tracts[1].Id,'Tract__c');
        //mapControllerV2.getMaps(tracts[2].Id,'Tract__c');
        //mapControllerV2.getMaps(opps[0].Id,'Opportunity');
		//mapControllerV2.getMaps(subtracts[0].Id, 'Subtract__c');
		mapControllerV2.getMaps(wells[0].Id, 'Well__c');
		mapControllerV2.getMaps(accounts[0].Id, 'Account');
		//mapControllerV2.getMaps(gisUpdateRequests[0].Id, 'GIS_Update_Request__c');
		//mapControllerV2.getMaps(units[0].Id, 'Unit__c');
        //mapControllerV2.getMaps(cases[2].Id,'Case');

        //Test.setMock(HttpCalloutMock.class,new ArcgisWellMock());
        //mapControllerV2.getWellPermitInfo(tracts[0].Id,'Tract__c','Tract');

        Test.stopTest();

    }

		static testMethod void testmapControllerV23() {
        //TestDataFactory.dataSetup();

		//List<Tract__c> tracts = [SELECT ID FROM Tract__c LIMIT 3];
		//List<Opportunity> opps = [SELECT ID FROM Opportunity LIMIT 1];
		//List<Subtract__c> subtracts = [SELECT ID FROM Subtract__c LIMIT 1];
		//List<Well__c> wells = [SELECT ID FROM Well__c LIMIT 1];
		//List<Account> accounts = [SELECT ID FROM Account LIMIT 1];
		List<GIS_Update_Request__c> gisUpdateRequests = [SELECT ID FROM GIS_Update_Request__c LIMIT 1];
		List<Unit__c> units = [SELECT ID FROM Unit__c LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class,new ArcgisMock());
        //mapControllerV2.getMaps(tracts[0].Id,'Tract__c');
        // Call again immediately to test caching of token
        //mapControllerV2.getMaps(tracts[1].Id,'Tract__c');
        //mapControllerV2.getMaps(tracts[2].Id,'Tract__c');
        //mapControllerV2.getMaps(opps[0].Id,'Opportunity');
		//mapControllerV2.getMaps(subtracts[0].Id, 'Subtract__c');
		//mapControllerV2.getMaps(wells[0].Id, 'Well__c');
		//mapControllerV2.getMaps(accounts[0].Id, 'Account');
		mapControllerV2.getMaps(gisUpdateRequests[0].Id, 'GIS_Update_Request__c');
		mapControllerV2.getMaps(units[0].Id, 'Unit__c');
        //mapControllerV2.getMaps(cases[2].Id,'Case');

       // Test.setMock(HttpCalloutMock.class,new ArcgisWellMock());
        //mapControllerV2.getWellPermitInfo(tracts[0].Id,'Tract__c','Tract');

        Test.stopTest();

    }

		static testMethod void testmapControllerV24() {
        //TestDataFactory.dataSetup();

		//List<Tract__c> tracts = [SELECT ID FROM Tract__c LIMIT 3];
		List<Opportunity> opps = [SELECT ID FROM Opportunity LIMIT 1];
		List<Subtract__c> subtracts = [SELECT ID FROM Subtract__c LIMIT 1];
		//List<Well__c> wells = [SELECT ID FROM Well__c LIMIT 1];
		//List<Account> accounts = [SELECT ID FROM Account LIMIT 1];
		//List<GIS_Update_Request__c> gisUpdateRequests = [SELECT ID FROM GIS_Update_Request__c LIMIT 1];
		//List<Unit__c> units = [SELECT ID FROM Unit__c LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class,new ArcgisMock());
        //mapControllerV2.getMaps(tracts[0].Id,'Tract__c');
        // Call again immediately to test caching of token
        //mapControllerV2.getMaps(tracts[1].Id,'Tract__c');
        //mapControllerV2.getMaps(tracts[2].Id,'Tract__c');
        mapControllerV2.getMaps(opps[0].Id,'Opportunity');
		mapControllerV2.getMaps(subtracts[0].Id, 'Subtract__c');
		//mapControllerV2.getMaps(wells[0].Id, 'Well__c');
		//mapControllerV2.getMaps(accounts[0].Id, 'Account');
		//mapControllerV2.getMaps(gisUpdateRequests[0].Id, 'GIS_Update_Request__c');
		//mapControllerV2.getMaps(units[0].Id, 'Unit__c');
        //mapControllerV2.getMaps(cases[2].Id,'Case');

        //Test.setMock(HttpCalloutMock.class,new ArcgisWellMock());
        //mapControllerV2.getWellPermitInfo(tracts[0].Id,'Tract__c','Tract');

        Test.stopTest();

    }


}