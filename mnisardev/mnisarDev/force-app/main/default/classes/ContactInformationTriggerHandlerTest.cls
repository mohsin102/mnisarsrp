@isTest
public class ContactInformationTriggerHandlerTest {
	
    static testMethod void testTrigger() {
        // test the trigger and helper method

        Account a1 = new Account();
        a1.Name = 'Seller';
        a1.Type = 'Portfolio Investment';
        insert a1;
        
		contactInformation__c ciRec = new contactInformation__c(Account__c=a1.Id,Phone__c='1234567890',Primary__c=true);
        insert ciRec;
        ciRec.Phone__c='';
        ciRec.Street__c='Test';
        update ciRec;
    }
}