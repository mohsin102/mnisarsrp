({
    doInit: function(component, event, helper) {
        component.set('v.isWaiting', true);
		helper.getData(component, helper);
    },
    handleComponentEvent: function(component, event, helper){

        helper.getData(component, helper);
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
    },

    loadMoreData: function (component, event, helper) {
        //Display a spinner to signal that data is being loaded
        event.getSource().set("v.isLoading", true);
        //Display "Loading" when more data is being loaded
        component.set('v.loadMoreStatus', 'Loading');
        if (component.get('v.tableData').length >= component.get('v.totalNumberOfRows')) {
			component.set('v.enableInfiniteLoading', false);
            //component.set('v.loadMoreStatus', 'No more data to load');
        } else {
			console.log('appending to datatable');
			var currentData = component.get('v.data');
			var tableData = component.get('v.tableData');
			var loadedRows = component.get('v.loadedRows');
            //Appends new data to the end of the table
			console.log('tableData length before concat is: ' + tableData.length);
            var newData = tableData.concat(currentData.slice(loadedRows,loadedRows + component.get('v.rowsToLoad')));
			console.log('newData length is: ' + newData.length);
			component.set('v.tableData', newData);
            component.set('v.loadMoreStatus', '');
			component.set('v.loadedRows', newData.length);
        }
		helper.setStatusMessage(component, helper);
        event.getSource().set("v.isLoading", false);
        
    }
})