//Created by John Gorrell December 2019
//Code coverage provided by projectPricingTest.cls

public class tractProjectAOIListAura  {

	@AuraEnabled
	public static projectTractsResult getTractProjectAOIs(String recordId){
		projectTractsResult result = new projectTractsResult();
		result.projectTracts = [SELECT aoiMaxOtgPrice__c, aoiMaxOtgPricePerAcre__c, aoiTargetOtgPrice__c, aoiTargetOtgPricePerAcre__c,
									grossAcresWithinAoi__c, netAcreageUnits__c, netAcresWithinAoi__c, percentageOfAcreageInAoi__c, pricingNetAcres__c, projectAoi__c, Name, Tract__c, tractGrossAcres__c,
									tractNetAcres__c, pricingPercentAcres__c, Id, projectAoi__r.Name
								FROM Project_AOI_Tract__c
								WHERE Tract__c = :recordId];
		for (Project_AOI_Tract__c projectTract: result.projectTracts){
			result.sumMaxPrice = result.sumMaxPrice + projectTract.aoiMaxOtgPrice__c;
			result.sumNetAcres = result.sumNetAcres + projectTract.pricingNetAcres__c;
			result.sumPercentAcres = result.sumPercentAcres + projectTract.pricingPercentAcres__c*100;
			result.sumTargetPrice = result.sumTargetPrice + projectTract.aoiTargetOtgPrice__c;
		}
		if(result.sumNetAcres > 0){
			result.maxPPA = result.sumMaxPrice/result.sumNetAcres;
			result.targetPPA = result.sumTargetPrice/result.sumNetAcres;
		}
		return result;
		
		/*finalResult result = new finalResult();
		List<Tract__c> tractList = [SELECT ID FROM Tract__c WHERE ID = :recordId];
		Map<String, Map<String, tractUtility.tractProjectPricing>> resultSet = tractUtility.getTractsPricing(tractList);
		System.debug(resultSet);
		System.debug(recordId);
		Map<String, tractUtility.tractProjectPricing> tractResults = resultSet.get(recordId);
		for(String projectTract:tractResults.keySet()){
			System.debug ('Adding pricing result for ' + projectTract);
			tractUtility.tractProjectPricing pricing = tractResults.get(projectTract);
			tractPricingResult newResult = new tractPricingResult();
			newResult.projectTractId = projectTract;
			newResult.projectTractName = pricing.projectTract.Name;
			newResult.projectTractLink = Url.getSalesforceBaseUrl().toExternalForm() + '/' + pricing.projectTract.Id;
			newResult.projectAOIId = pricing.projectAOI.Id;
			newResult.projectAOIName = pricing.projectAOI.Name;
			System.debug('pricing.projectAOI.Name value is: ' + newResult.projectAOIName);
			newResult.projectAOILink = Url.getSalesforceBaseUrl().toExternalForm() + '/' + pricing.projectAOI.Id;
			newResult.percentAcres = pricing.projectTract.percentageOfAcreageInAOI__c/100;
			newResult.netAcres = pricing.projectTract.netAcresWithinAOI__c;
			newResult.aoiSuggPPA = pricing.projectAOI.aoiSuggestedOtgPrice__c;
			newResult.aoiTargetPPA = pricing.projectAOI.aoiTargetOtgPrice__c;
			newResult.aoiMaxPPA = pricing.projectAOI.aoiMaxOtgPrice__c; 
			newResult.aoiTractTargetPrice = pricing.aoiTractTargetOTGPrice;
			newResult.aoiTractMaxPrice = pricing.aoiTractMaxOTGPrice;
			result.pricingResults.add(newResult);
			System.debug(newResult);
		}

		Map<String, tractUtility.tractPricing> defaultPricing = tractUtility.getTractsDefaultPricing(tractList);
		tractUtility.tractPricing currentTractDefaultPricing = defaultPricing.get(recordId);
		result.percentAcres = currentTractDefaultPricing.percentCovered;

		result.targetPrice = currentTractDefaultPricing.targetTotalOTGCost;
		result.maxPrice = currentTractDefaultPricing.maxTotalOTGCost;
		result.netAcres = currentTractDefaultPricing.totalIncludedAcres;
		result.targetPPA = currentTractDefaultPricing.targetOTGCostPerAcre;
		result.maxPPA = currentTractDefaultPricing.maxOTGCostPerAcre;

		System.debug(result);
		return result;
		*/
	}

	public class projectTractsResult{
		@AuraEnabled public List<Project_AOI_Tract__c> projectTracts {get; set;}
		@AuraEnabled public Double sumNetAcres {get; set;}
		@AuraEnabled public Double sumPercentAcres {get; set;}
		@AuraEnabled public Double sumTargetPrice {get; set;}
		@AuraEnabled public Double targetPPA {get; set;}
		@AuraEnabled public Double sumMaxPrice {get; set;}
		@AuraEnabled public Double maxPPA {get; set;}


		public projectTractsResult(){
		projectTracts = new List<Project_AOI_Tract__c>();
		sumNetAcres = 0;
		sumPercentAcres = 0;
		sumTargetPrice = 0;
		targetPPA = 0;
		sumMaxPrice = 0;
		maxPPA = 0;
		}

	}
/*
	public class finalResult{
		@AuraEnabled public List<tractPricingResult> pricingResults {get; set;}
		@AuraEnabled public Double percentAcres {get; set;}
		@AuraEnabled public Double netAcres {get; set;}
		@AuraEnabled public Double targetPrice {get; set;}
		@AuraEnabled public Double maxPrice {get; set;}
		@AuraEnabled public Double targetPPA {get; set;}
		@AuraEnabled public Double maxPPA {get; set;}

		public finalResult(){
			pricingResults = new List<tractPricingResult>();
			netAcres = 0;
			percentAcres = 0;
			targetPrice = 0.00;
			maxPrice = 0.00;
			targetPPA = 0.00;
			maxPPA = 0.00;
		}
	}

	public class tractPricingResult{
		@AuraEnabled public String projectTractId {get; set;}
		@AuraEnabled public String projectTractName {get; set;}
		@AuraEnabled public String projectTractLink {get; set;}
		@AuraEnabled public String projectAOIId {get; set;}
		@AuraEnabled public String projectAOIName {get; set;}
		@AuraEnabled public String projectAOILink {get; set;}
		@AuraEnabled public Double percentAcres {get; set;}
		@AuraEnabled public Double netAcres {get; set;}
		@AuraEnabled public Decimal aoiSuggPPA {get; set;}
		@AuraEnabled public Decimal aoiTargetPPA {get; set;}
		@AuraEnabled public Decimal aoiMaxPPA {get; set;}
		@AuraEnabled public Decimal aoiTractTargetPrice {get; set;}
		@AuraEnabled public Decimal aoiTractMaxPrice {get; set;}

		public tractPricingResult(){
			projectTractId = '';
			projectTractName = '';
			projectTractLink = '';
			projectAOIId = '';
			projectAOIName = '';
			projectAOILink = '';
			netAcres = 0;
			percentAcres = 0;
			aoiSuggPPA = 0;
			aoiTargetPPA = 0;
			aoiMaxPPA = 0; 
			aoiTractTargetPrice = 0;
			aoiTractMaxPrice = 0;
		}
	}
*/
}