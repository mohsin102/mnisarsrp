({
    doInit : function(component, event, helper) {
        component.set('v.mycolumns', [
            { label: 'Well Interest Revenue Name', fieldName: 'RevenueNamelinkName', type: 'url', cellAttributes: { alignment: 'left'}, 
             typeAttributes: { label: { fieldName:'RevenueName' }, target:'_blank'}, initialWidth:150, sortable: true },
            { label: 'Production Month', fieldName: 'Production_Month__c', type: 'date-local', cellAttributes: { alignment: 'left'}, sortable: true },
            { label: 'SRP Owned', fieldName: 'SRP_Owned__c', type: 'boolean', cellAttributes: { alignment: 'left'}, sortable: true},
            { label: 'Net Gas Revenue', fieldName: 'Well_Net_Revenue_Value_Gas__c', type: 'currency', cellAttributes: { alignment: 'left'}, sortable: true },
            { label: 'Net Oil Revenue', fieldName: 'Well_Net_Revenue_Value_Oil__c', type: 'currency', cellAttributes: { alignment: 'left'}, sortable: true },
            { label: 'Owner Net Revenue', fieldName: 'Owner_Net_Revenue_Value__c', type: 'currency', cellAttributes: { alignment: 'left'}, sortable: true },
            { label: 'Actual Total Revenue', fieldName: 'Actual_Total_Revenue__c', type: 'currency', cellAttributes: { alignment: 'left'}, sortable: true },
            { label: 'Revenue Is Estimate', fieldName: 'Revenue_Is_Estimate__c', type: 'boolean', cellAttributes: { alignment: 'left'} },
        ]);
            //component.set("v.Spinner", true);
            var action = component.get('c.getAllWellInterestRevenue');
            action.setParams({
            	'recId':component.get('v.recordId')
            });
            action.setCallback(this, function (response) {
            //component.set("v.Spinner", false);
                var state = response.getState();
                var result = response.getReturnValue();
                if (state === "SUCCESS") {
                    result.forEach(function(record){
                        record.linkName = '/'+record.Id;
                        record.RevenueNamelinkName = '/'+record.Id;
                        if (record.Name) {
                             record.RevenueName = record.Name;
                        }
                           
                    });
                    component.set("v.wellInterstList", result);
                    component.set("v.WellListlength", result.length);
                
                } 
            });
            $A.enqueueAction(action);
            },
            handleSort : function(component,event,helper){
                var sortBy = event.getParam("fieldName");
                var sortDirection = event.getParam("sortDirection");
                component.set("v.sortBy",sortBy);
                component.set("v.sortDirection",sortDirection);
                helper.sortData(component,sortBy,sortDirection);
            },
            
 })