public class OpportunityTractController {
    
    @AuraEnabled
    public static List<Opportunity_Tract__c> getOppTracts(Id oppId){
        
        List<Opportunity_Tract__c> oppTractList = new List<Opportunity_Tract__c>();
        oppTractList = [Select Id, Name, Account_Name__c, OTG_Cost__c,Tract__c,Tract__r.Name from Opportunity_Tract__c Where Opportunity__c =:oppId];
        return oppTractList;
    }
}