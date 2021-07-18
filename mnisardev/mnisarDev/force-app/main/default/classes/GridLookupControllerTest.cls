@isTest
public class GridLookupControllerTest {


    static testMethod void link_Tract() {
        Id [] fixedResults = new Id[1];
        LandGridTract__c lt = new LandGridTract__c();
        lt.Name='Bexar 1-579348 TX';
        lt.County__c ='Bexar';
        insert lt;

        Account a = new Account();
        a.Name = 'New Account';
        insert a;

        Tract__c tract = new Tract__c();
        //tract.SRP_Responsible_Entity__c = a.Id;
		tract.Account__c = a.Id;
        insert tract;



        Test.startTest();

        GridLookupController.linkTract(lt.Id,tract.Id);

        Test.stopTest();
    }


static testMethod void search_should_return_Tract() {
        Id [] fixedResults = new Id[1];
        LandGridTract__c lt = new LandGridTract__c();
        Id rtId = Schema.SObjectType.LandGridTract__c.getRecordTypeInfosByName().get('Texas (Abstract)').getRecordTypeId();
    	lt.Name='Bexar 1-579348 TX';
        lt.County__c ='Bexar';
        lt.RecordTypeId = rtId;
        lt.Block__c = 'T1N';
        lt.Section__c = '32';
        insert lt;

        LandGridTract__c lt2 = new LandGridTract__c();
        rtId = Schema.SObjectType.LandGridTract__c.getRecordTypeInfosByName().get('Texas (Section)').getRecordTypeId();
        System.debug('rt1'+rtId);
        lt2.Name='Howard 1-579348 TX';
        lt2.County__c ='Howard';
        lt2.RecordTypeId = rtId;
        lt2.Block__c = 'T1N';
        lt2.Section__c = '32';
        insert lt2;

        LandGridTract__c lt3 = new LandGridTract__c();
        rtId = Schema.SObjectType.LandGridTract__c.getRecordTypeInfosByName().get('Tax Parcel States').getRecordTypeId();
        lt3.Name='Martin 1-579348 TX';
        lt3.County__c ='Martin';
        lt3.RecordTypeId = rtId;
        lt3.Block__c = 'T5N';
        lt3.Section__c = '11';
        insert lt3;

        Test.startTest();
        fixedResults.add(lt.Id);
        fixedResults.add(lt2.Id);
        fixedResults.add(lt3.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();

        List<LookupSearchResult> results = GridLookupController.search('TX Bexar', selectedIds);
        results = GridLookupController.search('Texa', selectedIds); // This one will test Section and Abstract as well
        results = GridLookupController.search('arkansas', selectedIds);
        results = GridLookupController.search('Colorado', selectedIds);
        results = GridLookupController.search('Montan', selectedIds);
        results = GridLookupController.search('Kansas', selectedIds);
        results = GridLookupController.search('mexi', selectedIds);
        results = GridLookupController.search('louisia', selectedIds);
        results = GridLookupController.search('montan', selectedIds);
        results = GridLookupController.search('wyoming', selectedIds);

        System.assertEquals(3, results.size());
        System.assertEquals(lt.Id, results.get(0).getId());

        LookupSearchResult lrr = results.get(0);
        String x = lrr.getSObjectType();
        x = lrr.getIcon();
        x = lrr.getSubtitle();
        x = lrr.getTitle();

        Test.stopTest();
    }

    static testMethod void search_should_not_return_selected_item() {
        Id [] fixedResults = new Id[1];
        LandGridTract__c lt1 = new LandGridTract__c();
    	lt1.Name='Bexar 1-579e38 TX';
        lt1.County__c ='Bexar';
        insert lt1;
        fixedResults.add(lt1.Id);
        LandGridTract__c lt2 = new LandGridTract__c();
    	lt2.Name='Bexar 1-179347 TX';
        lt2.County__c ='Bexar';
        insert lt2;

        Test.startTest();
        fixedResults.add(lt2.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        selectedIds.add(lt2.Id);
        List<LookupSearchResult> results = GridLookupController.search('zzzzzzzzzzzzzzzz', selectedIds);
        System.assertEquals(2, results.size());
        Test.stopTest();
        
        
    }

    
}