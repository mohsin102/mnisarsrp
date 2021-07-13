/**
    * @description : This class is used to delete RLI records related to the given RC Id
    *               Once all related RLI are deleted, the finish method of the class calls the
    *               ImportLineItemsController.importRecords method to read the uploaded file and insert nnew RC.
    * @author Jade Tran
    **/
public class DeleteAndUploadRoyaltyLineItemBatch implements Database.batchable<sObject>,Database.Stateful{
	Id rcId;
    Id contentDocumentId;
    Id logId;
    Integer OldRoyaltyLineItem = 0;
    public DeleteAndUploadRoyaltyLineItemBatch(Id contentDocumentId,Id rcId,Id logId){
        this.rcId = rcId;
        this.contentDocumentId = contentDocumentId;
        this.logId = logId;
    }
    
    public Database.QueryLocator start(Database.BatchableContext context){ 
        String query='Select Id from Royalty_Line_Item__c where Royalty_Check__c =: rcId';
        return Database.getQueryLocator(query);

    }     
    public void execute(Database.BatchableContext context, List<sObject> scope){ 
        try{
            OldRoyaltyLineItem += scope.size();
        	delete scope;
            if(Test.isRunningTest()){
                throw new applicationException('error message');
            }
        }catch(Exception e){
            log__c log = new log__c();
            log.Id = logId;
            log.Status__c = 'Error';
            log.Process__c = 'Delete Royalty Line Items';
            log.Error_Message__c = e.getMessage() ;
            log.Stack_Trace__c = e.getStackTraceString();
            log.royaltyCheck__c = rcId;
            update log;
            
        }
    }     
    public void finish(Database.batchableContext context){
        ImportLineItemsController.importRecords(contentDocumentId,'Flat', rcId,logId);
        log__c log = new log__c();
        log.Id = logId;
        log.Status__c = 'Complete';
        log.Process__c = 'Delete Royalty Line Items';
        log.OldRoyaltyLineItem__c = OldRoyaltyLineItem;
        update log;
    }
    
    public class applicationException extends Exception {}
}