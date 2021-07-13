@isTest 
private class TestDataFactoryTest {

	@TestSetup
	static void tractReconciliationTestData(){
		TestDataFactory.dataSetup();
		TitleIntegrationJob__c tpj = [SELECT ID FROM TitleIntegrationJob__c LIMIT 1];
		String str = 'Party,Final,Address,Notes,Lease,Book,Page,Inst.,Lease LOR,Executive,Royalty,NPRI8,Bonus,Delay,Ingress,WI,NRI,LOR,OI,Area,Gr.Ac.,NMRA,NLRA,Depth,Mineral,State,County,Location,Status,Assigned User\r' +
							'Sherri Lee Hollis,final,"6405 Hamstead Dr. Amarillo, TX 79109",,1020/432,1020,432,,0.1875,0.11111111,0.02222222,,0.02222222,0.02222222,0.02222222,,,0.00416667,,SW,160.00,3.55555556,0.66666667,,,TX,Howard,031-02N-009,Initial Rev.,MSB\r'+
							'Sherri Lee Hollis,final,"6405 Hamstead Dr. Amarillo, TX 79109",,1253/16,1253,16,,0.25,,0.00444444,,0.00444444,0.00444444,0.00444444,,,0.00111111,,N2,320.00,1.42222222,0.35555556,,,TX,Howard,031-02N-009,Initial Rev.,MSB\r'+
							'Sherri Lee Hollis,final,"6405 Hamstead Dr. Amarillo, TX 79109",,1253/19,1253,19,,0.25,,0.00444444,,0.00444444,0.00444444,0.00444444,,,0.00111111,,N2,320.00,1.42222222,0.35555556,,,TX,Howard,031-02N-009,Initial Rev.,MSB\r'+
							'Sherri Lee Hollis,final,"6405 Hamstead Dr. Amarillo, TX 79109",,1253/13,1253,13,,0.25,,0.00444444,,0.00444444,0.00444444,0.00444444,,,0.00111111,,N2,320.00,1.42222222,0.35555556,,,TX,Howard,031-02N-009,Initial Rev.,MSB\r'+
							'Sherri Lee Hollis,final,"6405 Hamstead Dr. Amarillo, TX 79109",,1253/22,1253,22,,0.25,0.11111111,0.02222222,,0.02222222,0.02222222,0.02222222,,,0.00555556,,SE,160.00,3.55555556,0.88888889,,,TX,Howard,031-02N-009,Initial Rev.,MSB\r';
		String[] csvFileLines;
		Blob csvFileBody;
		//ContentDocument newDocument = new ContentDocument();
		ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        //cv.ContentDocumentId = contentDocumentId;
        cv.VersionData = Blob.valueOf(str);
        cv.Title = 'flatFileTest.csv';
		cv.FirstPublishLocationId = tpj.Id;
		//cv.FileExtension = 'csv';
		//cv.FileType = 'csv';
        cv.PathOnClient = 'flatFileTest.csv';
        
        insert cv;
		//newDocument.Title = 'flatFileTest';
		//Insert newDocument;
		System.debug('newDocumentId value is: ' + cv.Id);
		
	}



    static testmethod void mainMethod(){
		Test.startTest();

		Profile userProfile = [Select ID, Name from Profile Where Name = :'Standard User' LIMIT 1];
		Profile adminProfile = [Select ID, Name from Profile Where Name = :'System Administrator' LIMIT 1];


		List<LandGridTract__c> landGridTracts = [SELECT ID FROM LandGridTract__c];
		System.assertEquals(12, landGridTracts.size());

        List<Account> accounts = [SELECT ID FROM Account];
		System.assertEquals(5, accounts.size());

        List<Tract__c> tracts = [SELECT ID FROM Tract__c];
		System.assertEquals(12, tracts.size());

		List<Subtract__c> subtracts = [SELECT ID FROM Subtract__c];
		System.assertEquals(12, subtracts.size());

		List<Project_AOI__c> projectAOIs = [SELECT ID FROM Project_AOI__c];
		System.assertEquals(3, projectAOIs.size());

		List<Project_AOI_Tract__c> projectAOITracts = [SELECT ID FROM Project_AOI_Tract__c];
		System.assertEquals(36, projectAOITracts.size());

        List<Opportunity> opps = [SELECT ID FROM Opportunity];
		System.assertEquals(1, opps.size());

        List<Case> cases = [SELECT ID FROM Case];
		System.assertEquals(5, cases.size());

        List<Opportunity_Tract__c> ots = [SELECT ID FROM Opportunity_Tract__c];
		System.assertEquals(12, ots.size());

        //List<Case_Tract__c> cts = [SELECT ID FROM Case_Tract__c];
		//System.assertEquals(60, cts.size());

		List<TitleIntegrationJob__c> tpjs = [SELECT ID FROM TitleIntegrationJob__c];
		System.assertEquals(5, tpjs.size());
		
		List<Evaluation__c> evals = [SELECT ID FROM Evaluation__c];
		System.assertEquals(2, evals.size());

		Test.stopTest();
	}
	
}