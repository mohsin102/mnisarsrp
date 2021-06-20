global with sharing class CDEX_SendNotificationsSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        List<Log__c> logs = [Select Id from Log__c where CreatedDate >=: system.today() AND Process__c like '%CDEX%'];
        if(logs.size()>0){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            
            email.setToAddresses(new List<String>{'jade.tran@srp-ok.com'});
            email.setSubject('CDEX Failure');
            
            email.setHtmlBody('Hello, <br/><br/>There are '+logs.size()+' failures due to cdex import. You can view more details from the object tab.<br/><br/>Regards<br/> Developer');
            try{
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            }catch(exception e){
                System.debug(e.getMessage());
            }
        }
    }
}