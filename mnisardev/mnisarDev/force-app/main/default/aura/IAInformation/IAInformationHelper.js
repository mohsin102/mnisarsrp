({
	getData: function(component, setActiveSection){
		component.set('v.isWaiting', true);

		var action = component.get('c.getInventoryAsset');
		var recordId = component.get('v.recordId');
		action.setParams({
			recordId: recordId
		});
		action.setCallback(this, function(response) {
			//component.set("v.Spinner", false);
			var state = response.getState();
			var result = response.getReturnValue();
			if (state === "SUCCESS") {
                
				/*result.forEach(function(record) {
					record.linkName = '/' + record.Id;
				});*/
				component.set("v.currentRecord", result);
			} else {
				var toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							"title": "Error!",
							"message": "Error retrieving record.  Please contact the Salesforce Team.",
							"type":"error",
							mode: 'sticky',
						});
			}
			component.set('v.isWaiting', false);
		});
		$A.enqueueAction(action);
	},
})