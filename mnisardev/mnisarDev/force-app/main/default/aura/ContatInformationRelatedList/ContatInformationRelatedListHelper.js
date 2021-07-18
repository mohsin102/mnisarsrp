({
	fetchRecords : function(component,event,helper) {
		var action = component.get('c.fetchContactInfo');
        var recordId = component.get('v.recordId');
        action.setParams({
            recordId: recordId
        });
        action.setCallback(this, function(response) {
            //component.set("v.Spinner", false);
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS") {
                 component.set("v.showSaveCancelBtn", false);
                component.set("v.data", result);
                component.set("v.listlength", result.length);
                if(result.length>0){
                    component.set('v.showTable',true);
                }else{
                    component.set('v.showTable',false);
                }
            } 
        });
        $A.enqueueAction(action);
	}
})