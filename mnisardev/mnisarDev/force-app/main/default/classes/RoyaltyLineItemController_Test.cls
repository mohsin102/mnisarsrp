@istest
public class RoyaltyLineItemController_Test {
    
    @isTest
    public static void testmethod1(){
        List<Account> acc = TestDataFactory.createAccounts(1);
        insert acc;
        
        
        Royalty_Check__c rcRec = new Royalty_Check__c();
        rcRec.Amount__c = 100;
        rcRec.Check_Issue_Date__c = system.today();
        rcRec.Payor_Lookup__c = acc[0].Id;
        insert rcRec;
        
        RoyaltyLineItemController.getRecords(rcRec.Id,10,1,'Name','asc');
    }
    @isTest
    public static void testmethod2(){
        List<Account> acc = TestDataFactory.createAccounts(1);
        insert acc;
        
        
        Royalty_Check__c rcRec = new Royalty_Check__c();
        rcRec.Amount__c = 100;
        rcRec.Check_Issue_Date__c = system.today();
        rcRec.Payor_Lookup__c = acc[0].Id;
        insert rcRec;
        
        Royalty_Line_Item__c rli = new Royalty_line_item__c();
        rli.Royalty_Check__c= rcRec.id;   
        rli.propertyName__c='test';
        insert rli;
        RoyaltyLineItemController.getRecordsForAssociation(rcRec.Id);
    }
    @isTest
    public static void testmethod3(){
        List<Account> acc = TestDataFactory.createAccounts(1);
        insert acc;
        
        
        Royalty_Check__c rcRec = new Royalty_Check__c();
        rcRec.Amount__c = 100;
        rcRec.Check_Issue_Date__c = system.today();
        rcRec.Payor_Lookup__c = acc[0].Id;
        insert rcRec;
        
        Royalty_Line_Item__c rli = new Royalty_line_item__c();
        rli.Royalty_Check__c= rcRec.id;   
        rli.propertyName__c='test';
        insert rli;
        RoyaltyLineItemController.getSearchResults('test');
    }
    
    
    
    @isTest
    public static void testmethod4(){
        List<Account> acc = TestDataFactory.createAccounts(1);
        insert acc;
        
        
        Royalty_Check__c rcRec = new Royalty_Check__c();
        rcRec.Amount__c = 100;
        rcRec.Check_Issue_Date__c = system.today();
        rcRec.Payor_Lookup__c = acc[0].Id;
        insert rcRec;
        
        Royalty_Line_Item__c rli = new Royalty_line_item__c();
        rli.Royalty_Check__c= rcRec.id;   
        rli.propertyName__c='test';
        rli.ownerNetValueActual__c=0.45;
        insert rli;
        List<String> rliIds = new List<String>();
        rliIds.add(rli.id);
        
        Well__c wellRec = new Well__c();
        wellRec.Name = 'TestWell';
        wellRec.API10__c ='9501724908';
        insert wellRec;
        List<String> wellIds = new List<String>();
        wellIds.add(wellRec.id);
        // RoyaltyLineItemController.associateWells(wellIds,'Test', rliIds,false);
        Well__c wellRec1 = new Well__c();
        wellRec1.Name = 'TestWell1';
        wellRec1.API10__c ='950249081';
        insert wellRec1;
        wellIds.add(wellRec1.id);
        // RoyaltyLineItemController.associateWells(wellIds,'Test', rliIds,false);
    }
    @isTest
    public static void testmethod5(){
        List<Account> acc = TestDataFactory.createAccounts(1);
        insert acc;
        
        
        Royalty_Check__c rcRec = new Royalty_Check__c();
        rcRec.Amount__c = 100;
        rcRec.Check_Issue_Date__c = system.today();
        rcRec.Payor_Lookup__c = acc[0].Id;
        insert rcRec;
        
        Royalty_Line_Item__c rli = new Royalty_line_item__c();
        rli.Royalty_Check__c= rcRec.id;   
        rli.propertyName__c='test';
        insert rli;
        List<String> rliIds = new List<String>();
        rliIds.add(rli.Id);
        RoyaltyLineItemController.getRLIData(rliIds);
        
    }
    
    @isTest
    public static void testmethod6(){
        Id recTypeId = Schema.getGlobalDescribe().get('mappingMetadata__c').getDescribe().getRecordTypeInfosByName().get('AssociatedAccount').getRecordTypeId();
        mappingMetadata__c mM = new mappingMetadata__c(RecordTypeId = recTypeId, key__c = 'testkey');
        insert mM;
        List<Royalty_Check__c> rcRecLst = new List<Royalty_Check__c>();
        List<Account> acc = TestDataFactory.createAccounts(1);
        insert acc;

        Royalty_Check__c rcRec = new Royalty_Check__c();
        rcRec.Amount__c = 100;
        rcRec.Check_Issue_Date__c = system.today();
        rcRec.Payor_Lookup__c = acc[0].Id;
        rcRec.Source__c = 'CDEX';
        rcRec.Payee_from_Source_File__c = 'testkey';
        rcRec.Payor_from_Source_File__c = 'testkey';
        insert rcRec;
        rcRecLst.add(rcRec);
        
        RoyaltyCheckTriggerHandler.UpdatePayorNPayee(rcRecLst);
    }
    
    @isTest
    public static void testmethod7(){
        List<Royalty_Check__c> newRCRecLst = new List<Royalty_Check__c>();
        Map<Id,Royalty_Check__c> oldRCRecMap = new Map<Id,Royalty_Check__c>();
        List<Account> acc = TestDataFactory.createAccounts(2);
        insert acc;

        Royalty_Check__c rcRecNew = new Royalty_Check__c();
        rcRecNew.Amount__c = 100;
        rcRecNew.Check_Issue_Date__c = system.today();
        rcRecNew.Payor_Lookup__c = acc[0].Id;
        rcRecNew.Payee_Lookup__c = acc[1].Id;
        rcRecNew.Source__c = 'CDEX';
        rcRecNew.Payee_from_Source_File__c = 'testkey';
        rcRecNew.Payor_from_Source_File__c = 'testkey';
        insert rcRecNew;
        rcRecNew.Payor_Lookup__c = acc[1].Id;
        rcRecNew.Payee_Lookup__c = acc[0].Id;
        update rcRecNew;
    }
    
    @isTest
    public static void testmethod8(){
        List<Account> acc = TestDataFactory.createAccounts(1);
        insert acc;
        
        Royalty_Check__c rcRec = new Royalty_Check__c();
        rcRec.Amount__c = 100;
        rcRec.Check_Issue_Date__c = system.today();
        rcRec.Payor_Lookup__c = acc[0].Id;
        rcRec.Source__c = 'CDEX';
        insert rcRec;

        Royalty_line_item__c rli = new Royalty_line_item__c(royalty_Check__c = rcRec.Id);
        insert rli;
        
        RoyaltyLineItemController.deleteLineItem(rli.Id);
    }
    
        @isTest
    public static void testmethod9(){
        List<Account> acc = TestDataFactory.createAccounts(1);
        insert acc;
        
        Royalty_Check__c rcRec = new Royalty_Check__c();
        rcRec.Amount__c = 100;
        rcRec.Check_Issue_Date__c = system.today();
        rcRec.Payor_Lookup__c = acc[0].Id;
        insert rcRec;
        
        Royalty_Line_Item__c rli = new Royalty_line_item__c();
        rli.Royalty_Check__c= rcRec.id;   
        rli.propertyName__c='test';
        rli.ownerNetValueActual__c=0.45;
        insert rli;
        List<String> rliIds = new List<String>();
        rliIds.add(rli.id);
        
        Well__c wellRec = new Well__c();
        wellRec.Name = 'TestWell';
        wellRec.API10__c ='9501724908';
        insert wellRec;
        List<String> wellIds = new List<String>();
        wellIds.add(wellRec.id);
        // RoyaltyLineItemController.associateWells(wellIds,'Test', rliIds,false);
        Well__c wellRec1 = new Well__c();
        wellRec1.Name = 'TestWell1';
        wellRec1.API10__c ='950249081';
        insert wellRec1;
        wellIds.add(wellRec1.id);
        // RoyaltyLineItemController.associateWells(wellIds,'Test', rliIds,false);
        
        revenueProperty__c revProp = new revenueProperty__c();
        insert revProp;
        
        RoyaltyLineItemController.associateWells(wellIds, String.valueOf(revProp.Id), rliIds, false); 
        RoyaltyLineItemController.associateWells(wellIds, String.valueOf(revProp.Id), rliIds, true);
    }
	@isTest
    public static void testmethod10(){
        List<Account> acc = TestDataFactory.createAccounts(1);
        insert acc;
        
        
        Royalty_Check__c rcRec = new Royalty_Check__c();
        rcRec.Amount__c = 100;
        rcRec.Check_Issue_Date__c = system.today();
        rcRec.Payor_Lookup__c = acc[0].Id;
        insert rcRec;
        
        RoyaltyLineItemController.getFilteredRecords(rcRec.Id,10,1,'Name','asc', 'LI', 1);
    }
	
}