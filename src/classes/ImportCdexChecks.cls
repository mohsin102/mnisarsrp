/**
* @Class Name          : ImportCdexChecks
* @Description        : This class is used to parse CDEX checks of JSON format and insert all details into different CDEX related objects in salesforce  
* @Author             : Jade Tran
**/
public class ImportCdexChecks {
    
    /**
* @description : This method is fired from ImportCdexChecks aura component. 
* This method queries all checks stored in JSON format in running user's library folder 'username_CdexChecks'.
* It then fires the createCdexChecks method to parse and insert all check info into CDEX related object in salesforce
* @author : Jade Tran 
* @param : none
* @return : Map<String,String>
**/
    @AuraEnabled
    public static Map<String,String> createCdexChecksFromLibrary(){
        Map<String,String> retMap = new Map<String,String>();
        return retMap;
    }
    
    public static Map<String,String> createCdexChecksFromCallout(Id checkId){
        Map<String,String> retMap = new Map<String,String>();
        String urlStr = CDEXCalloutHelper.cdex.url;
        String checkNumber = CDEXCalloutHelper.cdex.checkNumber;
        try{
            //Get Source folder name based on running user; Get Id of source and target folders 
            CdexWrapper cdexFinalWrap = new cdexWrapper();
            cdexFinalWrap = createCdexChecks();
			if(Limits.getDmlRows() + cdexFinalWrap.checkList.size() >= limits.getLimitDmlRows()){
				throw new cdexException('Error loading CDEX Check before check Insert. DML Row Limit is: ' + Limits.getLimitDmlRows() +
										' current count is: ' + Limits.getDmlRows() + ' current insert contains: ' + cdexFinalWrap.checkList.size() +
										' records.');
			}
            if(cdexFinalWrap.checkList.size()>0){
                retMap.put('Checks',String.valueOf(cdexFinalWrap.checkList.size()));
                //Database.upsert( cdexFinalWrap.checkList, Royalty_Check__c.Check_Number__c.getDescribe().getSObjectField() ,true ) ;
                if(checkId != null){
                    cdexFinalWrap.checkList[0].Id = checkId;
                    Database.update(cdexFinalWrap.checkList);
                    
                    List<Royalty_Line_Item__c> oldRliList = [Select Id from Royalty_Line_Item__c where Royalty_Check__c =: checkId];
                    If(oldRliList.size()>0){
                        database.delete(oldRliList);
                    }
                }else{
                    Database.insert( cdexFinalWrap.checkList);
                }
                
            }
			if(Limits.getDmlRows() + cdexFinalWrap.cdexLineItemList.size() >= limits.getLimitDmlRows()){
				throw new cdexException('Error loading CDEX Check before line item Insert. DML Row Limit is: ' + Limits.getLimitDmlRows() +
										' current count is: ' + Limits.getDmlRows() + ' current insert contains: ' + cdexFinalWrap.cdexLineItemList.size() +
										' records.');
			}

            //Upsert Cdex details
            if(cdexFinalWrap.cdexLineItemList.size()>0){
                retMap.put('Details',String.valueOf(cdexFinalWrap.cdexLineItemList.size()));
                //Database.upsert( cdexFinalWrap.cdexLineItemList, Royalty_Line_Item__c.detailId__c.getDescribe().getSObjectField() ,true ) ;
                Database.insert( cdexFinalWrap.cdexLineItemList);
            }

			if(Limits.getDmlRows() + cdexFinalWrap.cdexDedLineItemList.size() >= limits.getLimitDmlRows()){
				throw new cdexException('Error loading CDEX Check before Deduction Insert. DML Row Limit is: ' + Limits.getLimitDmlRows() +
										' current count is: ' + Limits.getDmlRows() + ' current insert contains: ' + cdexFinalWrap.cdexDedLineItemList.size() +
										' records.');
			}

            //Upsert Cdex deduction
            if(cdexFinalWrap.cdexDedLineItemList.size()>0){
                retMap.put('Deductions',String.valueOf(cdexFinalWrap.cdexDedLineItemList.size()));
                //Database.upsert( cdexFinalWrap.cdexDedLineItemList, Deduction__c.detailId__c.getDescribe().getSObjectField() ,true ) ;
                Database.insert( cdexFinalWrap.cdexDedLineItemList);
            }
            
            //create Log record if any exceptions occur    
        }catch(Exception e){
            retMap.put('ERROR',String.valueOf(e.getMessage()));
            
            log__c logRec = new log__c();
            logRec.Process__c = 'Cdex Check Import';
            logRec.Status__c = 'ERROR';
            logRec.Error_Message__c = e.getMessage();
            logRec.Additional_Details__c = 'Check Number: '+checkNumber+' ---- Check Url: '+urlStr;
            logRec.Stack_Trace__c = e.getStackTraceString();
            insert logRec;
            
            energyLinkBucket__c eRec = [Select Id from energyLinkBucket__c where checkUrl__c =:urlStr Limit 1];
            eRec.invalid__c = true;
            if(e.getMessage().contains('Insert failed. First exception on row 0; first error: DUPLICATE_VALUE, duplicate value found: Check_Number__c')){
                eRec.isDuplicate__c = true;
            }
            update eRec;
            
            
        }
        return retMap;
    }
    
    /**
* @description : Parse JSON check to CdexParser wrapper instances
* @author : Jade Tran
* @param : body 
* @return : CdexWrapper 
**/
    public static CdexWrapper createCdexChecks(){
        cdexWrapper cdexFileWrap = new cdexWrapper();
        List<Royalty_Check__c> checkList = new List<Royalty_Check__c>();
        Royalty_Check__c check;
        Map<String,List<sObject>> detailTaxDeductionMap = new Map<String,List<sObject>>();
        List<Royalty_Line_Item__c> cdexLineItemList = new List<Royalty_Line_Item__c>();
        List<Deduction__c> cdexDedLineItemList = new List<Deduction__c>(); 
        //Iterate all checks in wrapper and create instances of Royalty_Check__c
        CdexParser.Check c = CDEXCalloutHelper.cdex.Check;
        //Create CDEX_Company__c instance for operator
        check = new Royalty_Check__c();
        check.source__c = 'CDEX';
        check.EnergyLInk_URL__c = CDEXCalloutHelper.cdex.url;
        CDEXCalloutHelper.cdex = null;
        check.Amount__c  = (c.TotalAmount!=null)? c.TotalAmount:0;
        check.Check_Issue_Date__c  = (c.CheckDate!=null)? date.valueOf(c.CheckDate):null;
        String checkNumberStr = string.valueOf(c.CheckNumber);
        while(checkNumberStr.indexOf('0')==0){
            checkNumberStr=checkNumberStr.replaceFirst('0','');
        }
        check.Check_Number__c  = (c.CheckNumber!=null)? checkNumberStr :null;
        check.Operator_Name__c  = (c.Operator.OrgName!=null)? c.Operator.OrgName:null;
        String ownerNumberStr = string.valueOf(c.OwnerNumber);
        while(ownerNumberStr.indexOf('0')==0){
            ownerNumberStr=ownerNumberStr.replaceFirst('0','');
        }
        check.Owner_Number__c  = (c.OwnerNumber!=null)? ownerNumberStr:null;
        check.Payee_from_Source_File__c = (c.Owner.OrgName!=null)? c.Owner.OrgName:null;
        check.Payor_from_Source_File__c = (c.Operator.OrgName!=null)? c.Operator.OrgName:null; 
        List<Account> accList = [Select Id from Account where Name =: c.Owner.OrgName];
        if(accList.size()>0){
            check.Payee_Lookup__c  = accList[0].Id;
        }
        accList = new List<Account>();
        accList = [Select Id from Account where Name =: c.Operator.OrgName];
        if(accList.size()>0){
            check.Payor_Lookup__c = accList[0].Id;
        }
        //check.InvoiceId__c  = (c.InvoiceId!=null)? String.valueOf(c.InvoiceId):null;
        
        checkList.add(check);
        
        //create check related child objects.
        detailTaxDeductionMap = createCdexLineItem(c.Properties,checkNumberStr);
        c = null;
        //Add all created instances into wrapper
        if(checkList.size()>0){
            cdexFileWrap.checkList.addAll(checkList);
            checkList= null;
        }
        cdexLineItemList.addAll((List<Royalty_Line_Item__c>)detailTaxDeductionMap.get('Detail'));
        if(cdexLineItemList.size()>0){
            cdexFileWrap.cdexLineItemList.addAll(cdexLineItemList);
            cdexLineItemList = null;
        }
        cdexDedLineItemList.addAll((List<Deduction__c>)detailTaxDeductionMap.get('Deduction'));
        if(cdexDedLineItemList.size()>0){
            cdexFileWrap.cdexDedLineItemList.addAll(cdexDedLineItemList);
            cdexDedLineItemList = null;
        }
        detailTaxDeductionMap = null;
        return cdexFileWrap;
    }
    
    /**
* @description : Method fired from createCdexChecks to create instance of Cdex properties and its related child records
* @author : Jade Tran
* @param prList 
* @param check 
* @return Map<String, List<sObject>> 
**/
    public static Map<String,List<sObject>> createCdexLineItem(List<CdexParser.Properties> prList,String checkNumber){
        
        Map<String,List<sObject>> detailTaxDeductionMap = new Map<String,List<sObject>>();
        
        
        Map<String,List<sObject>> rliDedMap;
        String PrtCostCenterCode;
        String OpCostCenterDesc;
        for(CdexParser.Properties p : prList){
            PrtCostCenterCode=  p.CostCenter.PrtCostCenterCode;
            OpCostCenterDesc = p.CostCenter.OpCostCenterDesc;
            for(CdexParser.Details detail: p.Details){
                if(detail.Taxes!=null || detail.Deductions!=null){
                    
                    rliDedMap = new Map<String,List<sObject>>();
                    rliDedMap = createCdexDeductionLineItem(checkNumber,detail,PrtCostCenterCode,OpCostCenterDesc);
                    
                    if(detailTaxDeductionMap.containsKey('Detail')){
                        
                        detailTaxDeductionMap.get('Detail').addAll((List<Royalty_Line_Item__c>)rliDedMap.get('Detail'));
                        if(detailTaxDeductionMap.containsKey('Deduction') && detailTaxDeductionMap.get('Deduction') != null){
                            detailTaxDeductionMap.get('Deduction').addAll((List<Deduction__c>)rliDedMap.get('Deduction'));
                        }else{
                            detailTaxDeductionMap.put('Deduction',(List<Deduction__c>)rliDedMap.get('Deduction'));
                        }
                    }else{
                        
                        detailTaxDeductionMap.put('Detail',(List<Royalty_Line_Item__c>)rliDedMap.get('Detail'));
                        if(rliDedMap.containsKey('Deduction') && rliDedMap.keySet().size()>0){
                            detailTaxDeductionMap.put('Deduction',(List<Deduction__c>)rliDedMap.get('Deduction'));
                        }
                    }
                }else if(detail.Taxes==null && detail.Deductions==null){
                    
                    Royalty_Line_Item__c cdexLineItemRec = new Royalty_Line_Item__c();
                    cdexLineItemRec.ownerNetValueActual__c = (detail.OwnerAmount!=null)? detail.OwnerAmount:null;
                    if(detailTaxDeductionMap.containsKey('Detail')){
                        detailTaxDeductionMap.get('Detail').add(getLineItem(checkNumber,detail,cdexLineItemRec,PrtCostCenterCode,OpCostCenterDesc));
                    }else{
                        detailTaxDeductionMap.put('Detail',new List<Royalty_Line_Item__c>{getLineItem(checkNumber,detail,cdexLineItemRec,PrtCostCenterCode,OpCostCenterDesc)});
                    }
                }
            }            
        }
        return detailTaxDeductionMap;
    }
    
    /**
* @description : Method fired from createCdexDeductionLineItem to create instance Royalty_Line_Item__c
* @author : Jade Tran
* @param detail 
* @param cdexLineItemRec 
* @return Royalty_Line_Item__c
**/
    public static Royalty_Line_Item__c getLineItem(String checkNumber,CdexParser.Details detail,Royalty_Line_Item__c cdexLineItemRec,String PrtCostCenterCode,String OpCostCenterDesc){
        Royalty_Check__c check = new Royalty_Check__c(Check_Number__c = checkNumber);
        cdexLineItemRec.detailId__c  = (detail.DetailId!=null)? String.valueOf(detail.DetailId):null;
        cdexLineItemRec.grossValueActual__c  = (detail.GrossAmount!=null)? detail.GrossAmount:null;
        cdexLineItemRec.grossVolumeActual__c  = (detail.GrossVolume!=null)? detail.GrossVolume:null;
        cdexLineItemRec.interestType__c  = (detail.OpTypeCode!=null)? detail.OpTypeCode:null;
        cdexLineItemRec.ownerValueActual__c  = (detail.OwnerAmount!=null)? detail.OwnerAmount:null;
        cdexLineItemRec.ownerVolumeActual__c  = (detail.OwnerVolume!=null)? detail.OwnerVolume:null;
        cdexLineItemRec.lineItemDecimal__c = (detail.OwnerPercent!=null)? detail.OwnerPercent/100:0; 
        cdexLineItemRec.Price__c  = (detail.Price!=null)? detail.Price:0;
        cdexLineItemRec.Product__c  = (detail.OpProductCode!=null)? detail.OpProductCode:null;
        //Commented Invalid Production month
        /*if(detail.ActivityDate!=null && Date.valueOf(detail.ActivityDate).year()>1700){
cdexLineItemRec.Production_Month__c  = (detail.ActivityDate!=null)? Date.valueOf(detail.ActivityDate):null;
}*/
        cdexLineItemRec.Production_Month__c  = (detail.ActivityDate!=null)? Date.valueOf(detail.ActivityDate):null;
        cdexLineItemRec.Property_Id__c = PrtCostCenterCode;
        cdexLineItemRec.Royalty_Check__r = check;
        cdexLineItemRec.propertyName__c = OpCostCenterDesc;
        return cdexLineItemRec;
    }
    
    
    
    /**
* @description : Method fired from createCdexLineItem to create instance of Cdex deduction
* @author : Jade Tran
* @param detail 
* @param type 
* @return List<Deduction__c> 
**/
    public static Map<String,List<sObject>> createCdexDeductionLineItem(String checkNumber,CdexParser.Details detail,String PrtCostCenterCode,String OpCostCenterDesc){
        Royalty_Line_Item__c cdexLineItemRec = new Royalty_Line_Item__c();
        cdexLineItemRec.detailId__c = (detail.DetailId!=null)? String.valueOf(detail.DetailId):null;
        Map<String,List<sObject>> rliDedMap = new Map<String,List<sObject>>();
        Royalty_Line_Item__c dummyRLI;
        List<Royalty_Line_Item__c> cdexLineItemList = new List<Royalty_Line_Item__c>();
        List<Deduction__c> cdexDedLineItemList = new List<Deduction__c>(); 
        Deduction__c cdexDedLineItemRec;
        Decimal grossAdjustmentsActual = 0.0;
        Decimal grossNetActual = 0.0;
        Decimal grossTaxesActual = 0.0;
        Decimal ownerAdjustmentsActual = 0.0;
        Decimal ownerNetValueActual = 0.0;
        Decimal ownerTaxesActual = 0.0;
        
        if(detail.Taxes!=null){
            for(CdexParser.Deductions tax: detail.Taxes){
                
                dummyRLI = new Royalty_Line_Item__c(detailId__c = cdexLineItemRec.detailId__c);
                cdexDedLineItemRec = new Deduction__c();
                cdexDedLineItemRec.detailId__c  = (tax.DetailId!=null)? String.valueOf(tax.DetailId):null;
                cdexDedLineItemRec.OpTypeCode__c  = (tax.OpTypeCode!=null)? tax.OpTypeCode:null;
                cdexDedLineItemRec.OpTypeDesc__c  = (tax.OpTypeDesc!=null)? tax.OpTypeDesc:null;
                cdexDedLineItemRec.EnergyLinkTypeDesc__c  = (tax.EnergyLinkTypeDesc!=null)? tax.EnergyLinkTypeDesc:null;
                cdexDedLineItemRec.PrtTypeCode__c  = (tax.PrtTypeCode!=null)? tax.PrtTypeCode:null;
                cdexDedLineItemRec.GrossAmount__c  = (tax.GrossAmount!=null)? tax.GrossAmount:0;
                cdexDedLineItemRec.OwnerAmount__c  = (tax.OwnerAmount!=null)? tax.OwnerAmount:0;
                cdexDedLineItemRec.type__c = 'Tax';
                cdexDedLineItemRec.RoyaltyLineItem__r = dummyRLI;
                cdexDedLineItemList.add(cdexDedLineItemRec);
                grossTaxesActual += cdexDedLineItemRec.GrossAmount__c;
                ownerTaxesActual += cdexDedLineItemRec.OwnerAmount__c;
                
            }
        }
        
        if(detail.Deductions != null){
            for(CdexParser.Deductions deduction: detail.Deductions){
                
                dummyRLI = new Royalty_Line_Item__c(detailId__c = cdexLineItemRec.detailId__c);
                cdexDedLineItemRec = new Deduction__c();
                cdexDedLineItemRec.detailId__c  = (deduction.DetailId!=null)? String.valueOf(deduction.DetailId):null;
                cdexDedLineItemRec.OpTypeCode__c  = (deduction.OpTypeCode!=null)? deduction.OpTypeCode:null;
                cdexDedLineItemRec.OpTypeDesc__c  = (deduction.OpTypeDesc!=null)? deduction.OpTypeDesc:null;
                cdexDedLineItemRec.EnergyLinkTypeDesc__c  = (deduction.EnergyLinkTypeDesc!=null)? deduction.EnergyLinkTypeDesc:null;
                cdexDedLineItemRec.PrtTypeCode__c  = (deduction.PrtTypeCode!=null)? deduction.PrtTypeCode:null;
                cdexDedLineItemRec.GrossAmount__c  = (deduction.GrossAmount!=null)? deduction.GrossAmount:0;
                cdexDedLineItemRec.OwnerAmount__c  = (deduction.OwnerAmount!=null)? deduction.OwnerAmount:0;
                cdexDedLineItemRec.type__c = 'Deductions'; 
                cdexDedLineItemRec.RoyaltyLineItem__r = dummyRLI;   
                cdexDedLineItemList.add(cdexDedLineItemRec);   
                grossAdjustmentsActual += cdexDedLineItemRec.GrossAmount__c;
                ownerAdjustmentsActual += cdexDedLineItemRec.OwnerAmount__c;
            }
        }
        grossNetActual = (detail.GrossAmount!=null)? detail.GrossAmount+ grossTaxesActual + grossAdjustmentsActual :0 + grossTaxesActual + grossAdjustmentsActual;
        ownerNetValueActual = (detail.OwnerAmount!=null)? detail.OwnerAmount+ ownerTaxesActual + ownerAdjustmentsActual:0 + ownerTaxesActual + ownerAdjustmentsActual;
        
        cdexLineItemRec.grossAdjustmentsActual__c = grossAdjustmentsActual ;
        cdexLineItemRec.grossNetActual__c = grossNetActual ;
        cdexLineItemRec.grossTaxesActual__c = grossTaxesActual ;
        cdexLineItemRec.ownerAdjustmentsActual__c = ownerAdjustmentsActual ;
        cdexLineItemRec.ownerNetValueActual__c = ownerNetValueActual ;
        cdexLineItemRec.ownerTaxesActual__c = ownerTaxesActual ;
        cdexLineItemList.add(getLineItem(checkNumber,detail,cdexLineItemRec,PrtCostCenterCode,OpCostCenterDesc));
        
        rliDedMap.put('Detail',cdexLineItemList);
        rliDedMap.put('Deduction',cdexDedLineItemList);
        return rliDedMap;
    }
    
    public class CdexWrapper{
        public  List<Royalty_Check__c> checkList = new List<Royalty_Check__c>();
        public  List<Royalty_Line_Item__c> cdexLineItemList = new List<Royalty_Line_Item__c>();
        public  List<Deduction__c> cdexDedLineItemList = new List<Deduction__c>();
    }
    
	public virtual class cdexException extends Exception{}
}