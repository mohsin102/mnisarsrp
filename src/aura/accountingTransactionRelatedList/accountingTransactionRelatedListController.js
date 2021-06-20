({
	doInit: function(component, event, helper) {
        helper.getData(component);
    },
    handleSort: function(component, event, helper) {
        var sortBy = event.getParam("fieldName");        
        var sortedDirection = event.getParam("sortDirection");
        component.set("v.sortedBy", sortBy);
        component.set("v.sortedDirection", sortedDirection);
        
        helper.sortData(component, sortBy, sortedDirection); 
    }

})