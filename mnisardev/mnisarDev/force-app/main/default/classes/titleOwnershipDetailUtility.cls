//After completion - delete existing instrumentType__c field on TitleOwnershipDetail__c and change api name on instrumentType__c.  Code will also need to be updated.

//Assumption that a TOT record will always have relatedTORs field populated.  If not, we do not have the necessary information to calculate the TOT instrument type.
//TOR record is updated with related TOT information after TOT has been created, so cannot pull relationship from TOR records.
public class titleOwnershipDetailUtility  {

	static final tractReconciliationSetting__mdt reconciliationSettings = [SELECT torRecordTypeId__c, totRecordTypeId__c, baseURL__c, Label, DeveloperName FROM tractReconciliationSetting__mdt WHERE baseURL__c = :URL.getSalesforceBaseUrl().toExternalForm().replace('https', 'http')];

	public static void calculateInstrumentType(List<TitleOwnershipDetail__c> newList , Map<Id, TitleOwnershipDetail__c> newMap){
		//System.debug(newList);
		//System.debug(newMap);
		List<String> relatedTORIds = new List<String>();
		for(TitleOwnershipDetail__c todItem : newList){
			if (todItem.RecordTypeId == reconciliationSettings.totRecordTypeId__c){
				String relatedTOR = todItem.RelatedTORs__c.substring(0,18);
				System.debug('Related TOR record id is: ' + relatedTOR);
				relatedTORIds.add(relatedTOR);
				//if a TOT record add to list of items to query related TOR records.
			}
			else if (todItem.RecordTypeId == reconciliationSettings.torRecordTypeId__c){
				//if a TOR record run logic to calculate instrument type
				setTORInstrumentType(todItem);
			}
		}
		
		if(relatedTORIds.size() > 0){
			List<TitleOwnershipDetail__c> relatedTORRecords = [SELECT Id, TargetOwnershipTract__c, instrumentType__c FROM TitleOwnershipDetail__c WHERE Id in :relatedTORIds];
			//Loop through results 
			for(TitleOwnershipDetail__c torRecord:relatedTORRecords){
				System.debug('torRecord id is: ' + torRecord.Id + ' instrument type is: ' + torRecord.instrumentType__c);
				//Loop through list of records
				for(TitleOwnershipDetail__c todItem: newList){
					//Check for totRecord type and matching first listed relatedTOR
					System.debug('Inside for loop');
					System.debug('totRecord is: ' + todItem.Id);
					//System.debug('todItem record type is: ' + todItem.RecordTypeId + 'related TOR is ' + todItem.RelatedTORs__c.substring(0,18) + ' torRecord.Id is: ' + torRecord.Id);

					if(todItem.RecordTypeId == reconciliationSettings.totRecordTypeId__c && todItem.RelatedTORs__c.substring(0,18) == torRecord.Id){
						todItem.instrumentType__c = torRecord.instrumentType__c;
					}
				}
			}
		}

	}

	public static void setTORInstrumentType(TitleOwnershipDetail__c torRecord){
		//Only update if record type is for a TOR record.
		if(torRecord.RecordTypeId == reconciliationSettings.torRecordTypeId__c){
			if(torRecord.lease__c == 'UMI'){
				torRecord.instrumentType__c = 'UMI';
			}
			else{
				if(torRecord.lor__c <> 0  && torRecord.lor__c != null){
					System.debug('executive is: ' + torRecord.executive__c);
					if(torRecord.executive__c <> 0 && torRecord.executive__c != null){
						if(torRecord.leaseLOR__c <> 0 && torRecord.leaseLOR__c != null){
							torRecord.instrumentType__c = 'MD';
						}
						else{
							torRecord.instrumentType__c = 'INVALID?';
						}
					}
					else{
						torRecord.instrumentType__c = 'NPRI';
					}
				}
				else{
					if(torRecord.nri__c <> 0 && torRecord.nri__c != null){
						torRecord.instrumentType__c = 'OGL';
					}
					else if (torRecord.oi__c <> 0 && torRecord.oi__c != null){
						torRecord.instrumentType__c = 'ORRI';
					}
					else{
						torRecord.instrumentType__c = 'INVALID';
					}
				}
			}
		}
	}

}