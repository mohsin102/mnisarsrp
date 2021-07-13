/**
    * @description : This class is used to split each row into a string and then create a RLI instance from that row  
    * @author Jade Tran
    **/
global class BatchCreateRoyaltyLineItem implements Database.batchable<String>,Database.Stateful{
    global String csvString;
    global  string str; 
    global  Boolean isFirstRow = true;
    global String errorStr;
    global Map<Integer,String> NumberFieldMap = new Map<Integer,String>();
    global Map<String,String> fieldConfigMap = new Map<String,String>();
    global ID rcId;
    global Integer propertyNameColumn;
    global LIst<Royalty_Line_Item__c> rliFinalList = new List<Royalty_Line_Item__c>();
    global Id logId; 
    
    global BatchCreateRoyaltyLineItem (String csvString,
                        Map<Integer,String> NumberFieldMap,
                        Map<String,String> fieldConfigMap,
                        ID rcId,Integer propertyNameColumn,Id logId){
                            this.csvString = csvString;
                            this.NumberFieldMap = NumberFieldMap;
                            this.fieldConfigMap = fieldConfigMap;
                            this.rcId = rcId;
                            this.propertyNameColumn = propertyNameColumn;
                            this.logId = logId;
                                
                        }
    
    global Iterable<String> start(Database.batchableContext info){ 
        return new Utility_RowIterator(csvString); 
    }     
    global void execute(Database.batchableContext info, List<String> scope){ 
        List<Royalty_Line_Item__c>  rliList = ImportLineItemsController.getRecords(scope,NumberFieldMap,fieldConfigMap,rcId,propertyNameColumn,logId);
        rliFinalList.addAll(rliList);
    }     
    global void finish(Database.batchableContext info){
        InserRoyaltyLineItemBatch insertRoyaltyLineItem = new InserRoyaltyLineItemBatch(rliFinalList,logId);
        Database.executeBatch(insertRoyaltyLineItem);
        if(logId!=null){
            log__c log = new log__c();
            log.Id = logId;
            log.Status__c = 'Complete';
            log.Process__c = 'Read Royalty Line Items';
            update log;
        }
    } 
}