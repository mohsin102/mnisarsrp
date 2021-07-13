({
	handleClick : function(component, event, helper) {
		var action = component.get('c.reprocessCdexCheck');
        var recordId = component.get('v.recordId');
        action.setParams({
            checkId: recordId
        });
        component.set('v.loading',true);
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS") {
                
                if(result==='Success'){
                    
                    component.set('v.loading',false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": "success",
                        "message": "Reprocessing Complete"
                    });
                    toastEvent.fire();
                	$A.get('e.force:refreshView').fire();
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": "error",
                        "message": result
                    });
                    toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
	}
})