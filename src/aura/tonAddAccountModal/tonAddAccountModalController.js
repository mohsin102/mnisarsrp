({
	init: function (component, event, helper) {
		var navService = component.find("navService");
        // Sets the route to /lightning/o/Account/home
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                objectApiName: 'TargetOwnershipName__c',
                actionName: 'view',
				recordId: component.get('v.tonId')
            }
        };
		//console.log(pageReference);
        component.set("v.pageReference", pageReference);
        // Set the URL on the link or use the default if there's an error
        var defaultUrl = "#";
        navService.generateUrl(pageReference)
            .then($A.getCallback(function(url) {
                component.set("v.url", url ? url : defaultUrl);
            }), $A.getCallback(function(error) {
                component.set("v.url", defaultUrl);
            }));
		
		var tonId = component.get('v.tonId');
		var action = component.get("c.getCurrentTon2");
		action.setParams({
				'tonRecordId': tonId
			});

		action.setCallback(this, function(response){
				var responseValue = response.getReturnValue();
				component.set('v.ton', responseValue);
			});

		$A.enqueueAction(action);
	},
	handleCancel: function(component, event, helper){
		component.destroy();
	},
	handleSave: function(component, event, helper){
		console.log('handleSave called');
		var recordForm = component.find('recordViewForm');
		console.log('Got recordForm');
		recordForm.submit();
		
	},
    handleSuccess : function(component, event, helper) {
        var updatedRecord = JSON.parse(JSON.stringify(event.getParams()));

		var action = component.get("c.linkTONToAccount");
		var tonId = component.get('v.tonId');
		var accountId = updatedRecord.response.id;

		action.setParams({
			'tonId': tonId,
			'accountId': accountId
		});

		action.setCallback(this, function(response){
			var responseValue = response.getReturnValue();
			if (responseValue){
					
				//console.log(responseValue);
				var navService = component.find("navService");
				// Uses the pageReference definition in the init handler
				var pageReference = component.get("v.pageReference");
				event.preventDefault();
				navService.navigate(pageReference);
				$A.get('e.force:refreshView').fire();
				component.destroy();
			}

		});

		$A.enqueueAction(action);
    }

})