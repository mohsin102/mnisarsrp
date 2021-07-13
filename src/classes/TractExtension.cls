public with sharing class TractExtension {
    public List<Opportunity_Tract__c> oppTractList {get; set;}

    @AuraEnabled(Cacheable=true)
    public static List<Opportunity_Tract__c> getOpps(Id tractId) {

        List<Opportunity_Tract__c> ots = [SELECT Opportunity__c, Opportunity__r.Name,
                Opportunity__r.StageName,
                Opportunity__r.Acquiring_Entity__r.Name,
                Opportunity__r.Acquiring_Entity__c,
                Opportunity__r.Type, Opportunity__r.Account.Name,
                Opportunity__r.AccountId,
                Opportunity__r.PSA_Date__c, Opportunity__r.CloseDate,
                Opportunity__r.Effective_Date__c,
                Opportunity__r.Owner.Name,Opportunity__r.OwnerId,
                Tract__r.Id,Tract__c,Tract__r.Name,Tract__r.Full_Legal_Name__c,Tract__r.Instrument_Type__c,
                OTG_Cost__c, OTG_Cost_Per_Acre__c, Total_Cost__c,Total_Cost_Per_Acre__c,
                FMV_Per_Acre__c, Fair_Market_Value__c, Instrument_Type__c, Tract_Acres__c,
                Gain_on_Asset__c, Id, Name, unitPrice__c, totalPrice__c, askUnitPrice__c, askTotalPrice__c
        FROM Opportunity_Tract__c WHERE Tract__c =: tractId
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

    public TractExtension(ApexPages.StandardController tractController)
    {
        Tract__c tract = (Tract__c)tractController.getRecord();
        oppTractList = getOpps(tract.Id);

    }
}