//Created 9-15-2020 by John Gorrell

//Provides test coverage for 
//UserDocument.cls
//unitRelatedWellFilesAura


@isTest 
private class unitRelatedWellFilesAuraTest  {

	@TestSetup
	static void tractReconciliationTestData(){
		TestDataFactory.dataSetup();

		List<ContentVersion> insertFiles = new List<ContentVersion>();
		Well__c well = [SELECT ID, Unit__c FROM Well__c LIMIT 1];
		Unit__c unit = new Unit__c(Id=well.Unit__c);
		unit.GIS_Unit_ID__c = 'relatedUnitTest';
		update unit;
		String str = 'Test Text file';
		ContentVersion cv = new ContentVersion();
		
        cv.ContentLocation = 'S';
        //cv.ContentDocumentId = contentDocumentId;
        cv.VersionData = Blob.valueOf(str);
        cv.Title = 'testFile.txt';
		cv.FirstPublishLocationId = well.Id;
		//cv.FileExtension = 'csv';
		//cv.FileType = 'csv';
        cv.PathOnClient = 'testFile.txt';
        insertFiles.add(cv);
        insert insertFiles;
	}

	static testmethod void mainMethod(){
        Test.startTest();
		   Unit__c testUnit = [SELECT ID FROM Unit__c WHERE GIS_Unit_ID__c = 'relatedUnitTest' LIMIT 1];
		   List<unitRelatedWellFilesAura.fileResponse> response = unitRelatedWellFilesAura.getFiles2(testUnit.Id);
		Test.stopTest(); 
	}

}