public with sharing class OppExtension {
    public List<Opportunity_Tract__c> oppTractList {get; set;}
	public List<Project_AOI_Tract__c> projectAOITractList {get; set;}
    public Boolean isAcquisition {get; set;}
    public Boolean isDivestiture {get; set;}


    @AuraEnabled(Cacheable=true)
    public static String getOppType(Id oppId) {
        Opportunity opp = [SELECT Id, RecordType.Name FROM Opportunity WHERE Id =: oppId];
        return opp.RecordType.Name;
    }

    @AuraEnabled(Cacheable=true)
    public static List<Opportunity_Tract__c> getTracts(Id recordId, String sObjectName) {
		String oppId = '';
		if(sObjectName == 'Opportunity'){
			oppId = recordId;
		}
		else if(sObjectName == 'Evaluation__c'){
			Evaluation__c currentEval = [SELECT Id, Opportunity__c FROM Evaluation__c WHERE Id = :recordId LIMIT 1];
			oppId = currentEval.opportunity__c;
		} 
        List<Opportunity_Tract__c> ots = [SELECT Tract__r.Id,Tract__c,Tract__r.Name,Tract__r.Full_Legal_Name__c,Tract__r.Instrument_Type__c,            
				OTG_Cost__c, OTG_Cost_Per_Acre__c, Total_Cost__c,Total_Cost_Per_Acre__c,Tract__r.Notes__c, Tract__r.titleSourceType__c,
                FMV_Per_Acre__c, Fair_Market_Value__c, Instrument_Type__c, Tract_Acres__c,tract__r.depth__c,
                Gain_on_Asset__c, Tract__r.percentCovered__c, Tract__r.targetPrice__c, Tract__r.maxPrice__c, Tract__r.targetPPA__c, Tract__r.maxPPA__c,
				Tract__r.netAcreageUnits__c, Name, Id, unitPrice__c, totalPrice__c, askUnitPrice__c, askTotalPrice__c
        FROM Opportunity_Tract__c WHERE Opportunity__c =: oppId
        ORDER BY Opportunity__r.Type,Opportunity__r.PSA_Date__c DESC
        ];
        return ots;
    }

	@AuraEnabled
	public static string updatePricing(Object data){
		List<Opportunity_Tract__c> updateOTs = (List<Opportunity_Tract__c>) JSON.deserialize(JSON.serialize(data), List<Opportunity_Tract__c>.class);
		try{
			update updateOTs;
			return 'Success: Pricing updated successfully';
		}
		catch (Exception e){
			return 'The following exception has occurred: ' + e.getMessage();
		}
	}

	//@AuraEnabled(Cacheable=true)
    //public static List<Opportunity_Tract__c> getTracts(Id oppId) {
	//	return getTracts(oppId, 'Opportunity');
    //}

	
    public OppExtension(ApexPages.StandardController oppController)
    {
        Id oppId = oppController.getRecord().Id;
        String oppType = getOppType(oppId);
		String sObjectName = oppController.getRecord().getSObjectType().getDescribe().getName();
        oppTractList = getTracts(oppId, sObjectName);
        isAcquisition = (oppType == 'Acquisition');
        isDivestiture = (oppType == 'Divestiture');
    }

}