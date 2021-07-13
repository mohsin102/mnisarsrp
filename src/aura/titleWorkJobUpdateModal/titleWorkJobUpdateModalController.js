({
	
	handleCancel: function (component, event, helper) {
		component.destroy();
		
	},
	handleSuccess : function(component, event, helper) {
		//console.log('handleSuccess called.');
		$A.get('e.force:refreshView').fire();
		component.destroy();

    },
	handleLoad : function(component, event, helper){
        var record = event.getParam("recordUi");
		console.log(JSON.stringify(record));
		//console.log(record.record.titleIntegrationJobs__r.length);
		if((record.record.fields.type__c.value == "Integration Review" || record.record.fields.type__c.value == "Attorney Review") && !component.get('v.hasIntegrations')){
			component.set('v.canDelete', true);
		}
		var action = component.get('c.fetchOwner');
			action.setParams({
				'ownerId': record.record.fields.OwnerId.value
			});
			action.setCallback(this, function(response) {
				var state = response.getState();
				var result = response.getReturnValue();
				if (state === "SUCCESS") {
					//console.log(JSON.stringify(response.getReturnValue()[0]));
					component.set('v.selectedOwner', response.getReturnValue()[0]);
				} else {
					console.log(state);
				}
		});
		$A.enqueueAction(action);
		console.log('recordEditForm is loaded.');
	},
	handleDeleteRecord: function(component, event, helper) {
        component.find("recordHandler").deleteRecord($A.getCallback(function(deleteResult) {
            // NOTE: If you want a specific behavior(an action or UI behavior) when this action is successful 
            // then handle that in a callback (generic logic when record is changed should be handled in recordUpdated event handler)
            if (deleteResult.state === "SUCCESS" || deleteResult.state === "DRAFT") {
                // record is deleted
                console.log("Record is deleted.");
            } else if (deleteResult.state === "INCOMPLETE") {
                console.log("User is offline, device doesn't support drafts.");
            } else if (deleteResult.state === "ERROR") {
                console.log('Problem deleting record, error: ' + JSON.stringify(deleteResult.error));
            } else {
                console.log('Unknown problem, state: ' + deleteResult.state + ', error: ' + JSON.stringify(deleteResult.error));
            }
			$A.get('e.force:refreshView').fire();
			component.destroy();
        }));
    },

    /**
     * Control the component behavior here when record is changed (via any component)
     */
    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "CHANGED") {
           // record is changed
        } else if(eventParams.changeType === "LOADED") {
            console.log('record has loaded');
        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted, show a toast UI message
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title": "Deleted",
                "message": "The record was deleted."
            });
            resultsToast.fire();

        } else if(eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving, or deleting the record
        }
    },
	userLookupSearch : function(component, event, helper) {
        
		//console.log('Search triggered in component controller.');
        const serverSearchAction = component.get('c.searchOwners');
        // Passes the action to the Lookup component by calling the search method
        component.find('userLookup').search(serverSearchAction);
    },
	handleSubmit: function(component, event, helper) {
        event.preventDefault();       // stop the form from submitting
		var fields = event.getParam('fields');
		if(component.get('v.selectedOwner')[0]){
			fields.OwnerId = component.get('v.selectedOwner')[0].id;
		}
		
        //fields.OwnerId = '32 Prince Street';
        component.find('titleWorkJobForm').submit(fields);
    },
})