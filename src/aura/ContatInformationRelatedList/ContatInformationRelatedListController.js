({
    doInit : function(component, event, helper) {
        
        
        helper.fetchRecords(component, event, helper);
    },
    
    showSaveCancelButtons: function(component, event, helper) {
        
        component.set("v.showSaveCancelBtn", true);
        
    },
    Save: function(component, event, helper) {
        // Check required fields(Name) first in helper method which is return true/false
        
        // call the saveAccount apex method for update inline edit fields update 
        
        var action = component.get("c.saveContactInfo");
        action.setParams({
            'lstContactInfo': component.get("v.data"),
            'recordId':component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // set AccountList list with return value from server.
                component.set("v.showError",false);
                component.set("v.showSaveCancelBtn", false);
                helper.fetchRecords(component, event, helper);
                //$A.get('e.force:refreshView').fire();
            }else{
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.errorStr",errors[0].message);
                        component.set("v.showError",true);
                    }
                }
            }
        });
        $A.enqueueAction(action);
        
    },
    addRow: function(component, event, helper) {
        var dataLen = component.get('v.listlength');
        var newRow = {
            Phone : '',
            address : '',
            primary : false,
            Street : '',
            State : '',
            City : '',
            Country : '',
            Zipcode : '',
            Status : 'Non Verified',
            Landline: false
        };
        
        var data =component.get("v.data");
        data.push(newRow);
        if(data.length>0){
            component.set('v.showTable',true);
        }
        component.set("v.data",data);
    },
    cancel: function(component, event, helper) {
         component.set("v.showError",false);
        helper.fetchRecords(component, event, helper);
    },
    deleteRow: function(component,event,helper){
        var row = event.getParam("row");
        var rowIndex = event.getParam("rowIndex");
        var data = component.get('v.data');
        data.splice(rowIndex, 1);
        component.set('v.data',data);
        if(row.Id != null && row.Id != '' && row.Id != undefined){
            var action = component.get('c.deleteContactInfo');
            action.setParams({
                'recordId':row.Id
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    // set AccountList list with return value from server.
                    component.set("v.showError",false);
                    component.set("v.showSaveCancelBtn", false);
                    helper.fetchRecords(component, event, helper);
                }else{
                    var errors = action.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            component.set("v.errorStr",errors[0].message);
                            component.set("v.showError",true);
                        }
                    }
                }
            });
            $A.enqueueAction(action);
        }
    }
})