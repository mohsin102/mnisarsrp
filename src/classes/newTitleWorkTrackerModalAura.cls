public with sharing class newTitleWorkTrackerModalAura  {

	@AuraEnabled
	public static List<AuraSelectOption> getWorkJobTypes(Id titleWorkTrackerId){
		System.debug('titleWorkTrackerId value is: ' + titleWorkTrackerId);
		List<AuraSelectOption> options = new List<AuraSelectOption>();
        List<TitleWorkJob__c> titleWorkJobs = new List<TitleWorkJob__c>();
		titleWorkJobs = [SELECT ID, type__c FROM TitleWorkJob__c WHERE TitleWorkTracker__c = :titleWorkTrackerId];
		Schema.DescribeFieldResult fieldResult = TitleWorkJob__c.type__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
		for( Schema.PicklistEntry f : ple){
			Boolean typeExists = false;
			for(TitleWorkJob__c titleWorkJob:titleWorkJobs){
				if (f.getValue() == titleWorkJob.type__c){
					typeExists = true;	
				}
			}
			options.add(new AuraSelectOption(f.getValue(), f.getLabel(), typeExists));   //put(f.getLabel(), f.getValue());
		}       
		return options;
	}

	@AuraEnabled
	public static titleWorkJobSelectOptions getTitleWorkJobSelectOptions(Id titleWorkTrackerId){
		titleWorkJobSelectOptions response = new titleWorkJobSelectOptions();
		List<TitleWorkJob__c> titleWorkJobs = new List<TitleWorkJob__c>();
		titleWorkJobs = [SELECT ID, type__c FROM TitleWorkJob__c WHERE TitleWorkTracker__c = :titleWorkTrackerId];
		Schema.DescribeFieldResult fieldResult = TitleWorkJob__c.type__c.getDescribe();
		List<Schema.PicklistEntry> pleTypes = fieldResult.getPicklistValues();
		String defaultType = String.valueOf(fieldResult.getDefaultValue());
		List<Schema.PicklistEntry> pleStatuses = TitleWorkJob__c.status__c.getDescribe().getPicklistValues();
		response.defaultType = String.valueOf(fieldResult.getDefaultValue());
        response.defaultStatus = String.valueOf(TitleWorkJob__c.status__c.getDescribe().getDefaultValue());
		for( Schema.PicklistEntry pleType : pleTypes){
			Boolean typeExists = false;
			for(TitleWorkJob__c titleWorkJob:titleWorkJobs){
				if (pleType.getValue() == titleWorkJob.type__c){
					typeExists = true;	
				}
			}
			response.workJobTypes.add(new AuraSelectOption(pleType.getValue(), pleType.getLabel(), typeExists));   //put(f.getLabel(), f.getValue());
		} 
		for( Schema.PicklistEntry pleStatus : pleStatuses){
			response.workJobStatuses.add(new AuraSelectOption(pleStatus.getValue(), pleStatus.getLabel(), false));   //put(f.getLabel(), f.getValue());
		}      

		return response;

	}

	@AuraEnabled
	public static createTitleTrackerResponse createTitleWorkTracker (String titleTrackerId, String landGridTractId, String projectAOIId, String workJobType, String ownerId, Date startDate, boolean createTitleTracker, String workJobStatus, date completionDate){
		System.debug('titleTrackerId is: ' + titleTrackerId + ' landGridTractId is: ' + landGridTractId + ' projectAOIId is: ' + ' workJobType is: ' + workJobType + ' ownerId is: ' + ownerId + ' startDate is: ' + startDate+ ' createTitleTracker is: ' + createTitleTracker + ' workJobStatus is: ' + workJobStatus + ' completionDate is: ' + completionDate);

		Schema.DescribeFieldResult fieldResult = TitleWorkTracker__c.status__c.getDescribe();
		
		createTitleTrackerResponse response = new createTitleTrackerResponse();
		try{
			TitleWorkJob__c newTitleWorkJob = new TitleWorkJob__c();
			if(createTitleTracker){
				List<TitleWorkTracker__c> existingTracker = new List<TitleWorkTracker__c>();
				existingTracker = [SELECT ID FROM TitleWorkTracker__c WHERE status__c != 'Complete' AND landGridTract__c = :landGridTractId];
				if(existingTracker.size() > 0){
					throw new titleTrackerException('In Progress Title Tracker already exists for selected Land Grid Tract.');
				}
				TitleWorkTracker__c newTitleWorkTracker = new TitleWorkTracker__c();
				newTitleWorkTracker.projectAOI__c = projectAOIId;
				
				//newTitleWorkTracker.startDate__c = startDate;
				newTitleWorkTracker.OwnerId = ownerId;
				newTitleWorkTracker.landGridTract__c = landGridTractId;
				insert newTitleWorkTracker;
				response.titleWorkTracker = newTitleWorkTracker;
				newTitleWorkJob.titleWorkTracker__c = newTitleWorkTracker.Id;
			}
			else{
				newTitleWorkJob.titleWorkTracker__c = titleTrackerId;
			}
			newTitleWorkJob.type__c = workJobType;
			//newTitleWorkJob.startDate__c = startDate;
			newTitleWorkJob.OwnerId = ownerId;
			newTitleWorkJob.status__c = workJobStatus;
			if(workJobStatus != 'Not Started'){
				newTitleWorkJob.startDate__c = startDate;
			}
			if(workJobStatus == 'Complete'){
				newTitleWorkJob.completionDate__c = completionDate;
			}
			newTitleWorkJob.landGridTract__c = landGridTractId;
			insert newTitleWorkJob;
			//TitleWorkTracker__c currentTitleWorkTracker = new TitleWorkTracker__c();
			//currentTitleWorkTracker.Id = titleTrackerId;
			//currentTitleWorkTracker.status__c = 'In Progress';
			//currentTitleWorkTracker.startDate__c = startDate;
			//update currentTitleWorkTracker;
			response.titleWorkJob = newTitleWorkJob;
			//jdg 05-14-2021 Removing code to create related Title Work Job.  This will be moved to "Start Tracker" functionality.
			/*newTitleWorkJob.type__c = workJobType;
			newTitleWorkJob.startDate__c = startDate;
			newTitleWorkJob.srpOwner__c = ownerId;
			newTitleWorkJob.status__c = defaultStatus;
			newTitleWorkJob.landGridTract__c = landGridTractId;
			insert newTitleWorkJob;
			response.titleWorkJob = newTitleWorkJob;*/

		}
		Catch(Exception e){
			response.returnMessage = e.getMessage();
			system.debug('ERROR CREATING TITLE WORK TRACKER' + e + '\n' + e.getMessage() + ' Line Number: ' + e.getLineNumber() + ' ' + e.getStackTraceString());
		}

		return response;
	}

	@AuraEnabled 
    public static List<LookupSearchResult> fetchUser(){
       String ltIcon = 'standard:user';
	   User u = [select id,Name from User where id =: userInfo.getUserId()];
	   List<LookupSearchResult> results = new List<LookupSearchResult>();
	   results.add(new LookupSearchResult(u.Id, 'User', ltIcon, u.Name, 'User'));
       return results;
    }

	@AuraEnabled 
    public static List<LookupSearchResult> fetchDefaultOwner(){
       String ltIcon = 'standard:queue';
	   DefaultValues__mdt defaultOwner = DefaultValues__mdt.getInstance('TitleIntegrationJob_c_OwnerId');
	   Group g = [select id,Name from Group where id =: defaultOwner.value__c];
	   List<LookupSearchResult> results = new List<LookupSearchResult>();
	   results.add(new LookupSearchResult(g.Id, 'Queue', ltIcon, g.Name, 'Queue'));
       return results;
    }

	@AuraEnabled 
    public static List<LookupSearchResult> fetchOwner(Id ownerId){
		//String ownerType = String.valueOf(ownerId.getSobjectType().getDescribe().getName());
		switch on ownerId.getSobjectType().getDescribe().getName(){
			when 'User'{
				String ltIcon = 'standard:user';
				User u = [select id,Name from User where id =: ownerId];
				List<LookupSearchResult> results = new List<LookupSearchResult>();
				results.add(new LookupSearchResult(u.Id, 'User', ltIcon, u.Name, 'User'));
				return results;
			}
			when 'Group'{
				String ltIcon = 'standard:queue';
				Group g = [select id,Name from Group where id =: ownerId];
				List<LookupSearchResult> results = new List<LookupSearchResult>();
				results.add(new LookupSearchResult(g.Id, 'Queue', ltIcon, g.Name, 'Queue'));
				return results;
			}
			when else{
				return null;
			}
		}

    }

	@AuraEnabled
	public static List<LookupSearchResult> searchLandGridTracts(String searchTerm, List<String> selectedIds){
		System.debug('Trying to get search results.');
		return lookupUtility.searchLandGridTract(searchTerm, selectedIds);
	}

	@AuraEnabled
	public static List<LookupSearchResult> searchProjectAOIs(String searchTerm, List<String> selectedIds){
		System.debug('Trying to get search results.');
		return lookupUtility.searchProjectAOI(searchTerm, selectedIds);
	}

	@AuraEnabled
	public static List<LookupSearchResult> searchUsers(String searchTerm, List<String> selectedIds){
		System.debug('Trying to get search results.');
		return lookupUtility.searchUsers(searchTerm, selectedIds);
	}

	@AuraEnabled
	public static List<LookupSearchResult> searchOwners(String searchTerm, List<String> selectedIds){
		System.debug('Trying to get search results.');
		return lookupUtility.searchOwners(searchTerm, selectedIds, 'TitleWorkTracker__c');
	}

	@AuraEnabled
	public static List<LookupSearchResult> searchOwnersTIJ(String searchTerm, List<String> selectedIds){
		System.debug('Trying to get search results.');
		return lookupUtility.searchOwners(searchTerm, selectedIds, 'TitleIntegrationJob__c');
	}

	

	public virtual class titleTrackerException extends Exception{}

	public class createTitleTrackerResponse{
		@AuraEnabled public String returnMessage {get;set;}
		@AuraEnabled public TitleWorkTracker__c titleWorkTracker {get;set;}
		@AuraEnabled public TitleWorkJob__c titleWorkJob {get;set;}

		public createTitleTrackerResponse(){
			returnMessage = 'SUCCESS';
			titleWorkTracker = new TitleWorkTracker__c();
			titleWorkJob = new TitleWorkJob__c();
		}
	}

	public class titleWorkJobSelectOptions{
		@AuraEnabled public List<AuraSelectOption> workJobTypes;
		@AuraEnabled public List<AuraSelectOption> workJobStatuses;
		@AuraEnabled public String defaultType;
		@AuraEnabled public String defaultStatus;

		public titleWorkJobSelectOptions(){
			workJobTypes = new List<AuraSelectOption>();
			workJobStatuses = new List<AuraSelectOption>();
			defaultType = '';
			defaultStatus = '';
		}
	}
}