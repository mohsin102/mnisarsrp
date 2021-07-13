//Create by John Gorrell 10/22/2019 as part of Tract Reconciliation Prject

//Test coverage provided by tractReconciliationAuraTest


public with sharing class tpjImportItemsAura  {


    static final List<tpjFileFieldMapping__mdt> fieldMappings = [SELECT required__c, sfFieldAPIName__c, sObjectName__c, tractsCOLabel__c FROM tpjFileFieldMapping__mdt];
	static LandGridTract__c currentLandGridTract = new LandGridTract__c();
	static Map<String,String> torFieldConfigMap = new Map<String,String>();
	static Map<String,String> tonFieldConfigMap = new Map<String,String>();
	static Map<String,String> runSheetFieldConfigMap = new Map<String,String>();
	static List<TitleOwnershipDetail__c> finalTORs = new List<TitleOwnershipDetail__c>();
	static List<TargetOwnershipName__c> finalTONs = new List<TargetOwnershipName__c>();
	static List<runSheetLineItem__c> finalRunSheetItems = new List<runSheetLineItem__c>();
	static Map<String, List<TitleOwnershipDetail__c>> resultMap = new Map<String, List<TitleOwnershipDetail__c>>();
	static Map<String, TargetOwnershipName__c> tonMap = new Map<String, TargetOwnershipName__c>();
	static List<List<String>> parsedCSV = new List<List<String>>();
	static List<String> lineValues = new List<String>();
	static List<String> tonUniqueIdentifier = new List<String> {'ownerName__c', 'final__c', 'address__c', 'notes__c'};
	static List<Integer> tonUniqueFieldIndex = new List<Integer>();
	static Map < String, Integer > torFieldNumberMap = new Map < String, Integer > ();
	static Map < Integer, String > torNumberFieldMap = new Map < Integer, String > ();
	static List<String> torLstFieldNames = new List<String>();
	static Map < String, Integer > tonFieldNumberMap = new Map < String, Integer > ();
	static Map < Integer, String > tonNumberFieldMap = new Map < Integer, String > ();
	static List<String> tonLstFieldNames = new List<String>();
	static Map < String, Integer > runSheetFieldNumberMap = new Map < String, Integer > ();
	static Map < Integer, String > runSheetNumberFieldMap = new Map < Integer, String > ();
	static List<String> runSheetLstFieldNames = new List<String>();
	static String tonUniqueString = '';
	static TitleIntegrationJob__c currentTPJ = new TitleIntegrationJob__c();
	static Map<String, Schema.SObjectField> M = Schema.SObjectType.TitleOwnershipDetail__c.fields.getMap();
	static Map<String, Schema.SObjectField> runSheetFieldMap = Schema.SObjectType.runSheetLineItem__c.fields.getMap();
	static ContentVersion cv = new ContentVersion();
	static Set<String> tpjAreas = new Set<String>();
	static List<quarterCallMapping__c> finalQuarterCalls = new List<quarterCallMapping__c>();

	
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
			currentTPJ = [SELECT  CreatedById, CreatedDate, Id, IsDeleted, jobNotes__c, LandGridTract__c, LastModifiedById, flatFileLoaded__c,
														   runSheetLoaded__c, flatFileName__c, flatFileId__c, runSheetName__c, runSheetId__c,
														   LastModifiedDate, LastReferencedDate, LastViewedDate, Name, SystemModstamp FROM TitleIntegrationJob__c
														   WHERE Id = :rcId LIMIT 1];
			if(currentTPJ.flatFileLoaded__c && fileType == 'flatFile'){
				throw new tpjImportException('Flat file has already been loaded for this TPJ.');
			}
			if(currentTPJ.runSheetLoaded__c && fileType == 'runSheet'){
				throw new tpjImportException('Run Sheet has already been loaded for this TPJ.');
			}
			if(fileType == 'runSheet' || fileType == 'flatFile'){
				getParsedLines(lineItemString);
			}
			//SSSCsvReader fileReader = new SSSCsvReader(lineItemString);
			//lineValues = fileReader.readLine();
			//System.debug(lineValues);
			//Do {
			//	lineValues = fileReader.readLine();
			//	System.debug(lineValues);
			//} while (lineValues != null);
			

			//if(fileType == 'flatFile'){
			//	parsedCSV = CSVFileUtil.parseCSV(fileContents, false);
			//}
			
			currentLandGridTract =[SELECT Id, Name FROM LandGridTract__c WHERE Id = :currentTPJ.LandGridTract__c LIMIT 1];
			
		
			for(tpjFileFieldMapping__mdt fieldMapping:fieldMappings){
				switch on fieldMapping.sObjectName__c{
					when 'TitleOwnershipDetail__c'{
						torFieldConfigMap.put(fieldMapping.tractsCOLabel__c, fieldMapping.sfFieldAPIName__c);
					}
					when 'TargetOwnershipName__c'{
						tonFieldConfigMap.put(fieldMapping.tractsCOLabel__c, fieldMapping.sfFieldAPIName__c);
					}
					when 'RunSheetLineItem__c'{
						runSheetFieldConfigMap.put(fieldMapping.tractsCOLabel__c, fieldMapping.sfFieldAPIName__c);
					}
				}
			}

			for (Integer i = 0; i < parsedCSV[0].size(); i++) {
				if(!String.isBlank(parsedCSV[0][i])){
					string fieldName = parsedCSV[0][i].replaceAll('[^a-zA-Z0-9 .]', '');
					//System.debug(csvFieldNames[i].isAlphanumericSpace());
					//System.debug('csvFieldName value is: ' + fieldName + ' map value is: ' + fieldConfigMap.get(fieldName));
					if(torFieldConfigMap.get(fieldName) != null){
						torNumberFieldMap.put(i,torFieldConfigMap.get(fieldName));
						torFieldNumberMap.put(torFieldConfigMap.get(fieldName), i);
						torLstFieldNames.add(torFieldConfigMap.get(fieldName));
					}
					if(tonFieldConfigMap.get(fieldName) != null){
						tonNumberFieldMap.put(i,tonFieldConfigMap.get(fieldName));
						tonFieldNumberMap.put(tonFieldConfigMap.get(fieldName), i);
						tonLstFieldNames.add(tonFieldConfigMap.get(fieldName));
					}
					if(runSheetFieldConfigMap.get(fieldName) != null){
						runSheetNumberFieldMap.put(i,runSheetFieldConfigMap.get(fieldName));
						runSheetFieldNumberMap.put(runSheetFieldConfigMap.get(fieldName), i);
						runSheetLstFieldNames.add(runSheetFieldConfigMap.get(fieldName));
					}


				}
			} 

			if(fileType == 'flatFile'){
				loadFlatFile(rcId);
			}
			else if(fileType == 'runSheet'){
				loadRunSheet(rcId);
			}
		}
		Catch(Exception e){
			returnString = e.getMessage();
			system.debug('ERROR IMPORTING TPJ FILE ' + e + '\n' + e.getMessage() + ' Line Number: ' + e.getLineNumber() + ' ' + e.getStackTraceString());
		}

		return returnString;
	}

	private static void loadFlatFile(ID rcId){			 

			for(String fieldName: tonUniqueIdentifier){
				//System.debug('fieldName value is: ' + fieldName);
				tonUniqueFieldIndex.add(tonFieldNumberMap.get(fieldName));
			}

			//Check for matching Land Grid Tract.  If not matched, throw new Error
			///tring fileLocation = parsedCSV[1][torFieldNumberMap.get('Location__c')].replaceAll('[^a-zA-Z0-9 .-]', '');
			//System.debug('file Location value is: ' + fileLocation + ' Name from LGT is: ' + currentLandGridTract.Name);
			//if(fileLocation != currentLandGridTract.Name){
			//	throw new tpjImportException('Land Grid Tract for this TPJ does not match source file.');
			//}

			//System.debug(tonUniqueFieldIndex);

			//System.debug(torNumberFieldMap);
			//System.debug(torFieldNumberMap);
			//System.debug(torLstFieldNames);

			//System.debug(tonNumberFieldMap);
			//System.debug(tonFieldNumberMap);
			//System.debug(tonLstFieldNames);

			//Check for required fields.  If not included in file, throw new Error
			for(tpjFileFieldMapping__mdt fieldMapping:fieldMappings){
				if(fieldMapping.required__c){
					switch on fieldMapping.sObjectName__c{
						when 'TitleOwnershipDetail__c'{
							if(!torFieldNumberMap.containsKey(fieldMapping.sfFieldAPIName__c)){
								throw new tpjImportException('Required Field ' + fieldMapping.tractsCOLabel__c + ' is not in the source file.');
							}
						}
						when 'TargetOwnershipName__c'{
							if(!tonFieldNumberMap.containsKey(fieldMapping.sfFieldAPIName__c)){
								throw new tpjImportException('Required Field ' + fieldMapping.tractsCOLabel__c + ' is not in the source file.');
							}
						}
					}
				}
			}


			
			//System.debug('parsedCSV size is: ' + parsedCSV.size());
		
			for(Integer i=1; i <parsedCSV.size();i++){
				TargetOwnershipName__c newTON = new TargetOwnershipName__c();
				TitleOwnershipDetail__c newTOR = new TitleOwnershipDetail__c();
				
				newTON.jobId__c = rcId;
				tonUniqueString = '';
				for(Integer a: tonUniqueFieldIndex){
					System.debug('i value is: ' + i);
					System.debug('a value is: ' + a);
					String parsedString = String.valueOf(parsedCSV[i][a]).replace('"', '');
					tonUniqueString = tonUniqueString + parsedString;	
					newTON.put(tonNumberFieldMap.get(a),parsedString);
					//System.debug('Fieldname applied is: ' + tonNumberFieldMap.get(a) + ' value is ' + parsedString);
				}
				if(!tonMap.containsKey(tonUniqueString)){
					tonMap.put(tonUniqueString, newTON);
				}
				for(Integer j=0; j < parsedCSV[i].size(); j++){
					//First pass identify and create unique TON String
					//Check to see if TON record is created, if not create TON and add to tonMap 
					//System.debug(parsedCSV[i][j] + 'j value is: ' + j);
					//System.debug ('Current value is ' + parsedCSV[i][j] + ' for field ' + torNumberFieldMap.get(j));
					//Schema.SObjectField field = M.get(torNumberFieldMap.get(j));
					//Schema.DisplayType FldType = field.getDescribe().getType();
					
					if(String.isNotEmpty(parsedCSV[i][j]) && torNumberFieldMap.containsKey(j)){
						if(torNumberFieldMap.get(j) == 'area__c'){
							tpjAreas.add(String.valueOf(parsedCSV[i][j]));
						}
						newTOR.put(torNumberFieldMap.get(j), getTypedValue(String.valueOf(M.get(torNumberFieldMap.get(j)).getDescribe().getType()), parsedCSV[i][j]));
					}
				}
				if(resultMap.containsKey(tonUniqueString)){
					resultMap.get(tonUniqueString).add(newTOR);
				}
				else{
					resultMap.put(tonUniqueString, new List<TitleOwnershipDetail__c> {newTOR});
				}
			}

			finalTONs.addAll(tonMap.values());
			insert finalTONs;

			for(TargetOwnershipName__c ton: finalTONS){
			
				String tonLookup = '';
				for(Integer a: tonUniqueFieldIndex){
					tonLookup = tonLookup + ton.get(tonNumberFieldMap.get(a));	
					//newTON.put(tonNumberFieldMap.get(a),parsedString);
					//System.debug('Fieldname applied is: ' + tonNumberFieldMap.get(a) + ' value is ' + parsedString);
				}
				List<TitleOwnershipDetail__c> currentTORs = resultMap.get(tonLookup);
				for(TitleOwnershipDetail__c currentTOR:currentTORs){
					currentTOR.targetOwnershipName__c = ton.Id;
					finalTORs.add(currentTOR);
				}
				//System.debug('currentTORs size is ' + currentTORs.size());
				//System.debug('tonLookup value is: ' + tonLookup);
				//List<TitleOwnershipDetail__c> torRecords = resultMap.get(ton.get(
			}

			//Add Quarter call mapping objects
			for(String area : tpjAreas){
				quarterCallMapping__c newQuarterCall = new quarterCallMapping__c();
				newQuarterCall.titleIntegrationJob__c = rcId;
				System.debug('newQuarterCall titleIntegrationJob value is: ' + newQuarterCall.titleIntegrationJob__c);
				newQuarterCall.area__c = area;
				finalQuarterCalls.add(newQuarterCall);
			}


			//System.debug(currentTON);
			//List<List<TitleOwnershipDetail__c>> masterRecords = resultMap.values();
			//System.debug(masterRecords);
			//for(List<TitleOwnershipDetail__c> torRecords:masterRecords){
			//	for(TitleOwnershipDetail__c torRecord: torRecords){
			//		finalTORs.add(torRecord);
			//		//System.debug(torRecord);
			//	}
			//}

			//System.debug(torRecords.size());
		
			//System.debug('finalTORs size is: ' + finalTORs.size());
			insert finalQuarterCalls;
			Id batchInstanceId = Database.executeBatch(new batchInsertTODRecords(finalTORs));
			//insert finalTORs;
			currentTPJ.flatFileLoaded__c = true;
			currentTPJ.flatFileName__c = cv.Title;
			currentTPJ.flatFileId__c = cv.ContentDocumentId;
			update currentTPJ;

			
		
    }

	private static void loadRunSheet(ID rcId){
		//System.debug('Running loadRunSheet');
		//Throw new tpjImportException ('Run sheet has not been programmed yet!!!');

		for(String fieldName: tonUniqueIdentifier){
				//System.debug('fieldName value is: ' + fieldName);
				tonUniqueFieldIndex.add(tonFieldNumberMap.get(fieldName));
			}

			//System.debug(runSheetNumberFieldMap);
			//System.debug(runSheetFieldNumberMap);
			//System.debug(runSheetLstFieldNames);

			//Check for required fields.  If not included in file, throw new Error
			for(tpjFileFieldMapping__mdt fieldMapping:fieldMappings){
				if(fieldMapping.required__c){
					switch on fieldMapping.sObjectName__c{
						when 'RunSheetLineItem__c'{
							if(!runSheetFieldNumberMap.containsKey(fieldMapping.sfFieldAPIName__c)){
								throw new tpjImportException('Required Field ' + fieldMapping.tractsCOLabel__c + ' is not in the source file.');
							}
						}
					}
				}
			}


			
			//System.debug('parsedCSV size is: ' + parsedCSV.size());
		
			for(Integer i=1; i <parsedCSV.size();i++){
				RunSheetLineItem__c newRunSheetItem = new RunSheetLineItem__c();
				//TitleOwnershipDetail__c newTOR = new Title_Ownership_Detail__c();
				newRunSheetItem.jobId__c = rcId;
				
				
				for(Integer j=0; j < parsedCSV[i].size(); j++){
					//System.debug(runSheetNumberFieldMap.get(j));
					//System.debug(parsedCSV[i][j]);
					if(String.isNotEmpty(parsedCSV[i][j]) && runSheetNumberFieldMap.containsKey(j)){
						//System.debug(j);
						//System.debug(M.get(runSheetNumberFieldMap.get(j)));
						//System.debug(getTypedValue(String.valueOf(M.get(runSheetNumberFieldMap.get(j)).getDescribe().getType()), parsedCSV[i][j]));

						newRunSheetItem.put(runSheetNumberFieldMap.get(j), getTypedValue(String.valueOf(runSheetFieldMap.get(runSheetNumberFieldMap.get(j)).getDescribe().getType()), parsedCSV[i][j]));
						System.debug(parsedCSV[i][j]);
						if(String.valueOf(runSheetFieldMap.get(runSheetNumberFieldMap.get(j)).getDescribe().getType()) == 'DATE' && parsedCSV[i][j] != 'FALSE'){
						System.debug('Date if evaluated to true');
							Date fieldDate = Date.parse(parsedCSV[i][j]);
							if (fieldDate > System.now().addDays(1)){
								throw new tpjImportException('All dates referenced on run sheets must be less than 1 day in the future.  Future date ' + fieldDate + ' found.');
							}
						}
					}
				}
				finalRunSheetItems.add(newRunSheetItem);
				

			}

			insert finalRunSheetItems;

			currentTPJ.runSheetLoaded__c = true;
			currentTPJ.runSheetName__c = cv.Title;
			currentTPJ.runSheetId__c = cv.ContentDocumentId;
			update currentTPJ;
		
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
			//finalLineGroup.replace('\n', '');
			//System.debug(finalLineGroup);
			//SSSCsvReader fileReader = new SSSCsvReader(finalLineGroup);
			//lineValues = fileReader.readLine();
			//System.debug(lineValues.size());
			//result.add(lineValues);
		
		
			//Do {
			//	List<String> newLine = new List<String>();
			//	newLine = fileReader.readLine();
			//	if(newLine != null){
			//		result.add(newLine);
			//	}
			//	lineValues = newLine;
			//} while (lineValues != null);
		}while(notFinished);
		//result.add(finalLineGroup);
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
		//result.remove(lineCounter-1);
		//return result;
	}

	private static object getTypedValue(String variableType, String variableValue) {
		//System.debug('variableType value is: ' + variableType + ' variableValue is: ' + variableValue);
		try{
			If (variableType == 'String') {
				return variableValue;
			}
			else If (variableType == 'Integer') {
				return Integer.valueOf(variableValue);
			} 
			else If (variableType == 'Decimal') {
				return Decimal.valueOf(variableValue);
			}
			else If (variableType == 'DOUBLE') {
				return Decimal.valueOf(variableValue);
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
			
			system.debug('ERROR IMPORTING TPJ FILE ' + e + '\n' + e.getMessage() + ' Line Number: ' + e.getLineNumber() + ' ' + e.getStackTraceString());
			throw new tpjImportException('Error uploading file :' + e.getMessage());
		}
	}
	
	

	public virtual class tpjImportException extends Exception{}
	
}