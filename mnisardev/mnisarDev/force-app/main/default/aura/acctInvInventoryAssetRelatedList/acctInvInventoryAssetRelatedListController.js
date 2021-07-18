({
	doInit: function(component, event, helper) {
        helper.getData(component);
    },
    handleApplicationEvent: function(component,event,helper){
         helper.getData(component);
    },
    handleSort: function(component, event, helper) {
        var sortBy = event.getParam("fieldName");        
        var sortedDirection = event.getParam("sortDirection");
        component.set("v.sortedBy", sortBy);
        component.set("v.sortedDirection", sortedDirection);
        
        helper.sortData(component, sortBy, sortedDirection);
        
    },
	openModal : function(component, event, helper) {
		
        $A.createComponent(
            "c:acctInvAssocInventoryAsset",
            {
                "recordId": component.get('v.recordId')
            },
            function(modal, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(modal);
                    component.set("v.body", body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }
            }
        );
	}
})