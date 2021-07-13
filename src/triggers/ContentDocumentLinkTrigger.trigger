trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert) {

    if(Trigger.isAfter && Trigger.isInsert){
        ContentDocumentLinkTriggerHelper.updateEvaluationRecords(Trigger.New);
    }
}