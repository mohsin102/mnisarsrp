({
	init: function (component, event, helper) {
		var action = component.get('c.fetchDefaultOwner');
		action.setCallback(this, function(response) {
			var state = response.getState();
			var result = response.getReturnValue();
			if (state === "SUCCESS") {
                
				console.log(response.getReturnValue()[0]);
				component.set('v.selectedOwner', response.getReturnValue()[0]);
				

			} else {
				alert(state);
			}
		});
		$A.enqueueAction(action);
		
	},
    handleSuccess : function(component, event, helper) {
        var payload = event.getParams();
        //console.log(JSON.stringify(payload));
		//console.log(payload.response.id);
		$A.get('e.force:refreshView').fire();
		var navService = component.find("navService");
		// Sets the route to /lightning/o/Account/home
		var pageReference = {
			type: 'standard__recordPage',
			attributes: {
				objectApiName: 'TitleIntegrationJob__c',
				actionName: 'view',
				recordId: payload.response.id
			}
		};
		navService.navigate(pageReference);
		component.destroy();

    },
	handleCancel: function (component, event, helper) {
		component.destroy();
		
	},
	handleSubmit: function(component, event, helper) {
		console.log('custom submit called');
        event.preventDefault();       // stop the form from submitting
        var fields = event.getParam('fields');
        fields.landGridTract__c = component.get('v.landGridTractId');
		fields.titleWorkJob__c = component.get('v.titleWorkJobId');
		if(component.get('v.selectedOwner')[0]){
			fields.OwnerId = component.get('v.selectedOwner')[0].id;
		}
        component.find('titleIntegrationJobForm').submit(fields);
    },
	userLookupSearch : function(component, event, helper) {
        
		//console.log('Search triggered in component controller.');
        const serverSearchAction = component.get('c.searchOwnersTIJ');
        // Passes the action to the Lookup component by calling the search method
        component.find('userLookup').search(serverSearchAction);
    },

})