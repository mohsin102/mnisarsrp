public without sharing class GISUpdateRequestController {
    
    @AuraEnabled
    public static void markAsComplete(Id recordId){

        GIS_Update_Request__c gisRec = [Select name from GIS_Update_Request__c where Id =: recordId];
        gisRec.Completion_Date__c = system.now();
        gisRec.Completed_By__c  = UserInfo.getUserId();
        update gisRec;

        FeedItem post = new FeedItem();
        post.ParentId = recordId;
        post.Body = 'User has completed GIS Update Request: '+gisRec.name;
        insert post;
    }
    
    @AuraEnabled
    public static void shapeUpdated(Id recordId){

        GIS_Update_Request__c gisRec = [Select name from GIS_Update_Request__c where Id =: recordId];  //new GIS_Update_Request__c(Id=recordId);
        gisRec.Shape_Updated_Date__c = system.now();
        gisRec.Shape_UpdatedBy__c = UserInfo.getUserId();
        update gisRec;

		FeedItem post = new FeedItem();
        post.ParentId = recordId;
        post.Body = 'User has updated shape for GIS Update Request: '+gisRec.name;
        insert post;

    }
    
    @AuraEnabled
    public static List<GIS_Update_Request__c> getRelatedGISUpdateRequest(Id unitId){

        List<GIS_Update_Request__c>  gisList = [Select Id, Name, Completed_By__c,Completed_By__r.Name,Completion_Date__c, Createdby.Name,CreatedDate from GIS_Update_Request__c where Unit__c=:unitId];
        return gisList;
    }
}