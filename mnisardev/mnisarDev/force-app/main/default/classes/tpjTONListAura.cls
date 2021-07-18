public class tpjTONListAura  {

	static final tractReconciliationSetting__mdt reconciliationSettings = [SELECT torRecordTypeId__c, totRecordTypeId__c, baseURL__c, Label, DeveloperName FROM tractReconciliationSetting__mdt WHERE baseURL__c = :URL.getSalesforceBaseUrl().toExternalForm().replace('https', 'http')];
	
	@AuraEnabled
	public static List<tonListWrapper> getTONs(String tpjRecordId){
		List<tonListWrapper> returnValue = new List<tonListWrapper>();
		List<TargetOwnershipName__c> relatedTONs = new List<TargetOwnershipName__c>();
		Map<Id, tonListWrapper> wrapperMap = new Map<Id, tonListWrapper>();
		List<String> totRecordIds = new List<String>();
		relatedTONs = [SELECT Id, (SELECT ID, RecordTypeId FROM TitleOwnershipDetails__r), ownerName__c, address__c, notes__c, link__c, jobId__r.Name, jobId__r.LandGridTract__r.Name, accountName__c, Account__c FROM TargetOwnershipName__c WHERE jobId__c = :tpjRecordId ORDER BY ownerName__c ASC LIMIT 2000];
		//Cycle through TONs and build wrapper items, map of wrapper items by TON, and list of TOT records to query reconciliations
		for(TargetOwnershipName__c currentTON: relatedTONs){
			tonListWrapper currentTONWrapper = new tonListWrapper();
			currentTONWrapper.ton= currentTON;
			currentTONWrapper.tonId = currentTON.Id;
			currentTONWrapper.tonName = currentTON.ownerName__c;
			currentTONWrapper.tonPartyAddress = currentTON.address__c;
			currentTONWrapper.tonNotes = currentTON.notes__c;
			currentTONWrapper.tonAccountName = currentTON.accountName__c;
			currentTONWrapper.tpjName = currentTON.jobId__r.Name;
			currentTONWrapper.landGridTractName = currentTON.jobId__r.LandGridTract__r.Name;
			for(TitleOwnershipDetail__c tod:currentTON.TitleOwnershipDetails__r){
				if(tod.RecordTypeId == reconciliationSettings.torRecordTypeId__c){
					currentTONWrapper.relatedTORs.add(tod);
					currentTONWrapper.tonTORCount++;
				}
				else if(tod.RecordTypeId == reconciliationSettings.totRecordTypeId__c){
					currentTONWrapper.relatedTOTs.add(tod);
					currentTONWrapper.tonTOTCount++;
					totRecordIds.add(tod.Id);
				}
			}
			wrapperMap.put(currentTONWrapper.tonId, currentTONWrapper);
		}

		//Basic wrapper has been created.  Now get reconcilation information and add to tonWrappers via the Map
		if(relatedTONs.size() > 0){
			List<tractReconciliation__c> tonReconciliations = [SELECT Id, tractAction__c, targetOwnershipTract__r.TargetOwnershipName__r.Id FROM tractReconciliation__c WHERE targetOwnershipTract__c in :totRecordIds];
			System.debug('Total Reconciliation count is: ' + tonReconciliations.size());
			for (tractReconciliation__c recon: tonReconciliations){
				System.debug(wrapperMap);
				System.debug(recon.targetOwnershipTract__c);
				tonListWrapper currentWrapper = wrapperMap.get(recon.targetOwnershipTract__r.TargetOwnershipName__r.Id);
				System.debug(currentWrapper);
				if(recon.tractAction__c == 'utility:add'){
					currentWrapper.tonTractCreatedCount++;
				}
				else if(recon.tractAction__c == 'utility:relate'){
					currentWrapper.tonTractMatchedCount++;
				}
			} 
		}
		//Once all values have been added to the map, get all values from the map and place them in the list for return.
		returnValue = wrapperMap.values();


		return returnValue;
	}

	@AuraEnabled
	public static boolean unlinkAccount(String tonRecordId){
		Boolean returnValue = false;
		TargetOwnershipName__c ton = [SELECT Id FROM TargetOwnershipName__c WHERE Id=:tonRecordId];
		ton.Account__c = null;
		update ton;
		returnValue = true;
		return returnValue;
	}

	@AuraEnabled
	public static accountSearchResponse getSearchResults(String searchString, Integer searchCounter, string tonRecordId){
		System.debug('TON ID is: ' + tonRecordId);
		accountSearchResponse returnValue = new accountSearchResponse();
		returnValue.currentTon = getCurrentTon(tonRecordId);
		returnValue.hasLockedTots = totBuilderAura.hasLockedTots(tonRecordId);
		returnValue.searchCounter = searchCounter;
		
		//Escape special characters for SOSL search - order of replacement matters - if you replace all backslashes late, you will end up with double backslashes.
		//searchString = searchString.replaceAll('[|,|.|\\,||"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]', '-');
		searchString = searchString.replace('\\', '\\');
		System.debug(searchString);
		searchString = String.escapeSingleQuotes(searchString);
		System.debug(searchString);
		searchString = searchString.replace('-', '\\-');
		System.debug(searchString);
		searchString = searchString.replace('+', '\\+');
		System.debug(searchString);
		searchString = searchString.replace('&', '\\&');
		System.debug(searchString);
		searchString = searchString.replace('|', '\\|');
		System.debug(searchString);
		searchString = searchString.replace('!', '\\!');
		System.debug(searchString);
		searchString = searchString.replace('{', '\\{');
		System.debug(searchString);
		searchString = searchString.replace('}', '\\}');
		System.debug(searchString);
		searchString = searchString.replace('[', '\\[');
		System.debug(searchString);
		searchString = searchString.replace(']', '\\]');
		System.debug(searchString);
		searchString = searchString.replace('(', '\\(');
		System.debug(searchString);
		searchString = searchString.replace(')', '\\)');
		System.debug(searchString);
		searchString = searchString.replace('^', '\\^');
		System.debug(searchString);
		searchString = searchString.replace('~', '\\~');
		System.debug(searchString);
		searchString = searchString.replace('*', '\\*');
		System.debug(searchString);
		searchString = searchString.replace(':', '\\:');
		System.debug(searchString);
		
		searchString = searchString.replace('\"', '\\"');
		System.debug(searchString);
		
		

		String searchQuery = 'FIND {' + searchString + '} IN ALL FIELDS RETURNING Account (Id,Name, BillingAddress, BillingStreet, BillingCity, BillingCountry, BillingPostalCode) LIMIT 10';
		
		List<List<SObject>>searchList = Search.query(searchQuery);
		for(SObject currentSObject:searchList[0]){
			Account currentAccount = (Account)currentSObject;
			accountSearchResult asr = new accountSearchResult();
			asr.Id = currentAccount.Id;
			asr.Name = currentAccount.Name;
			asr.BillingAddress = currentAccount.BillingAddress;
			asr.BillingStreet = currentAccount.BillingStreet;
			asr.BillingCity = currentAccount.BillingCity;
			asr.BillingCountry = currentAccount.BillingCountry;
			asr.BillingPostalCode = currentAccount.BillingPostalCode;
			returnValue.accounts.add(asr);
		}
		return returnValue;
	}

	@AuraEnabled
	public static Boolean linkTONToAccount(String tonId, string accountId){
		Boolean returnValue = false;
		TargetOwnershipName__c ton = [SELECT ID FROM TargetOwnershipName__c WHERE Id=:tonId LIMIT 1];
		ton.Account__c = accountId;
		update ton;
		returnValue = true;
		return returnValue;

	}

	@AuraEnabled
	public static Boolean saveAndLinkTONToAccount(String tonId, Account newAccount){
		Boolean returnValue = false;
		insert newAccount;
		returnValue = linkTONToAccount(tonId, newAccount.Id);
		return returnValue;

	}

	private static TargetOwnershipName__c getCurrentTon(String tonRecordId){
		TargetOwnershipName__c returnValue = new TargetOwnershipName__c();
		returnValue = [SELECT Id, Name, ownerName__c, address__c, jobId__r.LandGridTract__r.Name, Account__c, jobId__c FROM TargetOwnershipName__c WHERE Id = :tonRecordId LIMIT 1];
		return returnValue;
	}

	@AuraEnabled
	public static TargetOwnershipName__c getCurrentTon2(String tonRecordId){
		System.debug('tonRecordId value is: ' + tonRecordId);
		TargetOwnershipName__c returnValue = new TargetOwnershipName__c();
		returnValue = [SELECT Id, Name, ownerName__c, address__c, jobId__r.LandGridTract__r.Name, Account__c FROM TargetOwnershipName__c WHERE Id = :tonRecordId LIMIT 1];
		return returnValue;
	}


	//@AuraEnabled
	//public static PageReference getCurrentApp(){
	//	String returnValue = '';
	//	returnValue = ApexPages.currentPage();
	//	return returnValue;
	//}

	public class accountSearchResponse{
		@AuraEnabled public List<accountSearchResult> accounts {get; set;}
		@AuraEnabled public Integer searchCounter {get; set;}
		@AuraEnabled public TargetOwnershipName__c currentTon {get; set;}
		@AuraEnabled public Boolean hasLockedTots {get; set;}

		public accountSearchResponse(){
			accounts = new List<accountSearchResult>();
			searchCounter = 0;
			currentTon = new TargetOwnershipName__c();
			hasLockedTots = false;
		}
	}

	public class accountSearchResult{
		@AuraEnabled public string Id {get; set;}
		@AuraEnabled public string Name {get; set;}
		@AuraEnabled public Address BillingAddress {get; set;}
		@AuraEnabled public string BillingStreet {get; set;}
		@AuraEnabled public string BillingCity {get; set;}
		@AuraEnabled public string BillingCountry {get; set;}
		@AuraEnabled public string BillingPostalCode {get; set;}
		@AuraEnabled public Boolean accountSelected {get; set;}

		public accountSearchResult(){
			Id = '';
			Name = '';
			//BillingAddress = '';
			BillingStreet = '';
			BillingCity = '';
			BillingCountry = '';
			BillingPostalCode = '';
			accountSelected = false;

		}
		
	}

	public class tonListWrapper{
		@AuraEnabled public TargetOwnershipName__c ton {get; set;}
		@AuraEnabled public List<TitleOwnershipDetail__c> relatedTORs {get; set;}
		@AuraEnabled public List<TitleOwnershipDetail__c> relatedTOTs {get; set;}
		@AuraEnabled public List<tractReconciliation__c> relatedReconciliations {get; set;}
		@AuraEnabled public String tonId {get; set;}
		@AuraEnabled public String tonName {get; set;}
		@AuraEnabled public String tonAccountName {get; set;}
		@AuraEnabled public String tonPartyAddress {get; set;}
		@AuraEnabled public String tonNotes {get; set;}
		@AuraEnabled public String tpjName {get; set;}
		@AuraEnabled public String landGridTractName {get; set;}
		@AuraEnabled public Integer tonTORCount {get; set;}
		@AuraEnabled public Integer tonTOTCount {get; set;}
		@AuraEnabled public Integer tonTractCreatedCount {get; set;}
		@AuraEnabled public Integer tonTractMatchedCount {get; set;}
		
		public tonListWrapper(){
			ton = new TargetOwnershipName__c();
			relatedTORs = new List<TitleOwnershipDetail__c>();
			relatedTOTs = new List<TitleOwnershipDetail__c>();
			relatedReconciliations = new List<tractReconciliation__c>();
			tonId = '';
			tpjName = '';
			landGridTractName = '';
			tonName='';
			tonAccountName = '';
			tonPartyAddress = '';
			tonNotes = '';
			tonTORCount = 0;
			tonTOTCount = 0;
			tonTractCreatedCount = 0;
			tonTractMatchedCount = 0;
		}
	
	}
	
	
}