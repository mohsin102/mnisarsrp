//Created by John Gorrell on 11/04/2019 as part of Tract Reconciliation Project

//Code coverage provided by tractReconciliationAuraTest

public with sharing class tractReconciliationAura  {

	static final tractReconciliationSetting__mdt reconciliationSettings = [SELECT torRecordTypeId__c, totRecordTypeId__c, baseURL__c, Label, DeveloperName FROM tractReconciliationSetting__mdt WHERE baseURL__c = :URL.getSalesforceBaseUrl().toExternalForm().replace('https', 'http')];

	@AuraEnabled
	public static tonReconciliationRecords getReconciliationRecords(String recordId){
		tonReconciliationRecords currentRecords = new tonReconciliationRecords();
		currentRecords.tonRecord = getTonRecord(recordId);
		currentRecords.tonTractRecords = getTonTractRecords(currentRecords.tonRecord.Account__c, currentRecords.tonRecord.jobId__r.LandGridTract__c, recordId);
		currentRecords.tonTotRecords = getTonTotRecords(recordId);
		currentRecords.tractInstrumentTypePicklist = getTractInstrumentTypePicklist();
		currentRecords.tractNetAcreageUnitsPicklist = getTractNetAcreageUnitsPicklist();
		return currentRecords;
	}

	@AuraEnabled
	public static tonReconciliationRecords getReconciledRecords(String recordId){
		tonReconciliationRecords currentRecords = new tonReconciliationRecords();
		currentRecords.tonRecord = getTonRecord(recordId);
		currentRecords.reconciliationRecords = getReconciliations(recordId);
		
		return currentRecords;
	}

	@AuraEnabled
	public static tractSaveResult saveTract(Boolean newTract, tractReconciliation__c tractReconciliation, Tract__c oldTract, Tract__c currentTract, TitleOwnershipDetail__c tot, TargetOwnershipName__c ton){
		tractSaveResult returnValue = new tractSaveResult();
		System.debug(newTract);
		System.debug(tractReconciliation);
		System.debug(oldTract);
		System.debug(currentTract);
		System.debug(tot);
		System.debug(ton);
		returnValue.success = true;
		try{
			List<SObject> updateList = new List<SObject>();
			List<SObject> newList = new List<SObject>();
			Subtract__c newSubtract = new Subtract__c();
			
			//If new first insert the tract record as the Id will be necessary for child items.
			if(newTract){
				currentTract.LandGridTract__c = ton.jobId__r.LandGridTract__c;
				currentTract.Account__c = ton.Account__c;
				insert currentTract;
				tractReconciliation.tractAction__c = 'utility:add';
				newSubtract.Subtract_Quarter_Call__c = currentTract.Quarter_Call__c;
				newSubtract.Subtract_Gross_Acres__c = currentTract.Gross_Acres__c;
				newSubtract.Subtract_Acres__c = currentTract.netAcres__c;
				newSubtract.Tract__c = currentTract.Id;
				//subtract creation logic moved to TractTrigger.
				//newList.add(newSubtract);
			}
			else{
				tractReconciliation.preTractNetAcreageUnits__c = oldTract.netAcreageUnits__c;
				tractReconciliation.preTractNetAcres__c = oldTract.netAcres__c;
                //tractReconciliation.acres = oldTract.netAcres__c+' '+oldTract.netAcreageUnits__c; 
				tractReconciliation.preTractDepth__c = oldTract.depth__c;
				tractReconciliation.preTractGrossAcres__c = oldTract.Gross_Acres__c;
				tractReconciliation.preTractInstrumentType__c = oldTract.Instrument_Type__c;
				tractReconciliation.preTractName__c = oldTract.Name;
				tractReconciliation.preTractQuarterCall__c = oldTract.Quarter_Call__c;
				tractReconciliation.tractAction__c = 'utility:relate';
				updateList.add(currentTract);
			}
			tractReconciliation.targetOwnershipTract__c = tot.Id;
			tractReconciliation.Tract__c = currentTract.Id;
			newList.add(tractReconciliation);
			tot.locked__c = true;
			updateList.add(tot);

			update updateList;
			insert newList;
			List<Tract__c> tractList = new List<Tract__c>();
			tractList.add(currentTract);
			//Map<String, tractUtility.tractTitleSourceValue> titleSourceResult = tractUtility.getTractTitleSource(tractList);
			//for(String tractId: titleSourceResult.keySet()){
			//	currentTract.titleSource__c = titleSourceResult.get(String.valueOf(tractId)).titleSource;	
			//}
			update currentTract; 
		}
		Catch(Exception e){
			returnValue.success = false;
			returnValue.message = e.getMessage();
			system.debug('ERROR SAVING TRACT ' + e + '\n' + e.getMessage() + ' Line Number: ' + e.getLineNumber() + ' ' + e.getStackTraceString());
		}

		return returnValue;
	}

	//Method to retrieve subject picklist values.
	private static List<AuraSelectOption> getTractInstrumentTypePicklist(){
		List<AuraSelectOption> options = new List<AuraSelectOption>();
        
		Schema.DescribeFieldResult fieldResult = Tract__c.Instrument_Type__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
		for( Schema.PicklistEntry f : ple)
		{
			options.add(new AuraSelectOption(f.getValue(), f.getLabel()));   //put(f.getLabel(), f.getValue());
		}       
		return options;
	}

	//Method to retrieve subject picklist values.
	private static List<AuraSelectOption> getTractNetAcreageUnitsPicklist(){
		List<AuraSelectOption> options = new List<AuraSelectOption>();
        
		Schema.DescribeFieldResult fieldResult =
		Tract__c.netAcreageUnits__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
		for( Schema.PicklistEntry f : ple)
		{
			options.add(new AuraSelectOption(f.getValue(), f.getLabel()));   //put(f.getLabel(), f.getValue());
		}       
		return options;
	}


	private static List<TitleOwnershipDetail__c> getTonTotRecords(String recordId){
		List<TitleOwnershipDetail__c> returnValue = new List<TitleOwnershipDetail__c>();
		returnValue = [SELECT Id, area__c, depth__c, instrumentType__c, grossAc__c, tractsCOCalculation__c, measurement__c, Link__c, locked__c, Name, quarterCall__c 
					   FROM TitleOwnershipDetail__c 
					   WHERE TargetOwnershipName__c = :recordId 
					   AND RecordTypeId=:reconciliationSettings.totRecordTypeId__c
					   AND Id NOT IN (SELECT targetOwnershipTract__c FROM tractReconciliation__c WHERE targetOwnershipTract__r.TargetOwnershipName__c = :recordId) 
					   ORDER BY Id ASC ];
		return returnValue;
	}

	private static List<Tract__c> getTonTractRecords(String accountId, String landGridTractId, String tonRecordId){
		List<Tract__c> returnValue = new List<Tract__c>();
		returnValue = [SELECT Id, Quarter_Call__c, depth__c, Instrument_Type__c, Gross_Acres__c, netAcres__c, netAcreageUnits__c, link__c, Name
					   FROM Tract__c WHERE Account__c = :accountId
					   AND Id NOT IN (SELECT Tract__c FROM tractReconciliation__c WHERE Tract__r.Account__c = :accountId AND targetOwnershipTract__r.TargetOwnershipName__c = :tonRecordId) 
					   AND LandGridTract__c = :landGridTractId
					   ORDER BY Id ASC];
		return returnValue;
	}

	private static List<reconciledRecord> getReconciliations(String recordId){
		System.debug('recordId value is: ' + recordId);
		List<tractReconciliation__c> tractReconciliations = new List<tractReconciliation__c>();
		List<reconciledRecord> returnValue = new List<reconciledRecord>();

		tractReconciliations = [SELECT Id, targetOwnershipTract__c, Tract__c, tractAction__c, toLabel(netAcreageUnitOption__c), toLabel(netAcresOption__c), toLabel(depthOption__c), toLabel(grossAcreageOption__c),
					   toLabel(instrumentTypeOption__c), toLabel(quarterCallOption__c), preTractNetAcreageUnits__c, preTractNetAcres__c, preTractDepth__c, preTractGrossAcres__c, link__c,
					   preTractInstrumentType__c, preTractName__c, preTractQuarterCall__c,
					   targetOwnershipTract__r.Id, targetOwnershipTract__r.area__c, targetOwnershipTract__r.depth__c,targetOwnershipTract__r.quarterCall__c, 
					   targetOwnershipTract__r.instrumentType__c, targetOwnershipTract__r.grossAc__c, targetOwnershipTract__r.tractsCOCalculation__c, targetOwnershipTract__r.measurement__c,
					   targetOwnershipTract__r.Link__c, targetOwnershipTract__r.locked__c, targetOwnershipTract__r.Name, Tract__r.Id, Tract__r.Quarter_Call__c, Tract__r.depth__c,
					   Tract__r.Instrument_Type__c, Tract__r.Gross_Acres__c, Tract__r.netAcres__c, Tract__r.netAcreageUnits__c, Tract__r.link__c, Tract__r.Name 
					   FROM tractReconciliation__c WHERE targetOwnershipTract__r.TargetOwnershipName__c = :recordId
					   ORDER BY Id ASC];
					   
	for(tractReconciliation__c tractReconciliation: tractReconciliations){
			reconciledRecord newRecord = new reconciledRecord();
			newRecord.reconciliationId = tractReconciliation.Id;
			newRecord.link = tractReconciliation.link__c;
			newRecord.totId = tractReconciliation.targetOwnershipTract__c;
			newRecord.tractId = tractReconciliation.Tract__c;
			newRecord.tractAction = tractReconciliation.tractAction__c;
			newRecord.netAcreageUnitOption = tractReconciliation.netAcreageUnitOption__c;
			newRecord.netAcresOption = tractReconciliation.netAcresOption__c;
			newRecord.depthOption = tractReconciliation.depthOption__c;
			newRecord.grossAcreageOption = tractReconciliation.grossAcreageOption__c;
			newRecord.instrumentTypeOption =  tractReconciliation.instrumentTypeOption__c;
			newRecord.quarterCallOption = tractReconciliation.quarterCallOption__c;
			newRecord.preTractNetAcreageUnits = tractReconciliation.preTractNetAcreageUnits__c;
			newRecord.preTractNetAcres = tractReconciliation.preTractNetAcres__c;
			newRecord.preTractDepth = tractReconciliation.preTractDepth__c;
			newRecord.preTractGrossAcres = tractReconciliation.preTractGrossAcres__c;
			newRecord.preTractInstrumentType = tractReconciliation.preTractInstrumentType__c;
			newRecord.preTractName = tractReconciliation.preTractName__c;
			newRecord.preTractQuarterCall = tractReconciliation.preTractQuarterCall__c;
			newRecord.totArea = tractReconciliation.targetOwnershipTract__r.area__c;
			newRecord.totQuarterCall = tractReconciliation.targetOwnershipTract__r.quarterCall__c;
			newRecord.totQuarterCallNote = 'Area from TOR was: ' + tractReconciliation.targetOwnershipTract__r.area__c;
			newRecord.totDepth = tractReconciliation.targetOwnershipTract__r.depth__c;
			newRecord.totInstrumentType = tractReconciliation.targetOwnershipTract__r.instrumentType__c;
			newRecord.totGrossAc = tractReconciliation.targetOwnershipTract__r.grossAc__c;
			newRecord.totTractsCOCalculation = tractReconciliation.targetOwnershipTract__r.tractsCOCalculation__c;
			newRecord.totMeasurement = tractReconciliation.targetOwnershipTract__r.measurement__c;
        	newRecord.acres = tractReconciliation.targetOwnershipTract__r.tractsCOCalculation__c+' '+tractReconciliation.targetOwnershipTract__r.measurement__c;
			newRecord.totLink = tractReconciliation.targetOwnershipTract__r.Link__c;
			newRecord.totLocked = tractReconciliation.targetOwnershipTract__r.locked__c;
			newRecord.totName = tractReconciliation.targetOwnershipTract__r.Name;
			newRecord.tractQuarterCall = tractReconciliation.Tract__r.Quarter_Call__c;
			newRecord.tractDepth = tractReconciliation.Tract__r.depth__c;
			newRecord.tractInstrumentType = tractReconciliation.Tract__r.Instrument_Type__c;
			newRecord.tractGrossAcres = tractReconciliation.Tract__r.Gross_Acres__c;
			newRecord.tractNetAcres = tractReconciliation.Tract__r.netAcres__c;
			newRecord.tractNetAcreageUnits = tractReconciliation.Tract__r.netAcreageUnits__c;
        	newRecord.netAcres = tractReconciliation.Tract__r.netAcres__c+' '+tractReconciliation.Tract__r.netAcreageUnits__c;
			newRecord.tractLink = tractReconciliation.Tract__r.link__c;
			newRecord.tractName = tractReconciliation.Tract__r.Name;
			returnValue.add(newRecord);
		}

		return returnValue;
	}

	private static TargetOwnershipName__c getTonRecord(String recordId){
		TargetOwnershipName__c returnValue = new TargetOwnershipName__c();
		returnValue = [SELECT Id, Account__c, Name, jobId__c, Account__r.Name, jobId__r.LandGridTract__c FROM TargetOwnershipName__c WHERE Id = :recordId ORDER BY Id ASC  LIMIT 1];
		return returnValue;
	}


	public class tonReconciliationRecords{
		@AuraEnabled public List<TitleOwnershipDetail__c> tonTotRecords {get; set;}
		@AuraEnabled public List<Tract__c> tonTractRecords {get; set;}
		@AuraEnabled public List<TitleOwnershipDetail__c> reconciledTonTotRecords {get; set;}
		@AuraEnabled public List<Tract__c> reconciledTonTractRecords {get; set;}
		@AuraEnabled public List<reconciledRecord> reconciliationRecords {get; set;}
		@AuraEnabled public TargetOwnershipName__c tonRecord {get; set;}
		@AuraEnabled public List<AuraSelectOption> tractInstrumentTypePicklist {get; set;}
		@AuraEnabled public List<AuraSelectOption> tractNetAcreageUnitsPicklist {get; set;}

		public tonReconciliationRecords(){
			tonTotRecords = new List<TitleOwnershipDetail__c>();
			tonTractRecords = new List<Tract__c>();
			reconciledTonTotRecords = new List<TitleOwnershipDetail__c>();
			reconciledTonTractRecords = new List<Tract__c>();
			reconciliationRecords = new List<reconciledRecord>();
			tonRecord = new TargetOwnershipName__c();
			tractInstrumentTypePicklist = new List<AuraSelectOption>();
			tractNetAcreageUnitsPicklist = new List<AuraSelectOption>();

		}
	}

	public class reconciledRecord{
		
		@AuraEnabled public Id reconciliationId {get; set;}
		@AuraEnabled public Id totId {get; set;}
		@AuraEnabled public Id TractId {get; set;}
		@AuraEnabled public String link {get; set;}
		@AuraEnabled public String tractAction {get; set;}
		@AuraEnabled public String netAcreageUnitOption {get; set;}
		@AuraEnabled public String netAcresOption {get; set;}
		@AuraEnabled public String depthOption {get; set;}
		@AuraEnabled public String grossAcreageOption {get; set;}
		@AuraEnabled public String instrumentTypeOption {get; set;}
		@AuraEnabled public String quarterCallOption {get; set;}
		@AuraEnabled public String preTractNetAcreageUnits {get; set;}
		@AuraEnabled public Double preTractNetAcres {get; set;}
		@AuraEnabled public String preTractDepth {get; set;}
		@AuraEnabled public Double preTractGrossAcres {get; set;}
		@AuraEnabled public String preTractInstrumentType {get; set;}
		@AuraEnabled public String preTractName {get; set;}
		@AuraEnabled public String preTractQuarterCall {get; set;}
		@AuraEnabled public String totArea {get; set;}
		@AuraEnabled public String totQuarterCall {get; set;}
		@AuraEnabled public String totQuarterCallNote {get; set;}
		@AuraEnabled public String totDepth {get; set;}
		@AuraEnabled public String totInstrumentType {get; set;}
		@AuraEnabled public Double totGrossAc {get; set;}
		@AuraEnabled public Double totTractsCOCalculation {get; set;}
		@AuraEnabled public String totMeasurement {get; set;}
		@AuraEnabled public String totLink {get; set;}
		@AuraEnabled public Boolean totLocked {get; set;}
		@AuraEnabled public String totName {get; set;}
		@AuraEnabled public String tractQuarterCall {get; set;}
		@AuraEnabled public String tractDepth {get; set;}
		@AuraEnabled public String tractInstrumentType {get; set;}
		@AuraEnabled public Double tractGrossAcres {get; set;}
        @AuraEnabled public String acres{get;set;}
        @AuraEnabled public String netAcres{get;set;}
		@AuraEnabled public Double tractNetAcres {get; set;}
		@AuraEnabled public String tractNetAcreageUnits {get; set;}
		@AuraEnabled public String tractLink {get; set;}
		@AuraEnabled public String tractName {get; set;}
		
		public reconciledRecord(){
			//reconciliationId = '';
			//totId = '';
			//tractId = ''; 
			link='';
			tractAction = '';
			netAcreageUnitOption = '';
			netAcresOption = '';
			depthOption = '';
			grossAcreageOption = '';
			instrumentTypeOption =  '';
			quarterCallOption = '';
			preTractNetAcreageUnits = '';
			preTractNetAcres = 0;
			preTractDepth = '';
			preTractGrossAcres = 0;
			preTractInstrumentType = '';
			preTractName = '';
			preTractQuarterCall = '';
			totArea = '';
			totQuarterCall = '';
			totQuarterCallNote = '';
			totDepth = '';
			totInstrumentType = '';
			totGrossAc = 0;
			totTractsCOCalculation = 0;
            netAcres='';
            acres='';
			totMeasurement = '';
			totLink = '';
			totLocked = true;
			totName = '';
			tractQuarterCall = '';
			tractDepth = '';
			tractInstrumentType = '';
			tractGrossAcres = 0;
			tractNetAcres = 0;
			tractNetAcreageUnits = '';
			tractLink = '';
			tractName = '';
		}
	}

	public class tractSaveResult{
		@AuraEnabled public Boolean success {get; set;}
		@AuraEnabled public String message {get; set;}

		public tractSaveResult(){
			success = false;
			message = '';
		}
	}
	
	public virtual class tpjImportException extends Exception{}

}