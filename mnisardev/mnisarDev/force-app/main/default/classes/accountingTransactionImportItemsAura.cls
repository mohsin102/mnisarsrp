//Create by John Gorrell 11/19/2020 as part of Tract Reconciliation Prject

//Test coverage provided by 


public with sharing class accountingTransactionImportItemsAura  {

	//Utilized existing custom metadata even though the naming convention is not completely correct.  Funcationality is the same and updating the api name of the custom metadata
	//could create issues with existing code.
    static final List<tpjFileFieldMapping__mdt> fieldMappings = [SELECT required__c, sfFieldAPIName__c, sObjectName__c, tractsCOLabel__c FROM tpjFileFieldMapping__mdt];
	static Map<String,headerField> acctTXNFieldConfigMap = new Map<String,headerField>();
	static Map<String,headerField> acctInvFieldConfigMap = new Map<String,headerField>();
	static List<pretransactionRecord> pretransactionRecords = new List<pretransactionRecord>();
	static List<AccountingTransaction__c> finalAcctTXNs = new List<AccountingTransaction__c>();
	static List<AccountingInvestment__c> finalAcctInvs = new List<AccountingInvestment__c>();
	static AccountingIntegrationJob__c currentAIJ = new AccountingIntegrationJob__c();
	static List<List<String>> parsedCSV = new List<List<String>>();
	static Map < String, Integer > acctTXNFieldNumberMap = new Map < String, Integer > ();
	static Map < Integer, String > acctTXNNumberFieldMap = new Map < Integer, String > ();
	static List<String> acctTXNLstFieldNames = new List<String>();
	static Map < String, Integer > acctInvFieldNumberMap = new Map < String, Integer > ();
	static Map < Integer, String > acctInvNumberFieldMap = new Map < Integer, String > ();
	static List<String> acctInvLstFieldNames = new List<String>();
	static Set<String> investmentNames = new Set<String>();
	static Map<String, AccountingInvestment__c> investmentMap = new Map<String, AccountingInvestment__c>();
	static List<AccountingInvestment__c> investmentList = new List<AccountingInvestment__c>();
	static List<String> lineValues = new List<String>();


	
	static Map<String, Schema.SObjectField> M = Schema.SObjectType.AccountingTransaction__c.fields.getMap();
	static ContentVersion cv = new ContentVersion();

	
    @AuraEnabled
    public static string importRecords(Id contentDocId,ID rcId, String fileType){
        
        cv = [SELECT VersionData, Title, ContentDocumentId FROM ContentVersion where ContentDocumentId =: contentDocId AND IsLatest =  true];
        String lineItemString = cv.versiondata.toString();
		//System.debug(lineItemString);
		Blob contents = cv.VersionData;
        String size =readCSVFile(lineItemString,rcId, contents, fileType);
        return size;
    }
    
    public static string readCSVFile(String lineItemString,ID rcId, Blob fileContents, String fileType) {
		String returnString = 'SUCCESS';
		try{
			currentAIJ = [SELECT CreatedById,CreatedDate,Id,IsDeleted,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Name,notes__c,OwnerId,status__c,
						  SystemModstamp,transactionFileId__c,transactionFileLoaded__c,transactionFileName__c 
						  FROM AccountingIntegrationJob__c
						  WHERE Id = :rcId LIMIT 1];
			if(currentAIJ.transactionFileLoaded__c && fileType == 'accountTransactionFile'){
				throw new aijImportException('Transaction file has already been loaded for this AIJ.');
			}
			if(fileType == 'accountTransactionFile'){
				getParsedLines(lineItemString);
			}
			
			
		
			for(tpjFileFieldMapping__mdt fieldMapping:fieldMappings){
				switch on fieldMapping.sObjectName__c{
					when 'AccountingTransaction__c'{
						acctTXNFieldConfigMap.put(fieldMapping.tractsCOLabel__c, new headerField(fieldMapping.sfFieldAPIName__c));
					}
					when 'AccountingInvestment__c'{
						acctInvFieldConfigMap.put(fieldMapping.tractsCOLabel__c, new headerField(fieldMapping.sfFieldAPIName__c));
					}
				}
			}
			System.debug('parsed csv contains ' + parsedCSV[0].size() + ' columns.');
			for (Integer i = 0; i < parsedCSV[0].size(); i++) {
				if(!String.isBlank(parsedCSV[0][i])){
					string fieldName = parsedCSV[0][i].replaceAll('[^a-zA-Z0-9 .]', '');
					//System.debug(csvFieldNames[i].isAlphanumericSpace());
					System.debug('csvFieldName value is: ' + fieldName + ' map value is: ' + acctTXNfieldConfigMap.get(fieldName));
					if(acctTXNFieldConfigMap.get(fieldName) != null){
						if(!acctTXNFieldConfigMap.get(fieldName).fieldIncluded){
							acctTXNFieldConfigMap.get(fieldName).fieldIncluded = true;
							acctTXNNumberFieldMap.put(i,acctTXNFieldConfigMap.get(fieldName).fieldName);
							acctTXNFieldNumberMap.put(acctTXNFieldConfigMap.get(fieldName).fieldName, i);
							acctTXNLstFieldNames.add(acctTXNFieldConfigMap.get(fieldName).fieldName);
						}
						else{
							throw new aijImportException('Transaction file has multiple columns with header field: ' + fieldName);
						}
					}
					if(acctInvFieldConfigMap.get(fieldName) != null){
						if(!acctInvFieldConfigMap.get(fieldName).fieldIncluded){
							acctInvFieldConfigMap.get(fieldName).fieldIncluded = true;
							acctInvNumberFieldMap.put(i,acctInvFieldConfigMap.get(fieldName).fieldName);
							acctInvFieldNumberMap.put(acctInvFieldConfigMap.get(fieldName).fieldName, i);
							acctInvLstFieldNames.add(acctInvFieldConfigMap.get(fieldName).fieldName);
						}
						else{
							throw new aijImportException('Transaction file has multiple columns with header field: ' + fieldName);
						}
					}


				}
			} 

			if(fileType == 'accountTransactionFile'){
				returnString = loadTransactionFile(rcId, returnString);
			}
		}
		Catch(Exception e){
			returnString = e.getMessage();
			system.debug('ERROR IMPORTING ACCOUNTING TRANSACTION FILE ' + e + '\n' + e.getMessage() + ' Line Number: ' + e.getLineNumber() + ' ' + e.getStackTraceString());
		}

		return returnString;
	}

	private static String loadTransactionFile(ID rcId, String returnString){			 
			
			Integer handledErrorCounter = 0;
			for(tpjFileFieldMapping__mdt fieldMapping:fieldMappings){
				if(fieldMapping.required__c){
					switch on fieldMapping.sObjectName__c{
						when 'AccountingTransaction__c'{
							if(!acctTXNFieldNumberMap.containsKey(fieldMapping.sfFieldAPIName__c)){
								throw new aijImportException('Required Field ' + fieldMapping.tractsCOLabel__c + ' is not in the source file.');
							}
						}
						when 'AccountingInvestment__c'{
							if(!acctinvFieldNumberMap.containsKey(fieldMapping.sfFieldAPIName__c)){
								throw new aijImportException('Required Field ' + fieldMapping.tractsCOLabel__c + ' is not in the source file.');
							}
						}
					}
				}
			}


			
			System.debug('parsedCSV size is: ' + parsedCSV.size());
		
			for(Integer i=1; i <parsedCSV.size();i++){
			
				AccountingInvestment__c newInvestment = new AccountingInvestment__c();
				pretransactionRecord newTransaction = new pretransactionRecord();

				newTransaction.accountingTransaction.accountingIntegrationJob__c = rcId;
				Integer transactionColumnNumber = acctTXNFieldNumberMap.get('transactionNumber__c');
				if(String.isNotEmpty(parsedCSV[i][transactionColumnNumber])){
					System.debug('cell values are i: ' + i + ' transactionColumnNumber: ' + transactionColumnNumber + ' cell value is: ' + parsedCSV[i][transactionColumnNumber] );
					if(String.valueOf(parsedCSV[i][transactionColumnNumber]).contains('IM*')){
						handledErrorCounter++;
						returnString = 'Partial Success - there were ' + handledErrorCounter + ' rows that were skipped due to validation.';
						continue;
					}
				}

				for(Integer j=0; j < parsedCSV[i].size(); j++){
					//First pass identify and create set of needed Accounting Investments
					//Check to see if Accounting Investment records are created
					//If created add to map, if not create and add to map
					System.debug('Cell value is: ' + parsedCSV[i][j] + ' j value is: ' + j + ' Investment key field number is ' + acctInvFieldNumberMap.get('investmentId__c'));
					
					if(String.isNotEmpty(parsedCSV[i][j]) && j == acctInvFieldNumberMap.get('investmentId__c')){
						
						newTransaction.accountingInvestmentId = parsedCSV[i][j];
					}
					if(String.isNotEmpty(parsedCSV[i][j]) && j == acctInvFieldNumberMap.get('glEntity__c')){
						
						newTransaction.glEntity = parsedCSV[i][j];
					}
					if(String.isNotEmpty(parsedCSV[i][j]) && j == acctTXNFieldNumberMap.get('costProceeds__c')) {
						System.debug('costProceeds value is: ' + Double.valueOf(getTypedValue(String.valueOf(M.get(acctTXNNumberFieldMap.get(j)).getDescribe().getType()), parsedCSV[i][j])));
						if(Double.valueOf(getTypedValue(String.valueOf(M.get(acctTXNNumberFieldMap.get(j)).getDescribe().getType()), parsedCSV[i][j]))>0){
							newTransaction.accountingTransaction.reconciliationType__c = 'Sales';
						}
						else{
							newTransaction.accountingTransaction.reconciliationType__c = 'Cost';
						}
					}
					if(String.isNotEmpty(parsedCSV[i][j]) && acctTXNNumberFieldMap.containsKey(j)){
						newTransaction.accountingTransaction.put(acctTXNNumberFieldMap.get(j), getTypedValue(String.valueOf(M.get(acctTXNNumberFieldMap.get(j)).getDescribe().getType()), parsedCSV[i][j]));
					}
				}
				if(newTransaction.glEntity != '' && newTransaction.accountingInvestmentId != ''){
					investmentNames.add(newTransaction.accountingInvestmentId + '|' + newTransaction.glEntity);
					newTransaction.uniqueKey = newTransaction.accountingInvestmentId + '|' + newTransaction.glEntity;
					pretransactionRecords.add(newTransaction);
				}
				else throw new aijImportException('Accounting Transaction does not have either an Investment Id or a GL Entity.  Values are Investment Id: ' + newTransaction.accountingInvestmentId + ' GL Entity: ' + newTransaction.glEntity);
				

			}
			investmentList = [SELECT Id, investmentId__c, glEntity__c, uniqueKey__c, Name FROM AccountingInvestment__c WHERE uniqueKey__c IN : investmentNames];
			for(AccountingInvestment__c investment: investmentList){
				if(investmentNames.contains(investment.uniqueKey__c)){
					investmentNames.remove(investment.uniqueKey__c);
					investmentMap.put(investment.uniqueKey__c, investment);
				}
			}
			for(String investmentName : investmentNames){
				AccountingInvestment__c newInvestment = new AccountingInvestment__c();
				String[] investmentIdSplit = investmentName.split('\\|');
				System.debug('investmentIdSplit value is:');
				System.debug(investmentIdSplit);
				if(investmentIdSplit.size() == 2){
					newInvestment.investmentId__c = investmentIdSplit[0];
					newInvestment.glEntity__c = investmentIdSplit[1];
					newInvestment.uniqueKey__c = investmentName;
					investmentMap.put(investmentName, newInvestment);
					finalAcctInvs.add(newInvestment);
				}
				else throw new aijImportException('Unable to create new investment with Id = ' + investmentName + ' investmentIdSplit size is: ' + investmentIdSplit.size() + ' Investment Name is: ' + investmentName);
			}
			insert finalAcctInvs;
			for(AccountingInvestment__c investment: finalAcctInvs){
				investmentMap.put(investment.uniqueKey__c, investment);
			}
			for(pretransactionRecord record: pretransactionRecords){
				record.accountingTransaction.investment__c = investmentMap.get(record.uniqueKey).Id;
				finalAcctTXNs.add(record.accountingTransaction); 
			}
			upsert finalAcctTXNs transactionNumber__c;

			currentAIJ.transactionFileLoaded__c = true;
			currentAIJ.transactionFileId__c = cv.ContentDocumentId;
			currentAIJ.transactionFileName__c = cv.Title;

			update currentAIJ;
			return returnString;
			
		
    }


	
	private static void getParsedLines(String lineItems){
		parsedCSV = new List<List<String>>();
		List<List<String>> result = new List<List<String>>();
		List<String> lineColumns = new List<String>();
		Integer stringLength = lineItems.length()-1;
		System.debug('Total String length is: ' + stringLength);
		Integer lineEnd = 0;
		Integer nextStart = 0;
		Boolean notFinished = true;
		Do{
			if(lineEnd + 250000 < stringLength){
				lineEnd = lineEnd + 250000;	
			}
			else{
				lineEnd = stringLength;
			}
			
			String lineGroup = lineItems.substring(nextStart, lineEnd);
			String reverseLineGroup = lineGroup.reverse();
			lineEnd = lineEnd - reverseLineGroup.indexOf('\r');
			System.debug('Start position is: ' + nextStart + ' endPosition is: ' + lineEnd);
			String finalLineGroup = lineItems.substring(nextStart,lineEnd);
			nextStart = lineEnd;
			if(nextStart > stringLength){
				notFinished = false;
			}
			parsedCSV.addAll(CSVFileUtil.parseCSV(Blob.valueOf(finalLineGroup), false));
			
		}while(notFinished);
		
		Integer lineCounter = 0;
		for(List<String> lineGroup2 : parsedCSV){
			lineCounter++;
			if(lineGroup2 != null){
				System.debug('Group ' + lineCounter);
				for(String itemString : lineGroup2){
					System.debug(itemString);
				}
			}
		} 
		
	}

	private static object getTypedValue(String variableType, String variableValue) {
		System.debug('variableType value is: ' + variableType + ' variableValue is: ' + variableValue);
		try{
			If (variableType == 'String') {
				return variableValue;
			}
			else If (variableType == 'Integer') {
				variableValue = variableValue.remove(',');
				return Integer.valueOf(variableValue.remove('"'));
			} 
			else If (variableType == 'Decimal') {
				variableValue = variableValue.remove(',');
				return Decimal.valueOf(variableValue.remove('"'));
			}
			else If (variableType == 'DOUBLE') {
				variableValue = variableValue.remove(',');
				return Decimal.valueOf(variableValue.remove('"'));
			}
			else If (variableType == 'CURRENCY') {
				variableValue = variableValue.remove(',');
				return Decimal.valueOf(variableValue.remove('"'));
			}
			else If (variableType == 'Boolean') {
				return Boolean.valueOf(variableValue);
			}
			else if (variableType == 'DATE'){
				if(variableValue == 'FALSE'){
					return null;
				}
				else{
					return Date.parse(variableValue);
				}
			}
			else {
				return variableValue;
			}
		}
		Catch(Exception e){
			
			system.debug('ERROR IMPORTING AIJ FILE ' + e + '\n' + e.getMessage() + ' Line Number: ' + e.getLineNumber() + ' ' + e.getStackTraceString());
			throw new aijImportException('Error uploading file :' + e.getMessage());
		}
	}
	
	

	public virtual class aijImportException extends Exception{}

	public class headerField {
		public String fieldName {get;set;}
		public Boolean fieldIncluded {get; set;}

		public headerField(){
			fieldName = '';
			fieldIncluded = false;
		}

		public headerField(String name){
			fieldName = name;
			fieldIncluded = false;
		}

	}

	public class pretransactionRecord{

		public AccountingTransaction__c accountingTransaction {get; set;}
		public String accountingInvestmentId {get; set;}
		public String glEntity {get; set;}
		public String uniqueKey {get; set;}

		public pretransactionRecord(){
			accountingTransaction = new AccountingTransaction__c();
			accountingTransaction.updateFromImport__c = true;
			accountingInvestmentId = '';
			glEntity = '';
			uniqueKey = '';
		}
	}
}