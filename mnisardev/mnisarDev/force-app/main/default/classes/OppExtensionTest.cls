@isTest
public class OppExtensionTest {

    static testMethod void testOppExtension() {

        Account a1 = new Account();
        a1.Name = 'Seller';
        insert a1;

        Account a2 = new Account();
        a2.Name = 'Buyer';
        insert a2;

        List<LandGridTract__c> lts = new List<LandGridTract__c>();
        LandGridTract__c lt1 = new LandGridTract__c();
        lt1.Name='Bexar 1-579e38 TX';
        lt1.County__c ='Bexar';
        lts.add(lt1);

        LandGridTract__c lt2 = new LandGridTract__c();
        lt2.Name='Bexar 1-179347 TX';
        lt2.County__c ='Bexar';
        lts.add(lt2);
        insert lts;

        Opportunity o = new Opportunity();
        o.Name = 'New Opp 1';
        o.AccountId = a1.Id;
        o.Acquiring_Entity__c = a2.Id;
        o.CloseDate = Date.today() + 30;
        o.StageName = 'Pending';
        insert o;

        Opportunity o2 = new Opportunity();
        o2.Name = 'New Opp 1';
        o2.AccountId = a1.Id;
        o2.Acquiring_Entity__c = a2.Id;
        o2.Effective_Date__c = date.today();
        o2.CloseDate = Date.today() + 30;
        o2.StageName = 'Closed Won';
        insert o2;

        Tract__c t1 = new Tract__c();
        t1.LandGridTract__c = lt1.Id;
        t1.Account__c = a1.Id;
        insert t1;

        Tract__c t2 = new Tract__c();
        t2.LandGridTract__c = lt2.Id;
        t2.Account__c = a2.Id;
        insert t2;

        Opportunity_Tract__c ot = new Opportunity_Tract__c();
        ot.Opportunity__c = o.Id;
        ot.Tract__c = t2.Id;
        insert ot;

        o.Type='Acquisition';
        o.Effective_Date__c=date.today();
        o.StageName='Closed Won';
        update o;
        
        Evaluation__c eval = new Evaluation__c(Opportunity__c = o.Id);
        insert eval;
        
        Object testData = JSON.deserialize('[{"askUnitPrice__c":"55555","Id":"a025G00000kFzNBQA0"}]', List<Opportunity_Tract__c>.class);

        Test.startTest();

        ApexPages.StandardController sc = new ApexPages.StandardController(o);
        PageReference pageRef = Page.OppTransactionList;
        pageRef.getParameters().put('id', String.valueOf(o.Id));
        Test.setCurrentPage(pageRef);
        OppExtension oe = new OppExtension(sc);

        System.debug(oe.oppTractList.size());
        
        OppExtension.getTracts(eval.Id, 'Evaluation__c');
        
        OppExtension.updatePricing(testData);

        Test.stopTest();


    }
}