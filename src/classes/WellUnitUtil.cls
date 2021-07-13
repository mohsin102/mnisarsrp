public with sharing class WellUnitUtil {
    @AuraEnabled(Cacheable=true)
    public static WellUnitUtilInfo getWellInfo(Id objId) {
        // Build the set of Subtract Ids based on object type
        Set <Id> subIds = new Set<Id>();
        if (Schema.Subtract__c.SObjectType == objId.getSobjectType()) {
            // Add Subtract Id
            subIds.add(objId);
            WellUnitUtilInfo w = getWellInfoBySubtracts(subIds);
            w.objName = 'Subtract__c';
            return w;
        } else if (Schema.Tract__c.SObjectType == objId.getSobjectType()) {
            // Add Subtracts that are children of this tract
            List<Subtract__c> subs = [SELECT Id FROM Subtract__c WHERE Tract__c = : objId];
            subIds = Util.getIds(subs);
            WellUnitUtilInfo w = getWellInfoBySubtracts(subIds);
            w.objName = 'Tract__c';
            return w;
        } else if (Schema.Opportunity.SObjectType == objId.getSobjectType()) {
            //Add unique Subtracts that are related to this opportunity
            List<Subtract__c> subs = [SELECT Id FROM Subtract__c WHERE Tract__c IN
                                        (SELECT Tract__c FROM Opportunity_Tract__c WHERE Opportunity__c =: objId)];
            subIds = Util.getIds(subs);
            WellUnitUtilInfo w = getWellInfoBySubtracts(subIds);
            w.objName = 'Opportunity';
            return w;
		} else if (Schema.Evaluation__c.SObjectType == objId.getSobjectType()) {
			Evaluation__c currentEval = [SELECT Id, Opportunity__c FROM Evaluation__c WHERE Id = :objId LIMIT 1];
			return getWellInfo(currentEval.opportunity__c);
        } else if(Schema.Unit__c.SObjectType == objId.getSobjectType()){
            WellUnitUtilInfo w = getWellInfoByUnits(new Set<Id>{objId});
            w.objName = 'Unit__c';
            return w;
        } else if(Schema.Account.SObjectType == objId.getSobjectType()){
            //Add unique Subtracts that are related to this opportunity
            List<Subtract__c> subs = [SELECT Id FROM Subtract__c WHERE Tract__r.Account__c =: objId];
            subIds = Util.getIds(subs);
            WellUnitUtilInfo w = getWellInfoBySubtracts(subIds);
            w.objName = 'Account';
            return w;
        }
        return null;
    }

    public static WellUnitUtilInfo getWellInfoBySubtracts(Set<Id> subtractIds) {
        WellUnitUtilInfo wi = new WellUnitUtilInfo();
        Date lastMonth = null;
        Set<Id> permitIds = new Set<Id>();
        Set<Id> payingHzIds = new Set<Id>();
        Set<Id> hzIds = new Set<Id>();
        Set<Id> payingVtIds = new Set<Id>();
        Set<Id> vtIds = new Set<Id>();
        Map<Id,Decimal> oirGasWellMap = new Map<Id,Decimal>();
        Map<Id,Decimal> oirOilWellMap  = new Map<Id,Decimal>();
        // Load Well Interest Allocations
        wi.permits = new List<Well__c>();
        wi.hzWells = new List<WellUnitWrapper>();
        wi.vertWells = new List<WellUnitWrapper>();

        Set<String> strSet = new Set<String>();
        Set<Id> wellIds = new Set<Id>();
        Map<Id,String> uaMap = new Map<Id,String>();
        Map<Id,Decimal> uaNRIMap = new Map<Id,Decimal>();
        Map<Id,unitAllocation__c> uaRecMap = new Map<Id,unitAllocation__c>();
        Set<Id> unitIds = new Set<Id>();
        unitAllocation__c uaRec;
        String str;

        for(revenueEstimate__c oir : [SELECT Id, unitAllocation__c,monthlyProduction__r.Well__c,
                ownerNetRevenueValueGas__c,ownerNetRevenueValueOil__c
                FROM revenueEstimate__c 
                WHERE unitAllocation__r.Subtract__c IN: subtractIds AND Inactive__c = false]){

                if(oirGasWellMap.containsKey(oir.monthlyProduction__r.Well__c)){
                    Decimal sumGas = oirGasWellMap.get(oir.monthlyProduction__r.Well__c)+((oir.ownerNetRevenueValueGas__c==null)?0.0:oir.ownerNetRevenueValueGas__c);
                    Decimal sumOil = oirGasWellMap.get(oir.monthlyProduction__r.Well__c)+((oir.ownerNetRevenueValueOil__c==null)?0.0:oir.ownerNetRevenueValueOil__c);
                    oirGasWellMap.put(oir.monthlyProduction__r.Well__c,sumGas);
                    oirOilWellMap.put(oir.monthlyProduction__r.Well__c,sumOil);
                }else{
                    oirGasWellMap.put(oir.monthlyProduction__r.Well__c,(oir.ownerNetRevenueValueGas__c==null)?0.0:oir.ownerNetRevenueValueGas__c);
                    oirOilWellMap.put(oir.monthlyProduction__r.Well__c,(oir.ownerNetRevenueValueOil__c==null)?0.0:oir.ownerNetRevenueValueOil__c);
                }
        } 
        for(unitAllocation__c sub:[Select Id,Unit__c from unitAllocation__c where subtract__c In:subtractIds and Inactive__c = false]){
            unitIds.add(sub.Unit__c);
        }
        Map<Id,Well__c> wellMap = new Map<Id,Well__c>([Select Id,Name,Current_Operator__r.Name, API10__c, Hole_Direction__c,
                Spud_Date__c, Permit_Date__c, Production_Actual_Start_Date__c, Unit__c,Unit__r.Name,
                Current_Operator_Name__c, Is_Permit__c, Is_Paying_calc__c, LastActivityDate__c,
                LastActivityType__c, Last_Production_Date__c, Last_Production_Month_Used__c,
                Last_Production_Month__c From Well__c where unit__c In: unitIds AND wellStatus__c ='Producing']);
system.debug(wellMap);
        Well__c wellRec;
        
        for(Id wellId : wellMap.keySet()){
            wellRec = new Well__c();
            wellRec = wellMap.get(wellId);
            
            Datetime actDate = null;
            if (null != wellRec.LastActivityDate__c) {
                actDate = wellRec.LastActivityDate__c + 1;  // without +1, the day before is displayed
            }
            Datetime prodDate = null;
            if (wellRec.Last_Production_Date__c != null) {
                prodDate = wellRec.Last_Production_Date__c + 1; // without +1, the day before is displayed
            }
            String direction = wellRec.Hole_Direction__c.left(1).toLowerCase();
            
            if (!wellRec.Is_Permit__c) {
                
                WellUnitWrapper ww = new WellUnitWrapper();
                ww.well = wellRec;
                ww.sumGas = oirGasWellMap.get(wellRec.Id);
                ww.sumOil = oirOilWellMap.get(wellRec.Id);
                
                if (wellRec.Is_Paying_calc__c) {
                    if (prodDate != null) {
                     ww.lastActivityInfo = prodDate.format('MM/dd/yy') + ' Prod';
                    }
                    if (direction == 'h') {
                        payingHzIds.add(wellRec.Id);
                    } else {
                        payingVtIds.add(wellRec.Id);
                    }
                }
                else {
                    // This is not paying, so update the last activity appropriately
                    if (actDate != null) {
                        ww.lastActivityInfo = actDate.format('MM/dd/yy') + ' ' + wellRec.LastActivityType__c;
                    }
                    else
                    {
                        if (wellRec.LastActivityDate__c  == null) {
                            ww.lastActivityInfo = 'Unknown';
                        }
                    }
                }
                // Increment horizontal/vertical counter
                if (direction == 'h') {
                    hzIds.add(wellRec.Id);
                    wi.hzWells.add(ww);
                    //wi.hzPaying++;
                } else {
                    vtIds.add(wellRec.Id);
                    wi.vertWells.add(ww);
                    //wi.vertPaying++;
                }
            }
        }
        // Track the last month there is a production record
        wi.lastMonth = lastmonth;

        // Get permits as wells without using the WellInfo wrapper
        List<Well__c> permitWells = new List<Well__c>();
        List<Well__c> ducs = new List<Well__c>();
        System.debug(unitIds);
        for(Well__c wRec: [SELECT Id, API10__c, Is_Permit__c, Current_Operator_Name__c,
                    Hole_Direction__c, LastActivityDate__c, LastActivityType__c, Name,wellStatus__c,Spud_Date__c, Unit__r.Name, Unit__c
                    FROM Well__c WHERE unit__c IN: unitIds AND (wellStatus__c = 'Permit' OR wellStatus__c = 'DUC')
                    AND Hole_Direction__c != 'Vertical'
                    ORDER BY Current_Operator_Name__c, LastActivityDate__c]){

                        if(wRec.wellStatus__c=='Permit'){
                            permitWells.add(wRec);
                        }else{
                            ducs.add(wRec);
                        }
                    }
        


        wi.permits = permitWells;
        wi.ducWells = ducs;
        wi.hzPaying = payingHzIds.size();
        wi.vertPaying = payingVtIds.size();
        wi.hzWellCount = hzIds.size();
        wi.vertWellCount = vtIds.size();
        
        return wi;
    }

    public static WellUnitUtilInfo getWellInfoByUnits(Set<id> unitIds){
        WellUnitUtilInfo wi = new WellUnitUtilInfo();
        Date lastMonth = null;
        Set<Id> permitIds = new Set<Id>();
        Set<Id> payingHzIds = new Set<Id>();
        Set<Id> hzIds = new Set<Id>();
        Set<Id> payingVtIds = new Set<Id>();
        Set<Id> vtIds = new Set<Id>();
        Map<Id,Decimal> oirGasWellMap = new Map<Id,Decimal>();
        Map<Id,Decimal> oirOilWellMap  = new Map<Id,Decimal>();
        // Load Well Interest Allocations
        wi.permits = new List<Well__c>();
        wi.hzWells = new List<WellUnitWrapper>();
        wi.vertWells = new List<WellUnitWrapper>();

        Set<String> strSet = new Set<String>();
        Set<Id> wellIds = new Set<Id>();
        Map<Id,String> uaMap = new Map<Id,String>();
        Map<Id,Decimal> uaNRIMap = new Map<Id,Decimal>();
        Map<Id,unitAllocation__c> uaRecMap = new Map<Id,unitAllocation__c>();
        unitAllocation__c uaRec;
        String str;
        Map<Id,Well__c> wellMap = new Map<Id,Well__c>([Select Id,Name,Current_Operator__r.Name, API10__c, Hole_Direction__c,
                Spud_Date__c, Permit_Date__c, Production_Actual_Start_Date__c, Unit__c,Unit__r.Name,
                Current_Operator_Name__c, Is_Permit__c, Is_Paying_calc__c, LastActivityDate__c,
                LastActivityType__c, Last_Production_Date__c, Last_Production_Month_Used__c,
                Last_Production_Month__c From Well__c where unit__c In: unitIds AND wellStatus__c ='Producing']);
system.debug(wellMap);
        Well__c wellRec;
        
        for(Id wellId : wellMap.keySet()){
            wellRec = new Well__c();
            wellRec = wellMap.get(wellId);
            
            Datetime actDate = null;
            if (null != wellRec.LastActivityDate__c) {
                actDate = wellRec.LastActivityDate__c + 1;  // without +1, the day before is displayed
            }
            Datetime prodDate = null;
            if (wellRec.Last_Production_Date__c != null) {
                prodDate = wellRec.Last_Production_Date__c + 1; // without +1, the day before is displayed
            }
            String direction = wellRec.Hole_Direction__c.left(1).toLowerCase();
            
            if (!wellRec.Is_Permit__c) {
                
                WellUnitWrapper ww = new WellUnitWrapper();
                ww.well = wellRec;
                
                if (wellRec.Is_Paying_calc__c) {
                    if (prodDate != null) {
                     ww.lastActivityInfo = prodDate.format('MM/dd/yy') + ' Prod';
                    }
                    if (direction == 'h') {
                        payingHzIds.add(wellRec.Id);
                    } else {
                        payingVtIds.add(wellRec.Id);
                    }
                }
                else {
                    // This is not paying, so update the last activity appropriately
                    if (actDate != null) {
                        ww.lastActivityInfo = actDate.format('MM/dd/yy') + ' ' + wellRec.LastActivityType__c;
                    }
                    else
                    {
                        if (wellRec.LastActivityDate__c  == null) {
                            ww.lastActivityInfo = 'Unknown';
                        }
                    }
                }

                // Increment horizontal/vertical counter

                if (direction == 'h') {
                    hzIds.add(wellRec.Id);
                    wi.hzWells.add(ww);
                    //wi.hzPaying++;
                } else {
                    vtIds.add(wellRec.Id);
                    wi.vertWells.add(ww);
                    //wi.vertPaying++;
                }
            }
        }

        // Track the last month there is a production record
        wi.lastMonth = lastmonth;

        // Get permits as wells without using the WellInfo wrapper
        List<Well__c> permitWells = new List<Well__c>();
        List<Well__c> ducs = new List<Well__c>();
        System.debug(unitIds);
        for(Well__c wRec: [SELECT Id, API10__c, Is_Permit__c, Current_Operator_Name__c,
                    Hole_Direction__c, LastActivityDate__c, LastActivityType__c, Name,wellStatus__c,Spud_Date__c, Unit__r.Name, Unit__c
                    FROM Well__c WHERE unit__c IN: unitIds AND (wellStatus__c = 'Permit' OR wellStatus__c = 'DUC')
                    AND Hole_Direction__c != 'Vertical'
                    ORDER BY Current_Operator_Name__c, LastActivityDate__c]){

                        if(wRec.wellStatus__c=='Permit'){
                            permitWells.add(wRec);
                        }else{
                            ducs.add(wRec);
                        }
                    }
        


        wi.permits = permitWells;
        wi.ducWells = ducs;
        wi.hzPaying = payingHzIds.size();
        wi.vertPaying = payingVtIds.size();
        wi.hzWellCount = hzIds.size();
        wi.vertWellCount = vtIds.size();
        
        return wi;
    }


    public class WellUnitUtilInfo {
        @AuraEnabled
        public string objName{get;set;}
        @AuraEnabled
        public List<Well__c> permits {get; set;}
        @AuraEnabled
        public List<Well__c> ducWells {get; set;}
        @AuraEnabled
        public List<WellUnitWrapper> hzWells {get; set;}
        @AuraEnabled
        public List<WellUnitWrapper> vertWells {get; set;}
        @AuraEnabled
        public Integer hzPaying {get; set;}
        @AuraEnabled
        public Integer vertPaying {get; set;}
        @AuraEnabled
        public Integer hzWellCount {get; set;}
        @AuraEnabled
        public Integer vertWellCount {get; set;}
        @AuraEnabled
        public Date lastMonth {get; set;}
    }

    public class WellUnitWrapper {
        @AuraEnabled
        public String lastActivityInfo {get; set;}
        @AuraEnabled
        public Well__c well {get; set;}
        @AuraEnabled
        public String uaName {get; set;}
        @AuraEnabled
        public Decimal uaDecimal {get; set;}
        @AuraEnabled
        public unitAllocation__c uaRec {get; set;}
        @AuraEnabled
        public Decimal sumGas {get; set;}
        @AuraEnabled
        public Decimal sumOil {get; set;}
    }

}