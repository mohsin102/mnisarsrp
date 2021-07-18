@isTest 
private class AccountingTransactionImportItemsAuraTest {

	@TestSetup
	private static void makeData(){
		TestDataFactory.dataSetup();
		List<ContentVersion> insertDataFiles = new List<ContentVersion>();
		List<AccountingIntegrationJob__c> aij = [SELECT ID FROM AccountingIntegrationJob__c LIMIT 4];
		String str = 'Entity,GL Entity,Investment,Description,Class,Invesment Type,Investment Type Description,,Trade Date,Code,,,,,Net Money,,Quantity,Factor,Ccy,Price,Cost/Proceeds,Accr Interest,Fin Chrg,Commission,Fees,Net Amount,Fx Rate,,,,,,,Price,Cost/Proceeds2,Commission,Fees,Accr Interest,Fin Chrg,,,,,,Settle Date,Broker,Txn No,Quote,Difference,Variance,Txn Description,Cash Account,,,,Category1,Category1 Description,Category2,Category2 Description,Category3,Category3 Description,Category4,Category4 Description,Category5,Category5 Description,Affirm Date,Txn Status,Counterparty,Trader,Ticker,PayRecFlag,SwapSign,,,,,\r'+
					  'BEPSV,BEP,BARBARAYOHO,BARBARAYOHO,OTHER,MINERAL,MINERALS,,1/2/2019,IPLBB,1,,,,"-17,142.19","17,142","17,142.19",,USD,1,"-17,142.19",0,0,0,0.00         0.00         0.00         0.00,"-17,142.19",,"17,142.19",,0,,,,1,"-17,142.19",0,0.00         0.00         0.00         0.00,0,0,"17,142.19",,0,,,1/2/2019,,11205,,,,Beginning Balance Load,999999,IT,0,IPL,,,,,,,,,,,,C,,,,,1,,,TRUE,TRUE,TRUE\r'+
					  'BEPSV,BEP,BRANDON,BRANDON,OTHER,MINERAL,MINERALS,,4/22/2020,IPL,1,,,,"-37,040.00","37,040","37,040.00",,USD,1,"-37,040.00",0,0,0,0.00         0.00         0.00         0.00,"-37,040.00",,"37,040.00",,0,,,,1,"-37,040.00",0,0.00         0.00         0.00         0.00,0,0,"37,040.00",,0,,,4/22/2020,,25286,,,,IPL Brandon,160300,IT,0,IPL,,,,,,,,,,,,C,,,,,1,,,TRUE,TRUE,TRUE\r'+
					  'BEPSV,BEP,CAIN,CAIN,OTHER,MINERAL,MINERALS,,5/26/2020,IPL,1,,,,"-56,864.00","56,864","56,864.00",,USD,1,"-56,864.00",0,0,0,0.00         0.00         0.00         0.00,"-56,864.00",,"56,864.00",,0,,,,1,"-56,864.00",0,0.00         0.00         0.00         0.00,0,0,"56,864.00",,0,,,5/26/2020,,25285,,,,IPL Cain,160300,IT,0,IPL,,,,,,,,,,,,C,,,,,1,,,TRUE,TRUE,TRUE\r'+
					  'BEPSV,BEP,CITRUSENERGYAPPALACHIA,CITRUSENERGYAPPALACHIA,OTHER,OVERRIDE,OVERRIDES,,1/2/2019,IPLBB,1,,,,"-1,438,000.00","1,438,000","1,438,000.00",,USD,1,"-1,438,000.00",0,0,0,0.00         0.00         0.00         0.00,"-1,438,000.00",,"1,438,000.00",,0,,,,1,"-1,438,000.00",0,0.00         0.00         0.00         0.00,0,0,"1,438,000.00",,0,,,1/2/2019,,11272,,,,Beginning Balance Load,999999,IT,0,IPL,,,,,,,,,,,,C,,,,,1,,,TRUE,TRUE,TRUE\r'+
					  'BEPSV,BEP,COUNTYOFALLEGHENY,COUNTYOFALLEGHENY,OTHER,LEASEHLD,LEASEHOLD,,1/2/2019,IPLBB,1,,,,"-85,000.00","85,000","85,000.00",,USD,1,"-85,000.00",0,0,0,0.00         0.00         0.00         0.00,"-85,000.00",,"85,000.00",,0,,,,1,"-85,000.00",0,0.00         0.00         0.00         0.00,0,0,"85,000.00",,0,,,1/2/2019,,11281,,,,Beginning Balance Load,999999,IT,0,IPL,,,,,,,,,,,,C,,,,,1,,,TRUE,TRUE,TRUE\r';
		ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        //cv.ContentDocumentId = contentDocumentId;
        cv.VersionData = Blob.valueOf(str);
        cv.Title = 'AccountingImportTest.csv';
		cv.FirstPublishLocationId = aij[0].Id;
		aij[0].notes__c = 'ImportTest1';
		//cv.FileExtension = 'csv';
		//cv.FileType = 'csv';
        cv.PathOnClient = 'AccountingImportTest.csv';
        insertDataFiles.add(cv);
		insert insertDataFiles;
		update aij;
	}


	@isTest
	private static void testImport1() {
		Test.startTest();       
		ContentVersion cv = [SELECT ContentDocumentId, FirstPublishLocationId FROM ContentVersion WHERE Title = 'AccountingImportTest.csv'];
		AccountingIntegrationJob__c aij = [SELECT ID FROM AccountingIntegrationJob__c WHERE Id = :cv.FirstPublishLocationId LIMIT 1];
		String testCount = accountingTransactionImportItemsAura.importRecords(cv.ContentDocumentId, aij.Id, 'accountTransactionFile');
		System.assertEquals(testCount, 'SUCCESS');
		testCount = accountingTransactionImportItemsAura.importRecords(cv.ContentDocumentId, aij.Id, 'accountTransactionFile');
		System.assertEquals(testCount, 'Transaction file has already been loaded for this AIJ.');
		List<AccountingTransaction__c> atList = [SELECT ID, reconciliationType__c FROM AccountingTransaction__c];
		for(AccountingTransaction__c at: atList){
			if(at.reconciliationType__c == 'Cost'){
				at.reconciliationType__c = 'Sales';
			}
			else{
				at.reconciliationType__c = 'Cost';
			}
		}
		update atList;
		
		Test.stopTest();

	}
}