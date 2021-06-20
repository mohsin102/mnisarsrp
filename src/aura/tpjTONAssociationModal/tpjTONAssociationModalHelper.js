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
		console.log('searchCounter value is: ' + searchCounter);
		var tonRecordId = component.get('v.tonId');
		searchCounter++;
		component.set('v.searchCounter', searchCounter);
		var action = component.get("c.getSearchResults");

		action.setParams({
			'searchCounter': searchCounter,
			'searchString': searchString,
			'tonRecordId': tonRecordId
		});

		action.setCallback(this, function(response){
			var responseValue = response.getReturnValue();
			var addAccount = {sobjectType:"tpjTONListAura.accountSearchResult", Id:"0", Name:"Add Account"};
			//console.log(responseValue);
			var currentSearchCounter = component.get('v.searchCounter');
			if(currentSearchCounter == responseValue.searchCounter){
				responseValue.accounts.push(addAccount);
				component.set('v.data', responseValue.accounts);
				component.set('v.ton', responseValue.currentTon);
				component.set('v.canUnlink', !responseValue.hasLockedTots);
			}
		});

		$A.enqueueAction(action);

		//console.log('Make call to controller to get top ten account records for: ' + searchString + ' searchCounter set to: ' + searchCounter);
	},
})