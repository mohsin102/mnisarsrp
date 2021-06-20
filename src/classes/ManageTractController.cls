public class ManageTractController {
    
    @AuraEnabled
    public static tableWrapper getTract(Id oppId){
        tableWrapper tableWrap = new tableWrapper();
        Set<Id> tractIds = new Set<id>(); 
        Opportunity oppRec = [Select id,AccountId from Opportunity Where Id =:oppId Limit 1];
        
        for(Opportunity_Tract__c oppTract : [Select Tract__c From Opportunity_Tract__c 
                        where Opportunity__c =: oppId]){
                            
                            tractIds.add(oppTract.Tract__c);
                        }  

        tableWrap.unassociatedTracts = [Select id,name,Full_Legal_Name__c,Quarter_Call__c,Instrument_Type__c,
                                        netAcreageUnits__c,netAcres__c, Gross_Acres__c, Notes__c, LandGridTract__c from tract__c 
                                        Where Account__c =:oppRec.AccountId AND Id not In: tractIds];

        tableWrap.associatedTracts = [Select id,name,Full_Legal_Name__c,Quarter_Call__c,Instrument_Type__c,
                                      netAcreageUnits__c,netAcres__c, Gross_Acres__c, Notes__c, LandGridTract__c from tract__c 
                                      Where Id In: tractIds];

        return tableWrap;
    }
	
	@AuraEnabled 
	public static tableWrapper getFilteredTracts(Id oppId, Integer pageNumber, Integer pageSize, String searchTerm, Integer searchCount){
        tableWrapper tableWrap = new tableWrapper();
		string searchStringCheck = '';
		if(searchTerm != null){
		 searchStringCheck = searchTerm.trim();
		}
		Boolean isFiltered = false;
		List<String> landGridTractIds = new List<String>();
		if(searchStringCheck.length() >1){
			Opportunity oppRec = [Select id,AccountId from Opportunity Where Id =:oppId Limit 1];
			landGridTractIds = getFilteredLandGridTracts(searchTerm, oppRec.AccountId);
			isFiltered = true;
		}
		tableWrap.associatedTracts = getAssociatedTract(oppId, pageNumber, pageSize, landGridTractIds, isFiltered, null);
		tableWrap.unassociatedTracts = getUnassociatedTract(oppId, pageNumber, pageSize, landGridTractIds, isFiltered, null);
		tableWrap.searchCounter = searchCount;
		return tableWrap;
		
			
	}
	
	@AuraEnabled
    public static List<Tract__c> getUnassociatedTract(Id oppId,Integer pageNumber,Integer pageSize, List<String> landGridTractIds, boolean filtered, String searchString){
		System.debug('input values are - oppId: ' + oppId + ' pageNumber: ' + pageNumber + ' pageSize: ' + pageSize + ' landGridTractIds: ' + landGridTractIds);
        
		Set<Id> tractIds = new Set<id>(); 
        Opportunity oppRec = [Select id,AccountId from Opportunity Where Id =:oppId Limit 1];
        if (landGridTractIds == null){
			landGridTractIds = new List<String>();
		}
		if(searchString == null){
			searchString = '';
		}
		if(searchString.length()>1 && landGridTractIds.size() == 0){
			System.debug('searching for landgridtracts with searchString: ' + searchString + ' account id: ' + oppRec.AccountId);
			landGridTractIds = getFilteredLandGridTracts(searchString, oppRec.AccountId);
		}

        //Separate Tracts and Land Grid Tracts
        Set<Id> searchedTractIds = new Set<Id>(); 
        Set<Id> searchedLandGridTractIds = new Set<Id>(); 
        for(Id objId: (List<Id>)landGridTractIds){
            if(objId.getSObjectType(). getDescribe().getName() =='Tract__c'){
                searchedTractIds.add(objId);
            }else{
                searchedLandGridTractIds.add(objId);
            }
        }

		System.debug('Modified input values are - searchString: ' + searchString + ' landGridTractIds: ' + landGridTractIds);
		System.debug('landGridTracts size is: ' + landGridTractIds.size());
		for(Opportunity_Tract__c oppTract : [Select Tract__c From Opportunity_Tract__c 
                        where Opportunity__c =: oppId]){                       
                            tractIds.add(oppTract.Tract__c);
		}
		List<Tract__c> unassociatedTracts = new List<Tract__c>();
		if(filtered){  
			unassociatedTracts = [Select id,name,Full_Legal_Name__c,Quarter_Call__c,Instrument_Type__c,
									netAcreageUnits__c,netAcres__c, Gross_Acres__c, Notes__c, LandGridTract__c,depth__c from tract__c 
									Where Account__c =:oppRec.AccountId AND Id not In: tractIds
									AND (LandGridTract__c IN :searchedLandGridTractIds OR Id In: searchedTractIds)
									LIMIT :pageSize OFFSET :pageSize*(pageNumber-1)];
		}
		else{
			unassociatedTracts = [Select id,name,Full_Legal_Name__c,Quarter_Call__c,Instrument_Type__c,
									netAcreageUnits__c,netAcres__c, Gross_Acres__c, Notes__c, LandGridTract__c,depth__c from tract__c 
									Where Account__c =:oppRec.AccountId AND Id not In: tractIds
									LIMIT :pageSize OFFSET :pageSize*(pageNumber-1)];
		}
		return unassociatedTracts;   
                       
    }   
	
    @AuraEnabled
    public static List<Tract__c> getAssociatedTract(Id oppId,Integer pageNumber,Integer pageSize, List<String> landGridTractIds, Boolean filtered, String searchString){
		System.debug('input values are - oppId: ' + oppId + ' pageNumber: ' + pageNumber + ' pageSize: ' + pageSize + ' landGridTractIds: ' + landGridTractIds);
        Set<Id> tractIds = new Set<id>(); 
        Opportunity oppRec = [Select id,AccountId from Opportunity Where Id =:oppId Limit 1];
		if (landGridTractIds == null){
			landGridTractIds = new List<String>();
		}
		if(searchString == null){
			searchString = '';
		}
		if(searchString.length()>1 && landGridTractIds.size() == 0){
			System.debug('searching for landgridtracts with searchString: ' + searchString + ' account id: ' + oppRec.AccountId);
			landGridTractIds = getFilteredLandGridTracts(searchString, oppRec.AccountId);
		}

        //Separate Tracts and Land Grid Tracts
        Set<Id> searchedTractIds = new Set<Id>(); 
        Set<Id> searchedLandGridTractIds = new Set<Id>(); 
        for(Id objId: (List<Id>)landGridTractIds){
            if(objId.getSObjectType(). getDescribe().getName() =='Tract__c'){
                searchedTractIds.add(objId);
            }else{
                searchedLandGridTractIds.add(objId);
            }
        }

		System.debug('Modified input values are - searchString: ' + searchString + ' landGridTractIds: ' + landGridTractIds);
		System.debug('landGridTracts size is: ' + landGridTractIds.size());
        for(Opportunity_Tract__c oppTract : [Select Tract__c From Opportunity_Tract__c 
                        where Opportunity__c =: oppId]){
                            
                            tractIds.add(oppTract.Tract__c);
        }  
		List<Tract__c> associatedTracts = new List<Tract__c>();
		if(filtered){  
			associatedTracts = [Select id,name,Full_Legal_Name__c,Quarter_Call__c,Instrument_Type__c,
                                netAcreageUnits__c,netAcres__c, Gross_Acres__c, Notes__c, LandGridTract__c,depth__c from tract__c 
                                Where Id In: tractIds
								AND (LandGridTract__c IN :searchedLandGridTractIds OR Id In: searchedTractIds)
                                LIMIT :pageSize OFFSET :pageSize*(pageNumber-1)];
		}
		else{
			associatedTracts = [Select id,name,Full_Legal_Name__c,Quarter_Call__c,Instrument_Type__c,
                                netAcreageUnits__c,netAcres__c, Gross_Acres__c, Notes__c, LandGridTract__c,depth__c from tract__c 
                                Where Id In: tractIds 
                                LIMIT :pageSize OFFSET :pageSize*(pageNumber-1)];
		}

        return associatedTracts;                           
    }
    
    @AuraEnabled
    public static void addTract(Id oppId,List<Tract__c> tracts){
        
        List<Opportunity_Tract__c> otList = new List<Opportunity_Tract__c>();
        Opportunity_Tract__c otRec;
        Opportunity oppRec = [Select id,AccountId from Opportunity Where Id =:oppId Limit 1];
        
        for(Tract__c tractRec : tracts){

            otRec = new  Opportunity_Tract__c();
            otRec.Tract__c = tractRec.Id;
            otRec.Opportunity__c = oppId;
            otList.add(otRec);
        }
        if(otList.size()>0){
            insert otList;
        }
    }

    @AuraEnabled
    public static void removeTract(Id oppId,List<Tract__c> tracts){
        
        List<Opportunity_Tract__c> otList = [Select Id from Opportunity_Tract__c 
                    Where Opportunity__c =:oppId AND Tract__c In: tracts];
        
        if(otList.size()>0){
            delete otList;
        }
    }

	public static List<String> getFilteredLandGridTracts (String searchTerm, String accountId){
        // Prepare query parameters
        List<string> results = new List<String>();
		if(!String.isBlank(searchTerm)){
			List<String> terms = searchTerm.split('\\s');
			List<String> newTerms = new List<String>();
			Map<String,String> aliasList = new Map<String,String>();

			for(String term : terms)		
			{
				// Aliases

				if (hasTerm(term,'tex'))
				{
					newTerms.add('(*TX* OR *' + term + '*)');
				}
				else if (hasTerm(term,'arka'))
				{
					newTerms.add('(*AR* OR *' + term + '*)');
				}
				else if (hasTerm(term,'colo'))
				{
					newTerms.add('(*CO* OR *' + term + '*)');
				}
				else if (hasTerm(term,'monta'))
				{
					newTerms.add('(*MT* OR *' + term + '*)');
				}
				else if (hasTerm(term,'kans'))
				{
					newTerms.add('(*KS* OR *' + term + '*)');
				}
				else if (hasTerm(term,'new') || hasTerm(term,'mexi'))
				{
					newTerms.add('(*NM* OR *' + term + '*)');
				}
				else if (hasTerm(term,'louis'))
				{
					newTerms.add('(*LA* OR *' + term + '*)');
				}
				else if (hasTerm(term,'wyo'))
				{
					newTerms.add('(*WY* OR *' + term + '*)');
				}
				else
				{
					newTerms.add('*' + term + '*');
				}
			}

			String newTerm = String.join(newTerms,' AND ');
			System.debug('newTerm: ' + newTerm + ' accountId: ' + accountId);
			Datetime qryStart = Datetime.now();
        
			List<List<SObject>> searchResults = [FIND :newTerm IN Name fields Returning Landgridtract__c(Id WHERE Id in (SELECT landgridtract__c FROM Tract__c WHERE account__c = :accountId)),Tract__c(Id WHERE account__c = :accountId)];
			System.debug('Result size: ' + searchResults.size());
        
			Datetime qryEnd = Datetime.now();
        
			System.debug(LoggingLevel.WARN, 'Result time: ' + (qryEnd.getTime() - qryStart.getTime()) + 'ms');
		

			// Extract Land Grid Tracts & convert them into LookupSearchResult
			
            

			LandGridTract__c [] lgTracts = ((List<LandGridTract__c>) searchResults[0]);
			for (LandGridTract__c lt : lgTracts) {
				results.add(String.valueOf(lt.Id));
			}

            Tract__c [] tracts = ((List<Tract__c>) searchResults[1]);
			for (Tract__c t : tracts) {
				results.add(String.valueOf(t.Id));
			}
            system.debug('********results*****'+results);
		}
		return results;
	}

	  //If the term starts with the selected value, return true
    private static Boolean hasTerm(String term, String value)
    {
        return (term.left(value.length()).toLowerCase() == value.toLowerCase());
    }


    public class tableWrapper{
        @AuraEnabled
        public List<Tract__c> unassociatedTracts{get;set;}
        @AuraEnabled
        public List<Tract__c> associatedTracts{get;set;}
		@AuraEnabled 
		public Integer searchCounter{get;set;}

		public tableWrapper(){
			unassociatedTracts = new List<Tract__c>();
			associatedTracts = new List<Tract__c>();
			searchCounter = 0;
		}
    }
}