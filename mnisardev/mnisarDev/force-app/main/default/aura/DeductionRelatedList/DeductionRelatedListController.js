({
	doInit : function(component, event, helper) {
		component.set('v.mycolumns', [
            {label: 'Name', fieldName: 'linkName', type: 'url', cellAttributes: { alignment: 'left' }, 
             typeAttributes: {label: { fieldName: 'Name' }, target: '_self'},sortable: true },
            { label: 'Detail Id', fieldName: 'detailId__c', type: 'text', cellAttributes: { alignment: 'left' }, sortable: true },
            { label: 'Distribution Percent', fieldName: 'distributionPercent__c', type: 'number', cellAttributes: { alignment: 'left' }, sortable: true },
            { label: 'Gross Amount', fieldName: 'GrossAmount__c', type: 'number', cellAttributes: { alignment: 'left' }, sortable: true },
            { label: 'Owner Amount', fieldName: 'OwnerAmount__c', type: 'number', cellAttributes: { alignment: 'left' }, sortable: true }
        ]);
        
        var action = component.get('c.getDeductions');
        var recordId = component.get('v.recordId');
        action.setParams({
            recordId: recordId
        });
        action.setCallback(this, function(response) {
            //component.set("v.Spinner", false);
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS") {
                result.forEach(function(record) {
                    record.linkName = '/' + record.Id;
                });
                component.set("v.data", result);
                component.set("v.listlength", result.length);
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
        
    }
})