({
	init: function (component, event, helper) {
		var action = component.get("c.getFiles2");

		action.setParams({
			unitId: component.get('v.recordId')
		});

		action.setCallback(this, function(response){
			var responseValue = response.getReturnValue();
			console.dir(response);
			 responseValue.forEach(function(record){
                            console.log(JSON.stringify(record.origContentVersion));
                        });
			console.log(JSON.stringify(responseValue));
			component.set('v.data', responseValue);
			component.set('v.isWaiting', false);
		});

		$A.enqueueAction(action);
	},

	/*previewFile :function(component,event,helper){
		//var selectedPillId = e.getSource().get("v.name");
		var selectedPillId = '069V0000000lXHdIAM';
		$A.get('e.lightning:openFiles').fire({
				recordIds: [selectedPillId]
				});
	},*/
})