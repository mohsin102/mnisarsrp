({
    //Mthod fires to sort rows in data table
	sortData: function (cmp, fieldName, sortDirection,helper) {
         var data;
        if(cmp.get('v.isAssociated')){
            data =  cmp.get("v.rliData");
        }else{
           data =  cmp.get("v.data");
           helper.getPageData(cmp);
        }
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse))
        if(cmp.get('v.isAssociated')){
            cmp.set("v.rliData", data);
        }else{
           cmp.set("v.data", data);
           helper.getPageData(cmp);
        }
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
    //Method fires to fetch List of Well records that matches the search string
    populateDataTable: function(component, event,helper){
		var searchString = component.get('v.searchString');
		var action = component.get("c.getSearchResults");

		action.setParams({
			'searchString': searchString
		});

		action.setCallback(this, function(response){
			var responseValue = response.getReturnValue();
				responseValue.forEach(function(record){
                            record.add='Add+';
                        });
            component.set('v.data', responseValue);
            helper.getPageData(component);
            var totalLineItems = component.get("v.data").length;
            component.set('v.totalLineItems',totalLineItems);
            var totalPages = Math.ceil(totalLineItems/component.get('v.pageSize'));
            component.set('v.totalPages',totalPages);
		});

		$A.enqueueAction(action);

		
	},
    //Method fires to fetch RLI records to populate on the data table
    populateRLIDataTable: function(component, event){
		var searchString = component.get('v.searchString');
		var action = component.get("c.getRLIData");

		action.setParams({
			'rliIds': component.get('v.rliIds')
		});

		action.setCallback(this, function(response){
			var responseValue = response.getReturnValue();
            responseValue.forEach(function(record){
                            record.link = '/'+record.Id;
                            if(record.Well__c){
                                record.linkProperty = '/'+record.Well__c;
                            }
            				if (record.Well__c) record.PropertyName = record.Well__r.Name;
                        });
				component.set('v.rliData', responseValue);
			
		});

		$A.enqueueAction(action);
    },
    getPageData:function  (component){
        var pageNumber = component.get('v.pageNumber')
        var data = component.get('v.data');
        var pageSize = component.get('v.pageSize');
        var pageData= data.slice((pageNumber - 1) * pageSize, pageNumber * pageSize);
        pageData = data.slice((pageNumber - 1) * pageSize, pageNumber * pageSize);
        component.set('v.pageData',pageData);
        var h = 2.85*pageData.length+2;
        
        component.set('v.height',"height:"+h+"rem");
        if(component.get('v.totalPages') === pageNumber){
            component.set('v.isLastPage',true);
        }else{
            component.set('v.isLastPage',false);
        }
        if(pageData.length===0){
			component.set('v.isLastPage',true);
			component.set('v.pageNumber',1);            
        }
    }
})