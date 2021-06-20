public class UnitAllocationTriggerHelper {

    public static void createOwnerInterestRevenue(List<unitAllocation__c> uaList){
        system.debug('InsideMethod---------');
        Map<Id,Id> uaUnitMap = new Map<Id,Id>();

        for(unitAllocation__c uaRec:[Select Id,unit__c from unitAllocation__c where Id In: uaList AND subtract__r.Tract__r.Instrument_Type__c != 'OGL'
                                AND subtract__r.Tract__r.Instrument_Type__c != 'Surface']){
            uaUnitMap.put(uaRec.Id, uaRec.unit__c);
        }
        createOwnerInterestRevenueBatch oirBatch = new createOwnerInterestRevenueBatch('unitAllocation__c',uaUnitMap);
        Database.executeBatch(oirBatch,50);
    }
}