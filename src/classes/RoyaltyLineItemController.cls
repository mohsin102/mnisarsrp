public class RoyaltyLineItemController {
    
    /***********
    * MethodName: getRecordsForAssociation
    * parameters: Royalty check Id from lightning component - RoyaltyLineItemAssociationRelatedList
    * ReturnType: List of royaltyLineItemWrapper (Wrapper classproperties - PropertyName,WellName,#of RoyaltyLineItems,Setof LineItem Ids
    * Description: This method is used to fetch List of # of Royalty Line Items grouped by Property Name. This method also return List of set of of
    * 				Royalty Line Items
	***********/    
    @AuraEnabled
    public static List<royaltyLineItemWrapper> getRecordsForAssociation(Id rcId){

        List<Royalty_Line_Item__c> rliList = [Select Id, propertyName__c,revenueProperty__c,
                                        revenueProperty__r.propertyName__c,
                                        revenueProperty__r.isNonWellRevenueProperty__c,
                                        Royalty_check__r.Payor_from_Source_File__c,
                                        Royalty_check__r.Payor_Lookup__r.Name
                                        from Royalty_Line_Item__c 
                                        where Royalty_Check__c =: rcId];

        String payorName =rliList[0].Royalty_check__r.Payor_from_Source_File__c;
        String payorAccName = rliList[0].Royalty_check__r.Payor_Lookup__r.Name;
        Map<Id,Set<String>> revenuePropertyMap = new Map<Id,Set<String>>();
        Map<Id,revenueProperty__c> revenuePropertyRecMap = new Map<Id,revenueProperty__c>();
        Set<Id> nonWellRevenueProperties = new Set<Id>();

        for(Royalty_Line_Item__c rli : rliList){

            if(revenuePropertyMap.containsKey(rli.revenueProperty__c)){
                revenuePropertyMap.get(rli.revenueProperty__c).add(rli.Id);
            }else{
                revenuePropertyMap.put(rli.revenueProperty__c,new set<String>{rli.Id});
                revenuePropertyRecMap.put(rli.revenueProperty__c,new revenueProperty__c(Id=rli.revenueProperty__c, 
                                                                            propertyName__c = rli.revenueProperty__r.propertyName__c));
            }
            if(rli.revenueProperty__r.isNonWellRevenueProperty__c){
                nonWellRevenueProperties.add(rli.revenueProperty__c);
            }
        }
        Map<Id,Set<String>> revenuePropertyWellMap = new Map<Id,Set<String>>();
        for(revenuePropertyWellAllocation__c rpw: [Select revenueProperty__c,well__r.Name
                                                from revenuePropertyWellAllocation__c 
                                                where revenueProperty__c In: revenuePropertyMap.keySet()]){
            
            if(revenuePropertyWellMap.containsKey(rpw.revenueProperty__c)){
                revenuePropertyWellMap.get(rpw.revenueProperty__c).add(rpw.well__r.Name);
            }else{
                revenuePropertyWellMap.put(rpw.revenueProperty__c,new set<String>{rpw.well__r.Name});
            }
        }

        List<royaltyLineItemWrapper> royaltyLineItemWrapList = new List<royaltyLineItemWrapper>();
        royaltyLineItemWrapper royaltyLineItemWrap;
        for(Id revenueProperty: revenuePropertyMap.keySet()){
            royaltyLineItemWrap = new royaltyLineItemWrapper();
            royaltyLineItemWrap.name = revenuePropertyRecMap.get(revenueProperty).propertyName__c;
            royaltyLineItemWrap.payorName = payorName;
            royaltyLineItemWrap.payorAccName = payorAccName;
            
            if(revenuePropertyWellMap.containsKey(revenueProperty)){
                List<String> wells = new List<String>(revenuePropertyWellMap.get(revenueProperty));
                royaltyLineItemWrap.wellName = String.join(wells,',');
            }else if(nonWellRevenueProperties.contains(revenueProperty)){
                royaltyLineItemWrap.wellName = 'Non Well Line Item';
            }else{
                royaltyLineItemWrap.wellName = '';
            }
            royaltyLineItemWrap.numberOfLineItems = revenuePropertyMap.get(revenueProperty).size();
            royaltyLineItemWrap.rliIds = revenuePropertyMap.get(revenueProperty);
            royaltyLineItemWrap.revenueProperty = revenuePropertyRecMap.get(revenueProperty);
            royaltyLineItemWrapList.add(royaltyLineItemWrap);
        }
        return royaltyLineItemWrapList; 
    }

    /***********
    * MethodName: getSearchResults
    * parameters: Search String
    * ReturnType: List of Well records 
    * Description: This method is used to fetch Well Records that are similar to the the search screen provided by the user.
    ***********/    
    @AuraEnabled
    public static List<Well__c> getSearchResults(String searchString){
        List<Well__c> wellNames = new List<Well__c>();
        //Escape special characters for SOSL search - order of replacement matters - if you replace all backslashes late, you will end up with double backslashes.
        //searchString = searchString.replaceAll('[|,|.|\\,||"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]', '-');
        searchString = searchString.replace('\\', '\\');
        searchString = String.escapeSingleQuotes(searchString);
        searchString = searchString.replace('-', '\\-');
        searchString = searchString.replace('+', '\\+');
        searchString = searchString.replace('&', '\\&');
        searchString = searchString.replace('|', '\\|');
        searchString = searchString.replace('!', '\\!');
        searchString = searchString.replace('{', '\\{');
        searchString = searchString.replace('}', '\\}');
        searchString = searchString.replace('[', '\\[');
        searchString = searchString.replace(']', '\\]');
        searchString = searchString.replace('(', '\\(');
        searchString = searchString.replace(')', '\\)');
        searchString = searchString.replace('^', '\\^');
        searchString = searchString.replace('~', '\\~');
        searchString = searchString.replace('*', '\\*');
        searchString = searchString.replace(':', '\\:');
        searchString = searchString.replace('\"', '\\"');
        
        String searchQuery = 'FIND {' + searchString + '} IN ALL FIELDS RETURNING Well__c (Id,Name, API10__c, Current_Operator_Name__c, County__c, State__c) LIMIT 50';
        
        List<List<SObject>>searchList = Search.query(searchQuery);
        for(SObject currentSObject:searchList[0]){
            Well__c currentWell = (Well__c)currentSObject;
            wellNames.add(currentWell);
        }
        return wellNames;
    }

        /***********
    * MethodName: associateWell
    * parameters: Well Id,PropertyName,List of Royalty Line Items
    * ReturnType: void
    * Description: This method is associate Well Record to each royalty line items provided in the parameter. 
    * 			This method  also saves the RoapertyName vs Api10 mapping in custom object mappingMetadata__c
    ***********/ 
    @AuraEnabled
    public static void associateWells(List<String> wellIds,String propertyName,List<String> rliIds,boolean isNonWellItem){
	String revenuePropertyId = propertyName;
        system.debug(revenuePropertyId);
        if(!isNonWellItem){ 
            List<revenuePropertyWellAllocation__c> rpwList = [Select Id from revenuePropertyWellAllocation__c where revenueProperty__c =: revenuePropertyId];
            if(!rpwList.isEmpty()){
                delete rpwList;
            }
            rpwList = new List<revenuePropertyWellAllocation__c>();
            List<String> wellNames = new List<String>();
            for(Well__c well : [Select Id,Name from Well__c where Id IN: wellIds]){
                rpwList.add(new revenuePropertyWellAllocation__c(
                    well__c = well.Id,revenueProperty__c = revenuePropertyId,splitpercent__c=(decimal.valueof(1)/wellIds.size()).setScale(2)
                ));
                wellNames.add(well.Name);
            }
            if(!rpwList.isEmpty()){
                insert rpwList;
            }
            List<sobject> sobjectList = new List<sObject>();
            List<Royalty_Line_Item__c> rliList = [Select Id from Royalty_Line_Item__c where revenueProperty__c =: revenuePropertyId];
            for(Royalty_Line_Item__c rli:rliList){
                rli.revenueAllocated__c = true;
            }
            sobjectList.addAll(rliList);

            revenueProperty__c rp = new revenueProperty__c(Id = revenuePropertyId,wells__c=String.join(wellNames,','));
            sobjectList.add(rp);
            update sobjectList;
        }else{
            revenueProperty__c revenueProperty = new revenueProperty__c(id = revenuePropertyId,isNonWellRevenueProperty__c=true);
            update revenueProperty;
            List<Royalty_Line_Item__c> rliList = [Select Id from Royalty_Line_Item__c where revenueProperty__c =: revenuePropertyId];
            for(Royalty_Line_Item__c rli:rliList){
                rli.revenueAllocated__c = true;
                rli.isNonWellLineItem__c = true;
            }
            update rliList;
        }
    }
    /***********
    * MethodName: getRLIData
    * parameters: List of Royalty Line Items' Ids
    * ReturnType: void
    * Description: This method returns the Royalty line Items based on the Ids passed from parameter 
    ***********/
    @AuraEnabled
    public static List<Royalty_Line_Item__c> getRLIData(List<String> rliIds){
        List<Royalty_Line_Item__c> rliList = [Select Id, Name, propertyName__c, Property_Id__c, WellNames__c, Well__r.Name,Product_Category__c, Production_Month__c, grossVolumeActual__c, revenueAllocated__c , lineItemDecimal__c,grossValueActual__c,grossTaxesActual__c,grossAdjustmentsActual__c,ownerNetValueActual__c,Royalty_Check__c from Royalty_Line_Item__c Where Id In: rliIds];
        return rliList;
    }
    /***********
    * MethodName: getRecords
    * parameters: Royalty Check Id, pageSize,PageNum,FieldName,SortDirection
    * ReturnType: wrapper
    * Description: This method fetches Royalty line Items for the given Royalty Check 
    ***********/
    @auraEnabled
    public static wrapper getRecords(String rcId,Integer pageSize, Integer pageNum,String fieldName,String sortDirection){
        
        Royalty_Check__c rcRec = [Select Id,totalrevenueallocated__c,of_Allocated_Line_Items__c,of_Unallocated_Line_Items__c From Royalty_Check__c Where Id =:rcId];
        List<Royalty_Line_Item__c> totalrecords = [Select Id from Royalty_Line_Item__c where Royalty_Check__c=:rcId];
        
        List<Royalty_Line_Item__c> totalAllocatedrecords = [Select Id from Royalty_Line_Item__c Where revenueAllocated__c = true AND Royalty_Check__c=:rcId];
        system.debug( rcId+'--'+pageSize+'--'+pageNum+'--'+fieldName+'--'+sortDirection);     
        String queryStr ='Select Id, Name, WellNames__c,Product_Category__c, Production_Month__c, revenueAllocated__c, lineItemDecimal__c,GrossVolumeActual__c,GrossValueActual__c,GrossTaxesActual__c,grossAdjustmentsActual__c,ownerNetValueActual__c,Royalty_Check__c,propertyName__c from Royalty_Line_Item__c Where Royalty_Check__c =\''+rcid+'\' Order By '+fieldName +' '+ sortDirection+' NULLS Last Limit '+ string.valueOf(pageSize) + ' OFFSET '+ string.valueOf((pageNum-1)*pageSize);
        List<Royalty_Line_Item__c> sobjList = Database.query(queryStr);
        wrapper wrap = new wrapper();
        wrap.royaltyLineItems = sobjList;
        wrap.royaltyLineItem = new Royalty_Line_Item__c();
        Integer totalPagesInt = 0;
        if(totalrecords.size()>0){
            totalPagesInt = totalrecords.size()/pageSize;
        }
        if(math.mod(totalrecords.size(),pageSize) != 0){
            totalPagesInt +=1;
        }
        wrap.totalPages = totalPagesInt;
        wrap.totalRevenueAllocated= (rcRec.totalrevenueallocated__c==null)?0:rcRec.totalrevenueallocated__c.setScale(2);
        wrap.totalLineItems =totalrecords.size();
        wrap.totalAllocatedLineItems = (rcRec.of_Allocated_Line_Items__c==null)?0:Integer.valueOf(rcRec.of_Allocated_Line_Items__c);
        return wrap;
    }

	@auraEnabled
    public static wrapper getFilteredRecords(String rcId,Integer pageSize, Integer pageNum,String fieldName,String sortDirection, String searchTerm, Integer searchCounter){
        List<String> terms = searchTerm.split('\\s');
        List<String> newTerms = new List<String>();
		List<Id> royaltyLineItemIds = new List<Id>();
		List<Id> revenuePropertyIds = new List<Id>();
		for(String term : terms)		
        {
            newTerms.add('*' + term + '*');
        }

        String newTerm = String.join(newTerms,' AND ');
		System.debug(newTerm);
		List<List<revenueProperty__c>> revenuePropertySearchResults = [FIND :newTerm IN ALL fields Returning revenueProperty__c(Id Order By Id)];
		for(revenueProperty__c revenueProperty: revenuePropertySearchResults[0]){
			revenuePropertyIds.add(revenueProperty.Id);
		}
		System.debug('rcId value is: ' + rcId);
		List<List<Royalty_Line_Item__c>> lineItemSearchResults = [FIND :newTerm IN ALL fields Returning Royalty_Line_Item__c(Id WHERE Royalty_Check__c = :rcId Order by Id)];
		System.debug('lineItemSearchResults are:');
		System.debug(lineItemSearchResults);
		for(Royalty_Line_Item__c lineItem: lineItemSearchResults[0]){
			royaltyLineItemIds.add(lineItem.Id);
		}
        //Royalty_Check__c rcRec = [Select Id,totalrevenueallocated__c,of_Allocated_Line_Items__c,of_Unallocated_Line_Items__c From Royalty_Check__c Where Id =:rcId];
        //List<Royalty_Line_Item__c> totalrecords = [Select Id from Royalty_Line_Item__c where Royalty_Check__c=:rcId];
        
        //List<Royalty_Line_Item__c> totalAllocatedrecords = [Select Id from Royalty_Line_Item__c Where revenueAllocated__c = true AND Royalty_Check__c=:rcId];
        //system.debug( rcId+'--'+pageSize+'--'+pageNum+'--'+fieldName+'--'+sortDirection);     
        String queryStr ='Select Id, Name, WellNames__c,Product_Category__c, Production_Month__c, revenueAllocated__c, lineItemDecimal__c,GrossVolumeActual__c,GrossValueActual__c,GrossTaxesActual__c,grossAdjustmentsActual__c,ownerNetValueActual__c,Royalty_Check__c,propertyName__c from Royalty_Line_Item__c Where (Id IN :royaltyLineItemIds OR revenueProperty__c IN :revenuePropertyIds) AND royalty_Check__c = :rcId Order By '+fieldName +' '+ sortDirection+' NULLS Last Limit '+ string.valueOf(pageSize) + ' OFFSET '+ string.valueOf((pageNum-1)*pageSize);
		String countQueryStr = 'Select count() from Royalty_Line_Item__c Where (Id IN :royaltyLineItemIds OR revenueProperty__c IN :revenuePropertyIds) AND royalty_Check__c = :rcId';
		String countAllocatedQueryStr = 'Select count() from Royalty_Line_Item__c Where (Id IN :royaltyLineItemIds OR revenueProperty__c IN :revenuePropertyIds) AND royalty_Check__c = :rcId AND revenueAllocated__c = true';
		System.debug(queryStr);
		Integer totalRecords = Database.countQuery(countQueryStr);
		Integer totalAllocatedRecords = Database.countQuery(countAllocatedQueryStr);
		System.debug('total records count is: ' + totalRecords + ' total Allocated records count is: ' + totalAllocatedRecords);

		List<Royalty_Line_Item__c> sobjList = Database.query(queryStr);
        wrapper wrap = new wrapper();
        wrap.royaltyLineItems = sobjList;
        wrap.royaltyLineItem = new Royalty_Line_Item__c();
        Integer totalPagesInt = 0;
        if(totalrecords>0){
            totalPagesInt = totalrecords/pageSize;
        }
        if(math.mod(totalrecords,pageSize) != 0){
            totalPagesInt +=1;
        }
        wrap.totalPages = totalPagesInt;
        //wrap.totalRevenueAllocated= (rcRec.totalrevenueallocated__c==null)?0:rcRec.totalrevenueallocated__c.setScale(2);
        wrap.totalLineItems =totalrecords;
        wrap.totalAllocatedLineItems = totalAllocatedRecords;
		wrap.searchCounter = searchCounter;
		return wrap;
		
    }

    @AuraEnabled
    public static void deleteLineItem(Id liId){
        Royalty_line_item__c rli = [Select Id from Royalty_line_item__c where Id=:liId limit 1];
        delete rli;
    }
    @AuraEnabled
    public static String updateRevenueProperty(String recordId, List<String> wellIds, boolean isNonWellItem){
        associateWells(wellIds,recordId,null,isNonWellItem);
        return 'success';
    }
    @AuraEnabled
    public static List<Well__c> getSelectedValues(String api10Values){
        try{
            Set<String> wellIds = new Set<String>();
            for(RevenuePropertyWellAllocation__c rpw : [Select splitPercent__c, well__c from RevenuePropertyWellAllocation__c where RevenueProperty__c =: api10Values]){
                wellIds.add(rpw.well__c);
            }
            List<Well__c> wellList = [Select Id,Name,API10__c,Current_Operator__c,
                                      Current_Operator__r.Name, wellStatus__c,
                                      Current_Operator_Name__c,County__c, State__c
                                     from Well__c where Id in: wellIds];
            return wellList;
        }catch(Exception e){
            throw new AuraHandledException('Error encountered in getWellList');
        }
    }

    public class wrapper{
        @AuraEnabled
        public List<Royalty_Line_Item__c> royaltyLineItems{get;set;}
        @AuraEnabled
        public Royalty_Line_Item__c royaltyLineItem{get;set;}
        @AuraEnabled
        public Decimal totalRevenueAllocated{get;set;}
        @AuraEnabled
        public Integer totalLineItems{get;set;}
        @AuraEnabled
        public Integer totalAllocatedLineItems{get;set;}
        @AuraEnabled
        public Integer totalPages{get;set;}
		@AuraEnabled
		public Integer searchCounter{get;set;}
    }
    
    public class royaltyLineItemWrapper{
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String wellName {get;set;}
        @AuraEnabled
        public integer numberOfLineItems{get;set;}
        @AuraEnabled
        public Set<String> rliIds{get;set;}
        @AuraEnabled
        public revenueProperty__c revenueProperty{get;set;}
        @AuraEnabled
        public String payorName{get;set;}
        @AuraEnabled
        public String payorAccName{get;set;}

 		
    }
    
}