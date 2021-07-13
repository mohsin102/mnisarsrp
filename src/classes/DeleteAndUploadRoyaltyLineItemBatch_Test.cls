@isTest
public class DeleteAndUploadRoyaltyLineItemBatch_Test{

    @isTest
    public static void deleteRLI_TestMethod(){

        String csvString = 'Check Number,Check Amount,Check Date,DedCode,Gross Adjustments,Gross Net,Gross Taxes,Gross Value,Gross Volume,Line Item Decimal,Line Item Net Value,Net Value,Price,Product,Production Month,Type,Property Id,Property Name,Owner Net Value \n';
        csvString += '123,123,01/01/2020,1.01,1.01,42942.8,1.01,45259.53,645.8,0.00068433,30.97,1.01,70.08,OIL,01-09-2018,R1,TestName,64356345,23,"test" \n';

        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.csv';
        cv.VersionData = Blob.valueOf(csvString);
        cv.IsMajorVersion = true;
        Insert  cv;

        Royalty_Check__c rcRecc= new Royalty_Check__c();
        rcRecc.Check_Number__c ='123';
        rcRecc.Check_Issue_Date__c = date.newinstance(2020,01,01);
        rcRecc.Amount__c = 123;
        rcRecc.Description__c = 'Test #987654321 '+rcRecc.Check_Issue_Date__c.format()+' $100.00' ;
        system.debug(rcRecc.Check_Issue_Date__c);
        insert rcRecc;
        
        Royalty_Line_Item__c rliRec = new Royalty_Line_Item__c();
        rliRec.Royalty_Check__c = rcRecc.id;
        //rliRec.Type__c = 'Revenue';
        rliRec.Production_Month__c = system.today();
        rliRec.ownerNetValueActual__c = 123;
        rliRec.lineItemDecimal__c = 0.00012122;
        rliRec.grossVolumeActual__c = 230.50;
        rliRec.propertyName__c = 'Test';
        rliRec.Price__c  = 200;
        insert rliRec;

        Log__c log = new Log__c();
        insert log;
        
        List<ContentDocument> cd = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        DeleteAndUploadRoyaltyLineItemBatch deleteAndUpload = new DeleteAndUploadRoyaltyLineItemBatch(cd[0].Id, rcRecc.Id,log.Id);
        Database.executebatch(deleteAndUpload);

    }

}