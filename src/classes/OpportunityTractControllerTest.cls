@isTest
public class OpportunityTractControllerTest {
	
    @isTest
    public static void testmethod1(){
    	
        Account a1 = new Account();
        a1.Name = 'Seller';
        a1.Type = 'Portfolio Investment';
        insert a1;
        
        LandGridTract__c lt2 = new LandGridTract__c();
        lt2.Name='Bexar 1-179347 TX';
        lt2.County__c ='Bexar';
        insert lt2;
        
    	Opportunity o = new Opportunity();
        o.Name = 'New Opp 1';
        o.AccountId = a1.Id;
        o.Acquiring_Entity__c = a1.Id;
        o.CloseDate = Date.today() + 30;
        o.StageName='Closed Won';
        o.Effective_Date__c=system.today();
        insert o;
        
        Tract__c t2 = new Tract__c();
        t2.LandGridTract__c = lt2.Id;
		t2.Account__c = a1.Id;
        insert t2;

        Opportunity_Tract__c ot = new Opportunity_Tract__c();
        ot.Opportunity__c = o.Id;
        ot.Tract__c = t2.Id;
        insert ot;
        
        List<Opportunity_Tract__c> oppTractList = OpportunityTractController.getOppTracts(o.Id);
        
    }
}