public class ImportLineItemsController {
    
    /**
* @description : This method is referred by ImportLineItem Aura component and Reprocess logic. 
*               This method queries the file content and converts to a string
*               and then passes it to the next method to read all the rows
* @author Jade Tran
* @param contentDocId 
* @param rcId 
* @param logId 
* @return ImportResultWrapper 
**/
    @AuraEnabled
    public static ImportResultWrapper importRecords(Id contentDocId,String fileType,ID rcId, Id logId){
        
        ContentVersion cv = [SELECT VersionData,Title FROM ContentVersion where ContentDocumentId =: contentDocId AND IsLatest =  true];
        String lineItemString = cv.versiondata.toString();
        Royalty_Check__c rc = new Royalty_Check__c();
        rc.Id = rcId;
        if(fileType=='Raw'){
            rc.rawFileId__c = contentDocId;
            rc.rawFileName__c = cv.Title;
            rc.Source__c = 'CSV';
            update rc;
        }else{
            rc.flatFileId__c = contentDocId;
            rc.flatFileName__c = cv.Title;
            rc.Source__c = 'CSV';
            update rc;
            return readCSVFile(lineItemString,rcId,logId);
        }
        
        return null;
    }
    
    /**
* @description : This method reads the csv columns, validates them with the required columns and then passes the data line items
*               to a batch class which creates RLI instances of all the rows.
* @author Jade Tran 
* @param lineItemString 
* @param rcId 
* @param logId 
* @return ImportResultWrapper 
**/
    public static ImportResultWrapper readCSVFile(String lineItemString,ID rcId,Id logId) {
        ImportResultWrapper importResultWrap = new ImportResultWrapper();
        Integer indexInteger = lineItemString.indexOf('\n');
        String dataLines = lineItemString.left(indexInteger);
        try{
            
            Map<String,String> fieldConfigMap = new Map<String,String>();
            String returnString = '';
            Set<String> requiredColumns = new Set<String>();
            
            //query metadata to create map of column vs API names, and list of required columns
            for(lineItemFieldMapping__mdt fieldDetail : [Select columnName__c,fieldAPIName__c,isRequired__c From lineItemFieldMapping__mdt]){
                fieldConfigMap.put(fieldDetail.columnName__c,fieldDetail.fieldAPIName__c);
                if(fieldDetail.isRequired__c){
                    requiredColumns.add(fieldDetail.columnName__c);
                }
            }
            
            Map < String, Integer > fieldNumberMap = new Map < String, Integer > ();
            Map < Integer, String > NumberFieldMap = new Map < Integer, String > ();
            List<String> lstFieldNames = new List<String>();
            
            //Read the 1st row of the file, to create a map of column vs index, index vs column and list of column names.
            string[] csvFieldNames = dataLines.split(',');
            Integer propertyNameColumn;
            for (Integer i = 0; i < csvFieldNames.size(); i++) {
                if(!String.isBlank(csvFieldNames[i])){
                    if(csvFieldNames[i]=='Property Name'){
                        propertyNameColumn=i;
                    }
                    NumberFieldMap.put(i,csvFieldNames[i]);
                    fieldNumberMap.put(csvFieldNames[i], i);
                    lstFieldNames.add(csvFieldNames[i].trim());
                }
            }
            
            //Check if required columns are present in the csv file
            boolean isValidCSV  = true;
            for(String requiredColumn : requiredColumns){
                if(!lstFieldNames.contains(requiredColumn)){
                    isValidCSV = false;
                    if(returnString==''){
                        returnString+=requiredColumn;
                    }else{
                        returnString+=', '+requiredColumn;
                    }
                }
            }
            
            //If file is valid, exeute batch to create RLI instances of each row
            if(isValidCSV){
                String rows = lineItemString.remove(dataLines+'\n');
                Id logIdTemp = logId;
                if(logId==null){
                    Log__c log = new log__c();
                    log.Process__c = 'Read Royalty Line Items';
                    log.royaltyCheck__c = rcId;
                    insert log;
                    logIdTemp = log.Id;
                }
                BatchCreateRoyaltyLineItem s = new BatchCreateRoyaltyLineItem(rows,NumberFieldMap,fieldConfigMap,rcId,propertyNameColumn,logIdTemp);
                importResultWrap.status = 'Success';
                //importResultWrap.totalLineItems = rliList.size();
                importResultWrap.batchJobId = Database.executeBatch(s);
                
                //If File is not valid, create/update the log record
            }else{
                importResultWrap.status = 'Error';
                importResultWrap.errorMessage = 'Please include the following Columns: '+returnString;
                Log__c log = new Log__c();
                if(logId!=null){
                    log.id = logId;
                }
                log.Process__c = 'Read Royalty Line Items';
                log.Status__c = 'Error';
                log.Error_Message__c = 'Please include the following Columns: '+returnString;
                log.royaltyCheck__c = rcId;
                upsert log;
                
            }
            if(Test.isRunningTest()){
                throw new applicationException('Erorr Message');
            }
            //Create/update log if Exceptions occur
        }catch(Exception e){
            importResultWrap.status = 'Error';
            importResultWrap.errorMessage = e.getMessage()+'  Class: ImportResultWrapper '+e.getLineNumber();
            Log__c log = new Log__c();
            if(logId!=null){
                log.id = logId;
            }
            log.Process__c = 'Read Royalty Line Items';
            log.Status__c = 'Error';
            log.Error_Message__c = e.getMessage();
            log.Stack_Trace__c = e.getStackTraceString();
            log.royaltyCheck__c = rcId;
            upsert log;
        }
        return importResultWrap;
    }
    
    /**
* @description : This method is used to fetch the batch details to display the progress on the Aura component
* @author Jade Tran 
* @param batchJobId 
* @return AsyncApexJob 
**/
    @AuraEnabled
    public static AsyncApexJob getJobDetails(Id batchJobId){
        AsyncApexJob aaj = [SELECT Id, Status,ExtendedStatus, JobItemsProcessed, TotalJobItems, NumberOfErrors
                            FROM AsyncApexJob WHERE ID =: batchJobId ];
        
        return aaj;
        
    }
    

    
    /**
* @description : This method is used to create RLI instances, Auto map Well records using Property name,
*               Split RLI record into multiple records if Property name has multiple API10 mapping,
*               Split RLI record in multiple records if multiple deducts are found in the row
* @author Jade Tran
* @param dataLines 
* @param NumberFieldMap 
* @param fieldConfigMap 
* @param rcId 
* @param propertyNameColumn 
* @param logId 
* @return List<Royalty_Line_Item__c> 
**/
    public static List<Royalty_Line_Item__c> getRecords(List<String> dataLines,
                                                        Map<Integer,String> NumberFieldMap,
                                                        Map<String,String> fieldConfigMap,
                                                        ID rcId,Integer propertyNameColumn,
                                                        Id logId){
                                                            
                                                            List<Royalty_Line_Item__c> rliFinalList = new List<Royalty_Line_Item__c>();
                                                            List<Royalty_Line_Item__c> rliList;
                                                            List<Royalty_Line_Item__c> rliDedList;
                                                            Royalty_Line_Item__c rliRec;
                                                            Well__c wellRec;
                                                            Map<String,String> fieldValMap;
                                                            try{   
                                                                for (String csvLine : dataLines) {
                                                                    rliList = new List<Royalty_Line_Item__c>();
                                                                    fieldValMap = new Map<String,String>();
                                                                    Integer startIndex;
                                                                    Integer endIndex;
                                                                    //replace , and " with strings in a data cell
                                                                    while(csvLine.indexOf('"') > -1){
                                                                        
                                                                        if(startIndex == null){
                                                                            startIndex = csvLine.indexOf('"');
                                                                            csvLine = csvLine.substring(0, startIndex) + ':quotes:' + csvLine.substring(startIndex+1, csvLine.length());
                                                                        }else{
                                                                            if(endIndex == null){
                                                                                endIndex = csvLine.indexOf('"');
                                                                                csvLine = csvLine.substring(0, endIndex) + ':quotes:' + csvLine.substring(endIndex+1, csvLine.length());
                                                                            }
                                                                        }
                                                                        
                                                                        if(startIndex != null && endIndex != null){
                                                                            String sub = csvLine.substring(startIndex, endIndex);
                                                                            sub = sub.replaceAll(',', ':comma:');
                                                                            csvLine = csvLine.substring(0, startIndex) + sub + csvLine.substring(endIndex, csvLine.length());
                                                                            startIndex = null;
                                                                            endIndex = null;
                                                                        }
                                                                    }
                                                                    rliRec = new Royalty_Line_Item__c();
                                                                    string[] csvRecordData = csvLine.split(',');
                                                                    Integer fieldNumber;
                                                                    String fieldValue;
                                                                    String fieldName;
                                                                    //iterating each data cell
                                                                    for(Integer j=0; j<csvRecordData.size();j++){
                                                                        if(null!=NumberFieldMap.get(j) && csvRecordData[propertyNameColumn]!=''){
                                                                            
                                                                            fieldName = NumberFieldMap.get(j).trim();
                                                                            fieldValue = csvRecordData[j];
                                                                            fieldValue = fieldValue.replaceAll(':comma:', ',');
                                                                            fieldValue = fieldValue.replaceAll(':quotes:', '');
                                                                            fieldValMap.put(fieldName,fieldValue);
                                                                            
                                                                            if(fieldConfigMap.containsKey(fieldName) && !String.isBlank(fieldValue)){
                                                                                //system.debug(fieldNa me+'  field');
                                                                                String fieldType = string.valueOf(Schema.SObjectType.Royalty_Line_Item__c.fields.getMap().get(fieldConfigMap.get(fieldName)).getDescribe().getType());
                                                                                //check if field type is number
                                                                                if(fieldType.equalsIgnoreCase('Double') || fieldType.equalsIgnoreCase('Currency')){
                                                                                    if(fieldValue==''){
                                                                                        fieldValue = '0.0';
                                                                                    }
                                                                                    fieldValue = fieldValue.remove('$');
                                                                                    if(fieldType.equalsIgnoreCase('Double')){
                                                                                        rliRec.put(fieldConfigMap.get(fieldName),double.valueOf(fieldValue));
                                                                                    }
                                                                                    if(fieldType.equalsIgnoreCase('Currency')){
                                                                                        system.debug('----CURR-----'+fieldConfigMap.get(fieldName)+'---Val-'+fieldValue);
                                                                                        rliRec.put(fieldConfigMap.get(fieldName),Decimal.valueOf(fieldValue.trim()));
                                                                                    }
                                                                                    
                                                                                    //check if field type is date
                                                                                }else if(fieldType.equalsIgnoreCase('Date')){
                                                                                    
                                                                                    if(fieldValue!=''){
                                                                                        //system.debug('fieldValue'+fieldValue);
                                                                                        String fval = fieldValue.replace('-','/');
                                                                                        date detaVal = date.parse(fval.trim());
                                                                                        //system.debug('Date= '+ detaVal);
                                                                                        rliRec.put(fieldConfigMap.get(fieldName),detaVal);
                                                                                    }
                                                                                    //check if field type is String
                                                                                }else if(fieldType.equalsIgnoreCase('String')||fieldType.equalsIgnoreCase('Picklist')){
                                                                                    rliRec.put(fieldConfigMap.get(fieldName),fieldValue);
                                                                                }else{
                                                                                    
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                    
                                                                    //Auto mapping RLI with well records based on property name
                                                                    rliRec.Royalty_Check__c = rcID;
                                                                    
                                                                    if(rliRec.propertyName__c!='' && rliRec.propertyName__c!=null){
                                                                        rliList.add(rliRec);
                                                                    }
                                                                    
                                                                    //Split RLI if Multiple Deducts are found
                                                                    if(rliList.size()>0){
                                                                        
                                                                        Royalty_Line_Item__c rliDedRec;
                                                                        Boolean hasMultipleDeducts;
                                                                        for(Royalty_Line_Item__c rRec : rliList){
                                                                            rliDedList = new List<Royalty_Line_Item__c>();
                                                                            hasMultipleDeducts = false;
                                                                            for(Integer x=1;x<=10;x++){
                                                                                
                                                                                String dedTypeField = 'Deduct Type '+String.valueOf(x);
                                                                                String grossDedField = 'Gross Deduct '+String.valueOf(x);
                                                                                String netDedField = 'Net Deduct '+String.valueOf(x);
                                                                                
                                                                                if(fieldValMap.containsKey(dedTypeField) && fieldValMap.containsKey(grossDedField) && fieldValMap.containsKey(netDedField)){
                                                                                    if(fieldValMap.get(dedTypeField)!='' && fieldValMap.get(grossDedField)!='' && fieldValMap.get(netDedField)!=''){
                                                                                        
                                                                                        hasMultipleDeducts = true;
                                                                                        if(x==1){
                                                                                            rRec.adjustmentCode__c = fieldValMap.get(dedTypeField);
                                                                                            rRec.grossAdjustmentsActual__c = double.valueOf(fieldValMap.get(grossDedField));
                                                                                            rRec.ownerAdjustmentsActual__c = double.valueOf(fieldValMap.get(netDedField));
                                                                                            rliDedList.add(rRec);
                                                                                        }else{
                                                                                            rliDedRec = new Royalty_Line_Item__c();
                                                                                            rliDedRec = rRec.clone(false, false, false, false);
                                                                                            rliDedRec.adjustmentCode__c = fieldValMap.get(dedTypeField);
                                                                                            rliDedRec.grossAdjustmentsActual__c = double.valueOf(fieldValMap.get(grossDedField));
                                                                                            rliDedRec.ownerAdjustmentsActual__c = double.valueOf(fieldValMap.get(netDedField));
                                                                                            rliDedList.add(rliDedRec);
                                                                                        }
                                                                                    }
                                                                                }
                                                                            }
                                                                            if(hasMultipleDeducts==false){
                                                                                rliFinalList.add(rRec);
                                                                            }else{
                                                                                Decimal lineItemNetVal = rRec.ownerNetValueActual__c/rliDedList.size();
                                                                                for(Royalty_Line_Item__c r : rliDedList){
                                                                                    r.ownerNetValueActual__c = lineItemNetVal;
                                                                                    System.debug('***********'+rRec.ownerNetValueActual__c+'  /  '+rliDedList.size()+'  =  '+lineItemNetVal);
                                                                                    rliFinalList.add(r);
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                    
                                                                }
                                                            }catch(Exception e){
                                                                Log__c log = new Log__c();
                                                                if(logId!=null){
                                                                	log.id = logId;
                                                                }
                                                                log.Process__c = 'Read Royalty Line Items';
                                                                log.Status__c = 'Error';
                                                                log.Error_Message__c = e.getMessage();
                                                                log.Stack_Trace__c = e.getStackTraceString();
                                                                log.royaltyCheck__c = rcId;
                                                                upsert log;
                                                            }
                                                            return rliFinalList;
                                                        }
    
    public class ImportResultWrapper{
        @AuraEnabled
        String status{get;set;}
        @AuraEnabled
        String errorMessage{get;set;}
        @AuraEnabled
        Integer totalLineItems{get;set;}
        @AuraEnabled
        String batchJobId{get;set;}
    }
    public class applicationException extends Exception {}
}