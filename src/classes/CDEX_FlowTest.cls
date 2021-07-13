@IsTest
Private with sharing class CDEX_FlowTest {
    @testSetup
    private static void makedata(){
        EnergyLinkBucket__c check = new EnergyLinkBucket__c(checkUrl__c='/energy_link/checks/68');
        insert check;
    }
    @IsTest
    Private static void createEnergyLink_TestMethod(){
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('RecentCheck');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        CDEXCalloutHelper.getRecentChecks();
    }
    @IsTest
    Private static void createEnergyLinkSchedule_TestMethod(){
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('RecentCheck');
        mock.setStatusCode(201);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        
        CDEX_CreateEnergyLinkScheduler s = new CDEX_CreateEnergyLinkScheduler();
        system.schedule('Test Territory Check', '0 0 23 * * ?', s);
    }
    @IsTest
    Private static void importCdexCheckSchedule_TestMethod(){
        EnergyLinkBucket__c[] checkLst = new EnergyLinkBucket__c[]{};
        For(Integer i = 1; i < 100; i++){
        	EnergyLinkBucket__c check = new EnergyLinkBucket__c(checkUrl__c='/energy_link/checks/68' + i, reprocess__c = TRUE);
            checkLst.add(check);
        }
        insert checkLst;
        System.assert(checkLst.size() > 90);
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Checkbody');
        mock.setStatusCode(201);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        CDEX_ImportChecksScheduler s = new CDEX_ImportChecksScheduler();
        system.schedule('Test Territory Check', '0 0 23 * * ?', s);
    }
	@IsTest
    Private static void sendNotificationsSchedule_TestMethod(){
            Log__c[] logLst = new Log__c[]{};
        For(Integer i = 1; i < 5; i++){
        	Log__c l = new Log__c(Process__c = 'CDEX');
            logLst.add(l);
        }
        insert logLst;
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Checkbody');
        mock.setStatusCode(201);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        CDEX_SendNotificationsSchedule s = new CDEX_SendNotificationsSchedule();
        system.schedule('Test Territory Check', '0 0 23 * * ?', s);
    }
    @IsTest
    Private static void importCdexBatch_TestMethod(){
        test.startTest();
        List<EnergylinkBucket__c> linkList = [SELECT Id FROM EnergylinkBucket__c ];
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Checkbody');
        mock.setStatusCode(201);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        MakeCalloutsBatch btch = new MakeCalloutsBatch(linkList);
        database.executeBatch(btch,1);
        Test.stopTest();
    }
    @IsTest
    Private static void importCdexCheck_TestMethod(){
        test.startTest();
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Checkbody');
        mock.setStatusCode(201);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        CDEXCalloutHelper.getCheckBody('/energy_link/checks/68',null);
        Test.stopTest();
    }
    @IsTest
    Private static void importCdexFinal_TestMethod(){
        test.startTest();
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'Checkbody' LIMIT 1];
        String checkBodyStr = sr.Body.toString();
        String checkBodyStr1 = checkBodyStr.substring(0,200).replaceFirst('details', 'Check');
        
        String checkBodyStr2 = checkBodyStr.substring(200);
        CDEXCalloutHelper.cdex = CdexParser.parse(checkBodyStr1+checkBodyStr2);
        ImportCdexChecks.createCdexChecksFromCallout(null);
        Test.stopTest();
    }
}