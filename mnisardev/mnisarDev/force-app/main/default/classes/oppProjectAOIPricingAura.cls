//Created by John Gorrell December 2019
//Code coverage provided by projectPricingTest.cls

public class oppProjectAOIPricingAura  {

	@AuraEnabled
	public static oppProjectPricing getOppPricing2 (String recordId){
		oppProjectPricing result = new oppProjectPricing();
		List<Project_AOI_Tract__c> oppProjectTracts = new List<Project_AOI_Tract__c>();
		List<Tract__c> relatedTracts = new List<Tract__c>();
		relatedTracts = [SELECT Id, netAcres__c 
										FROM Tract__c 
										WHERE Id in (SELECT Tract__c FROM Opportunity_Tract__c WHERE Opportunity__c = :recordId)];
		oppProjectTracts = [SELECT Id, aoiMaxOtgPrice__c, aoiTargetOtgPrice__c, pricingPercentAcres__c, pricingNetAcres__c, Tract__r.netAcres__c
						    FROM Project_AOI_Tract__c 
							WHERE Tract__c in (SELECT Tract__c FROM Opportunity_Tract__c WHERE Opportunity__c = :recordId)];
		for(Project_AOI_Tract__c oppProjectTract: oppProjectTracts){
			//result.suggestedPrice = result.suggestedPrice + oppProjectTract.aoiSuggestedOtgPrice__c;
			result.targetPrice = result.targetPrice + oppProjectTract.aoiTargetOtgPrice__c;
			result.maxPrice = result.maxPrice + oppProjectTract.aoiMaxOtgPrice__c;
			result.netAcres = result.netAcres + oppProjectTract.pricingNetAcres__c;
		}
		for(Tract__c relatedTract : relatedTracts){
			if(relatedTract.netAcres__c <> null){
				result.totalAcres = result.totalAcres + relatedTract.netAcres__c;
			}
		}
		if(result.netAcres > 0){
			//result.suggestedPPA = result.suggestedPrice/result.netAcres;
			result.targetPPA = result.targetPrice/result.netAcres;
			result.maxPPA = result.maxPrice/result.netAcres;
		}

		if(result.totalAcres > 0){
			result.percentCovered = result.netAcres/result.totalAcres;
		}


		return result;
	}

	public class oppProjectPricing{
		@AuraEnabled public Double percentCovered {get; set;}
		@AuraEnabled public Double netAcres {get; set;}
		@AuraEnabled public Double totalAcres {get; set;}
		@AuraEnabled public Double suggestedPPA {get; set;}
		@AuraEnabled public Double suggestedPrice {get; set;}
		@AuraEnabled public Double targetPPA {get; set;}
		@AuraEnabled public Double targetPrice {get; set;}
		@AuraEnabled public Double maxPPA {get; set;}
		@AuraEnabled public Double maxPrice {get; set;}

		public oppProjectPricing(){
			percentCovered = 0;
			netAcres = 0;
			totalAcres = 0;
			suggestedPPA = 0;
			suggestedPrice = 0;
			targetPPA = 0;
			targetPrice = 0;
			maxPPA = 0;
			maxPrice = 0;
		}
	}

}