//Test coverage included in titleWorkAuraTest.cls

public class landGridTractRelatedListAura  {

	@AuraEnabled
    public static List<TitleWorkJob__c> getTitleWorkJobs(Id recordId) {
		List<TitleWorkJob__c> titleWorkJobs = new List<TitleWorkJob__c>();
        titleWorkJobs = [SELECT 
						 completionDate__c,CreatedDate,Id,Name ,srpOwner__c,
						 startDate__c,status__c, type__c, srpOwner__r.Name, titleWorkTracker__c
						 FROM TitleWorkJob__c
						 WHERE titleWorkTracker__r.landGridTract__c =: recordId
						 ORDER by Name
        ];
        return titleWorkJobs;
    }

	@AuraEnabled
    public static List<TitleWorkTracker__c> getTitleWorkTrackers(Id recordId) {
		List<TitleWorkTracker__c> titleWorkTrackers = new List<TitleWorkTracker__c>();
        titleWorkTrackers = [SELECT	completionDate__c, CreatedById, CreatedDate, Id, IsDeleted, landGridTract__c,  LastActivityDate,
								LastModifiedById, LastModifiedDate, Name, projectAOI__c, srpOwner__c, startDate__c, status__c, SystemModstamp 
						 FROM TitleWorkTracker__c
						 WHERE landGridTract__c =: recordId
						 ORDER by Name DESC
        ];
        return titleWorkTrackers;
    }


	@AuraEnabled
	public static List<Tract__c> getTracts(Id recordId){
		List<Tract__c> relatedTracts = new List<Tract__c>();
		relatedTracts = [SELECT 
						 netAcreageUnits__c,netAcres__c,depth__c,Full_Legal_Name__c,maxPPA__c,maxPrice__c,Name,Notes__c,
						 OTG_Cost_Per_Acre__c,OTG_Cost__c,percentCovered__c,targetPPA__c,targetPrice__c,Total_Cost_Per_Acre__c,Total_Cost__c,
						 LandGridTract__c, Instrument_Type__c 
						 FROM Tract__c
						 WHERE LandGridTract__c = :recordId
						 ORDER by Name
		];
		return relatedTracts;
	}
	
}