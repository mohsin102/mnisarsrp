global class createOwnerInterestRevenueBatch implements Database.Batchable<sObject>{
    
    global final String Query;
    global static boolean updateWellInterestRevenue = true;
    global string objectName;
    global Map<Id,Id> objectUnitMap ;
    global Set<id> unitIds = new Set<Id>();
    global date dt = system.Today().addMonths(-6);
    global createOwnerInterestRevenueBatch(String objectName,Map<Id,Id> objectUnitMap){
        this.objectName = objectName;
        this.objectUnitMap = new Map<Id,Id>();
        this.objectUnitMap = objectUnitMap;
        
        for(Id uId : objectUnitMap.values()){
            this.unitIds.add(uId);
        }
        if(objectName == 'unitAllocation__c'){
            
            Query='Select Id,well__r.Unit__c From monthly_Production__c Where well__r.Unit__c In: unitIds  and   Production_Date__c >=: dt';
        }else if(objectName == 'Monthly_Production__c'){
            Query='Select Id,unit__c from unitAllocation__c where unit__c In: unitIds AND subtract__r.Tract__r.Instrument_Type__c != \'OGL\' AND subtract__r.Tract__r.Instrument_Type__c != \'Surface\'';
        }else{ 
            Query='Select Id,unit__c from unitAllocation__c where oirCount__c = 0';
        }
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, 
                        List<sObject> scope){
                            revenueEstimate__c oirRec;
                            List<revenueEstimate__c> oirList = new List<revenueEstimate__c>();
                            
                            if(objectName =='Monthly_Production__c' ){
                                for(unitAllocation__c suaRec: (List<unitAllocation__c>)scope){   
                                    for(Id mpRecId : objectUnitMap.keySet()){
                                        if(objectUnitMap.get(mpRecId)==suaRec.unit__c){
                                            oirRec = new revenueEstimate__c();
                                            oirRec.unitAllocation__c = suaRec.Id;
                                            oirRec.MonthlyProduction__c = mpRecId;
                                            oirList.add(oirRec);
                                        }
                                    }
                                }
                            }else if(objectName =='unitAllocation__c' ){
                                for(Monthly_Production__c mpRec: (List<Monthly_Production__c>)scope){   
                                    for(Id suaRecId : objectUnitMap.keySet()){
                                        if(objectUnitMap.get(suaRecId)==mpRec.Well__r.Unit__c){
                                            oirRec = new revenueEstimate__c();
                                            oirRec.unitAllocation__c = suaRecId;
                                            oirRec.MonthlyProduction__c = mpRec.Id;
                                            oirList.add(oirRec);
                                        }
                                    }
                                }
                            }
                            
                            if(!oirList.isEmpty()){
                                insert oirList;
                            } 

                        }
    
    global void finish(Database.BatchableContext BC){
        //do nothing
    }
    
}