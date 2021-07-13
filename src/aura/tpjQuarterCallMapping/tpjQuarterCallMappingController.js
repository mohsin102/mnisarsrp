({
	init: function (component, event, helper) {
		component.set('v.isWaiting', true);
		component.set('v.sortedBy', 'tonName');
		component.set('v.sortedDirection', 'ASC');

		var recordId = component.get("v.recordId");
		var action = component.get("c.getMappings");

		action.setParams({
			recordId: recordId
		});

		action.setCallback(this, function(response){
			var responseValue = response.getReturnValue();
			console.log('response size is: ' + responseValue.length);
            component.set('v.data', responseValue);
			component.set('v.isWaiting', false);
		});

		$A.enqueueAction(action);

    },

	updateMapping: function(component, event, helper){
		var mappings = component.get("v.data");
		var recordId = component.get("v.recordId");
		var action = component.get("c.updateMappings");

		action.setParams({
			mappings: mappings,
			recordId: recordId
		});

		action.setCallback(this, function(response){
			var responseValue = response.getReturnValue();
			//console.log('response size is: ' + responseValue.length);
            //component.set('v.data', responseValue);
			//component.set('v.isWaiting', false);
		});

		$A.enqueueAction(action);
	},

	lockMapping: function(component, event, helper){
		var recordId = component.get("v.recordId");
		var action = component.get("c.lockQuarterCallMap");

		action.setParams({
			recordId: recordId
		});

		action.setCallback(this, function(response){
			var responseValue = response.getReturnValue();
			//console.log('response size is: ' + responseValue.length);
            //component.set('v.data', responseValue);
			//component.set('v.isWaiting', false);
			$A.get('e.force:refreshView').fire();
		});

		$A.enqueueAction(action);
	},
})