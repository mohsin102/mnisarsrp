({
    lookupSearch : function(component, event, helper) {
        // Get the TractLookupController.search server side action
        const serverSearchAction = component.get('c.search');
        // Passes the action to the Lookup component by calling the search method
        component.find('lookup').search(serverSearchAction);
    }
})