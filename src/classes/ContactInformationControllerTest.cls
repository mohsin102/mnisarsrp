@isTest
public class ContactInformationControllerTest {
	
    static testMethod void testTrigger() {
        // test the trigger and helper method

        Account a1 = new Account();
        a1.Name = 'Seller';
        a1.Type = 'Portfolio Investment';
        insert a1;
        List<contactInformation__c> cilist = new List<contactInformation__c>();
		contactInformation__c ciRec = new contactInformation__c(Account__c=a1.Id,Phone__c='1234567890',Primary__c=true);
        cilist.add(ciRec);
        
        ciRec = new contactInformation__c(Account__c=a1.Id,Street__c='1234567890',Primary__c=true);
        cilist.add(ciRec);
        insert cilist;
        ContactInformationController.fetchContactInfo(a1.Id);
        ContactInformationController.saveContactInfo( ContactInformationController.createWrapperList(cilist) , a1.Id);
        ContactInformationController.deleteContactInfo(ciRec.Id);
    }
}