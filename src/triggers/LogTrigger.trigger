trigger LogTrigger on Log__c (after insert)  { 
	
	List<LogSetting__mdt> logSetting = [SELECT emailAddresses__c FROM LogSetting__mdt WHERE DeveloperName = 'Default' LIMIT 1];
	List<String> emailAddresses = logSetting[0].emailAddresses__c.split('\\|');
	
	Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    email.setToAddresses(emailAddresses);
    email.setSubject('Log Failure');
            
    email.setHtmlBody('Hello, <br/><br/>There are '+Trigger.new.size()+' new log files.');
    try{
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }catch(exception e){
        System.debug(e.getMessage());
    }

}