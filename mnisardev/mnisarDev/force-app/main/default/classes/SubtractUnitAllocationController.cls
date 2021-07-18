public class SubtractUnitAllocationController {

    /**
    * @description 
    * @author Jade Tran
    * @param recordId 
    * @return uaWrapper 
    **/
    @AuraEnabled
    public static uaWrapper getRecords(Id recordId, String acctName){
        List<unitAllocation__c> uaList = new List<unitAllocation__c>();

        if(recordId.getSObjectType().getDescribe().getName() =='Tract__c' ){
            List<Subtract__c> subtractList = [Select Id from subtract__c where Tract__c =:recordId];
            uaList = [Select id,Name,unit__c,unit__r.Name,Subtract__c,Subtract__r.name,
                       subtractGrossAcres__c, uaSubtractGrossAcres__c,unitGrossAcres__c,allocationPercentage__c,
                       unitNRI__c,unit__r.GIS_Unit_Name__c,unit__r.Unit_Type__c,
                       Subtract__r.Tract__r.Name,
                       Subtract__r.Tract__c,Subtract__r.Tract__r.Account__c,
                       Subtract__r.Tract__r.Account__r.Name
                       from unitAllocation__c where subtract__c In: subtractList and Inactive__c = false];
        }else if(recordId.getSObjectType().getDescribe().getName() =='Subtract__c' ){
            uaList = [Select id,Name,unit__c,unit__r.Name,Subtract__c,Subtract__r.name,
                       subtractGrossAcres__c, uaSubtractGrossAcres__c,unitGrossAcres__c,allocationPercentage__c,
                       unitNRI__c,unit__r.GIS_Unit_Name__c,
                       unit__r.Unit_Type__c,Subtract__r.Tract__r.Name,
                       Subtract__r.Tract__c,Subtract__r.Tract__r.Account__c,
                       Subtract__r.Tract__r.Account__r.Name
                       from unitAllocation__c where subtract__c =: recordId and Inactive__c = false];
        }else if(recordId.getSObjectType().getDescribe().getName() =='Unit__c'){
            if (acctName !=''){
			    acctName = '%'+acctName+'%';
                uaList = [Select id,Name,unit__c,unit__r.Name,Subtract__c,Subtract__r.name,
                        subtractGrossAcres__c, uaSubtractGrossAcres__c,unitGrossAcres__c,allocationPercentage__c, unit__r.GIS_Unit_Name__c,
                        unitNRI__c,Subtract__r.Tract__r.Name, Subtract__r.Tract__r.CreatedDate,
                        unit__r.Unit_Type__c,Subtract__r.Tract__c,Subtract__r.Tract__r.Account__c,
                        Subtract__r.Tract__r.Account__r.Name
                        from unitAllocation__c where unit__c =: recordId  and Subtract__r.Tract__r.Account__r.Name like :acctName and Inactive__c = false];
            }else{
                uaList = [Select id,Name,unit__c,unit__r.Name,Subtract__c,Subtract__r.name,
                        subtractGrossAcres__c, uaSubtractGrossAcres__c,unitGrossAcres__c,allocationPercentage__c, unit__r.GIS_Unit_Name__c,
                        unitNRI__c,Subtract__r.Tract__r.Name, Subtract__r.Tract__r.CreatedDate,
                        unit__r.Unit_Type__c,Subtract__r.Tract__c,Subtract__r.Tract__r.Account__c,
                        Subtract__r.Tract__r.Account__r.Name
                        from unitAllocation__c where unit__c =: recordId and Inactive__c = false];
            }
        }else if(recordId.getSObjectType().getDescribe().getName() =='Opportunity'){
            List<Subtract__c> subs = [SELECT Id FROM Subtract__c WHERE Tract__c IN
                                        (SELECT Tract__c FROM Opportunity_Tract__c WHERE Opportunity__c =: recordId)];
            
            uaList = [Select id,Name,unit__c,unit__r.Name,Subtract__c,Subtract__r.name,subtractGrossAcres__c, uaSubtractGrossAcres__c,unitGrossAcres__c,allocationPercentage__c,unitNRI__c,Subtract__r.Tract__r.Name,
                       Subtract__r.Tract__c,Subtract__r.Tract__r.Account__c,unit__r.GIS_Unit_Name__c,unit__r.Unit_Type__c,
                       Subtract__r.Tract__r.Account__r.Name from unitAllocation__c where subtract__c In: subs and Inactive__c = false];
        }
		else if(recordId.getSObjectType().getDescribe().getName() =='Evaluation__c'){
			Evaluation__c currentEval = [SELECT Id, Opportunity__c FROM Evaluation__c WHERE Id = :recordId LIMIT 1];
			return getRecords(currentEval.opportunity__c, '');
		}

		else if(recordId.getSObjectType().getDescribe().getName() =='Account'){
           
            
            uaList = [Select id,Name,unit__c,unit__r.Name,Subtract__c,Subtract__r.name,subtractGrossAcres__c, uaSubtractGrossAcres__c,unitGrossAcres__c,allocationPercentage__c,unitNRI__c,Subtract__r.Tract__r.Name,
                       Subtract__r.Tract__c,Subtract__r.Tract__r.Account__c,unit__r.GIS_Unit_Name__c,unit__r.Unit_Type__c,
                       Subtract__r.Tract__r.Account__r.Name from unitAllocation__c where subtract__r.Tract__r.Account__c =: recordId and Inactive__c = false];
        }else if(recordId.getSObjectType().getDescribe().getName() =='Well__c'){
            
            Well__c wellRec = [Select Id, unit__c from Well__c where Id =: recordId];

            uaList = [Select id,Name,unit__c,unit__r.Name,Subtract__c,Subtract__r.name,
                        subtractGrossAcres__c, uaSubtractGrossAcres__c,unitGrossAcres__c,allocationPercentage__c,
                        unitNRI__c,Subtract__r.Tract__r.Name,
                        Subtract__r.Tract__c,Subtract__r.Tract__r.Account__c,unit__r.GIS_Unit_Name__c,unit__r.Unit_Type__c,
                        Subtract__r.Tract__r.Account__r.Name from unitAllocation__c where unit__c =: wellRec.unit__c  and Inactive__c = false];
        }else if(recordId.getSObjectType().getDescribe().getName() =='GIS_Update_Request__c'){

            GIS_Update_Request__c record = [Select Id, Unit__c from GIS_Update_Request__c where Id=:recordId];
			if (acctName !=''){
			acctName = '%'+acctName+'%';
            uaList = [Select id,Name,unit__c,unit__r.Name,Subtract__c,Subtract__r.name,
                        subtractGrossAcres__c, uaSubtractGrossAcres__c,unitGrossAcres__c,allocationPercentage__c,
                        unitNRI__c,Subtract__r.Tract__r.Name,
                        Subtract__r.Tract__c,Subtract__r.Tract__r.Account__c,Inactive__c,CreatedDate,LastModifiedDate,
                        Subtract__r.Tract__r.Account__r.Name from unitAllocation__c where unit__c =: record.unit__c and Subtract__r.Tract__r.Account__r.Name like :acctName];
        }
		 else {
			 uaList = [Select id,Name,unit__c,unit__r.Name,Subtract__c,Subtract__r.name,
                        subtractGrossAcres__c, uaSubtractGrossAcres__c,unitGrossAcres__c,allocationPercentage__c,
                        unitNRI__c,Subtract__r.Tract__r.Name,
                        Subtract__r.Tract__c,Subtract__r.Tract__r.Account__c,Inactive__c,CreatedDate,LastModifiedDate,
                        Subtract__r.Tract__r.Account__r.Name from unitAllocation__c where unit__c =: record.unit__c];
		 }
		}
        uaWrapper sWrap = new uaWrapper();
        sWrap.sObjectName = recordId.getSObjectType().getDescribe().getName();
        sWrap.uaList  = uaList;
        return sWrap;
    }

    public class uaWrapper{
        @AuraEnabled
        public List<unitAllocation__c> uaList{get;set;}
        @AuraEnabled
        public string sObjectName{get;set;}
        
    }
}