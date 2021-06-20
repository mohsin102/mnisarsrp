//Create by John Gorrell 09/08/2019 as part of mini project for creating TOTs.

//Test coverage provided by tractReconciliationAuraTest

public with sharing class totBuilderAura  {

	static final tractReconciliationSetting__mdt reconciliationSettings = [SELECT torRecordTypeId__c, totRecordTypeId__c, baseURL__c, Label, DeveloperName FROM tractReconciliationSetting__mdt WHERE baseURL__c = :URL.getSalesforceBaseUrl().toExternalForm().replace('https', 'http')];

	public static List<TitleOwnershipDetail__c> getTORRecords(String tonRecordId){
		List<TitleOwnershipDetail__c> relatedTORRecords = new List<TitleOwnershipDetail__c>();
		relatedTORRecords = [SELECT Id, RecordType.Name, Name, TargetOwnershipName__r.Name, TargetOwnershipName__c, targetOwnershipName__r.jobId__c, tonName__c, Area__c, Depth__c, Executive__c,
																 Bonus__c, Royalty__c, WI__c, NRI__c, LOR__c, bookPageFrm__c, bookPageTOT__c, OI__c, grossAc__c, leaseLOR__c, Lease__c, Page__c,
																 Book__c, County__c, torGroupNum__c, RelatedTORs__c, Link__c, instrumentType__c, measurement__c, tractsCOCalculation__c, friendlyName__c,
																 quarterCall__c
																 FROM TitleOwnershipDetail__c 
																 WHERE TargetOwnershipName__c = :tonRecordId
																 AND RecordTypeId = :reconciliationSettings.torRecordTypeId__c
																 AND TargetOwnershipTract__c <> ''
																 ORDER BY Id ASC];
		return relatedTORRecords;
	}

	@AuraEnabled
	public static List<TitleOwnershipDetail__c> getTODRecords(String tonRecordId, String recordTypeId){
		//List<torLine> response = new List<torLine>();
		System.debug('Base URL is ' + URL.getSalesforceBaseUrl().toExternalForm());
		List<TitleOwnershipDetail__c> relatedTORRecords = new List<TitleOwnershipDetail__c>();
		if(recordTypeId == reconciliationSettings.torRecordTypeId__c){
		relatedTORRecords = [SELECT Id, RecordType.Name, Name, TargetOwnershipName__r.Name, TargetOwnershipName__c, targetOwnershipName__r.jobId__c, tonName__c, Area__c, Depth__c, Executive__c,
																 Bonus__c, Royalty__c, WI__c, NRI__c, LOR__c, bookPageFrm__c, bookPageTOT__c, OI__c, grossAc__c, leaseLOR__c, Lease__c, Page__c,
																 Book__c, County__c, torGroupNum__c, RelatedTORs__c, Link__c, instrumentType__c, measurement__c, tractsCOCalculation__c, friendlyName__c, 
																 quarterCall__c
																 FROM TitleOwnershipDetail__c 
																 WHERE TargetOwnershipName__c = :tonRecordId
																 AND RecordTypeId = :recordTypeId
																 AND TargetOwnershipTract__c = ''
																 ORDER BY Id ASC];
		}
		else{
		relatedTORRecords = [SELECT Id, RecordType.Name, Name, TargetOwnershipName__r.Name, TargetOwnershipName__c, targetOwnershipName__r.jobId__c, tonName__c, Area__c, Depth__c, Executive__c,
																 Bonus__c, Royalty__c, WI__c, NRI__c, LOR__c, OI__c, bookPageFrm__c, bookPageTOT__c, grossAc__c, leaseLOR__c, Lease__c, Page__c,
																 Book__c, County__c, torGroupNum__c, RelatedTORs__c, Link__c, instrumentType__c, measurement__c, tractsCOCalculation__c,
																 areaOperator__c, quarterCallOperator__c, bonusOperator__c,	bookPageOperator__c, countyOperator__c,	depthOperator__c, executiveOperator__c,	
																 grossAcOperator__c, lorOperator__c, nriOperator__c, oiOperator__c, royaltyOperator__c, wiOperator__c,
																 leaseLOROperator__c, leaseOperator__c, friendlyName__c, locked__c, quarterCall__c
																 FROM TitleOwnershipDetail__c 
																 WHERE TargetOwnershipName__c = :tonRecordId
																 AND RecordTypeId = :recordTypeId
																 ORDER BY ID ASC];
		}
		return relatedTORRecords;

	}

	public static boolean hasLockedTots(String tonRecordId){
		Boolean returnValue = false;
		List<TitleOwnershipDetail__c> totRecords = getTODRecords(tonRecordId, reconciliationSettings.totRecordTypeId__c);
		for(TitleOwnershipDetail__c totRecord:totRecords){
			if(totRecord.locked__c){
				returnValue = true;
			}
		}
		return returnValue;
	}
	
	@AuraEnabled
	public static List<totGroup> getNewTots2 (List<TitleOwnershipDetail__c> inputTorLines){
		System.debug(inputTorLines);
		List<totGroup> response = new List<totGroup>();
		Map<Integer, List<TitleOwnershipDetail__c>> totGroupMap = new Map<Integer, List<TitleOwnershipDetail__c>>();
		for(TitleOwnershipDetail__c currentTor: inputTorLines){
			System.debug('CurrentTor groupNum is: ' + currentTor.torGroupNum__c);
			if(currentTor.torGroupNum__c != null){
				if(totGroupMap.containsKey(Integer.valueOf(currentTor.torGroupNum__c))){
					totGroupMap.get(Integer.valueOf(currentTor.torGroupNum__c)).add(currentTor);
				}
				else{
					List<TitleOwnershipDetail__c> newTorLineList = new List<TitleOwnershipDetail__c>();
					newTorLineList.add(currentTor);
					totGroupMap.put(Integer.valueOf(currentTor.torGroupNum__c), newTorLineList);
				}
			}
		}
		for(Integer mapTotGroupNumber: totGroupMap.keySet()){
			//Add logic to create summary row.
			totGroup newTotGroup = new totGroup();
			String relatedTorRecords = '';
			
			newTotGroup.totGroupNumber = mapTotGroupNumber;
			newTotGroup.torLines2 = totGroupMap.get(mapTotGroupNumber);
			
			for(TitleOwnershipDetail__c torLine:newTotGroup.torLines2){
				relatedTorRecords = relatedTorRecords + ',' + torLine.Id;
				
			}
			
			relatedTorRecords = relatedTorRecords.right(relatedTorRecords.length()-1);
			System.debug('relatedTorRecords value is: ' + relatedTorRecords);
			TitleOwnershipDetail__c newTot = new TitleOwnershipDetail__c();
			newTot.RecordTypeId = reconciliationSettings.totRecordTypeId__c;
			//newTot.Name = inputTorLines[0].torName;
			//newTot.Job_Id__c = newTotGroup.torLines2[0].Job_Id__c;
			newTot.TargetOwnershipName__c = newTotGroup.torLines2[0].TargetOwnershipName__c;
			//newTot.Total_Ownership_Name__r.Name = newTotGroup.torLines2[0].Total_Ownership_Name__r.Name;
			//newTot.torGroupNum__c = mapTotGroupNumber;
			//newTot.tonName__c = newTotGroup.torLines2[0].tonName__c;
			newTot.area__c = newTotGroup.torLines2[0].Area__c;
			newTot.quarterCall__c = newTotGroup.torLines2[0].quarterCall__c;
			newTot.depth__c = newTotGroup.torLines2[0].Depth__c;
			newTot.executive__c = newTotGroup.torLines2[0].Executive__c;
			newTot.Bonus__c = newTotGroup.torLines2[0].Bonus__c;
			newTot.Royalty__c = newTotGroup.torLines2[0].Royalty__c;
			newTot.WI__c = newTotGroup.torLines2[0].WI__c;
			newTot.NRI__c = newTotGroup.torLines2[0].NRI__c;
			newTot.LOR__c = newTotGroup.torLines2[0].LOR__c;
			newTot.OI__c = newTotGroup.torLines2[0].OI__c;
			newTot.grossAc__c = newTotGroup.torLines2[0].grossAc__c;
			newTot.leaseLOR__c = newTotGroup.torLines2[0].leaseLOR__c;
			newTot.Lease__c = newTotGroup.torLines2[0].Lease__c;
			//newTot.final__c = newTotGroup.torLines2[0].final__c;
			//newTot.Page__c = newTotGroup.torLines2[0].Page__c;
			//newTot.Book__c = newTotGroup.torLines2[0].Book__c;
			newTot.County__c = newTotGroup.torLines2[0].County__c;
			//newTot.Address__c = newTotGroup.torLines2[0].Address__c;
			//newTot.Notes__c = newTotGroup.torLines2[0].Notes__c;
			//newTot.areaOperator__c = 'First';
			newTot.quarterCallOperator__c = 'First';
			newTot.depthOperator__c = 'First';
			newTot.executiveOperator__c = 'First';
			newTot.bonusOperator__c = 'First';
			newTot.royaltyOperator__c = 'First';
			newTot.wiOperator__c = 'First';
			newTot.nriOperator__c = 'First';
			newTot.lorOperator__c = 'First';
			newTot.oiOperator__c = 'First';
			newTot.grossAcOperator__c = 'First';
			newTot.leaseLOROperator__c = 'First';
			newTot.leaseOperator__c = 'First';
			//newTot.pageOperator__c = 'First';
			newTot.bookPageOperator__c = 'First';
			newTot.countyOperator__c = 'First';
			//newTot.finalOperator__c = 'First';
			newTot.bookPageTOT__c = newTotGroup.torLines2[0].Book__c + '/' + newTotGroup.torLines2[0].Page__c;
			newTot.torGroupNum__c = newTotGroup.torLines2[0].torGroupNum__c;
			newTot.RelatedTORs__c = relatedTorRecords;
			System.debug('torGroupNum__c value is: ' + newTot.torGroupNum__c);
			newTotGroup.tot.add(newTot);
			//newTotGroup.torLines2.add(summaryRow);
			response.add(newTotGroup); 
			System.debug('Response size is currently: ' + response.size());
		}
		System.debug(response);
		if(response.size()>0){
			return response;
		}
		else{
			return null;
		}
	}

	@AuraEnabled
	public static totViewerResponse getSavedTots2 (String tonRecordId){
		List<TitleOwnershipDetail__c> inputTorLines = new List<TitleOwnershipDetail__c>();
		List<TitleOwnershipDetail__c> totLines = new List<TitleOwnershipDetail__c>();
		totViewerResponse response = new totViewerResponse();
		inputTorLines = getTORRecords(tonRecordId);
		totLines = getTODRecords(tonRecordId, reconciliationSettings.totRecordTypeId__c);
		response.allTots = totLines;
		System.debug(inputTorLines);
		
		Map<Integer, List<TitleOwnershipDetail__c>> totGroupMap = new Map<Integer, List<TitleOwnershipDetail__c>>();
		for(TitleOwnershipDetail__c currentTor: inputTorLines){
			System.debug('CurrentTor groupNum is: ' + currentTor.torGroupNum__c);
			if(currentTor.torGroupNum__c != null){
				if(totGroupMap.containsKey(Integer.valueOf(currentTor.torGroupNum__c))){
					totGroupMap.get(Integer.valueOf(currentTor.torGroupNum__c)).add(currentTor);
				}
				else{
					List<TitleOwnershipDetail__c> newTorLineList = new List<TitleOwnershipDetail__c>();
					newTorLineList.add(currentTor);
					totGroupMap.put(Integer.valueOf(currentTor.torGroupNum__c), newTorLineList);
				}
			}
		}
		for(Integer mapTotGroupNumber: totGroupMap.keySet()){
			//Add logic to create summary row.
			totGroup newTotGroup = new totGroup();
			newTotGroup.totGroupNumber = mapTotGroupNumber;
			newTotGroup.torLines2 = totGroupMap.get(mapTotGroupNumber);
			for(TitleOwnershipDetail__c currentTot:totLines){
				if(currentTot.torGroupNum__c == mapTotGroupNumber){
					newTotGroup.tot.add(currentTot);
					response.savedTots.add(newTotGroup);
				}
			}
			
			//newTotGroup.tot.add(newTot);
			//newTotGroup.torLines2.add(summaryRow);
			//response.add(newTotGroup); 
			System.debug('Response size is currently: ' + response.savedTots.size());
		}
		System.debug(response.savedTots.size());
		if(response.savedTots.size()>0){
			return response;
		}
		else{
			return null;
		}
	}

		@AuraEnabled
	public static String saveNewTots (List<totGroup> inputTotGroups){
		String response = 'Success';
		try{
		List<TitleOwnershipDetail__c> updateTotRecords = new List<TitleOwnershipDetail__c>();
		List<TitleOwnershipDetail__c> updateTorRecords = new List<TitleOwnershipDetail__c>();
		for(totGroup currentTotGroup:inputTotGroups){
			updateTotRecords.addAll(currentTotGroup.tot);
			updateTorRecords.addAll(currentTotGroup.torLines2);
		}
		System.debug(updateTotRecords);
		insert updateTotRecords;
		for(TitleOwnershipDetail__c totRecordWithId: updateTotRecords){
			System.debug('Current Tot Id is: ' + totRecordWithId.Id + ' RelatedTORs__c value is: ' + totRecordWithId.RelatedTORs__c);
			//Integer i = 0;
			//Integer summaryRowMarker = 0;
			for(TitleOwnershipDetail__c currentTOR: updateTorRecords){
				if(currentTOR.Id != null){
					if(totRecordWithId.RelatedTORs__c.contains(currentTOR.Id)){
						currentTOR.TargetOwnershipTract__c = totRecordWithId.Id;
					}
				}
				//else{
				//	summaryRowMarker = i;
					//mark the tor record to be removed as it is a summary row.
				//}
				//i++;
			}
			//updateTorRecords.remove(summaryRowMarker);

		}
		update updateTorRecords;
		}
		catch (Exception e) {
			 response = 'ERROR SAVING TOTS ' + e + '\n' + e.getMessage() + ' Line Number: ' + e.getLineNumber() + ' ' + e.getStackTraceString();
			 system.debug('ERROR SAVING TOTS ' + e + '\n' + e.getMessage() + ' Line Number: ' + e.getLineNumber() + ' ' + e.getStackTraceString());
		}
		return response;
	}

	@AuraEnabled
	public static Boolean deleteTots (List<String> selectedTotIds){
		Boolean returnValue = false;
		try{
			List<TitleOwnershipDetail__c> totsToDelete = [SELECT ID FROM TitleOwnershipDetail__c WHERE Id IN :selectedTotIds];
			delete totsToDelete;
			returnValue = true;
		}
		catch (Exception e) {
            returnValue = false;
            system.debug('ERROR DELETING TOTS ' + e + '\n' + e.getMessage() + ' Line Number: ' + e.getLineNumber() + ' ' + e.getStackTraceString());
        }
		return returnValue;

	}

	@AuraEnabled
	public static totBuilderResponse getBuilderData(String tonRecordId){
		totBuilderResponse response = new totBuilderResponse();
		response.allTors = getTODRecords(tonRecordId, reconciliationSettings.torRecordTypeId__c);
		response.allTots = getTODRecords(tonRecordId, reconciliationSettings.totRecordTypeId__c);
		return response;
	}

    @AuraEnabled
    public static List<Opportunity> getOppRecords(String tonRecordId){
        List<Opportunity> oppList = new List<Opportunity>();
        TargetOwnershipName__c tonRec = [Select Id,Account__c from TargetOwnershipName__c where Id=:tonRecordId Limit 1];
        if(tonRec.Account__c!=null){
            oppList = [Select Id, Name, Acquiring_Entity__r.Name,Type,PSA_Date__c,CloseDate,Effective_Date__c,StageName,Total_Acreage__c,
            Total_OTG_Cost__c,Total_Cost__c from Opportunity where AccountId=:tonRec.Account__c];
        }
        return oppList;
	}
    
	@AuraEnabled
    public static String getAccountID(String tonRecordId){
        TargetOwnershipName__c tonRec = [Select Id,Account__c from TargetOwnershipName__c where Id=:tonRecordId Limit 1];
    
        return tonRec.Account__c;
	}
	//Wrapper classes
	//public class torLine{
	//	//@AuraEnabled public TitleOwnershipDetail__c torRecord {get;set;}
	//	@AuraEnabled public Integer totGroupNumber {get;set;}
	//	@AuraEnabled public String torId {get;set;}
	//	@AuraEnabled public String torName {get;set;}
	//	@AuraEnabled public String totalOwnershipId {get;set;}
	//	@AuraEnabled public String totalOwnershipName {get;set;}
	//	@AuraEnabled public String partyName {get;set;}
	//	@AuraEnabled public String area {get;set;}
	//	@AuraEnabled public String depth {get;set;}
	//	@AuraEnabled public Decimal executive {get;set;}
	//	@AuraEnabled public Decimal bonus {get;set;}
	//	@AuraEnabled public Decimal royalty {get;set;}
	//	@AuraEnabled public Decimal wi {get;set;}
	//	@AuraEnabled public Decimal nri {get;set;}
	//	@AuraEnabled public Decimal lor {get;set;}
	//	@AuraEnabled public Decimal oi {get;set;}
	//	@AuraEnabled public Decimal grossAcres {get;set;}
	//	@AuraEnabled public Decimal leaseLOR {get;set;}
	//	@AuraEnabled public String lease {get;set;}
	//	@AuraEnabled public String page {get;set;}
	//	@AuraEnabled public String book {get;set;}
	//	@AuraEnabled public String county {get;set;}
	//	@AuraEnabled public String finalString {get;set;}

	//	public torLine(){
	//		//torRecord = new TitleOwnershipDetail__c();
	//		totGroupNumber = null;
	//		torId = '';
	//		torName='';
	//		totalOwnershipName = '';
	//		partyName = '';
	//		area = '';
	//		depth='';
	//		executive=null;
	//		bonus = null;
	//		royalty = null;
	//		wi=null;
	//		nri=null;
	//		lor=null;
	//		oi=null;
	//		grossAcres=null;
	//		leaseLOR = null;
	//		lease='';
	//		page = '';
	//		book = '';
	//		county = '';
	//		finalString = '';

	//	}

	//}

	public class totGroup{
		@AuraEnabled public Integer totGroupNumber {get;set;}
		//@AuraEnabled public List<torLine> torLines{get;set;}
		@AuraEnabled public List<TitleOwnershipDetail__c> torLines2 {get;set;}
		@AuraEnabled public List<TitleOwnershipDetail__c> tot {get;set;}
		@AuraEnabled public Boolean hasUnsavedChanges{get;set;}

		public totGroup(){
			totGroupNumber = null;
			//torLines = new List<torLine>();
			torLines2 = new List<TitleOwnershipDetail__c>();
			tot = new List<TitleOwnershipDetail__c>();
			hasUnsavedChanges = false;
		}
	}

	public class totViewerResponse{
		@AuraEnabled public List<totGroup> savedTots {get; set;}
		@AuraEnabled public List<TitleOwnershipDetail__c> allTots {get; set;}

		public totViewerResponse(){
			savedTots = new List<totGroup>();
			allTots = new List<TitleOwnershipDetail__c>();
		}
	}

	public class totBuilderResponse{
		@AuraEnabled public List<TitleOwnershipDetail__c> allTors {get; set;}
		@AuraEnabled public List<TitleOwnershipDetail__c> allTots {get; set;}

		public totBuilderResponse(){
			allTors = new List<TitleOwnershipDetail__c>();
			allTots = new List<TitleOwnershipDetail__c>();
		}
	}
	
}