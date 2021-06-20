@isTest
public class ManageTractControllerTest{
    
    @testSetup static void methodName() {
        Account a1 = new Account();
        a1.Name = 'Seller';
        a1.Type = 'Portfolio Investment';
        insert a1;
        
        Account a2 = new Account();
        a2.Name = 'Buyer';
        a2.Type = 'Portfolio Investment';
        insert a2;
        
        Opportunity o = new Opportunity();
        o.Name = 'New Opp 1';
        o.AccountId = a1.Id;
        o.Acquiring_Entity__c = a2.Id;
        o.CloseDate = Date.today() + 30;
        o.StageName='Closed Won';
        o.Effective_Date__c=system.today();
        insert o;
        
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
        
        Tract__c t1 = new Tract__c();
        t1.LandGridTract__c = lt1.Id;
        t1.Commission_Amount__c=1.00;
        t1.Value_Per_Acre__c=1.00;
        t1.OTG_Cost_Per_Acre__c=1.00;
        t1.Other_Capitalized_Costs__c=1.00;
        t1.Title_Cost__c=1.00;
        t1.netAcres__c=1.00;
        t1.Notes__c='test';
		t1.Account__c = a1.Id;
        insert t1;
        
        Tract__c t2 = new Tract__c();
        t2.LandGridTract__c = lt2.Id;
        t2.Commission_Amount__c=1.00;
        t2.Value_Per_Acre__c=1.00;
        t2.OTG_Cost_Per_Acre__c=1.00;
        t2.Other_Capitalized_Costs__c=1.00;
        t2.Title_Cost__c=1.00;
        t2.netAcres__c=1.00;
        t2.Notes__c='test';
		t2.Account__c = a2.Id;
        insert t2;
        
        Opportunity_Tract__c ot = new Opportunity_Tract__c();
        ot.Opportunity__c = o.Id;
        ot.Tract__c = t2.Id;
        insert ot;
        
    }
    
    
    @isTest
    private static void getTractTestMethod(){
        Opportunity oppRec = [Select id,AccountId from Opportunity Limit 1];
        ManageTractController.getTract(oppRec.Id);
    }
    
    @isTest 
    public static void getFilteredTractsTestMethod(){
		Test.startTest();
        Opportunity opp = [Select id,AccountId from Opportunity Limit 1];
        ManageTractController.getFilteredTracts(opp.Id, 1, 5,'tex', 2);
        List<Tract__c> t = [Select Id from tract__c];
        delete t;
        List<LandGridTract__c> l = [Select Id from LandGridTract__c];
        delete l;
        ManageTractController.getFilteredTracts(opp.Id, 1, 5,'tex', 2);
        ManageTractController.getFilteredTracts(opp.Id, 1, 5,'arka', 2);
        ManageTractController.getFilteredTracts(opp.Id, 1, 5,'colo', 2);
        ManageTractController.getFilteredTracts(opp.Id, 1, 5,'monta', 2);
        ManageTractController.getFilteredTracts(opp.Id, 1, 5,'kans', 2);
        ManageTractController.getFilteredTracts(opp.Id, 1, 5,'new', 2);
        ManageTractController.getFilteredTracts(opp.Id, 1, 5,'louis', 2);
        ManageTractController.getFilteredTracts(opp.Id, 1, 5,'wyo', 2);
        ManageTractController.getFilteredTracts(opp.Id, 1, 5,'test', 2);
        ManageTractController.getFilteredTracts(opp.Id, 1, 5,'', 2);
        Test.stopTest();
    }
    @isTest
    public static void addTractTestmethod(){
        
        List<Tract__c> tracts = new List<Tract__c>();
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
        
        Tract__c t1 = new Tract__c();
        t1.LandGridTract__c = lt1.Id;
        t1.Commission_Amount__c=1.00;
        t1.Value_Per_Acre__c=1.00;
        t1.OTG_Cost_Per_Acre__c=1.00;
        t1.Other_Capitalized_Costs__c=1.00;
        t1.Title_Cost__c=1.00;
        t1.netAcres__c=1.00;
        t1.Notes__c='test';
        tracts.add(t1);
        
        Tract__c t2 = new Tract__c();
        t2.LandGridTract__c = lt2.Id;
        t2.Commission_Amount__c=1.00;
        t2.Value_Per_Acre__c=1.00;
        t2.OTG_Cost_Per_Acre__c=1.00;
        t2.Other_Capitalized_Costs__c=1.00;
        t2.Title_Cost__c=1.00;
        t2.netAcres__c=1.00;
        t2.Notes__c='test';
        tracts.add(t2);
        Opportunity oppRec = [Select id,AccountId from Opportunity Limit 1];
        try{
            ManageTractController.addTract(oppRec.Id,tracts);
        }catch(Exception e){
            
        }
    }
    
    @isTest
    public static void removeTractTestMethod(){
        Opportunity opp = [Select id,AccountId from Opportunity Limit 1];
        List<Tract__c> tracts = [Select Id from Tract__c];
        
        ManageTractController.removeTract(opp.Id,tracts);
    }
}