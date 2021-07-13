@isTest
public class EvaluationListController_Test {

    @isTest
    public static void testMethod1(){
        
        Account a1 = new Account();
        a1.Name = 'Seller';
        a1.Type = 'Portfolio Investment';
        insert a1;

        Account a2 = new Account();
        a2.Name = 'Buyer';
        a2.Type = 'Portfolio Investment';
        insert a2;
        
        Opportunity opp = new opportunity();
        opp.Name = 'New Opp 1';
        opp.AccountId = a1.Id;
        opp.Acquiring_Entity__c = a2.Id;
        opp.CloseDate = Date.today() + 30;
        opp.StageName = 'Pending';
        insert opp;
        
        Evaluation__c evalRec = new Evaluation__c();
        evalRec.status__c = 'Not Started';
        evalRec.opportunity__c = opp.Id;
        insert evalRec;
        
        Test.startTest();
        EvaluationListController.getEvaluationRecords(opp.Id);
        Test.stopTest();
    }
}