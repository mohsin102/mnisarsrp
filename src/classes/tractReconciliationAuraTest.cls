//Test class created by John Gorrell 11/05/2019

//Provides code coverage for the following classes:
//	tpjImportItemsAura
//	totBuilderAura
//	CSVFileUtil
//	describerUtil
//	tractReconciliationoAura
//	Partial coverage of TractTrigger and TractTriggerHelper
// tpjTONListAura
// tpjQuarterCallMapping

@isTest 
private class tractReconciliationAuraTest {

	@TestSetup
	static void tractReconciliationTestData(){
		TestDataFactory.dataSetup();
		List<ContentVersion> insertDataFiles = new List<ContentVersion>();
		TitleIntegrationJob__c tpj = [SELECT ID FROM TitleIntegrationJob__c LIMIT 1];
		String str = 'Party,Final,Address,Notes,Lease,Book,Page,Inst.,Lease LOR,Executive,Royalty,NPRI8,Bonus,Delay,Ingress,WI,NRI,LOR,OI,Area,Gr.Ac.,NMRA,NLRA,Depth,Mineral,State,County,Location,Status,Assigned User\r' +
							'Sherri Lee Hollis,final,"6405 Hamstead Dr. Amarillo, TX 79109",,1020/432,1020,432,,0.1875,0.11111111,0.02222222,,0.02222222,0.02222222,0.02222222,,,0.00416667,,SW,160.00,3.55555556,0.66666667,,,TX,Howard,031-02N-009,Initial Rev.,MSB\r'+
							'Sherri Lee Hollis,final,"6405 Hamstead Dr. Amarillo, TX 79109",,1253/16,1253,16,,0.25,,0.00444444,,0.00444444,0.00444444,0.00444444,,,0.00111111,,N2,320.00,1.42222222,0.35555556,,,TX,Howard,031-02N-009,Initial Rev.,MSB\r'+
							'Sherri Lee Hollis,final,"6405 Hamstead Dr. Amarillo, TX 79109",,1253/19,1253,19,,0.25,,0.00444444,,0.00444444,0.00444444,0.00444444,,,0.00111111,,N2,320.00,1.42222222,0.35555556,,,TX,Howard,031-02N-009,Initial Rev.,MSB\r'+
							'Sherri Lee Hollis,final,"6405 Hamstead Dr. Amarillo, TX 79109",,1253/13,1253,13,,0.25,,0.00444444,,0.00444444,0.00444444,0.00444444,,,0.00111111,,N2,320.00,1.42222222,0.35555556,,,TX,Howard,031-02N-009,Initial Rev.,MSB\r'+
							'Sherri Lee Hollis,final,"6405 Hamstead Dr. Amarillo, TX 79109",,1253/22,1253,22,,0.25,0.11111111,0.02222222,,0.02222222,0.02222222,0.02222222,,,0.00555556,,SE,160.00,3.55555556,0.88888889,,,TX,Howard,031-02N-009,Initial Rev.,MSB\r';
		ContentVersion cv = new ContentVersion();
		
        cv.ContentLocation = 'S';
        //cv.ContentDocumentId = contentDocumentId;
        cv.VersionData = Blob.valueOf(str);
        cv.Title = 'flatFileTest.csv';
		cv.FirstPublishLocationId = tpj.Id;
		//cv.FileExtension = 'csv';
		//cv.FileType = 'csv';
        cv.PathOnClient = 'flatFileTest.csv';
        insertDataFiles.add(cv);

		String str2 = 'Class,Type,Subtype,Grantor,Grantee,Date,Recorded,Inst.Date,Acknowledged,Filed,Booktype,Book,Page,Inst.No.,County/State,Notes,Requirements,Essences,Flags,Restrictions,Warnings,Files\r'+
					   'CD,convey,LANDMAN STATEMENT,LANDMAN STATEMENT,,01/01/1700,01/01/1700,01/01/1700,,01/01/1700,,,,,"Howard, TX","This report covers instruments from the records of the County Clerk in Howard County, Texas from Patent through 8/23/2019.  '+
						'There were several problems with this section to make note of, beginning with Minnie Smith intending for each of her 5 children to own 1 section of surface fee simple, but share equally in the mineral estate. However, this was not how the title played out in the subject lands, beginning in 138/80, in which Minnie conveys all of her interest in the W/2, including her mineral interest. Subsequent to this, Minnie\'s children convey out several NPRI\'s. Then, in 1991, a Stipulation of Interest as to all of Section 8 is signed by all of the minerals owners at the time. However, this Stipulation did not make any mention of any royalty ownership. This is the same with the 2014 Stipulation of Interest. Due to neither of these Stipulations mentioning the royalties, and the fact that the NPRI\'s were conveyed out prior to the Stipulations, the final ownership interests for this report are different in the W/2 and the E/2. The interests listed on the Tax Rolls found on DrillingInfo do not match the interests found in this report. ' +
						'Examiner was able to obtain a similar interest as found on DI by averaging the royalty interests that a final owner has as to this report, and multiplying the average by the assumed lease royalty.' +
						'It is assumed that all of the Memo OGL\'s in this section include a 1/4 royalty. This is based on the tax rolls crediting SM Energy with 75% NRI, and no instruments of record in which any ORRI is reserved or conveyed.' +
						'Examiner was unable to properly calculate the ingress interests in this report. The Ownership tab no longer shows this interest in Tracts. Additionally, the Stipulations did not state who owned the ingress, even with these interests having been broken up prior in title.   ' +
						'Cordero currently owns in this section.  Rrig bought a mineral interest from ES3 Minerals LLC who purchased the full interest of the estate of Mary Christine Smith.  RRig purchased ""a full, unburdened 58.85/638.5"", however, Grantors do not have a ""full, unburdened"" 58.85/638.5 in the royalty estate of the west half.  They have only .07550248 (58.85/638.5 = .09216915).  Examiner has passed all their royalty interest in the west half.  To the extent RRig Energy, LLC or ES3 claims an interest greater than our ownership reports, curative may be required.'+
						'ES3 Minerals, LLC is left with a 0.783085% interest in the Mineral Estate less and except the royalty. ",,,,,,\r'+
						'NCD,misc,Survey,"D. L. Cunningham, Surveyor",,11/17/1876,3/2/1928,FALSE,FALSE,FALSE,,68,295,,"Howard, TX","Confirms the survey, plat and field notes for Sec 8, B31, T2N as filed at 38/56 and 13/56, being 640 acres.",,,,,,volume-68_page-295_02eafb8c-07ee-4e2e-b0b3-4cd9f6094acf.pdf\r'+
						'CD,convey,Patent,"State of Texas Coke R. Stevenson, Governor of the State of Texas","Mrs. Minnie Smith J. N. Groves",12/08/1898,12/1/1943,12/08/1898,,12/1/1943,,117,338,,"Howard, TX","Grants to Mrs. Minnie Smith, 638.6 acres of land situated in Howard County, known as Survey 8, Certificate 2/188, Block 31, T2N.'+
						'Bought and fully paid for on the application of J. N. Graves filed in the General Land Office 12/8/1898, under the laws regulating the sale of Public Free School land.  Section said to be 638.6 acres",,"For the purpose of tracts, as no certificate was found filed of record for Certificate 2/188 in regards to subject lands,'+
						' examiner conveyed to J. N. Groves all interest at the date he filed application in the General Land Office.",,,,"0117_0338.pdf 2.188.pdf"\r'+
						'CD,convey,QCD,J. N. Groves,Wm. Reed,12/26/1899,12/26/1899,12/26/1899,,12/26/1899,,7,356,,"Howard, TX","Quitclaims all my interest in that certain tract of State School Land known as Section 8, Block 31, North Certificate 7188.  Said land was sold and awarded by A. J. Baker General Land Commissioner to J. N. Groves on 12/8/1898.",,,,,,volume-7_page-356_1d7acf50-9884-4022-9655-6654cbd800d9.pdf\r';
		System.debug('Length of str2 is: ' + str2.length());
		ContentVersion cv2 = new ContentVersion();
        cv2.ContentLocation = 'S';
        //cv.ContentDocumentId = contentDocumentId;
        cv2.VersionData = Blob.valueOf(str2);
        cv2.Title = 'runSheetTest.csv';
		cv2.FirstPublishLocationId = tpj.Id;
		//cv.FileExtension = 'csv';
		//cv.FileType = 'csv';
        cv2.PathOnClient = 'runSheetTest.csv';
        insertDataFiles.add(cv2);

        insert insertDataFiles;
		
		//newDocument.Title = 'flatFileTest';
		//Insert newDocument;
		System.debug('new FlatFile DocumentId value is: ' + cv.ContentDocumentId + ' new runSheet DocumentId value is: ' + cv2.ContentDocumentId);
		System.debug('flatFile String length is: ' + cv.VersionData.size());
		System.debug('runSheet String length is: ' + cv2.VersionData.size());
	}



    static testmethod void mainMethod(){
        Test.startTest();       
		ContentVersion cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'flatFileTest.csv' LIMIT 1];
		ContentVersion cv2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'runSheetTest.csv' LIMIT 1];
		System.debug('Flatfile ContentDocumentId is: ' + cv.ContentDocumentId + ' runSheet ContentDocumentId is: ' + cv2.ContentDocumentId);
		TitleIntegrationJob__c tpj = [SELECT ID FROM TitleIntegrationJob__c LIMIT 1];
		String testCount = tpjImportItemsAura.importRecords(cv.ContentDocumentId, tpj.Id, 'flatFile');
		System.assertEquals(testCount, 'SUCCESS');
		//System.debug('testCount value: ' + testCount);
		testCount = tpjImportItemsAura.importRecords(cv.ContentDocumentId, tpj.Id, 'flatFile');
		System.assertEquals(testCount, 'Flat file has already been loaded for this TPJ.');
		List<TitleOwnershipDetail__c> todList = [SELECT Id, targetOwnershipName__c, targetOwnershipName__r.jobId__c FROM TitleOwnershipDetail__c];
		System.debug('todList size is: ' + todList.size());
		for(TitleOwnershipDetail__c tod: todList){
			System.debug('TitleOwnershipDetail Id is: ' + tod.Id + ' jobId is: ' + tod.targetOwnershipName__r.jobId__c);
		}
		//System.debug('testCount value: ' + testCount);
		//System.debug('Processing runSheet next.');
		testCount = tpjImportItemsAura.importRecords(cv2.ContentDocumentId, tpj.Id, 'runSheet');
		System.assertEquals(testCount, 'SUCCESS');
		//System.debug('testCount value: ' + testCount);
		testCount = tpjImportItemsAura.importRecords(cv2.ContentDocumentId, tpj.Id, 'runSheet');
		System.assertEquals(testCount, 'Run Sheet has already been loaded for this TPJ.');
		//System.debug('testCount value: ' + testCount);
		//System.debug('Base URL is: ' + Url.getSalesforceBaseUrl().toExternalForm());
		Test.stopTest();
		List<quarterCallMapping__c> qcMappings = tpjQuarterCallMappingAura.getMappings(tpj.Id);
		for(quarterCallMapping__c qcMapping: qcMappings){
			qcMapping.quarterCall__c = qcMapping.area__c + ' Test';
		}
		String qcMappingsUpdated = tpjQuarterCallMappingAura.updateMappings(qcMappings, tpj.Id);
		String lockQCMapping = tpjQuarterCallMappingAura.lockQuarterCallMap(tpj.Id);
		System.assertEquals(qcMappingsUpdated, 'Success');
		List<TargetOwnershipName__c> tons = [SELECT ID, ownerName__c FROM TargetOwnershipName__c];
		for(TargetOwnershipName__c ton: tons){
			System.debug('TON values are ownerName__c: ' + ton.ownerName__c);
		}
		System.assertEquals(tons.size(), 1);
		TargetOwnershipName__c ton = tons[0];
		
		List<tpjTONListAura.tonListWrapper> tpjTONS = tpjTONListAura.getTONs(tpj.Id);
		System.assertEquals(tpjTONS.size(), 1);

		List<Account> accountList = [SELECT ID, Name FROM Account];
		List<Id> fixedSearchResults = new List<Id>();
		for(account a: accountList){
			fixedSearchResults.add(a.Id);
		} 
		Test.setFixedSearchResults(fixedSearchResults);
		System.debug(accountList);

		Boolean hasLockedTots = totBuilderAura.hasLockedTots(tpjTONS[0].tonId);
		System.assertEquals(hasLockedTots, false);
		
		
		totBuilderAura.totBuilderResponse tbr = totBuilderAura.getBuilderData(ton.Id);
		//actual insertion of records is now in a future method and will not return immediate results.  Commenting out verification.  jdg 05-16-2020
		System.assertEquals(tbr.allTors.size(), 5);
		System.assertEquals(tbr.allTots.size(), 0);
		tpjTONListAura.accountSearchResponse initialResponse = tpjTONListAura.getSearchResults(tpjTONS[0].ton.ownerName__c, 1, tpjTONS[0].tonId);
		initialResponse = tpjTONListAura.getSearchResults('New', 0, tpjTONS[0].tonId);
		for(TitleOwnershipDetail__c tor:tbr.allTors){
			tor.torGroupNum__c = Math.floor(Math.random() * 2);
		}
		List<totBuilderAura.totGroup> newTots = totBuilderAura.getNewTots2(tbr.allTors);
		System.assert(newTots.size() > 0);
		System.assert(newTots.size() <=2);
		String savedTots = totBuilderAura.saveNewTots(newTots);
		System.assertEquals(savedTots, 'Success');
		totBuilderAura.totViewerResponse viewerResponse = totBuilderAura.getSavedTots2(ton.Id);
		System.assertEquals(viewerResponse.allTots.size(), newTots.size());
		System.assertEquals(viewerResponse.savedTots.size(), newTots.size());
		
		Account newTestAccount = new Account(Name='Tract Reconciliation Test Account');
		Boolean insertAndLinked = tpjTONListAura.saveAndLinkTONToAccount(tpjTONS[0].tonId, newTestAccount);
		System.assertEquals(insertAndLinked, true);
		Boolean unlinked = tpjTONListAura.unlinkAccount(tpjTONS[0].tonId);
		System.assertEquals(unlinked, true);
		Account newTestAccount2 = new Account(Name='Tract Reconciliation Test Account 2');
		insertAndLinked = tpjTONListAura.saveAndLinkTONToAccount(tpjTONS[0].tonId, newTestAccount2);
		TargetOwnershipName__c testTON = tpjTONListAura.getCurrentTon2(tpjTONS[0].tonId);
		//Need to test delete tots from totBuilderAura, but can run after reconciliation testing

		tractReconciliationAura.tonReconciliationRecords tonRR = tractReconciliationAura.getReconciliationRecords(ton.Id);
		tractReconciliation__c newReconciliation = new tractReconciliation__c();
		newReconciliation.instrumentTypeOption__c = 'totValue';
		newReconciliation.netAcreageUnitOption__c = 'totValue';
		newReconciliation.netAcresOption__c = 'totValue';
		newReconciliation.depthOption__c = 'totValue';
		newReconciliation.grossAcreageOption__c = 'totValue';
		newReconciliation.quarterCallOption__c = 'totValue';
		Tract__c newTract = new Tract__c();
		newTract.depth__c = 'New Depth';
		newTract.Quarter_Call__c = 'New Quarter Call';
		newTract.Instrument_Type__c = 'MD';
		newTract.Gross_Acres__c = 320;
		newTract.netAcres__c = 2.844;
		newTract.netAcreageUnits__c = 'NRA';
		System.debug('ton account record is: ' + tonRR.tonRecord.Account__c);
		tractReconciliationAura.tractSaveResult newTractSaveResult = tractReconciliationAura.saveTract(true, newReconciliation, null, newTract, tonRR.tonTotRecords[0], tonRR.tonRecord);
		System.debug(newTractSaveResult);
		newTract.netAcres__c = 10;
		update newTract;

		tractReconciliationAura.tonReconciliationRecords reconciledRecords = tractReconciliationAura.getReconciledRecords(ton.Id);
		List<String> tractIds = new List<String>();
		for(Tract__c tract: reconciledRecords.reconciledTonTractRecords){
			tractIds.add(tract.Id);
		}
		List<Subtract__c> subtracts = [SELECT ID FROM Subtract__c WHERE Tract__c IN :tractIds];
		System.assertEquals(tractIds.size(), subtracts.size());
		List<String> totDeletes = new List<String>();
		for(TitleOwnershipDetail__c tot: tonRR.tonTotRecords){
			Boolean reconciled = false;
			for(tractReconciliationAura.reconciledRecord rr: reconciledRecords.reconciliationRecords){
				if (rr.totId == tot.Id){
					reconciled = true;
				}
			}
			if(!reconciled){
				totDeletes.add(tot.Id);
			}
		}
		System.debug(totDeletes);
		totBuilderAura.deleteTots(totDeletes);
		
        
   }
  
}