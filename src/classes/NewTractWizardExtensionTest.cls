@isTest
public class NewTractWizardExtensionTest {


static testMethod void testPage() {

        Account a = new Account();
        a.Name = 'Responsible Entity';
        insert a;

        LandGridTract__c lt = new LandGridTract__c();
    	lt.Name='Bexar 1-579348 TX';
        lt.County__c ='Bexar';
        insert lt;

		List<Opportunity> opps = TestDataFactory.createOpportunities(1,a);
        insert opps;


        Test.startTest();

        PageReference p = Page.NewTractWizard;
        Test.setCurrentPage(p);
        Tract__c newTract = new Tract__c();
        //newTract.SRP_Responsible_Entity__c = a.Id;

        ApexPages.StandardController c = new ApexPages.StandardController(newTract);
        NewTractWizardExtension ne = new NewTractWizardExtension(c);

        ne.saveNew();
		
		//Check for errors
		ApexPages.Message[] pageMessages = ApexPages.getMessages();
		for(ApexPages.Message message: pageMessages){
			System.debug(message);
		}
		
		System.assertEquals(2, pageMessages.size());

		//Clear error messages

		System.Test.clearApexPageMessages();
		System.debug('message size after clear is: ' + ApexPages.getMessages().size());
		newTract.Instrument_Type__c = 'Surface';
        newTract.Ford_Tract_Status__c = '103 - Outreach';

        ne.newTract = newTract;
		//Removing instrument per Quin (jdg 2-13-2020)
        //ne.updateInstrument();
        newTract.Instrument_Type__c = 'ORRI';
        newTract.LandGridTract__c = lt.Id;
		newTract.Account__c = a.Id;

        ne.newTract = newTract;
        ne.selLandGridTract = lt;
        ne.selLandGridTractId = lt.Id;
		ne.newTract.LandgridTract__c = lt.Id;

        /*ne.showInstrument = true;
        ne.updateInstrument();

        ne.showNewInstrument = false;
        ne.updateInstrument();

        ne.useExisting();
        ne.useNewInstrument();
		*/
        ne.save();
		
		pageMessages = ApexPages.getMessages();
		

		for(ApexPages.Message message: pageMessages){
			System.debug(message);
		}

		System.assertEquals(0, pageMessages.size());

		/*
        ne.newInstrument.Lessor__c = 'Billy';
        ne.newInstrument.Lessee__c = 'Willy';
        ne.saveNew();
		*/
        ne.newTract = new Tract__c();
        //ne.newTract.SRP_Responsible_Entity__c = a.Id;
        ne.selLandGridTract = lt;
        ne.selLandGridTractId = lt.Id;
        ne.newTract.LandgridTract__c = lt.Id;
        ne.save();

		pageMessages = ApexPages.getMessages();
		

		for(ApexPages.Message message: pageMessages){
			System.debug(message);
		}

		System.assertEquals(2, pageMessages.size());

        ApexPages.currentPage().getParameters().put('selectedValue', lt.Id);
        ne.setId();

		ApexPages.currentPage().getParameters().put('selectedOppValue', opps[0].Id);
		ne.setOppId();

		List<Account> accounts = [SELECT ID FROM Account];
		System.assertEquals(1, accounts.size());

		List<LandGridTract__c> landGridTracts = [SELECT ID FROM LandGridTract__c];
		System.assertEquals(1, landGridTracts.size());

		List<Tract__c> tracts = [SELECT ID FROM Tract__c];
		System.assertEquals(1, tracts.size());

		List<Subtract__c> subtracts = [SELECT ID FROM Subtract__c];
		System.assertEquals(1, subtracts.size());

        Test.stopTest();

    }

        
    }