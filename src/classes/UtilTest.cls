@isTest
public with sharing class UtilTest {

    static testMethod void testUtils() {
        List<Account> accs = new List<Account>();
        Account a1 = new Account(Name = 'Account1');
        Account a2 = new Account(Name = 'Account2');
        accs.add(a1);
        accs.add(a2);
        insert accs;
        Test.startTest();

        system.assert(Util.getIds(accs).size() == 2);

        Test.stopTest();
    }

}