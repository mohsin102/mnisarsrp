@isTest
public class RoyaltyCheckExtensionTest {

    static testMethod void testRoyaltyCheckExtension() {

        Test.startTest();

        Royalty_Check__c chk = new Royalty_Check__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(chk);
        PageReference pageRef = Page.RoyaltyCheckEdit;
        pageRef.getParameters().put('on', 'SM');
        Test.setCurrentPage(pageRef);
        RoyaltyCheckExtension rc = new RoyaltyCheckExtension(sc);

        Royalty_Check__c rc1 = rc.selCheck;
        rc.save();
       /* rc1.Payee__c = 'n';
        rc1.Payee__c = 'na';
        rc1.Payor__c = 'fufu'; */
        rc1.Amount__c = 4.44;
        rc1.Check_Issue_Date__c = Date.valueOf('2019-07-24');
        rc1.Owner_Number__c = '1293';
        rc1.Check_Number__c = 'E394867';
        rc1.Notes__c = 'H';
        rc.save();
        rc.saveNew();

        Test.stopTest();


    }
}