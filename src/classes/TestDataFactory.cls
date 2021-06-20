@isTest
public with sharing class TestDataFactory {

	public static void dataSetup(){
		Profile userProfile = [Select ID, Name from Profile Where Name = :'Standard User' LIMIT 1];
		Profile adminProfile = [Select ID, Name from Profile Where Name = :'System Administrator' LIMIT 1];

		insert new SRPFieldHistoryConversionSettings__c(conversionSize__c = 1, defaultStartTime__c = 22, emailDistribution__c = 'test@test.com', minutesBetweenRuns__c = 5, deleteSObjectNameIndex__c = 'Tract__c', deleteSize__c = 1, referenceIdGroupSize__c = 1);

		List<LandGridTract__c> landGridTracts = createLandgridTracts(3);
        insert landGridTracts;

        List<Account> accounts = createAccounts(5);
        insert accounts;

        List<Tract__c> tracts = createTracts(landGridTracts,accounts[0]);
        insert tracts;

		List<Project_AOI__c> projectAOIs = createProjectAOIs(3);
		insert projectAOIs;

		List<Project_AOI_Tract__c> projectAOITracts = createProjectAOITracts(tracts, projectAOIs);
		insert projectAOITracts;

        List<Opportunity> opps = createOpportunities(1,accounts[0]);
        insert opps;

        List<Case> cases = createCases(5);
        insert cases;

        List<Opportunity_Tract__c> ots = createOppTracts(opps,tracts);
        insert ots;

		List<InventoryAsset__c> inventoryAssets = createInventoryAssets(ots, 1);
		insert inventoryAssets;

        /*List<Case_Tract__c> cts = createCaseTracts(cases,tracts);
        insert cts;*/

		
		
		List<User> adminUser = createUsers(1, adminProfile);
		insert adminUser;

		List<User> standardUsers = createUsers(5, userProfile);
		insert standardUsers;
		
		List<TitleWorkTracker__c> twts = createTWTs(landGridTracts, standardUsers, 5);
		insert twts;

		List<TitleWorkJob__c> twjs = createTWJs(twts, 5);
		insert twjs;

		List<TitleIntegrationJob__c> tpjs = createTPJs(twjs, landGridTracts, 5);
		insert tpjs;

		List<Evaluation__c> evals = createEvaluations(opps, standardUsers , 2);
		insert evals;

		/*List<TitleWorkTracker__c> twts = createTitleWorkTrackers(landGridTracts, standardUsers);
		insert twts;

		List<TitleWorkJob__c> twjs = createTitleWorkJobs(twts);
		insert twjs;
		*/
		List<diTexasPermitWithAcreage__c> diPermits = createDITexasPermits(10);
		insert diPermits;

		List<TaxRollOwner__c> taxRollOwners = createTaxRollOwners(5);
		insert taxRollOwners;

		List<RRCLease__c> rrcLeases = createRRCLeases(5, diPermits);
		insert rrcLeases;

		List<taxRollInterest__c> taxRollInterests = createTaxRollInterests(taxRollOwners, rrcLeases);
		insert taxRollInterests;

		List<Unit__c> units = createUnits(accounts, 5);
		insert units;

		List<Well__c> wells = createWells(units, 5);
		insert wells;

		List<Monthly_Production__c> mps = createMonthlyProductions(wells, 5);
		insert mps;

		List<Instrument__c> instruments = createInstruments(5);
		insert instruments;

		List<unitAllocation__c> uas = createUnitAllocations(units);
		insert uas;

		List<revenueEstimate__c> res = createRevenueEstimates(uas, mps, 10);
		insert res;

		List<GIS_Update_Request__c> gisUpdateRequests = createGISUpdateRequests(units, 5);
		insert gisUpdateRequests;

		List<AccountingIntegrationJob__c> aijs = createAccountingIntegrationJobs(5);
		insert aijs;

		List<AccountingInvestment__c> ais = createAccountingInvestments(5);
		insert ais;

		List<AccountingTransaction__c> ats = createAccountingTransactions(5, ais, aijs);
		insert ats;

		List<divisionOrder__c> divOrderLst = createDivisionOrders(5);
		insert divOrderLst;

		List<Opportunity_Case__c> oppCaseLstLst = createOpportunityCase(5, opps[0], cases[0]);
		insert oppCaseLstLst;
	}

    public static Id getLandGridTractRecordTypeId(String rtName)
    {
        Id TypeId = Schema.SObjectType.LandGridTract__c.getRecordTypeInfosByName().get(rtName).getRecordTypeId();
        return TypeId;
    }

    public static List<Opportunity> createOpportunities(Integer count, Account acc)
    {
        List<Opportunity> newOppItems = new List<Opportunity>();
        for (Integer i=0;i<count;i++)
        {
            Opportunity o = new Opportunity();
            o.Name = 'Opp'+i;
            o.CloseDate = Date.today()+30;
            o.Acquiring_Entity__c = acc.Id;
            o.StageName = 'Pending';
            newOppItems.add(o);
        }
        return newOppItems;
    }

	public static List<Opportunity_Case__c> createOpportunityCase(Integer count, Opportunity opp, Case cse)
    {
        List<Opportunity_Case__c> newOppCaseItems = new List<Opportunity_Case__c>();
        for (Integer i=0;i<count;i++)
        {
            Opportunity_Case__c oc = new Opportunity_Case__c();
			oc.case__c = cse.Id;
			oc.opportunity__c = opp.Id;
            newOppCaseItems.add(oc);
        }
        return newOppCaseItems;
    }

	public static List<Project_AOI__c> createProjectAOIs (Integer count){
		List<Project_AOI__c> result = new List<Project_AOI__c>();
		for(Integer i=0;i<count;i++){
			Project_AOI__c p = new Project_AOI__c();
			p.Name = 'TestProject' + i;
			//p.aoiSuggestedOtgPrice__c = 10*i;
			p.aoiTargetOtgPrice__c = 20*i;
			p.aoiMaxOtgPrice__c = 30*i;
			result.add(p);
		}
		return result;
	}

	public static List<Project_AOI_Tract__c> createProjectAOITracts(List<Tract__c> tracts, List<Project_AOI__c> projectAOIs){
		List<Project_AOI_Tract__c> result = new List<Project_AOI_Tract__c>();
		for(Tract__c tract: tracts){
			for(Project_AOI__c projectAOI : projectAOIs){
				Project_AOI_Tract__c pat = new Project_AOI_Tract__c();
				pat.Tract__c = tract.Id;
				pat.percentageOfAcreageInAoi__c = 10;
				pat.projectAoi__c = projectAOI.Id;
				result.add(pat);
			}
		}
		return result;
	}

    public static List<LandGridTract__c> createLandgridTracts(Integer count)
    {
        List<LandGridTract__c> newLandGridTracts = new List<LandGridTract__c>();
        for (Integer i=0;i<count;i++)
        {
            LandGridTract__c lt = new LandGridTract__c();
            lt.County__c = 'Howard'+count;
            lt.State__c = 'TX';
            lt.Block__c = count + ' T1S';
            lt.Name = lt.CombinedLegal__c;
            lt.RecordTypeId = getLandGridTractRecordTypeId('Texas (Section)');
            newLandGridTracts.add(lt);
        }
        for (Integer i=0;i<count;i++)
        {
            LandGridTract__c lt = new LandGridTract__c();
            lt.County__c = 'Arkansas'+count;
            lt.State__c = 'AR';
            lt.STR_Text__c = count+'S-3W';
            lt.Name = lt.CombinedLegal__c;
            lt.RecordTypeId = getLandGridTractRecordTypeId('PLSS States');
            newLandGridTracts.add(lt);
        }
        for (Integer i=0;i<count;i++)
        {
            LandGridTract__c lt = new LandGridTract__c();
            lt.County__c = 'Arkansas'+count;
            lt.State__c = 'AR';
            lt.STR_Text__c = count+'S-3W';
            lt.Name = lt.CombinedLegal__c;
            lt.RecordTypeId = getLandGridTractRecordTypeId('Texas (Abstract)');
            newLandGridTracts.add(lt);
        }
        // Tax Parcel States
        for (Integer i=0;i<count;i++)
        {
            LandGridTract__c lt = new LandGridTract__c();
            lt.County__c = 'Arkansas'+count;
            lt.State__c = 'AR';
            lt.STR_Text__c = count+'S-3W';
            lt.Name = lt.CombinedLegal__c;
            lt.RecordTypeId = getLandGridTractRecordTypeId('Tax Parcel States');
            newLandGridTracts.add(lt);
        }
        return newLandGridTracts;

    }

    public static List<Tract__c> createTracts(List<LandGridTract__c> landGridTracts, Account a)
    {
        // build tracts from Land Grid Tracts
        List<Tract__c> newTracts = new List<Tract__c>();
        for (LandGridTract__c lg : landGridTracts)
        {
            Tract__c tract = new Tract__c();
			tract.netAcres__c = 10;
            tract.Account__c = a.Id;
            newTracts.add(tract);
        }
        return newTracts;
    }

    // Creates tracts with LandGridTracts
    public static List<Tract__c> createTracts(Integer count, Account a)
    {
        List<LandGridTract__c> landGridTracts = createLandgridTracts(count);
        return createTracts(landGridTracts,a);
    }

    public static List<Account> createAccounts(Integer count)
    {
        List<Account> newAccounts = new List<Account>();
        for (Integer i = 0;i<count;i++)
        {
            Account a = new Account();
            a.Name = 'New Account'+i;
            newAccounts.add(a);
        }
        return newAccounts;
    }

    public static List<Case> createCases(Integer count)
    {
        List<Case> cases = new List<Case>();
        for (Integer i = 0;i<count;i++)
        {
            Case c = new Case(
                    Origin = 'Email',
                    Status = 'New'
            );
            cases.add(c);
        }
        return cases;
    }

    public static List<Opportunity_Tract__c> createOppTracts(List<Opportunity> opps, List<Tract__c> tracts)
    {
        // Creates a cartesian product of the cases and tracts input as Case Tracts

        Set<String> keys = new Set<String>();
        List<Opportunity_Tract__c> newOTs = new List<Opportunity_Tract__c>();
        for(Tract__c t : tracts)
        {
            for(Opportunity o : opps)
            {
                // Create UNIQUE combos only
                if (!keys.contains(o.Id + ':' + t.Id)) {
                    newOTs.add(new Opportunity_Tract__c(Opportunity__c=o.Id,Tract__c=t.Id));
                }
                keys.add(o.Id + ':' +t.Id);
            }
        }
        return newOTs;
    }

	public static List<TitleWorkTracker__c> createTWTs(List<LandGridTract__c> landGridTracts,  List<User> users, Integer count){
		List<TitleWorkTracker__c> response = new List<TitleWorkTracker__c>();
		for(Integer i = 0; i < count; i++){
			Integer lgtSelected = Integer.valueOf(Math.floor(Math.random() * landGridTracts.size())); 
			Integer userSelected = Integer.valueOf(Math.floor(Math.random() * users.size()));
			TitleWorkTracker__c twt = new TitleWorkTracker__c();
			twt.landGridTract__c = landGridTracts[lgtSelected].Id;
			twt.srpOwner__c = users[userSelected].Id;
			response.add(twt);
		}  
		return response;
	}

	public static List<TitleWorkJob__c> createTWJs(List<TitleWorkTracker__c> titleWorkTrackers, Integer count){
		List<TitleWorkJob__c> response = new List<TitleWorkJob__c>();
		for(Integer i = 0; i < count; i++){
			Integer twtSelected = Integer.valueOf(Math.floor(Math.random() * titleWorkTrackers.size())); 
			TitleWorkJob__c twj = new TitleWorkJob__c();
			twj.titleWorkTracker__c = titleWorkTrackers[twtSelected].Id;
			twj.srpOwner__c = titleWorkTrackers[twtSelected].srpOwner__c;
			response.add(twj);
		}  
		return response;
	}

	public static List<TitleIntegrationJob__c> createTPJs(List<TitleWorkJob__c> titleWorkJobs, List<LandGridTract__c> landGridTracts, Integer count){
		List<TitleIntegrationJob__c> response = new List<TitleIntegrationJob__c>();
		for(Integer i = 0; i < count; i++){
			Integer twjSelected = Integer.valueOf(Math.floor(Math.random() * titleWorkJobs.size())); 
			Integer landGridCounter = 0;
			Integer lgtSelected = 0;
			for(LandGridTract__c lgt: landGridTracts){
				if(lgt.Id == titleWorkJobs[twjSelected].titleWorkTracker__c){
					lgtSelected = landGridCounter;
				}
				landGridCounter++;
			}
			TitleIntegrationJob__c tpj = new TitleIntegrationJob__c();
			tpj.titleWorkJob__c = titleWorkJobs[twjSelected].Id;
			tpj.landGridTract__c = landGridTracts[lgtSelected].Id;
			response.add(tpj);
		}  
		return response;
	}
	
	public static List<Evaluation__c> createEvaluations(List<Opportunity> relatedOpps, List<User> relatedUsers, Integer count){
		List<Evaluation__c> response = new List<Evaluation__c>();
		for(Integer i = 0; i < count; i++){
			Integer oppSelected = Integer.valueOf(Math.floor(Math.random() * relatedOpps.size())); 
			Integer userSelected = Integer.valueOf(Math.floor(Math.random() * relatedUsers.size())); 
			Evaluation__c eval = new Evaluation__c();
			eval.srpInvestmentTeamReviewer__c = relatedUsers[userSelected].Id;
			eval.opportunity__c = relatedOpps[oppSelected].Id;
			eval.status__c = 'Not Started';
			response.add(eval);
		}
		return response;
	}

	public static List<User> createUsers(Integer cnt, Profile inputProfile) {
		List<User> newUsers = new List<User> ();
		for (Integer i = 0; i<cnt; i++) {
			User newUser = new User(Alias = 'testUse' + i, Email = 'tester' + i + '@test.srp-ok.com',
			                        EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = inputProfile.Id,
			                        TimeZoneSidKey = 'America/Los_Angeles', UserName = inputProfile.Name.replaceAll('(\\s+)', '') + 'tester' + i + '@test.srp-ok.com');
			newUsers.add(newUser);
		}
		return newUsers;
	}

	/*public static List<TitleWorkTracker__c> createTitleWorkTrackers(List<LandGridTract__c> landGridTracts, List<User> owners){
		List<TitleWorkTracker__c> twts = new List<TitleWorkTracker__c>();
		for(LandGridTract__c lgt:landGridTracts){
			Integer ownerSelected = Integer.valueOf(Math.floor(Math.random() * owners.size()));
			TitleWorkTracker__c twt = new TitleWorkTracker__c(landGridTract__c = lgt.Id, srpOwner__c = owners[ownerSelected].Id, startDate__c = Date.today(), status__c='In Progress');
			twts.add(twt);
		}
		return twts;
	}

	

	public static List<TitleWorkJob__c> createTitleWorkJobs(List<TitleWorkTracker__c> twts){
		List<TitleWorkJob__c> twjs = new List<TitleWorkJob__c>();

		for(TitleWorkTracker__c twt:twts){
			TitleWorkJob__c twj = new TitleWorkJob__c(startDate__c = Date.today(), srpOwner__c = twt.srpOwner__c, status__c = 'In Progress', type__c= 'Landman', titleWorkTracker__c = twt.Id);
			twjs.add(twj);
		}
		return twjs;
	}*/

	public static List<diTexasPermitWithAcreage__c> createDITexasPermits(Integer count){
		List<diTexasPermitWithAcreage__c> response = new List<diTexasPermitWithAcreage__c>();
		for (Integer i = 0; i<count; i++) {
			diTexasPermitWithAcreage__c newPermit = new diTexasPermitWithAcreage__c(API10__c = 'API10_'+i, countyName__c='testCounty', leaseName__c='testLease'+i,
																					permitNumber__c = 'permit'+i, permittedAcres__c = i*10, rrcDistrict__c = 'district' + i,
																					rrcLeaseNumber__c = 'testLease' + String.valueOf(i+1), stateName__c = 'testState');
			response.add(newPermit);
		}
		return response;
	}

	public static List<TaxRollOwner__c> createTaxRollOwners(Integer Count){
		List<TaxRollOwner__c> response = new List<TaxRollOwner__c>();
		for (Integer i = 0; i<count; i++)  {
			TaxRollOwner__c newOwner = new taxRollOwner__c(ownerAddress__c = 'test Owner Address',
																  ownerCity__c = 'testCity', ownerName__c = 'testOwner' + String.valueOf(i+1), ownerState__c = 'testState' ,ownerZip__c = 'testZip');
			response.add(newOwner);
		}
		return response;
	}

	public static List<RRCLease__c> createRRCLeases(Integer Count, List<diTexasPermitWithAcreage__c> diPermits){
		List<RRCLease__c> response = new List<RRCLease__c>();
		for (Integer i = 0; i<count; i++){
			Integer permitSelected = Integer.valueOf(Math.floor(Math.random() * diPermits.size()));
			RRCLease__c newLease = new RRCLease__c(texasPermitWithAcre__c = diPermits[permitSelected].Id, legalDescription__c = 'test Legal Description' + String.valueOf(i+1), rrcLeaseNumber__c = 'testLease' + String.valueOf(i+1) );
			response.add(newLease);
		}
		return response;
	}

	public static List<taxRollInterest__c> createTaxRollInterests(List<taxRollOwner__c> owners, List<RRCLease__c> leases){
		List<taxRollInterest__c> response = new List<taxRollInterest__c>();
		for (TaxRollOwner__c owner: owners) {
			for(RRCLease__c lease: leases){
				taxRollInterest__c newInterest = new taxRollInterest__c(taxRollOwner__c = owner.Id, interest__c=0.5, interestType__c = 'OR', legalDescription__c = 'test Legal Description',  
																	  taxValue__c = 100 , year__c = System.now().year(), rrcLease__c = lease.Id );
				response.add(newInterest);
			}
		}
		return response;
	}

	public static List<Unit__c> createUnits(List<Account> accounts, Integer count){
		List<Unit__c> response = new List<Unit__c>();
		for (Integer i = 0; i<count; i++){
			Integer accountSelected = Integer.valueOf(Math.floor(Math.random() * accounts.size()));
			Unit__c unit = new Unit__c(Operator__c = accounts[accountSelected].Id);
			response.add(unit);
        }
        return response;
	}

	public static List<Well__c> createWells(List<Unit__c> units, Integer count){
		List<Well__c> response = new List<Well__c>();
		for (Integer i = 0; i<count; i++){
			Integer unitSelected = Integer.valueOf(Math.floor(Math.random() * units.size()));
			Well__c well = new Well__c(Unit__c = units[unitSelected].Id, Name='Test Well ' + i+1, API10__c = String.valueOf(i+1), Hole_Direction__c = 'Horizontal');
			response.add(well);
        }
        return response;
	}	

	public static List<Monthly_Production__c> createMonthlyProductions(List<Well__c> wells, Integer count){
		List<Monthly_Production__c> response = new List<Monthly_Production__c>();
		for (Integer i = 0; i<count; i++){
			Integer wellSelected = Integer.valueOf(Math.floor(Math.random() * wells.size()));
			Monthly_Production__c mp = new Monthly_Production__c(Unique_Key__c = wells[wellSelected].Id + '-' + i+1 + System.today().format(), Production_Date__c = System.today().addMonths(-13), Well__c = wells[wellSelected].Id);
			response.add(mp);
        }
        return response;
	}
	 
	 public static List<unitAllocation__c> createUnitAllocations(List<Unit__c> units){
        List<unitAllocation__c> response = new List<unitAllocation__c>();
        Integer count = 0;
		for(Subtract__c subtract : [Select Id from Subtract__c Limit 50]){
			Integer unitSelected = Integer.valueOf(Math.floor(Math.random() * units.size()));
            unitAllocation__c suaRec = new unitAllocation__c(allocationFactorOverride__c = count+1, Subtract__c = subtract.Id, unit__c = units[unitSelected].Id );
            response.add(suaRec);
			count++;
        }
        return response;
	}

	public static List<revenueEstimate__c> createRevenueEstimates(List<unitAllocation__c> uas, List<Monthly_Production__c> mps, Integer count){
		List<revenueEstimate__c> response = new List<revenueEstimate__c>();
		for (Integer i = 0; i<count; i++){
			Integer uaSelected = Integer.valueOf(Math.floor(Math.random() * uas.size()));
			Integer mpSelected = Integer.valueOf(Math.floor(Math.random() * mps.size()));
			revenueEstimate__c re = new revenueEstimate__c(unitAllocation__c = uas[uaSelected].Id, MonthlyProduction__c = mps[mpSelected].Id, SRP_Owned__c=false);
			response.add(re);
        }
        return response;
	}

	public static List<Instrument__c> createInstruments(Integer count){
		List<Instrument__c> response = new List<Instrument__c>();
		for (Integer i = 0; i<count; i++){
			Instrument__c newInstrument = new Instrument__c(Instrument_Number__c = String.valueOf(i), Lessee__c = 'Test Lessee ' + i+1, Lessor__c = 'Test Lessor ' + i + 1, termMeasure__c=null, extensionTermMeasure__c = null);
			response.add(newInstrument);
		}
		return response;
	}
	
	public static List<GIS_Update_Request__c> createGISUpdateRequests(List<Unit__c> units, Integer count){
		List<GIS_Update_Request__c> response = new List<GIS_Update_Request__c>();
		for (Integer i = 0; i<count; i++){
			Integer unitSelected = Integer.valueOf(Math.floor(Math.random() * units.size()));
			GIS_Update_Request__c request = new GIS_Update_Request__c(Unit__c = units[unitSelected].Id);
			response.add(request);
        }
        return response;
	}

	public static List<InventoryAsset__c> createInventoryAssets(List<Opportunity_Tract__c> ots, Integer count){
		List<InventoryAsset__c> response = new List<InventoryAsset__c>();
		for (Integer i = 0; i<count; i++){
			Integer otAcSelected = Integer.valueOf(Math.floor(Math.random() * ots.size()));
			Integer otSellSelected = Integer.valueOf(Math.floor(Math.random() * ots.size()));
			InventoryAsset__c request = new InventoryAsset__c(assetAcquisition__c = ots[otAcSelected].Id, assetSale__c = ots[otSellSelected].Id);
			response.add(request);
        }
        return response;
	}

	public static List<AccountingIntegrationJob__c> createAccountingIntegrationJobs(Integer count){
		List<AccountingIntegrationJob__c> response = new List<AccountingIntegrationJob__c>();
		for (Integer i = 0; i<count; i++){
			AccountingIntegrationJob__c request = new AccountingIntegrationJob__c(notes__c = 'This is test Job ' + String.valueOf(i));
			response.add(request);
        }
        return response;
	}

	public static List<AccountingInvestment__c> createAccountingInvestments(Integer count){
		List<AccountingInvestment__c> response = new List<AccountingInvestment__c>();
		for (Integer i = 0; i<count; i++){
			AccountingInvestment__c request = new AccountingInvestment__c(investmentID__c = 'LANCASTERHERE ' + String.valueOf(i));
			response.add(request);
        }
        return response;
	}

	public static List<AccountingTransaction__c> createAccountingTransactions(Integer count, List<AccountingInvestment__c> ais, List<AccountingIntegrationJob__c> aijs){
		List<AccountingTransaction__c> response = new List<AccountingTransaction__c>();
		for (Integer i = 0; i<count; i++){
			Integer aiSelected = Integer.valueOf(Math.floor(Math.random() * ais.size()));
			Integer aijSelected = Integer.valueOf(Math.floor(Math.random() * aijs.size()));
			AccountingTransaction__c request = new AccountingTransaction__c(transactionNumber__c = String.valueOf(i), investment__c = ais[aiSelected].Id, accountingIntegrationJob__c = aijs[aijSelected].Id, reconciliationType__c = 'Cost' );
			response.add(request);
        }
        return response;
	}

	public static List<divisionOrder__c> createDivisionOrders(Integer count)
    {
        List<divisionOrder__c> divOrders = new List<divisionOrder__c>();
        for (Integer i = 0;i<count;i++)
        {
            divisionOrder__c d = new divisionOrder__c(
				status__c = 'Not Started'
            );
            divOrders.add(d);
        }
        return divOrders;
    }
}