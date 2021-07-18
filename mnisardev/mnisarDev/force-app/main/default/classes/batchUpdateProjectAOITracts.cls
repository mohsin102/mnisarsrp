global class batchUpdateProjectAOITracts implements Database.Batchable<SObject> {
	global final Set<Id> projectAOIs;
	global final Set<Id> tracts;

	global batchUpdateProjectAOITracts(Set<Id> updatedProjects, Set<Id> updatedTracts) {
		projectAOIs = updatedProjects;
		tracts = updatedTracts;
		
	}
	
	/**
	 * @description gets invoked when the batch job starts
	 * @param context contains the job ID
	 * @returns the record set as a QueryLocator object that will be batched for execution
	 */ 
	global Database.QueryLocator start(Database.BatchableContext context) {
		if(projectAOIs != null){
			return Database.getQueryLocator('SELECT Id, Name FROM Project_AOI_Tract__c WHERE projectAoi__c IN :projectAOIs');
		}
		if(tracts != null){
			return Database.getQueryLocator('SELECT Id, Name FROM Project_AOI_Tract__c WHERE Tract__c IN :tracts');
		}
		else return null;
	}

	/**
	 * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
	 * @param context contains the job ID
	 * @param scope contains the batch of records to process.
	 */ 
   	global void execute(Database.BatchableContext context, List<Project_AOI_Tract__c> scope) {
		System.debug('Update size is: ' + scope.size());
		update scope;
	}
	
	/**
	 * @description gets invoked when the batch job finishes. Place any clean up code in this method.
	 * @param context contains the job ID
	 */ 
	global void finish(Database.BatchableContext context) {
		
	}
}