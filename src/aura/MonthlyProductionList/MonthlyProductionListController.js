({
    doInit : function(component, event, helper) {
        
        component.set('v.mycolumns', [
             {label: 'Name', fieldName: 'linkName', type: 'url', 
            typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'},sortable: true, cellAttributes: { alignment: 'left'} },
            { label: 'Production Date', fieldName: 'Production_Date__c', type: 'date-local', sortable: true, cellAttributes: { alignment: 'left'} },
            { label: 'Monthly Production (Gas)', fieldName: 'Gas__c', type: 'number', sortable: true ,cellAttributes: { alignment: 'left'}},
			{ label: 'Monthly Production (Liquid)', fieldName: 'Liquid__c', type: 'number', sortable: true,cellAttributes: { alignment: 'left'} },
        ]);
                //component.set("v.Spinner", true);
                var action = component.get('c.getAllMonthlyProduction');
                
                 action.setParams({
            'oId':component.get('v.recordId')
        });
                action.setCallback(this, function (response) {
                   //component.set("v.Spinner", false);
                    var state = response.getState();
                    var result = response.getReturnValue();
                    if (state === "SUCCESS") {
                        result.forEach(function(record){
                            record.linkName = '/'+record.Id;
                        });
                        component.set("v.monthlyProductionList", result);
            			component.set("v.monthlyProductionListlength", result.length);
            
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