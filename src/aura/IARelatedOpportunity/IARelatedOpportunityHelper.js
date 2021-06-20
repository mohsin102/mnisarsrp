({
	getData: function(component, event, helper, relatedField){
		var action = component.get('c.getRelatedOpp');
		action.setParams({
			'recordId': component.get('v.recordId'),
			'relatedField': relatedField,

		});
		action.setCallback(this, function(response) {
			//component.set("v.Spinner", false);
			var state = response.getState();
			var result = response.getReturnValue();
			if (state === "SUCCESS") {
				console.log(component.get('v.relatedType') + ' Organizational Transfer value is: ' + result.organizationalTransfer);
				component.set("v.relatedOpportunityTract", result);
				if(!result.inactive){
					var expandEvent = component.getEvent('expandSection');
					expandEvent.setParams({
						"sectionName": component.get('v.relatedType')
					 });
					expandEvent.fire();
				}
			} else {
				console.log('Error loading record.');
			}
		});
		$A.enqueueAction(action);
	},
})