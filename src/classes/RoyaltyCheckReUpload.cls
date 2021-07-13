public without sharing class RoyaltyCheckReUpload{
	
    /**
    * @description : This Method is used to fetch the current user's library folder, which will contain all the Check csv 
    *               which need to be Re-uploaded. The Method gets 10 files at a time, and reads the first two rows of each files,
    *               to get the corresponding RC record in Salesforce using Check number,date and Amount. The method then calls a batch 
    *               process which deletes the related RLI records of the fetched RC.
    * @author Jade Tran
    * @param docId 
    * @return List<Log__c> 
    **/
    @AuraEnabled
    public static List<Log__c> runReUpload(Id docId){ 
        List<Log__c> logList = new List<Log__c>();
        String returnStr ='';
        String contentId='';
        ContentWorkspace source;
        ContentWorkspace target;
        ContentWorkspace invalid;
        try{
            
            String[] userEmail = userInfo.getUserEmail().split('@');
            //fetch All Library folders required
            source = [SELECT Id, Name FROM ContentWorkspace where Name=: userEmail[0]];
            target = [SELECT Id, Name FROM ContentWorkspace where Name='ProcessedChecks'];
            invalid = [SELECT Id, Name FROM ContentWorkspace where Name='Invalid Checks'];
            Set<Id> contentDocIds = new Set<Id>();
            //Fetch the files in the source folder with Limit 10
            if(null==docId){
                for(ContentDocumentLink cdl : [Select Id,ContentDocumentId from ContentDocumentLink where LinkedEntityId =: source.Id Limit 10]){
                    contentDocIds.add(cdl.ContentDocumentId);
                }
            }else{
                
                contentDocIds.add(docId);
            }
            Map<Id,String> cNumberMap = new Map<Id,String>();
            Map<Id,String> cAmountMap = new Map<Id,String>();
            Map<Id,String> cDateMap = new Map<Id,String>();
            //Iterating the list of documnets, to fetch the related RC
            for(ContentVersion cv : [SELECT VersionData,ContentDocumentId,title FROM ContentVersion where ContentDocumentId IN: contentDocIds AND IsLatest =  true]){
                system.debug(cv.title);
                contentId = cv.ContentDocumentId;
                String lineItemString = cv.versiondata.toString();
                Integer indexInteger = lineItemString.indexOf('\n');
                String dataLines = lineItemString.left(indexInteger);
                string[] csvFieldNames = dataLines.split(',');
                Integer checkNumberIndex;
                Integer checkAmountIndex;
                Integer checkIssueDateIndex;
                //Getting column index of Check Number,Amount and Date
                for (Integer i = 0; i < csvFieldNames.size(); i++) {
                    if(csvFieldNames[i]=='Check Number'){
                        checkNumberIndex = i;
                    }else If(csvFieldNames[i]=='Check Amount'){
                        checkAmountIndex = i;
                    }else If(csvFieldNames[i]=='Check Date'){
                        checkIssueDateIndex = i;
                    }
                }
                String rows = lineItemString.remove(dataLines+'\n');
                indexInteger = rows.indexOf('\n');
                dataLines = rows.left(indexInteger);
                
                Integer startIndex;
                Integer endIndex;
                //replace any , or " found in the data cell with ":comma:" or ":quotes:" respectively
                while(dataLines.indexOf('"') > -1){

                    if(startIndex == null){
                        startIndex = dataLines.indexOf('"');
                        dataLines = dataLines.substring(0, startIndex) + ':quotes:' + dataLines.substring(startIndex+1, dataLines.length());
                    }else{
                        if(endIndex == null){
                            endIndex = dataLines.indexOf('"');
                            dataLines = dataLines.substring(0, endIndex) + ':quotes:' + dataLines.substring(endIndex+1, dataLines.length());
                        }
                    }
                    
                    if(startIndex != null && endIndex != null){
                        String sub = dataLines.substring(startIndex, endIndex);
                        sub = sub.replaceAll(',', ':comma:');
                        dataLines = dataLines.substring(0, startIndex) + sub + dataLines.substring(endIndex, dataLines.length());
                        startIndex = null;
                        endIndex = null;
                    }
                }
                string[] values = dataLines.split(',');
                String cNumber;
                double cAmount;
                Date cDate;
                //File should have all 3 values populated to find the correct RC in salesforce
                if(checkNumberIndex>=0 && checkAmountIndex>=0 && checkIssueDateIndex>=0 &&
                   values[checkNumberIndex] !='' && values[checkAmountIndex] !='' && values[checkIssueDateIndex] !=''){
                       cNumber = String.valueOf(values[checkNumberIndex]);
                       while(cNumber.indexOf('0')==0){
                           cNumber=cNumber.replaceFirst('0','');
                       }
                    
                    if(values[checkAmountIndex]!=''){
                        cAmount = double.valueOf(values[checkAmountIndex]);
                    }
                    String[] dateStr = values[checkIssueDateIndex].split('/');
                    cDate = date.newinstance(Integer.valueOf(dateStr[2]),Integer.valueOf(dateStr[0]),Integer.valueOf(dateStr[1]));
                    
                    system.debug('-'+cNumber+'-');
                    system.debug('-'+cAmount+'-');
                    system.debug('-'+cDate+'-');

                    //Fetch RC in salesforce
                    List<Royalty_check__c> rc = [Select Id from Royalty_check__c where Check_Number__c =: cNumber
                                        AND Amount__c =: cAmount
                                        AND Check_Issue_Date__c =: cDate LIMIT 1];
                    
                    if(rc.size()>0){
                        system.debug(2);
                        //Create a Log record if RC is found with Process: Find Royalty Check and status: Complete
                        Log__c log = new Log__c();
                        log = createLog('Find Royalty Check','Complete', '', '','', rc[0].id,'');
                        logList.add(log);

                        //Create Instance of Batch job to delete the related RLI records and then read the file to insert new RLI
                        DeleteAndUploadRoyaltyLineItemBatch deleteAndUpload = new DeleteAndUploadRoyaltyLineItemBatch(cv.ContentDocumentId, rc[0].Id,log.Id);
                        Database.executebatch(deleteAndUpload);
                    
                        ContentDocument c = new ContentDocument(Id=cv.ContentDocumentId);
                        c.ParentId = target.Id;
                        update c;
                        ContentDocumentLink cdl = new ContentDocumentLink();
                        List<ContentDocumentLink> cdlList = [Select Id from ContentDocumentLink where ContentDocumentId =: contentId AND LinkedEntityId =: rc[0].Id];
                        if(cdlList.size()<=0){
                            cdl.ContentDocumentId = contentId;
                            cdl.LinkedEntityId = rc[0].Id;
                            cdl.ShareType = 'V';
                            insert cdl;
                        }
                        cdlList = [Select Id from ContentDocumentLink where ContentDocumentId =: contentId AND LinkedEntityId =: source.Id];
                        delete cdlList;
                    }else{
                        system.debug(3);
                        //Create a Log record if RC is not foundwith Process: Find Royalty Check and status: Error
                        Log__c log = new Log__c();
                        String errorStr = 'Royalty Check not found';
                        String addDetails = 'File Id: '+contentId;
                        log = createLog('Find Royalty Check','Error', errorStr ,'',addDetails, null,'');
                        logList.add(log);
                        ContentDocument c = new ContentDocument(Id=contentId);
                        c.ParentId = invalid.Id;
                        update c;
                        ContentDocumentLink cdl = new ContentDocumentLink();
                        List<ContentDocumentLink> cdlList = [Select Id from ContentDocumentLink where ContentDocumentId =: contentId AND LinkedEntityId =: log.Id];
                        if(cdlList.size()<=0){
                            cdl.ContentDocumentId = contentId;
                            cdl.LinkedEntityId = log.Id;
                            cdl.ShareType = 'V';
                            insert cdl;
                        }
                        cdlList = [Select Id from ContentDocumentLink where ContentDocumentId =: contentId AND LinkedEntityId =: source.Id];
                        delete cdlList;
                        returnStr = 'Log record Id: '+log.Id;
                    }
                }else{
                    system.debug(4);
                    //Create log record if any of Check Number, Amount, Date is not found in the file
                    
                    Log__c log = new Log__c();
                    String errorStr = 'Invalid Source. Please ensure to have Check Number, Check Date, Check Amount';
                    String addDetails = 'File Id: '+contentId;
                    log = createLog('Find Royalty Check','Error', errorStr ,'',addDetails, null,'');
                    logList.add(log);
                    ContentDocument c = new ContentDocument(Id=contentId);
                    c.ParentId = invalid.Id;
                    update c;
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    List<ContentDocumentLink> cdlList = [Select Id from ContentDocumentLink where ContentDocumentId =: contentId AND LinkedEntityId =: log.Id];
                        if(cdlList.size()<=0){
                            cdl.ContentDocumentId = contentId;
                            cdl.LinkedEntityId = log.Id;
                            cdl.ShareType = 'V';
                            insert cdl;
                        }
                    cdlList = [Select Id from ContentDocumentLink where ContentDocumentId =: contentId AND LinkedEntityId =: source.Id];
                    delete cdlList;
                    returnStr = 'Log record Id: '+log.Id;
                }   
            } 
        }catch(Exception e){
            system.debug(5);
            //Create log record if any other exceptions occur
            System.debug('Error Log Created');
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            System.debug('Error Log Created');
            Log__c log = new Log__c();
            String addDetails = 'File Id: '+contentId;
            log = createLog('Find Royalty Check','Error', e.getMessage() ,e.getStackTraceString(),addDetails, null,'');
            logList.add(log);
            system.debug(contentId);
            if(contentId!=null && contentId!=''){
                ContentDocument c = new ContentDocument(Id=contentId);
                c.ParentId = invalid.Id;
                update c;
            
                ContentDocumentLink cdl = new ContentDocumentLink();
                List<ContentDocumentLink> cdlList = [Select Id from ContentDocumentLink where ContentDocumentId =: contentId AND LinkedEntityId =: log.Id];
                if(cdlList.size()<=0){
                    cdl.ContentDocumentId = contentId;
                    cdl.LinkedEntityId = log.Id;
                    cdl.ShareType = 'V';
                    insert cdl;
                }
                cdlList = [Select Id from ContentDocumentLink where ContentDocumentId =: contentId AND LinkedEntityId =: source.Id];
                delete cdlList;
            }
            returnStr = 'Log record Id: '+log.Id;
        }
        return logList;
    }

    /**
    * @description : Method to Create Log record.
    * @author Jade Tran
    * @param process 
    * @param Status 
    * @param errorMessage 
    * @param stackTrace 
    * @param addDetails 
    * @param rcid 
    * @param comments 
    * @return log__c 
    **/
    public static log__c createLog(String process,String Status, String errorMessage, 
                            String stackTrace,String addDetails, 
                            Id rcid,String comments){
        log__c logRec = new log__c();
        logRec.Process__c = process;
        logRec.Status__c = status;
        logRec.Error_Message__c = errorMessage;
        logRec.Stack_Trace__c = stackTrace;
        logRec.Additional_Details__c = addDetails;
        logRec.royaltyCheck__c = rcid;
        logRec.CommentsNotes__c = comments;
        insert logRec;
        return logRec;
    }

}