//Controller class to fetch deductions related to Royalty line Item
public class DeductionController{

    @AuraEnabled
    public static List<deduction__c> getDeductions(Id recordId){
        
        List<deduction__c> dedList = [Select Id, Name, detailId__c, distributionPercent__c,EnergyLinkTypeDesc__c, GrossAmount__c, LineComment__c, OpTypeCode__c,
                OpTypeDesc__c, OwnerAmount__c, OwnerPercent__c, PrtTypeCode__c, Type__c from deduction__c where RoyaltyLineItem__c =: recordId];

                return dedList;
    }
}