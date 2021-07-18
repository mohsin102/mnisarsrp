public class RoyaltyCheckTriggerHandler{

    public static void updateCheckInfo(List<Royalty_Check__c> newList){
        
        Map<Id,String> accMap = new Map<Id,String>();
        Set<Id> accId= new Set<id>();
        for(Royalty_Check__c  rcRec : newList){
            accId.add(rcRec.Payor_Lookup__c);
        }
        for(Account accRec:[Select Id, name From Account Where id In: accId]){
            accMap.put(accRec.Id, accRec.Name);
        }
        for(Royalty_Check__c  rcRec : newList){
            String payorStr = accMap.get(rcRec.Payor_Lookup__c)==null?'':accMap.get(rcRec.Payor_Lookup__c);
            rcRec.Description__c = payorStr+' #'+rcRec.Check_Number__c+' '+rcRec.Check_Issue_Date__c.format()+' $' + String.valueOf(rcRec.Amount__c);
            
            rcRec.operatorCheckNumberKey__c = accMap.get(rcRec.Payor_Lookup__c)+' #'+rcRec.Check_Number__c;
            if(rcRec.Operator_Name__c==null){
                rcRec.Operator_Name__c = accMap.get(rcRec.Payor_Lookup__c);
            }
        }
    }

    public static void UpdatePayorNPayee(List<Royalty_Check__c> newList){
        Id recTypeId = Schema.getGlobalDescribe().get('mappingMetadata__c').getDescribe().getRecordTypeInfosByName().get('AssociatedAccount').getRecordTypeId();
        Map<String,String> accountMapping = new Map<String,String>();
        for(mappingMetadata__c mapRec : [Select Id,key__c,value__c from mappingMetadata__c where RecordTypeId =: recTypeId]){
            accountMapping.put(mapRec.key__c,mapRec.value__c);
        }

        for(Royalty_Check__c  rcRec : newList){
            if(rcRec.Source__c == 'CDEX'){
                if(accountMapping.containsKey(rcRec.Payee_from_Source_File__c)){
                    rcRec.Payee_Lookup__c = accountMapping.get(rcRec.Payee_from_Source_File__c);
                }
                if(accountMapping.containsKey(rcRec.Payor_from_Source_File__c)){
                    rcRec.Payor_Lookup__c = accountMapping.get(rcRec.Payor_from_Source_File__c);
                }
            }
        }
    }

    public static void updateAccountMapping(List<Royalty_Check__c> newList,Map<Id,Royalty_Check__c> oldMap){
        
        Map<String,String> accountMapping = new Map<String,String>();

        for(Royalty_Check__c  rcRec : newList){
            if(rcRec.Source__c == 'CDEX'){
                if(rcRec.Payee_Lookup__c != oldMap.get(rcRec.Id).Payee_Lookup__c && 
                    String.isNotBlank(rcRec.Payee_from_Source_File__c) && rcRec.Payee_Lookup__c!=null){
                    
                    accountMapping.put( rcRec.Payee_from_Source_File__c,rcRec.Payee_Lookup__c);
                }if(rcRec.Payor_Lookup__c != oldMap.get(rcRec.Id).Payor_Lookup__c && 
                    String.isNotBlank(rcRec.Payor_from_Source_File__c) && rcRec.Payor_Lookup__c!=null){
                    
                    accountMapping.put( rcRec.Payor_from_Source_File__c,rcRec.Payor_Lookup__c);
                }
            }
        }

        List<mappingMetadata__c> mppList = new List<mappingMetadata__c>();
        Id recTypeId = Schema.getGlobalDescribe().get('mappingMetadata__c').getDescribe().getRecordTypeInfosByName().get('AssociatedAccount').getRecordTypeId();
        for(mappingMetadata__c mapRec : [Select Id,key__c,value__c from mappingMetadata__c where RecordTypeId =: recTypeId AND key__c IN: accountMapping.keySet()]){
            mapRec.value__c = accountMapping.get(mapRec.key__c);
            mppList.add(mapRec);
            accountMapping.remove(mapRec.key__c);
        }

        for(String key: accountMapping.keySet()){
            mppList.add(new mappingMetadata__c(key__c=key,value__c=accountMapping.get(key),RecordTypeId=recTypeId));
        }
        upsert mppList;
    }
}