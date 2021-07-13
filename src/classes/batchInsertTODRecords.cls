global class batchInsertTODRecords implements Database.Batchable<SObject> {
	
	List<SObject> batchList;

	global batchInsertTODRecords(List<sObject> objList) {
		if (objList == null) objList = new List<sObject>();      
		this.batchList = objList;
	}
	

	global Iterable<SObject> start(Database.BatchableContext context) {
		return this.batchList;
	}

	
   	global void execute(Database.BatchableContext context, List<sObject> scope) {
		insert scope;
	}
	
	global void finish(Database.BatchableContext context) {
		
	}
}