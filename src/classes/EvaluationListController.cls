public class EvaluationListController {
	
    @AuraEnabled
    public static EvaluationWrapper getEvaluationRecords(Id recordId){
        
        List<Evaluation__c> evalList = new List<Evaluation__c>();
        String sObjName = recordId.getSObjectType().getDescribe().getName(); 
		if(sObjName=='Opportunity'){
            evalList = [Select Id,Name,Status__c,opportunity__c, Owner.Name , Owner.Id , srpInvestmentTeamReviewer__r.Name, srpInvestmentTeamReviewer__c, startDate__c, completionDate__c  from Evaluation__c where opportunity__c=:recordId];
        }
        EvaluationWrapper wrap = new EvaluationWrapper();
        wrap.evalList = evalList;
        wrap.sObjectType = sObjName;
        return wrap;
    }
    
    public class EvaluationWrapper{
        @AuraEnabled
        public List<Evaluation__c> evalList{get;set;}
        @AuraEnabled
        public string sObjectType{get;set;}
    }
}