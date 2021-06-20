public with sharing class homeTitleWorkTrackerAura  {
	
	@AuraEnabled
    public static List<TitleWorkJob__c> getTitleWorkJobs(Id recordId) {
		List<TitleWorkJob__c> titleWorkJob = new List<TitleWorkJob__c>();
        titleWorkJob = [SELECT CreatedById,	CreatedDate, Id, IsDeleted,	LastModifiedById, LastModifiedDate,	LastReferencedDate,	LastViewedDate,	Name,
							   SystemModstamp, completionDate__c, egnyteLink__c, landGridTract__c, landGridTract__r.Name, leaseAnalysis__c, leaseholdTitle__c, mineralTitle__c,
							   OwnerId, startDate__c, status__c, surfaceTitle__c, thoroughness__c, titleNoteQuality__c, titleSystemEntryAccuracy__c,
							   tractComplexityLeaseholdTitle__c, tractComplexityMineralTitle__c, tractComplexitySurfaceTitle__c, tractTitleComplexityNotes__c, tractsCO__c, type__c,
							   Owner.Name, Owner.FirstName,
									(SELECT CreatedById, CreatedDate, flatFileId__c, flatFileLoaded__c, flatFileName__c, Id, IsDeleted, jobNotes__c, landGridTract__c, LastModifiedById,
											LastModifiedDate, LastReferencedDate, LastViewedDate, Name, runSheetId__c, runSheetLoaded__c, runSheetName__c, status__c,
											SystemModstamp, titleWorkJob__c, landGridTract__r.Name
									 FROM titleIntegrationJobs__r )
						FROM TitleWorkJob__c
						WHERE landGridTract__c =: recordId
						ORDER by Name DESC
        ];
        return titleWorkJob;
    }

	@AuraEnabled
	public static titleTrackerResponse getTitleTrackers(String status){
		titleTrackerResponse response = new titleTrackerResponse();
		List<TitleWorkTracker__c> titleTrackers = new List<TitleWorkTracker__c>();
		//List<GroupMember> userGroups = [SELECT GroupId FROM GroupMember WHERE UserOrGroupId = :UserInfo.getUserId()];
		//List<Id> userGroupIds = new List<Id>();
		//for (GroupMember userGroup: userGroups){
		//	userGroupIds.add(userGroup.GroupId);
		//}
		List<TitleWorkJob__c> titleWorkJobs = [SELECT titleWorkTracker__c FROM TitleWorkJob__c WHERE ownerId = :UserInfo.getUserId()];
		Set<String> relatedIds = new Set <String>();
		for(titleWorkJob__c twj: titleWorkJobs){
			relatedIds.add(twj.titleWorkTracker__c);
		}
		titleTrackers = [SELECT completionDate__c,CreatedById,CreatedDate,Id,IsDeleted,landGridTract__c,LastActivityDate,LastModifiedById,
							    LastModifiedDate,Name,projectAOI__c,OwnerId,startDate__c,status__c, Owner.Name, projectAOI__r.Name,
								landGridTract__r.Name,
							    (SELECT CreatedById,	CreatedDate, Id, IsDeleted,	LastModifiedById, LastModifiedDate,	LastReferencedDate,	LastViewedDate,	Name,
							    SystemModstamp, completionDate__c, egnyteLink__c, landGridTract__c, OwnerId, Owner.Name, landGridTract__r.Name, leaseAnalysis__c, leaseholdTitle__c, mineralTitle__c,
							    startDate__c, status__c, surfaceTitle__c, thoroughness__c, titleNoteQuality__c, titleSystemEntryAccuracy__c,
							    tractComplexityLeaseholdTitle__c, tractComplexityMineralTitle__c, tractComplexitySurfaceTitle__c, tractTitleComplexityNotes__c, tractsCO__c, type__c,
							    Owner.FirstName			
							    FROM titleWorkJobs__r ORDER BY Name  DESC)
						 FROM TitleWorkTracker__c
						 WHERE (OwnerId = : UserInfo.getUserId()
						 OR ID in :relatedIds
						 )
						 AND status__c = :status
						 ORDER by Name DESC];
		List<Id> includedJobs = new List<Id>();
		for(TitleWorkTracker__c titleTracker:titleTrackers){
			for(TitleWorkJob__c workJob: titleTracker.titleWorkJobs__r){
				includedJobs.add(workJob.Id);
			}
		}

		

		List<TitleIntegrationJob__c> integrationJobs = [SELECT CreatedById, CreatedDate, flatFileId__c, flatFileLoaded__c, flatFileName__c, Id, IsDeleted, jobNotes__c, landGridTract__c,
															   LastModifiedById, LastModifiedDate, LastReferencedDate, LastViewedDate, Name, runSheetId__c, runSheetLoaded__c,
															   runSheetName__c, status__c, SystemModstamp, titleWorkJob__c 
														From TitleIntegrationJob__c 
														WHERE titleWorkJob__c in :includedJobs
														ORDER BY Name DESC];
	
		for(TitleWorkTracker__c titleTracker:titleTrackers){
			if(titleTracker.status__c != 'Complete'){
				response.hasTrackerInProgress = true;
			}
			titleTracker currentTracker = new titleTracker();
			currentTracker.titleWorkTracker = titleTracker;
			for(TitleWorkJob__c workJob: titleTracker.titleWorkJobs__r){
				titleWorkJob currentWorkJob = new titleWorkJob();
				currentWorkJob.titleWorkJob = workJob;
				if(workJob.type__c == 'Integration Review'){
					currentTracker.hasIntegrationReview = true;
				}
				if(workJob.type__c == 'Attorney Review'){
					currentTracker.hasAttorneyReview = true;
				}
				currentTracker.titleWorkJobs.add(currentWorkJob);
				for(TitleIntegrationJob__c integrationJob:integrationJobs){
					if (integrationJob.titleWorkJob__c == workJob.Id){
						currentWorkJob.titleIntegrations.add(integrationJob);
					}
				}
			}
			response.titleTrackers.add(currentTracker);
		}
		for(titleTracker currentTitleTracker:response.titleTrackers){
			System.debug('Title Tracker for record Id: ' + currentTitleTracker.titleWorkTracker.Id);
			for(titleWorkJob workJob: currentTitleTracker.titleWorkJobs){
				System.debug('Title Work Job for record Id: ' + workJob.titleWorkJob.Id);
				for(TitleIntegrationJob__c integrationJob:workJob.titleIntegrations){
					System.debug('Title Integration for record Id: ' + integrationJob.Id);
				}
			}
		}
		System.debug(titleTrackers);
		return response;
	}

	public class titleTrackerResponse{
		@AuraEnabled public List<titleTracker> titleTrackers {get; set;}
		@AuraEnabled public Boolean hasTrackerInProgress {get; set;}

		public titleTrackerResponse(){
			titleTrackers = new List<titleTracker>();
			hasTrackerInProgress = false;
		}

	}

	public class titleTracker{
		@AuraEnabled public TitleWorkTracker__c titleWorkTracker {get;set;}
		@AuraEnabled public List<titleWorkJob> titleWorkJobs {get;set;}
		@AuraEnabled public Boolean hasIntegrationReview {get; set;}
		@AuraEnabled public Boolean hasAttorneyReview {get; set;}

		public titleTracker(){
			titleWorkTracker = new TitleWorkTracker__c();
			titleWorkJobs = new List<titleWorkJob>();
			hasAttorneyReview = false;
			hasAttorneyReview = false;
		}
	}

	public class titleWorkJob{
		@AuraEnabled public TitleWorkJob__c titleWorkJob {get;set;}
		@AuraEnabled public List<TitleIntegrationJob__c> titleIntegrations{get;set;}
		@AuraEnabled public Boolean hasReview {get; set;}

		public titleWorkJob(){
			titleWorkJob = new TitleWorkJob__c();
			titleIntegrations = new List<TitleIntegrationJob__c>();
			hasReview = false;
		}
	}

	
}