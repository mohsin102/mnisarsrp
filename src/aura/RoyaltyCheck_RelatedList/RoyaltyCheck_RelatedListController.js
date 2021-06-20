({
    handleRecordLoad: function(component, event, helper) {
        component.set('v.mycolumns', [
            {label: 'Name', fieldName: 'rcId', type: 'url', cellAttributes: { alignment: 'left' }, 
             typeAttributes: {label: { fieldName: 'name' }, target: '_self'},sortable: true },
            { label: 'Count of line items', fieldName: 'countRLI', type: 'number', cellAttributes: { alignment: 'left' },sortable: true },
            {label: 'Payor', fieldName: 'payorId', type: 'url', cellAttributes: { alignment: 'left' }, 
             typeAttributes: {label: { fieldName: 'payor' }, target: '_self'},sortable: true },
            {label: 'Payee', fieldName: 'payeeId', type: 'url', cellAttributes: { alignment: 'left' }, 
             typeAttributes: {label: { fieldName: 'payee' }, target: '_self'},sortable: true },
            { label: 'Check Number', fieldName: 'checkNumber', type: 'text', cellAttributes: { alignment: 'left' },sortable: true },
            { label: 'Check Date', fieldName: 'checkDate', type: 'date-local', cellAttributes: { alignment: 'left' }, sortable: true },
            { label: 'Owner Net Value', fieldName: 'ownerNetValue', type: 'currency', cellAttributes: { alignment: 'left' }, sortable: true }
        ]);
        //component.set("v.Spinner", true);
        var action = component.get('c.getRoyaltyCheckList');
        action.setParams({
            recordId:component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            //component.set("v.Spinner", false);
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS") { 
                
                result.forEach(function(record) {
                     
                    record.linkName = '/' + record.Id;
                    record.lineItems = record.of_Allocated_Line_Items__c + record.of_Unallocated_Line_Items__c;
                    if(record.Payor_Lookup__c !== undefined && record.Payor_Lookup__c !== '' && record.Payor_Lookup__c !== null){
                        record.payorLink = '/' + record.Payor_Lookup__c;
                        record.payorName = record.Payor_Lookup__r.Name;
                    }
                    if(record.Payee_Lookup__c !== undefined && record.Payee_Lookup__c !== '' && record.Payee_Lookup__c !== null){
                        record.payeeLink = '/' + record.Payee_Lookup__c;
                        record.payeeName = record.Payee_Lookup__r.Name;
                    }
                    
                });
              
                component.set("v.data", result);
                component.set("v.listlength", result.length);

            } else {
                component.set('v.error',true);
            }
        });
        $A.enqueueAction(action);
        
        
    },
    handleSort: function(component, event, helper) {
        var sortBy = event.getParam("fieldName");
        var sortedDirection = event.getParam("sortDirection");
        component.set("v.sortedBy", sortBy);
        component.set("v.sortedDirection", sortedDirection);
        helper.sortData(component, sortBy, sortedDirection);
        
    },
    createNew: function(component,event,helper){
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({ 
            "entityApiName": "GIS_Update_Request__c",
            "defaultFieldValues": {
            "Unit__c":component.get('v.recordId')
            }
        });
        createRecordEvent.fire();
    }
})