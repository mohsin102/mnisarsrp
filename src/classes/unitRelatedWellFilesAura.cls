//Create by John Gorrell 0914/2020 - Pivotal Tracker Case 174765345

//Test coverage provided by 

public with sharing class unitRelatedWellFilesAura{  

	@AuraEnabled
	public static List<fileResponse> getFiles2(String unitId){
		List<fileResponse> response = new List<fileResponse>();
		List<ContentVersion> contents = new List<ContentVersion>();
		List<ContentDocumentLink> documentList =  [SELECT ContentDocumentId  FROM ContentDocumentLink where LinkedEntityId in (SELECT Id FROM Well__c WHERE Unit__c = :unitId)];
		

		if(documentList.size() > 0){
			Set <String> documentIds = new Set<String>();
			for(ContentDocumentLink doc:documentList){
				documentIds.add(doc.ContentDocumentId);
			}
			contents = [SELECT Title, ContentDocumentId, FileExtension, FileType, ContentModifiedDate, ContentSize FROM ContentVersion where ContentDocumentId IN :documentIds AND IsLatest =  true];
		}

		for(ContentVersion cv: contents){
			UserDocument ud = new UserDocument(cv);
			fileResponse fr = new fileResponse();
			fr.cv = ud.origContentVersion;
			fr.fileTypeImage = ud.fileTypeImage;
			fr.friendlyFileType = ud.friendlyFileType;
			fr.friendlyFileSize = getFriendlyFileSize(ud.origContentVersion.ContentSize);
			response.add(fr);
		}
		System.debug(response);

		return response;
	}

	public static String getFriendlyFileSize(Integer fieldSize){
		if(fieldSize > 1000000){
			return fieldSize / 1000000 + 'GB';
		}
		if(fieldSize > 1000){
			return fieldSize / 1000 + 'KB';
		}
		if(fieldSize >0){
			return fieldSize + 'B';
		}
		return '';
	}

	public class fileResponse {
        @AuraEnabled
        public ContentVersion cv {get; set;}
        @AuraEnabled
        public String fileTypeImage {get; set;}
		@AuraEnabled
		public String friendlyFileType {get; set;}
		@AuraEnabled
		public String friendlyFileSize {get; set;}

		public fileResponse(){
			cv = new ContentVersion();
			fileTypeImage = '';
			friendlyFileType = '';
			friendlyFileSize = '';
		}
    }

}