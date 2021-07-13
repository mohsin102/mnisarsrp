/**
 * Created by Nathan.Shulman on 7/17/2019.
 */

public with sharing class RoyaltyCheckExtension {
    public Royalty_Check__c selCheck {get; set;}
    public String operatorName {get; set;}

    public String getUniqueName() {
        // Build the name to display
        String UniqueString =  '';//(selCheck.Payor__c == null ? '[payor]' : selCheck.Payor__c);
        UniqueString += ' #' + (selCheck.Check_Number__c == null ? '[check no.]' : selCheck.Check_Number__c);
        UniqueString += ' ' + (selCheck.Check_Issue_Date__c == null ? '[date]' : selCheck.Check_Issue_Date__c.format());
        UniqueString += ' $' + (selCheck.Amount__c == null ? '[amt]' : String.valueOf(selCheck.Amount__c));
        return UniqueString;
    }

    public RoyaltyCheckExtension (ApexPages.StandardController rcController) {
        // Create a new check, or load existing check
        Id selId = rcController.getId();
        if (selCheck == null && selId == null) {
            selCheck = new Royalty_Check__c();
            operatorName = ApexPages.currentPage().getParameters().get('on');
            if (operatorName != null) {
                System.debug('op ' + operatorName);
                selCheck.Operator_Name__c = operatorName;
                //selCheck.Payor__c = operatorName;
            }
        } else {
            selCheck = [SELECT Id, Name, Operator_Name__c, Amount__c, Check_Issue_Date__c, Owner_number__c,
                    Check_Number__c, Description__c,  Notes__c
            FROM Royalty_Check__c WHERE Id =: selId];
        }
    }

    public PageReference saveNew() {
        return saveCheck(Page.RoyaltyCheckEdit);
    }

    public PageReference save() {
        return saveCheck(null);
    }

    private PageReference saveCheck(PageReference nextPage) {
        Boolean isValid = true;

        /*if (String.IsBlank(selCheck.Payor__c)) {
            isValid = false;
            selCheck.Payor__c.addError('Payor is required.');
        }*/

        if (String.IsBlank(selCheck.Operator_Name__c)) {
            isValid = false;
            selCheck.Operator_Name__c.addError('Operator is required.');
        }

        if (String.IsBlank(selCheck.Check_Number__c)) {
            isValid = false;
            selCheck.Check_Number__c.addError('Check Number is required.');
        }

        if (selCheck.Check_Issue_Date__c == null) {
            isValid = false;
            selCheck.Check_Issue_Date__c.addError('Issue Date is required.');
        }

        if (selCheck.Amount__c == null) {
            isValid = false;
            selCheck.Amount__c.addError('Amount is required.');
        }

        if (isValid) {
            selCheck.Description__c = getUniqueName();
            upsert selCheck;
            PageReference tractPage = nextPage;
            if (tractPage == null) {
                tractPage = new PageReference('/'+selCheck.Id);
            }

            tractPage.setRedirect(true);
            return tractPage;
        }
        else {
            return null;
        }

    }
}