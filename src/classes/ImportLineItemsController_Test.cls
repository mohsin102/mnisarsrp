@isTest
public class ImportLineItemsController_Test{

    @isTest
    public static void testMethod1(){

        String csvString = 'Check Number,Check Amount,Check Date,Owner Net Value,Price,Property Name,Gross Value,Property Id,Owner Taxes,Line Item Decimal,Gross Volume,Gross Net,Gross Taxes,Type,Owner Volume,Line Item Net Value,Production Month,Product,Deduct Type 1,Gross Deduct 1,Net Deduct 1,Deduct Type 2,Gross Deduct 2,Net Deduct 2 \n';
		csvString += '123,123,01/01/2020,123,123,test,123,123,123,123,123,123,123,R1,123,123,01-09-2018,OIL,R1,123,123,R1,123,123 \n';

        String csvString1 = 'Check Number,Check Amount,Check Date,Owner Net Value,Price,Property Name,Gross Value,Property Id,Owner Taxes,Line Item Decimal,Gross Volume,Gross Net,Gross Taxes,Type,Owner Volume,Line Item Net Value,Production Month,Product,Deduct Type 1,Gross Deduct 1,Net Deduct 1 \n';
		csvString1 += '123,123,01/01/2020,123,123,TestWell,123,123,123,123,123,123,123,R1,123,123,01-09-2018,OIL,R1,123,123,"Test" \n';

        String csvString2 = 'Check Number,Check Amount,Check Date,Owner Net Value,Price,Property Name,Gross Value,Property Id,Owner Taxes,Line Item Decimal,Gross Volume,Gross Net,Gross Taxes,Type,Owner Volume,Line Item Net Value,Production Month,Product,Deduct Type 1,Gross Deduct 1,Net Deduct 1 \n';
		csvString2 += '123,123,01/01/2020,123,123,TestWells,123,123,123,123,123,123,123,R1,123,123,01-09-2018,OIL,R1,123,123,"Test" \n';

        String csvString3 = 'Check Number,Check Amount,Check Date,Price,Property Name,Gross Value,Property Id,Owner Taxes,Line Item Decimal,Gross Volume,Gross Net,Gross Taxes,Type,Owner Volume,Line Item Net Value,Production Month,Product \n';
		csvString3 += '123,123,01/01/2020,123,TestWell,123,123,123,123,123,123,123,R1,123,123,01-09-2018,OIL,"Test" \n';
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.csv';
        cv.VersionData = Blob.valueOf(csvString);
        cv.IsMajorVersion = true;
        Insert  cv;
        
        Log__c log = new Log__c();
        insert log;
              
        
        Well__c wellRec = new Well__c();
        wellRec.Name = 'TestWell';
        wellRec.API10__c ='9501724908';
        insert wellRec;

        wellRec = new Well__c();
        wellRec.Name = 'TestWell';
        wellRec.API10__c ='9501';
        insert wellRec;

        Royalty_Check__c rcRecc= new Royalty_Check__c();
        //rcRecc.Payor__c = 'Test';
        rcRecc.Check_Number__c ='987654321';
        rcRecc.Check_Issue_Date__c = system.today();
        rcRecc.Amount__c = 100;
        rcRecc.Description__c = 'Test #987654321 '+system.today().format()+' $100.00' ;
        insert rcRecc;
		
        mappingMetadata__c mmRec = new mappingMetadata__c();
        mmRec.key__c='TestWell';
        mmRec.value__c='95017324908';
        mmRec.RecordTypeId = Schema.getGlobalDescribe().get('mappingMetadata__c').getDescribe().getRecordTypeInfosByName().get('AssociatedWell').getRecordTypeId();
        insert mmRec;

        mmRec = new mappingMetadata__c();
        mmRec.key__c='TestWells';
        mmRec.value__c='95017324908,9501';
        mmRec.RecordTypeId = Schema.getGlobalDescribe().get('mappingMetadata__c').getDescribe().getRecordTypeInfosByName().get('AssociatedWell').getRecordTypeId();
        insert mmRec;
        
        List<ContentDocument> cd = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ImportLineItemsController.importRecords(cd[0].Id,'Flat',rcRecc.Id,log.Id);
        ImportLineItemsController.importRecords(cd[0].Id,'Raw',rcRecc.Id,log.Id);
        
        ImportLineItemsController.readCSVFile(csvString1,rcRecc.Id,log.Id);
        ImportLineItemsController.readCSVFile(csvString2,rcRecc.Id,null);
        ImportLineItemsController.readCSVFile(csvString3,rcRecc.Id,null);
    }
}