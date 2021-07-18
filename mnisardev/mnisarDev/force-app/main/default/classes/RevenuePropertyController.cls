public class RevenuePropertyController {

    @AuraEnabled
    public static List<checkWrapper> getRoyaltyCheckList(String recordId){
        try{
            Set<String> rcIds = new Set<String>();
            for(Royalty_line_item__c rli :[Select royalty_Check__c from Royalty_line_item__c where RevenueProperty__c =: recordId]){
                rcIds.add(rli.royalty_Check__c);
            }
            List<Royalty_Check__C> rcList = [Select Id, Name,of_Allocated_Line_Items__c,of_Unallocated_Line_Items__c,
                                            Payor_Lookup__c,Payor_Lookup__r.Name,Payee_Lookup__c,Payee_Lookup__r.Name,
                                            Check_Number__c,Check_Issue_Date__c,
                                            (Select Id,ownerNetValueActual__c from Line_Items__r Where RevenueProperty__c =: recordId)
                                            from Royalty_Check__c where Id In: rcIds];
            List<checkWrapper> checkList = new List<checkWrapper>();
            checkWrapper check;
            Decimal ownerNetValue;
            for(Royalty_Check__C rc: rcList){
                check = new checkWrapper();
                ownerNetValue = 0;
                check.rcId = '/'+rc.Id;
                check.name = rc.Name;
                check.countRLI = rc.Line_Items__r.size();
                check.payor = rc.Payor_Lookup__r.Name;
                check.payorId = rc.Payor_Lookup__c!=null?'/'+rc.Payor_Lookup__c:'';
                check.payee = rc.Payee_Lookup__r.Name;
                check.payeeId = rc.Payee_Lookup__c!=null?'/'+rc.Payee_Lookup__c:'';
                check.checkNumber = rc.Check_Number__c;
                check.checkDate = rc.Check_Issue_Date__c;
                for(Royalty_line_item__c rli: rc.Line_Items__r){
                    ownerNetValue += rli.ownerNetValueActual__c!=null?rli.ownerNetValueActual__c:0;
                }
                check.ownerNetValue = ownerNetValue.setScale(2);
                checkList.add(check);
            }
            return checkList;
        }catch(Exception e){
            system.debug(e.getMessage());
            system.debug(e.getStackTraceString());
            throw new AuraHandledException('Error encountered in getRoyaltyCheckList');
        }
    }
    
    @AuraEnabled
    public static List<wellWrapper> getWellList(String recordId){
        try{
            Map<String,Decimal> wellMap = new Map<String,Decimal>();
            for(RevenuePropertyWellAllocation__c rpw : [Select splitPercent__c, well__c from RevenuePropertyWellAllocation__c where RevenueProperty__c =: recordId]){
                wellMap.put(rpw.well__c,rpw.splitPercent__c);
            }
            List<wellWrapper> wellWrapperList = new List<wellWrapper>();
            wellWrapper wellWrap;
            for(Well__c well : [Select Id,Name,API10__c,Current_Operator__c,
                                      Current_Operator__r.Name, wellStatus__c,
                                      Current_Operator_Name__c,County__c, State__c
                                     from Well__c where Id in: wellMap.keySet()]){

                                         wellWrap = new wellWrapper();
                                         wellWrap.well = well;
                                         wellWrap.splitPercent = wellMap.get(well.Id);
                                         wellWrapperList.add(wellWrap);
                                     }
            return wellWrapperList;
        }catch(Exception e){
            throw new AuraHandledException('Error encountered in getWellList');
        }
    }
    
    public class checkWrapper{
        @AuraEnabled
        public   String rcId{get;set;}
        @AuraEnabled
        public   String name{get;set;}
        @AuraEnabled
        public   Integer countRLI{get;set;}
        @AuraEnabled
        public   String payor{get;set;}
        @AuraEnabled
        public   String payorId{get;set;}
        @AuraEnabled
        public   String payee{get;set;}
        @AuraEnabled
        public   String payeeId{get;set;}
        @AuraEnabled
        public   String checkNumber{get;set;}
        @AuraEnabled
        public   date checkDate{get;set;}
        @AuraEnabled
        public   Decimal ownerNetValue{get;set;}
    }

    public class wellWrapper{

        @AuraEnabled
        public   Well__c well{get;set;}
        @AuraEnabled
        public decimal splitPercent{get;set;}
    }

}