public class ContactInformationTriggerHandler {
    
    public static void updateInfoOnAccount(List<contactInformation__c> newList){
        
        Map<Id,Account> accountMap = new Map<Id,Account>();
        Account accRec;
            for(contactInformation__c infoRec : newList){
                if(infoRec.Primary__c){
                    if(accountMap.containsKey(infoRec.Account__c)){
                        accRec = accountMap.get(infoRec.Account__c);
                    }else{
                        accRec = new Account(Id=infoRec.Account__c);
                    }
                    system.debug(infoRec.ContactInformationType__c );
                    if(infoRec.Phone__c != null && infoRec.Phone__c != ''){
                        accRec.Phone = infoRec.Phone__c;
                    }else{
                        accRec.BillingStreet = infoRec.Street__c;
                        accRec.BillingCity = infoRec.City__c;
                        accRec.BillingState = infoRec.stateProvince__c;
                        accRec.BillingCountry = infoRec.Country__c;
                        accRec.BillingPostalCode = infoRec.zipPostalCode__c;
                    }
                    accountMap.put(infoRec.Account__c,accRec);
                }
            }
    	system.debug(accountMap);
        if(accountMap.size()>0){
            update accountMap.values();
        }
    }
}