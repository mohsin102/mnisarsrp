public class WellInterestAllocationListController {
    
    @AuraEnabled
    public static list<Well__c> getAllWellUnits(string acId){
        list<Well__c> AllUnitWells =  new list<Well__c>(); 
        AllUnitWells = [select id, name,Unit__c, Type__c, Total_Depth__c,Current_Operator_Name__c, Current_Operator__c,Current_Operator__r.Name from Well__c where Unit__c =: acId and Unit__c!=null limit 50000];
        return AllUnitWells;
    }
   
    @AuraEnabled
    public static list<Tract__c> getAllAccountsTracts(string accID){
        list<Tract__c> AllWellTracts =  new list<Tract__c>(); 
        system.debug('--------accID--------'+accID); 
        AllWellTracts = [select id, name,Operator_Name__c from Tract__c where Account__c =: accID and Account__c!=null and Account__r.Type='Portfolio Investment' limit 50000];
        return AllWellTracts;
    }
    @AuraEnabled
    public Static list<Monthly_Production__c>getAllMonthlyProduction(string oId){
        list<Monthly_Production__c> monthlProductionlist= new list<Monthly_Production__c>();
        monthlProductionlist=[Select Name,Production_Date__c,Gas__c,Liquid__c from Monthly_Production__c where Well__c=:oId];
        return monthlProductionlist;
    }
    
    
    @AuraEnabled
    public Static list<Subtract__c> getSubtracts(Id tractId){
        list<Subtract__c> subtractList= new list<Subtract__c>();
        String sObjName = tractId.getSObjectType().getDescribe().getName();
        if(sObjName=='Tract__c'){
            subtractList=[Select Id,Name, Subtract_Quarter_Call__c,Subtract_Acres__c,Subtract_Gross_Acres__c,Subtract_NRI__c, Instrument__c, Instrument__r.Name, Instrument_Lease_Royalty__c From Subtract__c Where Tract__c=:tractId Limit 5000];
        }
        if(subtractList.size()>0)
            return subtractList;
        return subtractList;
    }
    
}