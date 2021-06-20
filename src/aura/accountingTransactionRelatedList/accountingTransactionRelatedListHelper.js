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
           {label: 'Name', fieldName: 'AtLink', type: 'url', cellAttributes: { alignment: 'left' }, 
                         typeAttributes: {label: { fieldName: 'Name' }, target: '_self'},sortable: true },
            { label: 'Trade Date', fieldName: 'tradeDate__c', type: 'date-local', sortable: true },
			{ label: 'TXN No', fieldName: 'transactionNumber__c', type: 'text', cellAttributes: { alignment: 'left' }, sortable: true },
			{ label: 'Investment Type Description', fieldName: 'investmentTypeDescription__c', type: 'text', sortable: true },
			{ label: 'Recon Type', fieldName: 'reconciliationType__c', type: 'text', sortable: true},
			{ label: 'Quantity', fieldName: 'quantity__c', type: 'number', sortable: true, typeAttributes: {minimumFractionDigits:4} },
			/*{ label: 'Reconciliation Type', fieldName: 'reconciliationType__c', type: 'comboboxExtended', 
				typeAttributes: {value: { fieldName: 'reconciliationType__c' }, variant:'label-hidden', options:[{ label: 'Cost', value: 'Cost' },{ label: 'Sales', value: 'Sales' }] }, sortable: true },*/
			{ label: 'Cost/Proceeds', fieldName: 'costProceeds__c', type: 'currency', sortable: true },
			{ label: 'Investment ID', fieldName: 'investmentIdLink', type: 'url', cellAttributes: { alignment: 'left' }, 
                         typeAttributes: {label: { fieldName: 'investmentIdName' }, target: '_self'},sortable: true },
			//{ label: 'Settle Date', fieldName: 'settleDate__c', type: 'date-local', sortable: true },
            //{ label: 'Cost/Proceeds', fieldName: 'costProceeds__c', type: 'currency', sortable: true },
            //{ label: 'Trade Date', fieldName: 'tradeDate__c', type: 'date-local', sortable: true },
            //{ label: 'Transaction Description', fieldName: 'transactionDescription__c', type: 'currency', sortable: true },
            //{ label: 'Description', fieldName: 'description__c', type: 'currency', sortable: true },    

            
			
        ]);
        var action = component.get('c.getAccountingTransaction');
        var recordId = component.get('v.recordId'); 
        action.setParams({
            recordId: recordId
        });
        action.setCallback(this, function(response) {
            //component.set("v.Spinner", false);
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS") {
                result.forEach(function(record) {
                    if(record.investment__c !== undefined && record.investment__c != null){
                    	record.investmentIdLink = '/' + record.investment__c;
						record.investmentIdName = record.investment__r.Name;
                    }
                    record.AtLink = '/' + record.Id;
                });
                component.set("v.data", result);
                
            }
        });
            $A.enqueueAction(action);
    }
})