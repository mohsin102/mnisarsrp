/**
    * @description : This class is used to insert RLI records in Batches 
    * @author Jade Tran
    **/
public class InserRoyaltyLineItemBatch implements Database.batchable<sObject>,Database.Stateful{
	public List<Royalty_Line_Item__c> rliList = new List<Royalty_Line_Item__c>();
	public Id logId;  
    public Integer NewRoyaltyLineItems = 0;
    public InserRoyaltyLineItemBatch(List<Royalty_Line_Item__c> rliList,Id logId){
        this.rliList = rliList;
        this.logId = logId;
    }
    
    public Iterable<sObject> start(Database.BatchableContext context){ 
        NewRoyaltyLineItems += rliList.Size();
        return rliList;
    }     
    public void execute(Database.BatchableContext context, List<Royalty_Line_Item__c> scope){ 
        try{
        	insert scope;
        }catch(exception e){
            Log__c log = new Log__c();
            log.id = logId;
            log.Process__c = 'Insert Royalty Line Items';
            log.Status__c = 'Error';
            log.Error_Message__c = e.getMessage();
            log.Stack_Trace__c = e.getStackTraceString();
            update log;
        }
    }     
    public void finish(Database.batchableContext context){
        if(logId!=null){
            Log__c log = new Log__c();
            log.id = logId;
            log.Process__c = 'Insert Royalty Line Items';
            log.Status__c = 'Complete';
            log.NewRoyaltyLineItems__c = NewRoyaltyLineItems;
            update log;
        }
    }
}