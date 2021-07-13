({
	sortData: function (component, fieldName, sortedDirection) {
        var data = component.get("v.data");
        var reverse = sortedDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse))
        component.set("v.data", data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a)?key(a):'', b = key(b)?key(b):'', reverse * ((a > b) - (b > a));
        }
	},
	getData: function (component){
			component.set('v.mycolumns', [
           {label: 'Accounting Investment', fieldName: 'aiLink', type: 'url', cellAttributes: { alignment: 'left' }, 
                         typeAttributes: {label: { fieldName: 'Name' }, target: '_self'},sortable: true },
            { label: 'Investment ID', fieldName: 'investmentID__c', type: 'String', sortable: true },
			{label: 'Created At', fieldName: 'CreatedDate', type: 'date', typeAttributes:{
																						year: "numeric",
																						month: "2-digit",
																						day: "2-digit",
																						hour: "2-digit",
																						minute: "2-digit"
																					}},
			{label: 'Updated At', fieldName: 'LastModifiedDate', type: 'date', typeAttributes:{
																						year: "numeric",
																						month: "2-digit",
																						day: "2-digit",
																						hour: "2-digit",
																						minute: "2-digit"
																					}},
			/*{ label: 'Total Cost/Proceeds', fieldName: 'totalCostProceeds__c', type: 'currency', sortable: true },
            { label: 'Total Cost Basis (from Assets)', fieldName: 'totalCostBasis__c', type: 'currency', sortable: true },*/
                    ]);
        
        
        var recordId = component.get('v.recordId'); 
        var action = component.get('c.getAccountingInvestment');
		action.setParams({
            recordId: recordId
        });
        action.setCallback(this, function(response) {
            //component.set("v.Spinner", false);
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS") {
                result.forEach(function(record) {
                  
                    record.aiLink = '/' + record.Id;
                });
                component.set("v.data", result);
                
            }
        });
            $A.enqueueAction(action);
    }
})