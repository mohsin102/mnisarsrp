({
	sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.data");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.data", data);
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
	populateDataTable: function(component, event){
		var searchString = component.get('v.searchString');
		var searchCounter = component.get('v.searchCounter');
		var currentResponse = component.get('v.responseValue');
		var selectedRecordId = component.get('v.selectedRecordId');
		console.log('Selected Record Id value is: ' + selectedRecordId);
		console.log('searchCounter value is: ' + searchCounter);
		//var tonRecordId = component.get('v.tonId');
		searchCounter++;
		component.set('v.searchCounter', searchCounter);
		var action = component.get("c.getNewSearchResult");
		console.log(searchCounter);
		action.setParams({
			'searchString': searchString,
			'searchCounter': searchCounter,
			'currentAccountId': selectedRecordId
			
		});

		action.setCallback(this, function(response){
			var responseValue = response.getReturnValue();
			var addAccount = {sobjectType:"taxRollRelateItemAura.accountSearchResult", Id:"addAccount", Name:"Add Account", accountSelected:false};
			responseValue.accounts.push(addAccount);
			console.log(responseValue);
			var currentSearchCounter = component.get('v.searchCounter');
			if(currentSearchCounter == responseValue.searchCounter){
				component.set('v.labelSuffix', ' based on search string "' + component.get('v.searchString') + '"');
				component.set('v.data', responseValue.accounts)

			}
		});

		$A.enqueueAction(action);

		//console.log('Make call to controller to get top ten account records for: ' + searchString + ' searchCounter set to: ' + searchCounter);
	},
})