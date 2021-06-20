public class ContactInformationController {
    // method for fetch account records list  
    @AuraEnabled
    public static List<ContactInfoWrapper> fetchContactInfo(Id recordId){
        
        List<ContactInfoWrapper> conInfoWrapList = new List<ContactInfoWrapper>();
        List<contactInformation__c> contactInfoList = [Select Id,Account__c, Phone__c, Street__c,
                                                       StateProvince__c, City__c,Country__c,zipPostalCode__c,
                                                       Primary__c,Type__c,Status__c,Notes__c from contactInformation__C where Account__c =:recordId];
        conInfoWrapList = createWrapperList(contactInfoList);
        
        return conInfoWrapList;
    }
    
    // method for update records after inline editing  
    @AuraEnabled
    public static void saveContactInfo(List<ContactInfoWrapper> lstContactInfo,Id recordId) {
        String msg = '';
        try{
            List<contactInformation__c> updateLstConInfo = new List<contactInformation__c>();
            List<contactInformation__c> insertLstConInfo = new  List<contactInformation__c>();
            contactInformation__c conInfoRec;
            Boolean hasPrimaryPhone = false;
            Boolean hasPrimaryAddress = false;
            for(ContactInfoWrapper conInfo : lstContactInfo){
                if(conInfo.Primary){
                    if(conInfo.Phone!=null && conInfo.Phone !=''){
                        if(hasPrimaryPhone){
                            throw new AuraHandledException('Multiple Contact Information with Primary Phone found');
                        }else{
                            hasPrimaryPhone = true;
                        }
                    }else{
                        if(hasPrimaryAddress){
                            throw new AuraHandledException('Multiple Contact Information with Primary Address found');
                        }else{
                            hasPrimaryAddress = true;
                        }
                    }
                }
                conInfoRec = new contactInformation__c();
                conInfoRec.Account__c=recordId;
                conInfoRec.Phone__c=conInfo.Phone;
                conInfoRec.Street__c=conInfo.street;
                conInfoRec.city__c=conInfo.city;
                conInfoRec.stateProvince__c=conInfo.state;
                conInfoRec.country__c=conInfo.country;
                conInfoRec.primary__c=conInfo.Primary;
                conInfoRec.Type__c=conInfo.Type;
                conInfoRec.Status__c=conInfo.Status;
                conInfoRec.Notes__c=conInfo.Notes;
                conInfoRec.zipPostalCode__c = conInfo.Zipcode;
                if(conInfo.Id != null && conInfo.Id != '' ){
                    conInfoRec.Id=conInfo.Id;
                    updateLstConInfo.add(conInfoRec);
                }else{
                    insertLstConInfo.add(conInfoRec);
                }
                
            }
            if(insertLstConInfo.size()>0){
                insert deDuplicate(insertLstConInfo);
            }
            
            if(updateLstConInfo.size()>0){
                update updateLstConInfo;
            }
            
        }catch(DmlException e){
            for (Integer i = 0; i < e.getNumDml(); i++) {
                //Get Validation Rule & Trigger Error Messages
                msg =+ e.getDmlMessage(i) +  '\n' ;
            }
            //throw DML exception message
            throw new AuraHandledException(msg);
        }
    }
    
    @AuraEnabled
    public static void deleteContactInfo(Id recordId) {
        String msg = '';
        try{
            contactInformation__c conInfoRec = new contactInformation__c(Id=recordId);
            delete conInfoRec;
        }catch(DmlException e){
            for (Integer i = 0; i < e.getNumDml(); i++) {
                //Get Validation Rule & Trigger Error Messages
                msg =+ e.getDmlMessage(i) +  '\n' ;
            }
            //throw DML exception message
            throw new AuraHandledException(msg);
        }
    }
    public static List<ContactInfoWrapper> createWrapperList(List<contactInformation__c> contactInfoList){
        
        List<ContactInfoWrapper> conInfoWrapList = new List<ContactInfoWrapper>();
        ContactInfoWrapper conInfoWrap;
        for(contactInformation__c conInfoRec : contactInfoList){
            conInfoWrap = new ContactInfoWrapper();
            conInfoWrap.Id = conInfoRec.Id;
            conInfoWrap.accountId = conInfoRec.Account__c;
            conInfoWrap.address = '';
            conInfoWrap.address += conInfoRec.Street__c!='' && conInfoRec.Street__c!=null?conInfoRec.Street__c+', ':'';
            conInfoWrap.address += conInfoRec.StateProvince__c!='' && conInfoRec.StateProvince__c!=null?conInfoRec.StateProvince__c+', ':'';
            conInfoWrap.address += conInfoRec.City__c!='' && conInfoRec.City__c!=null?conInfoRec.City__c+', ':'';
            conInfoWrap.address += conInfoRec.Country__c!='' && conInfoRec.Country__c!=null?conInfoRec.Country__c+', ':'';
            conInfoWrap.address += conInfoRec.zipPostalCode__c!='' && conInfoRec.zipPostalCode__c!=null?conInfoRec.zipPostalCode__c:'';
            
            conInfoWrap.phone = conInfoRec.Phone__c!='' && conInfoRec.Phone__c!=null?conInfoRec.Phone__c:'';
            conInfoWrap.Street = conInfoRec.Street__c;
            conInfoWrap.State  = conInfoRec.StateProvince__c;
            conInfoWrap.City = conInfoRec.City__c;
            conInfoWrap.Country = conInfoRec.Country__c;
            conInfoWrap.Zipcode = conInfoRec.zipPostalCode__c;
            conInfoWrap.Primary = conInfoRec.Primary__c;
            conInfoWrap.Type=conInfoRec.Type__c;
            conInfoWrap.Status=conInfoRec.Status__c;
            conInfoWrap.Notes=conInfoRec.Notes__c;
            conInfoWrapList.add(conInfoWrap);
        }
        return conInfoWrapList;
    }
    
    public static List<contactInformation__c> deDuplicate(List<contactInformation__c> primaryList){
        List<contactInformation__c> listToInsert = new List<contactInformation__c> ();
        
        Set<String> jsonStringSet = new Set<String>();
        for(contactInformation__c c : primaryList){
            jsonStringSet.add(JSON.serialize(c));
        }
        
        for(String s: jsonStringSet){
            listToInsert.add((contactInformation__c)JSON.deserialize(s,contactInformation__c.class));
        }
        return listToInsert;
        
    }
    
    public class ContactInfoWrapper{
        @AuraEnabled
        public String Id{get;set;}
        @AuraEnabled
        public String accountId{get;set;}
        @AuraEnabled
        public String Phone{get;set;}
        @AuraEnabled
        public String address{get;set;}
        @AuraEnabled
        public Boolean Primary{get;set;}
        @AuraEnabled
        public String Street{get;set;}
        @AuraEnabled
        public String State{get;set;}
        @AuraEnabled
        public String City{get;set;}
        @AuraEnabled
        public String Country{get;set;}
        @AuraEnabled
        public String Zipcode{get;set;}
        @AuraEnabled
        public String Type{get;set;}
        @AuraEnabled
        public String Status{get;set;}
        @AuraEnabled
        public String Notes{get;set;}
        
    }
}