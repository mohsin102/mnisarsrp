({
    sortData: function (component, fieldName, sortedDirection) {
        var data = component.get("v.data");
        var reverse = sortedDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        console.log('---11---'+sortedDirection);
        data.sort(this.sortBy(fieldName, reverse))
        component.set("v.data", data);
    },
    sortBy: function (field, reverse, primer) {
        console.log('---2---'+reverse);
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a)?key(a):'', b = key(b)?key(b):'', reverse * ((a > b) - (b > a));
        }
    },
	getData: function(component){
		component.set('v.isWaiting', true);
		var action = component.get('c.getRelatedHistory');
		var recordId = component.get('v.recordId');
		var primaryObjectType = component.get('v.sObjectName');
		action.setParams({
			recordId: recordId,
			primaryObjectType: primaryObjectType
		});
		action.setCallback(this, function(response) {
			//component.set("v.Spinner", false);
			var state = response.getState();
			var result = response.getReturnValue();
			if (state === "SUCCESS") {
				result.forEach(function(record) {
						record.userName = record.changedBy__r.Name;
						record.userLink = '/' + record.changedBy__c;
					});
				component.set("v.data", result);
				component.set("v.listlength", result.length);
				component.set('v.isWaiting', false);
				if(result.length>10){
				console.log('Length is greater than 10');
				var tableDiv = component.find("tableDiv");
				console.log(tableDiv);
				$A.util.addClass(tableDiv, 'maxHeight');
			}
			//alert('Table should be refreshed.');
			} else {
				alert(state);
				component.set('v.isWaiting', false);
			}
			
			
		});
		$A.enqueueAction(action);
			
	},
    
})