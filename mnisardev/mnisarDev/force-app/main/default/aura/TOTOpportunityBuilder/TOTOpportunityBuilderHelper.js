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

	getAccountID: function(component, event, helper){
	        var action = component.get('c.getAccountID');
            var tId= component.get('v.recordId');
            action.setParams({
            tonRecordId : tId
            });
            action.setCallback(this, function (response) {
            //component.set("v.Spinner", false);
                var state = response.getState();
                var result = response.getReturnValue();
                if (state === "SUCCESS") {
                   component.set('v.accountId', result);
				   if(result!=undefined && result!=null && result!=''){
                        
                            component.set('v.canCreate', true);
                        }
				                   }
            });
            $A.enqueueAction(action);
			}
})