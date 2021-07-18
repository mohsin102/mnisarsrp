({
	handleCancel: function(component, event, helper){
		$A.get('e.force:refreshView').fire();
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

		var action = component.get("c.setRelatedRecord");
		var taxRollOwnerId = component.get('v.taxRollOwner').Id;
		var accountId = updatedRecord.response.id;
		var updateField = component.get('v.relatedFieldName');

		action.setParams({
				'recordId': taxRollOwnerId,
				'relatedRecordId': accountId,
				'updateField': updateField
			});


		action.setCallback(this, function(response){
			var responseValue = response.getReturnValue();
			if (responseValue){
					
				//console.log(responseValue);
				//var navService = component.find("navService");
				// Uses the pageReference definition in the init handler
				//var pageReference = component.get("v.pageReference");
				//event.preventDefault();
				//navService.navigate(pageReference);
				$A.get('e.force:refreshView').fire();
				component.destroy();
			}

		});

		$A.enqueueAction(action);
    }

})