public class reprocessRevenueEstimatesController {
    public static List<revenueEstimate__c> createRevenueEstimates(List<Monthly_Production__c> scope) {
        revenueEstimate__c oirRec;
        List<revenueEstimate__c> oirList = new List<revenueEstimate__c>();
        Set<Id> mpIds;
        Map<Id,Set<Id>> unitMpMap = new Map<Id,Set<Id>>();
        for(Monthly_Production__c mpRec : scope){
            
            if(unitMpMap.containsKey(mpRec.Well__r.Unit__c)){
                unitMpMap.get(mpRec.Well__r.Unit__c).add(mpRec.Id);
            }else{
                mpIds = new Set<Id>();
                mpIds.add(mpRec.Id);
                unitMpMap.put(mpRec.Well__r.Unit__c,mpIds);
            }
        }
        system.debug(unitMpMap);
        for(UnitAllocation__c uaRec : [Select Id,unit__c from UnitAllocation__c where unit__c In:unitMpMap.keySet() AND subtract__r.Tract__r.Instrument_Type__c != 'OGL' AND subtract__r.Tract__r.Instrument_Type__c != 'Surface']){
            
            for(Id mpId: unitMpMap.get(uaRec.unit__c)){
                oirRec = new revenueEstimate__c();
                oirRec.unitAllocation__c = uaRec.Id;
                oirRec.MonthlyProduction__c = mpId;
                oirList.add(oirRec);
            }
        }
        return oirList;
    }
}