@isTest
public class ContentDocumentLinkTriggerHelper_Test {
    @TestSetup
	static void tractReconciliationTestData(){
		TestDataFactory.dataSetup();
	}
	
	
	@isTest
    public static void testMethod1(){
        
		Opportunity oppRec = [SELECT ID FROM Opportunity LIMIT 1];
        
        Evaluation__c evalRec = new Evaluation__c(status__c='Not Started',opportunity__c=oppRec.Id);
        insert evalRec;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = evalRec.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
    }
}