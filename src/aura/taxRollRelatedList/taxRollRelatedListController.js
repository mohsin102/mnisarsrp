({
    doInit: function(component, event, helper) {
        component.set('v.isWaiting', true);
        switch(component.get('v.relatedObject')) {
		  case "TaxRollInterest__c":
			component.set('v.columns', [
            {label: 'Name', fieldName: 'linkName', type: 'url', cellAttributes: { alignment: 'left' }, 
             typeAttributes: {label: { fieldName: 'Name' }, target: '_blank', tooltip:'Open Tax Roll Interest in a new tab'},sortable: true },
			{ label: 'Tax Roll Owner Name', fieldName: 'taxRollOwnerName', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'taxRollOwnerName' }, value:{ fieldName: 'taxRollOwnerName' }}, sortable: true},
            { label: 'Account', fieldName: 'accountName', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'accountName' }, value:{ fieldName: 'accountName' }}, sortable: true},
			]);
			break;
		  
		  default:
			// code block
		}
		helper.getData(component);
    },
	refreshData: function(component, event, helper){
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