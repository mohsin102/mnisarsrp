({
    doInit : function(component,event,helper){	
        var email = $A.get("$SObjectType.CurrentUser.Email").split('@');
        component.set('v.folderName',email[0]);
    },
    
    handleClick : function(component, event, helper) {
		var action = component.get('c.createCdexChecksFromLibrary');
        component.set('v.loading',true);
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS") {
                component.set('v.loading',false);
                component.set('v.showResults',true);
                var retVal = [];
                for ( var key in result ) {
                    retVal.push({value:result[key], key:key});
                    if(key==="Error"){
                        component.set('v.isError',true);
                        component.set('v.errorStr',result[key]);
                    }
                }
                component.set('v.retMap',retVal);
            }
        });
        $A.enqueueAction(action);
	}
})