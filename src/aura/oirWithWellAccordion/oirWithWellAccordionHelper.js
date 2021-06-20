({
	getData : function(component,event,helper) {
		var action = component.get('c.getWells');
        var recordId = component.get('v.recordId');
        action.setParams({
            recordId: recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS") {
                console.log(JSON.stringify(result));
                component.set("v.Wells", result);

            }
        });
        $A.enqueueAction(action);
	}
})