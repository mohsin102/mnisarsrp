public class boSRPFieldHistoryHandler implements Queueable 
{

	private List<boSRPFieldHistory__b> boHistories;
	private List<srpFieldHistory__c> histories;
	private Boolean isRetry;

	public boSRPFieldHistoryHandler(List<boSRPFieldHistory__b> boHistories, List<srpFieldHistory__c> histories, Boolean isRetry){
		this.boHistories = boHistories;
		this.histories = histories;
		this.isRetry = isRetry;
	}

	public void execute(QueueableContext context){
        
        //List<ExceptionStorage__c> errors = new List<ExceptionStorage__c>();
        
        try {
            List<srpFieldHistory__c> updateHistories = new List<srpFieldHistory__c>();
			List<srpFieldHistory__c> removeHistories = new List<srpFieldHistory__c>();
			// We have to use insertImmediate() to insert big object records.
            List<Database.SaveResult> srList;
			if(Test.isRunningTest()){
				srList = new List<Database.SaveResult>();
				Database.SaveResult trueResult = (Database.SaveResult)JSON.deserialize('{"success":true,"id":"0013000000abcde"}', Database.SaveResult.class);
				
				Database.SaveResult falseResult = (Database.SaveResult)JSON.deserialize('{"success":false,"errors":[{"message":"You cannot do this...","statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION"}]}', Database.SaveResult.class);
				srList.add(trueResult);
				srList.add(falseResult);
			}
			else{
				srList = Database.insertImmediate(boHistories);
            }
            // Check the save results from the bulk 
			Integer srListCounter = 0;
            for (Database.SaveResult sr: srList) {
                if (sr.isSuccess()) {
					   removeHistories.add(histories[srListCounter]);
                       System.debug('Successfully inserted SRP Field History with Id: '+ sr.getId());
					   System.debug('Regular History Record Record Id to be deleted is: ' + histories[srListCounter].Id);
                } else {
                       for (Database.Error err : sr.getErrors()) {
                        // Display an error message if the insert failed
                        System.debug(err.getStatusCode() + ': ' + err.getMessage() + '; ' +
                                    'Error fields: ' + err.getFields());
                        System.debug('Regular History Record to keep is: ' + histories[srListCounter].Id);
						
						//srpFieldHistory__c removedHistory = histories.remove(srListCounter);
						srpFieldHistory__c updateHistory = histories[srListCounter].clone(true, true, false, false);
						if(histories[srListCounter].conversionErrorCount__c != null){
							updateHistory.conversionErrorCount__c = histories[srListCounter].conversionErrorCount__c + 1;
						}
						else{
							updateHistory.conversionErrorCount__c = 1;
						}
						String fieldList = '';
						for(String fieldString: err.getFields()){
							fieldList = fieldList + '|' + fieldString;
						}
						fieldList = fieldList.right(fieldList.length() -1);
						updateHistory.lastConversionErrorFields__c = fieldList;
						updateHistory.lastConversionErrorMessage__c = err.getMessage();
						updateHistory.lastConversionErrorStatus__c = String.valueOf(err.getStatusCode());
						updateHistories.add(updateHistory);
                    }
                }
				srListCounter++;
            }
			if(removeHistories.size() > 0){
				delete removeHistories;
			}
			if(updateHistories.size()>0){
				update updateHistories;
			}
        }
        catch (Exception e) {
            // Exception occurred, output the exception message
            System.debug('Exception: ' + e.getTypeName() + ', ' + e.getMessage() + ', ' + e.getStackTraceString());
            
            // Write any errors to a custom object as well
            //ExceptionStorage__c es = new ExceptionStorage__c(
            //       name = 'Exception',
            //       ExceptionMessage__c = e.getMessage(),
            //       ExceptionType__c = e.getTypeName()
            //);
            //errors.add(es);
        }
        
        // If any errors occurred, save the ExceptionStorage records
        //if (errors.size() > 0) {
        //       insert errors;
        //}
    }
	
}