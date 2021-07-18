({
	doInit : function(component, event, helper) {
		helper.getData(component,event,helper);
	},
    collapseAll : function(component,event,helper){
        
        component.set('v.activeSections',[]);
        var button = component.find('buttonId');
        $A.util.addClass(button, 'slds-hide');
    },
    onToggle : function(component,event,helper){
        let activeSections = component.get("v.activeSections");
        if (activeSections.length === 0) {
            var button = component.find('buttonId');
        	$A.util.addClass(button, 'slds-hide');
        }else{
            var button = component.find('buttonId');
        	$A.util.removeClass(button, 'slds-hide');
        }
    },
    handleComponentEvent: function(component,event,helper){
        helper.getData(component,event,helper);
    }
})