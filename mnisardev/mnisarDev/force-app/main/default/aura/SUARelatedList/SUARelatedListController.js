({
    doInit: function(component, event, helper) {
        helper.getData(component);
    },
    handleComponentEvent: function(component, event, helper){

        helper.getData(component);
    },
    handleSort: function(component, event, helper) {
        var sortBy = event.getParam("fieldName");        
        var sortedDirection = event.getParam("sortDirection");
        component.set("v.sortedBy", sortBy);
        component.set("v.sortedDirection", sortedDirection);
        if(sortBy==='linkName'){
            sortBy='Name';
        }else if(sortBy==='AccountLink'){
            sortBy='AccountName';
        }else if(sortBy==='TractLink'){
            sortBy='TractName';
        }
        
        helper.sortData(component, sortBy, sortedDirection);
        
    },

    createNewSubtract: function(component, event, helper) {

        var createSubtractEvent = $A.get("e.force:createRecord");
        createSubtractEvent.setParams({
            "entityApiName": "Subtract__c",
            "defaultFieldValues": {
                'Tract__c': component.get('v.recordId')
            }
        });
        createSubtractEvent.fire();
        /*var actionAPI = component.find("quickActionAPI");
        var fields = { tractId : { Id : "Tract__c.Id" } };
        var args = { actionName : "Subtract__c.Clone",  // Clone action on the Subtract object
        entityName : "Subtract__c", targetFields : fields };
        actionAPI.setActionFieldValues(args).then(function(result) {
        actionAPI.invokeAction(args);
        
        }).catch(function(e) {
        console.error(e.errors);
        });*/
    }
})