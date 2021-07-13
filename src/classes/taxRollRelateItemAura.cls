public with sharing class taxRollRelateItemAura  {

	@AuraEnabled
	public static taxRollInterestSearchResponse getInitialResults(Id recordId, String searchObject){
		taxRollInterestSearchResponse response = new taxRollInterestSearchResponse();
		//sObject currentRecord = recordId.getSObjectType().newSObject(recordId);
		String sObjectTypeName = recordId.getSObjectType().getDescribe().getName();
		System.debug('sObjectType value is: ' + sObjectTypeName);
		if(sObjectTypeName == 'TaxRollInterest__c'){
			response.currentInterest = [SELECT Id, Name, rrcLeaseNumber__c, taxRollOwner__c, taxRollOwner__r.account__c, taxRollOwner__r.account__r.Name, taxRollOwner__r.Name, taxRollOwner__r.ownerName__c FROM taxRollInterest__c WHERE Id = :recordId];
			response.rrcLeaseNumber = response.currentInterest.rrcLeaseNumber__c;
		}
		if(sObjectTypeName == 'TaxRollOwner__c'){
			response.currentOwner = [SELECT Account__c,Id,Name,ownerAddress__c,ownerCity__c,ownerName__c,ownerState__c,ownerZip__c,uid__c FROM TaxRollOwner__c WHERE Id = :recordId];
			//response.rrcLeaseNumber = response.currentInterest.rrcLeaseNumber__c;
		}
		if(sObjectTypeName == 'RRCLease__c'){
			response.currentLease = [SELECT Id, Name, legalDescription__c, permitAcresUserOverride__c, rrcLeaseNumber__c, texasPermitWithAcre__c, uid__c FROM RRCLease__c WHERE Id = :recordId];
			response.rrcLeaseNumber = response.currentLease.rrcLeaseNumber__c;
		}
		Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(new String[]{searchObject});
		response.searchObjectLabel = descResult[0].getLabel();
		switch on searchObject{
			when 'diTexasPermitWithAcreage__c'{
				//response.diPermits.Id
				List<diTexasPermitWithAcreage__c> diPermits = new List<diTexasPermitWithAcreage__c>();
				diPermits = [SELECT Id, Name, API10__c, countyName__c, leaseName__c, permitNumber__c, permittedAcres__c, rrcDistrict__c, rrcLeaseNumber__c, stateName__c 
									  FROM diTexasPermitWithAcreage__c
									  WHERE rrcLeaseNumber__c = :response.rrcLeaseNumber];
				for(diTexasPermitWithAcreage__c diPermit: diPermits){
					diPermitSearchResult newResult = new diPermitSearchResult();
					newResult.Id = diPermit.Id;
					newResult.Name = diPermit.Name;
					newResult.api10 = diPermit.API10__c;
					newResult.permitNumber = diPermit.permitNumber__c;
					newResult.leaseName = diPermit.leaseName__c;
					newResult.permittedAcres = diPermit.permittedAcres__c;
					newResult.rrcLeaseNumber = diPermit.rrcLeaseNumber__c;
					if(diPermit.Id == response.currentLease.texasPermitWithAcre__c){
						newResult.permitSelected = true;
						response.selectedRecord = newResult.Id;
					}
					response.diPermits.add(newResult);
				}
			}
			when 'Account'{
				System.debug('Tax Roll Owner Name value is: ' + response.currentOwner.ownerName__c);
				response.accounts = getAccountSearchResults(response.currentOwner.ownerName__c, 0, response.currentOwner.account__c); 
				response.selectedRecord = response.currentOwner.account__c;
			}
			when else{

			}
		}
		system.debug(descResult[0].getLabel());
		return response;
	}

	@AuraEnabled
	public static String setRelatedRecord (Id recordId, String relatedRecordId, String updateField){
		System.debug('Record Id value is: ' + recordId + ' relatedRecordId value is: ' + relatedRecordId + ' updateField value is: ' + updateField);
		String response = 'Updated Related Record';
		try{
			sObject currentRecord = recordId.getSObjectType().newSObject(recordId);
			//taxRollInterest__c currentRecord = [SELECT ID FROM taxRollInterest__c WHERE ID = :recordId];
			currentRecord.put(updateField, relatedRecordId);
			System.debug('Current record value for field: ' + updateField + ' value: ' + currentRecord.get(updateField));
			update currentRecord;
		}
		Catch(Exception e){
			response = e.getMessage();
			system.debug('ERROR SETTING RELATED RECORD ON TAX ROLL INTEREST ' + e + '\n' + e.getMessage() + ' Line Number: ' + e.getLineNumber() + ' ' + e.getStackTraceString());
		}
		return response;

	}

	@AuraEnabled
	public static taxRollInterestSearchResponse getNewSearchResult(String searchString, Integer searchCounter, String currentAccountId){
		taxRollInterestSearchResponse response = new taxRollInterestSearchResponse();
		System.debug('Method called');
		try{
			response.accounts = getAccountSearchResults(searchString, searchCounter, currentAccountId);
			response.searchCounter = searchCounter;
			for(accountSearchResult asr: response.accounts){
					if(asr.Id == response.currentInterest.taxRollOwner__r.account__c){
						response.selectedRecord = asr.Id;
					}
				}
		}
		Catch(Exception e){
			response.hasError = true;
			response.errorString = e.getMessage();
			system.debug('ERROR GETTING SEARCH RESPONSE ' + e + '\n' + e.getMessage() + ' Line Number: ' + e.getLineNumber() + ' ' + e.getStackTraceString());
		}
		
		return response;
	}

	private static List<accountSearchResult> getAccountSearchResults(String searchString, Integer searchCounter, String currentAccountId){
		//System.debug('TON ID is: ' + tonRecordId);
		List<accountSearchResult> returnValue = new List<accountSearchResult>();
		//returnValue.searchCounter = searchCounter;
		
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
		
		List<Account> currentInterestAccount = [SELECT Id,Name, BillingAddress, BillingStreet, BillingCity, BillingCountry, BillingPostalCode FROM Account WHERE Id = :currentAccountId];
		if(currentInterestAccount.size() > 0){
			accountSearchResult currentInterestasr = new accountSearchResult();
			currentInterestasr.Id = currentInterestAccount[0].Id;
			currentInterestasr.Name = currentInterestAccount[0].Name;
			currentInterestasr.accountSelected = true;
			currentInterestasr.BillingAddress = currentInterestAccount[0].BillingAddress;
			currentInterestasr.BillingStreet = currentInterestAccount[0].BillingStreet;
			currentInterestasr.BillingCity = currentInterestAccount[0].BillingCity;
			currentInterestasr.BillingCountry = currentInterestAccount[0].BillingCountry;
			currentInterestasr.BillingPostalCode = currentInterestAccount[0].BillingPostalCode;
			returnValue.add(currentInterestasr);
		}

		String searchQuery = 'FIND {' + searchString + '} IN ALL FIELDS RETURNING Account (Id,Name, BillingAddress, BillingStreet, BillingCity, BillingCountry, BillingPostalCode) LIMIT 10';
		
		List<List<SObject>>searchList = Search.query(searchQuery);
		for(SObject currentSObject:searchList[0]){
			Account currentAccount = (Account)currentSObject;
			if((returnValue.size()>0 && currentAccount.Id != returnValue[0].Id)||returnValue.size()==0){
				accountSearchResult asr = new accountSearchResult();
				asr.Id = currentAccount.Id;
				asr.Name = currentAccount.Name;
				asr.BillingAddress = currentAccount.BillingAddress;
				asr.BillingStreet = currentAccount.BillingStreet;
				asr.BillingCity = currentAccount.BillingCity;
				asr.BillingCountry = currentAccount.BillingCountry;
				asr.BillingPostalCode = currentAccount.BillingPostalCode;
				if(asr.Id == currentAccountId){
					asr.accountSelected = true;
				}
				returnValue.add(asr);
			}
			
		}
		return returnValue;
	}


	public class taxRollInterestSearchResponse{
		@AuraEnabled public DescribeSObjectResult searchObject {get; set;}
		@AuraEnabled public String errorString {get; set;}
		@AuraEnabled public Boolean hasError {get; set;}
		@AuraEnabled public String searchObjectLabel {get; set;}
		@AuraEnabled public TaxRollInterest__c currentInterest{get; set;}
		@AuraEnabled public TaxRollOwner__c currentOwner{get; set;}
		@AuraEnabled public RRCLease__c currentLease{get;set;}
		@AuraEnabled public List<accountSearchResult> accounts {get; set;}
		@AuraEnabled public List<diPermitSearchResult> diPermits {get; set;}
		@AuraEnabled public Integer searchCounter {get; set;}
		@AuraEnabled public String selectedRecord {get; set;}
		@AuraEnabled public String rrcLeaseNumber{get;set;}

			public taxRollInterestSearchResponse(){
			
			errorString = '';
			hasError = false;
			currentInterest = new taxRollInterest__c();
			currentLease = new RRCLease__c();
			currentOwner = new TaxRollOwner__c();
			//searchObject = new DescribeSObjectResult();
			accounts = new List<accountSearchResult>();
			diPermits = new List<diPermitSearchResult>();
			searchObjectLabel = '';
			searchCounter = 0;
			selectedRecord = '';
			rrcLeaseNumber = '';
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

	public class diPermitSearchResult{
		@AuraEnabled public string Id {get; set;}
		@AuraEnabled public string Name {get; set;}
		@AuraEnabled public String rrcLeaseNumber {get; set;}
		@AuraEnabled public String api10 {get; set;}
		@AuraEnabled public String permitNumber {get; set;}
		@AuraEnabled public String leaseName {get; set;}
		@AuraEnabled public Decimal permittedAcres {get; set;}
		@AuraEnabled public Boolean permitSelected {get; set;}

		public diPermitSearchResult(){
			Id = '';
			Name = '';
			rrcLeaseNumber = '';
			api10 = '';
			permitNumber = '';
			leaseName = '';
			permittedAcres = 0;
			permitSelected = false;

		}
		
	}

}