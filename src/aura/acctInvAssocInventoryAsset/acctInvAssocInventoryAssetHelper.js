({
    //Mthod fires to sort rows in data table
	sortData: function (cmp, fieldName, sortDirection,helper) {
        var data;
		switch(fieldName){
			case 'link':
				fieldName = 'Name';
				break;
			case 'ownerLink':
				fieldName = 'inventoryOwnerName__c';
				break;
			case 'acquisitionOpportunityLink':
				fieldName = 'acquisitionOpportunityName__c';
				break;
			case 'sellerLink':
				fieldName = 'sellerPreviousOwnerName__c';
				break;
			case 'saleOpportunityLink':
				fieldName = 'saleOpportunityName__c';
				break;
			case 'buyerLink':
				fieldName = 'buyerNextOwnerName__c'
				break;
		}
        data = cmp.get("v.data");
        helper.getPageData(cmp);
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.data", data);
		helper.getPageData(cmp);
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
		var recordId = component.get('v.recordId');
		var searchCounter = component.get('v.searchCounter');
		console.log('recordId value is: ' + recordId);
		var searchString = component.get('v.searchString');
		var action = component.get("c.getSearchResults");

		action.setParams({
			'searchString': searchString,
			'searchCounter': searchCounter
		});

		action.setCallback(this, function(response){
			var searchCounter = component.get('v.searchCounter');
			console.log('searchCounter in callback value is: ' + searchCounter);
			console.log('searchCounter from controller is: ' + response.getReturnValue().searchCounter);
			var responseValue = response.getReturnValue();
			if(responseValue.searchCounter == searchCounter){
				responseValue.inventoryAssets.forEach(function(record){
							helper.updateRecord(component, record);
                        });
				component.set('v.data', responseValue.inventoryAssets);
				helper.sortData(component, component.get('v.sortedBy'), component.get('v.sortedDirection'),helper);
				var totalLineItems = component.get("v.data").length;
				component.set('v.totalLineItems',totalLineItems);
				var totalPages = Math.ceil(totalLineItems/component.get('v.pageSize'));
				component.set('v.totalPages',totalPages);
				helper.getPageData(component);
			}
		});

		$A.enqueueAction(action);

		
	},
	updateRecord: function(component, record){
		var recordId = component.get('v.recordId');
		console.log('accounting investment value is: ' + record.accountingInvestment__c + ' recordId value is: ' + recordId);
		if(record.accountingInvestment__c == recordId){
			record.action='Remove-';
			record.disabled = false;
		}else if(record.accountingInvestment__c == '' || !record.accountingInvestment__c){
			record.action='Add+';
			record.disabled = false;
		}
		else{
			record.action='Remove-';
			record.disabled = true;
		}
		record.link =  '/' + record.Id;
		record.ownerLink = record.inventoryOwnerId__c?'/' + record.inventoryOwnerId__c:''; 
		record.acquisitionOpportunityLink = record.acquisitionOpportunityId__c?'/' + record.acquisitionOpportunityId__c:'';
		record.saleOpportunityLink = record.saleOpportunityId__c?'/' + record.saleOpportunityId__c:'';
		record.sellerLink = record.sellerPreviousOwnerId__c?'/' + record.sellerPreviousOwnerId__c:'';
		record.buyerLink = record.buyerNextOwnerId__c?'/' + record.buyerNextOwnerId__c:'';
	},
	getAssetsByOpportunity: function(component,event,helper){
		//console.log('make apex server call to get records from list of Opportunities');
		var recordId = component.get('v.recordId');
		var action = component.get("c.getOpportunitySearchResults");
		action.setParams({
			opportunityIds: component.get('v.oppIds')
		});

		action.setCallback(this, function(response){
			
			var responseValue = response.getReturnValue();
			responseValue.inventoryAssets.forEach(function(record){
						helper.updateRecord(component, record);
                    });
			component.set('v.data', responseValue.inventoryAssets);
			console.log(JSON.stringify(component.get('v.data')));
			helper.sortData(component, component.get('v.sortedBy'), component.get('v.sortedDirection'),helper);
			var totalLineItems = component.get("v.data").length;
			component.set('v.totalLineItems',totalLineItems);
			var totalPages = Math.ceil(totalLineItems/component.get('v.pageSize'));
			component.set('v.totalPages',totalPages);
			helper.getPageData(component);
			if(responseValue.opps){
                component.set('v.selectedOpps',responseValue.opps);
            }
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
		console.log('Total pages is: ' + component.get('v.totalPages') + 'pageNumber is: ' + pageNumber);
        if(component.get('v.totalPages') === pageNumber){
            component.set('v.isLastPage',true);
        }
		else{
			component.set('v.isLastPage',false);
		}
    }
})