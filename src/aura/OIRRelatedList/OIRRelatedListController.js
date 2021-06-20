({
    doInit: function(component, event, helper) {
        
        component.set('v.mycolumns', [
            {label: 'Name', fieldName: 'linkName', type: 'url', cellAttributes: { alignment: 'left' }, 
             typeAttributes: {label: { fieldName: 'Name' }, target: '_self'},sortable: true },
            { label: 'Production Month', fieldName: 'productionMonth__c', type: 'date-local', cellAttributes: { alignment: 'left'}, sortable: true },
			{ label: 'SRP Owned', fieldName: 'SRP_Owned__c', type: 'boolean', cellAttributes: { alignment: 'left'}, sortable: true},
            	{label: 'Owner Entity', fieldName: 'ownerEntityLink', type: 'url', cellAttributes: { alignment: 'left' }, 
             typeAttributes: {label: { fieldName: 'ownerEntityName' }, target: '_self'},sortable: true },
			 
			{ label: 'Net Gas Revenue', fieldName: 'ownerNetRevenueValueGas__c', type: 'currency', cellAttributes: { alignment: 'left'}, sortable: true },
            { label: 'Net Oil Revenue', fieldName: 'ownerNetRevenueValueOil__c', type: 'currency', cellAttributes: { alignment: 'left'}, sortable: true },
            { label: 'Owner Net Revenue', fieldName: 'ownerNetRevenueValue__c', type: 'currency', cellAttributes: { alignment: 'left'}, sortable: true },
            //{ label: 'Actual Total Revenue', fieldName: 'actualTotalRevenue__c', type: 'currency', cellAttributes: { alignment: 'left'}, sortable: true ,initialWidth:250},
            //{ label: 'Revenue Is Estimate', fieldName: 'revenueIsEstimate__c', type: 'boolean', cellAttributes: { alignment: 'left'} ,initialWidth:150},
        ]);
        //component.set("v.Spinner", true);
        helper.getData(component,event,helper);
            
    },
    handleSort: function(component, event, helper) {
        var sortBy = event.getParam("fieldName");
        var sortedDirection = event.getParam("sortDirection");
        component.set("v.sortedBy", sortBy);
        component.set("v.sortedDirection", sortedDirection);
        helper.sortData(component, sortBy, sortedDirection);
        
    },
    createWIA: function(component){
        component.set("v.showModal",true);
    },

    cancel: function(component){
         component.set("v.showModal",false);
    },

    save:  function(component,event,helper){
       
            var s = JSON.stringify(component.get('v.excludeRevenue'));
        var action = component.get('c.saveExcludedRevenue');
       
        action.setParams({
            recordId: component.get('v.recordId'),
            uaId: component.get('v.suaId'),
            excludedRevenue: s
        });
        action.setCallback(this, function(response) {
            //component.set("v.Spinner", false);
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS") {
                component.set("v.showModal",false);
            component.set("v.savedExcludeRevenue",s);
            	helper.getData(component,event,helper);
            	var cmpEvent = component.getEvent("modalEvent");
            	cmpEvent.fire();
            }
            });
             $A.enqueueAction(action);
    }

})