({
    doInit : function(component,event,helper){	
        var email = $A.get("$SObjectType.CurrentUser.Email").split('@');
        component.set('v.folderName',email[0]);
    },
    
    handleClick : function(component, event, helper) {
		var action = component.get('c.runReUpload');
        component.set('v.loading',true);
        action.setParams({
            docId: null
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS") {
                component.set('v.loading',false);
                component.set('v.showResults',true);
                if(result.length ==='' || result.length === undefined || result.length===0){
                	component.set('v.totalChecks',"0");
                    var retStr = 'No checks to process';
                    component.set('v.retStr',retStr);
                }else if(result.length===1 && result[0].Stack_Trace__c ==='Class.RoyaltyCheckReUpload.runReUpload: line 13, column 1'){
                    var retStr = 'Folder not found';
                    component.set('v.retStr',retStr);
                }
                else{
                    component.set('v.totalChecks',result.length);
                    var validChecks =0;
                    for(var i=0;i<result.length;i++){
                        if(result[i].royaltyCheck__c !=='' && result[i].royaltyCheck__c !== undefined){
                            validChecks++;
                        }
                    }
                    component.set('v.validChecks',validChecks);
                    var retStr = 'Reprocessing '+ component.get('v.validChecks')+' out of '+component.get('v.totalChecks')+' checks.';
                    component.set('v.retStr',retStr);
                }
                
            }else{
                var retStr = 'An error encountered performing the requested operation. Please contact the admin.';
                component.set('v.retStr',retStr);
                component.set('v.loading',false);
                component.set('v.showResults',true);
            }
        });
        $A.enqueueAction(action);
	}
})