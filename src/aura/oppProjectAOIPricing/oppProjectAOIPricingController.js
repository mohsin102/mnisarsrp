({
	init: function (component, event, helper) {
		var action = component.get("c.getOppPricing2");

		action.setParams({
			'recordId': component.get('v.recordId')
		});

		action.setCallback(this, function(response){
			var responseValue = response.getReturnValue();
			console.log(JSON.stringify(responseValue));
			component.set('v.percentCovered', responseValue.percentCovered);
			component.set('v.suggestedPPA', responseValue.suggestedPPA);
			component.set('v.suggestedPricing', responseValue.suggestedPrice);
			component.set('v.targetPPA', responseValue.targetPPA);
			component.set('v.targetPricing', responseValue.targetPrice);
			component.set('v.maxPPA', responseValue.maxPPA);
			component.set('v.maxPricing', responseValue.maxPrice);
			//console.log(JSON.stringify(responseValue.pricingResults));
			//console.log(JSON.stringify(responseValue.percentAcres));
			//component.set('v.data', torData);
			component.set('v.isWaiting', false);
		});

		$A.enqueueAction(action);
	},
})