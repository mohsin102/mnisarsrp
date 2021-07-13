public class UnitAllocationWithTractController{

    @AuraEnabled
    public static list<retWrapper> getUAwithTractOwner(Id recordId){

        Well__c wellRec = [Select unit__c from well__c where Id=:recordId];

        List<unitAllocation__c> uaList = [Select Id,Subtract__r.Tract__r.Account__c,Subtract__r.Tract__r.Account__r.Name from unitAllocation__c where unit__c =: wellRec.unit__c];
        Map<Id,retWrapper> retMap = new Map<Id,retWrapper>();
        Report r = [SELECT  Id,  DeveloperName FROM Report WHERE Name = 'Wells with Unit Allocations' LIMIT 1];
        for(unitAllocation__c ua : uaList){
            if(retMap.containsKey(ua.Subtract__r.Tract__r.Account__c)){
                retWrapper values = retMap.get(ua.Subtract__r.Tract__r.Account__c);
                values.count += 1;
                retMap.put(ua.Subtract__r.Tract__r.Account__c,values);
            }else{
                retWrapper values = new retWrapper();
                values.reportURL = URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/Report/'+string.valueOF(r.Id)+'/view';
                values.ownerId = ua.Subtract__r.Tract__r.Account__c;
                values.ownerName = ua.Subtract__r.Tract__r.Account__r.Name;
                values.count = 1;
                retMap.put(ua.Subtract__r.Tract__r.Account__c,values);
            }
        }
        return retMap.values();
    }

    public class retWrapper{
        @AuraEnabled
        public String ownerId{get;set;}
        @AuraEnabled
        public String ownerName{get;set;}
        @AuraEnabled
        public Integer count{get;set;}
        @AuraEnabled
        public String reportURL{get;set;}
    }
}