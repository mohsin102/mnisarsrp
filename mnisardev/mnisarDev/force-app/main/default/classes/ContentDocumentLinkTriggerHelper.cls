public class ContentDocumentLinkTriggerHelper {

    public static void updateEvaluationRecords(List<contentDocumentLink> newList){
        
        Set<Id> evaluationSet = new Set<Id>();
        for(contentDocumentLink rec : newList){
            if(rec.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Evaluation__c'){
                evaluationSet.add(rec.LinkedEntityId);
            }
        }
        if(evaluationSet.size()>0){
            List<Evaluation__c> eList = new List<Evaluation__c>();
            for(Id eId : evaluationSet){
                Evaluation__c eRec = new Evaluation__c();
                eRec.hasAttachment__c =true;
                eRec.Id = eId;
                eList.add(eRec);
            }
            if(eList.size()>0){
                update eList;
            }
        }
    }
}