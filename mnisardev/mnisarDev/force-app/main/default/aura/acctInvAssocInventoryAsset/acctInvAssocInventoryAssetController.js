({
    //Method fires on load of componenet. If Royalty Line Items are associated, List of RLI related to the Property name are displayed in a table,
    // else a search bar is displayed to search for the correct Well within salesforce and associate it.
    init : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Action', fieldName: 'action', type: "button",
                 typeAttributes: {label: {fieldName: 'action'}, 
                                  name: {fieldName: 'action'}, title: 't1', disabled: {fieldName: 'disabled'},
                                  value: {fieldName: 'fn2'}, variant: 'base' }, initialWidth: 100},
			{label: 'Inventory Asset', fieldName: 'link', type: 'url', cellAttributes: { alignment: 'left' }, 
                    typeAttributes: {label: { fieldName: 'Name' }, tooltip:{fieldName: 'Name'}, target: '_self'},sortable: true, initialWidth: 150 },
            {label: 'Inventory Owner', fieldName: 'ownerLink', type: 'url', cellAttributes: { alignment: 'left' }, 
                    typeAttributes: {label: { fieldName: 'inventoryOwnerName__c' }, tooltip:{fieldName: 'inventoryOwnerName__c'}, target: '_self'},sortable: true, initialWidth: 200 },
            { label: 'Acq Close Date', fieldName: 'acquistionCloseDate__c', type: 'date-local', sortable: true, initialWidth: 150},
			{ label: 'Acq Effective Date', fieldName: 'acquisitionEffectiveDate__c', type: 'date-local', sortable: true, initialWidth: 150 },
			{label: 'Acq Opportunity', fieldName: 'acquisitionOpportunityLink', type: 'url', cellAttributes: { alignment: 'left' }, 
                    typeAttributes: {label: { fieldName: 'acquisitionOpportunityName__c' }, tooltip:{fieldName: 'acquisitionOpportunityName__c'}, target: '_self'},sortable: true, initialWidth: 250 },
            { label: 'Acq Unit Price', fieldName: 'acquisitionUnitPrice__c', type: 'currency', cellAttributes: { alignment: 'left' }, sortable: true, initialWidth: 150 },
			{ label: 'Acq Price', fieldName: 'acquisitionTotalPrice__c', type: 'currency', cellAttributes: { alignment: 'left' }, sortable: true, initialWidth: 150 },
			{label: 'Seller (Previous Owner)', fieldName: 'sellerLink', type: 'url', cellAttributes: { alignment: 'left' }, 
                    typeAttributes: {label: { fieldName: 'sellerPreviousOwnerName__c' }, tooltip:{fieldName: 'sellerPreviousOwnerName__c'}, target: '_self'},sortable: true, initialWidth: 250 },

            { label: 'Sale Close Date', fieldName: 'saleCloseDate__c', type: 'date-local', sortable: true, initialWidth: 150 },
			{ label: 'Sale Effective Date', fieldName: 'saleEffectiveDate__c', type: 'date-local', sortable: true, initialWidth: 150 },
			{label: 'Sale Opportunity', fieldName: 'saleOpportunityLink', type: 'url', cellAttributes: { alignment: 'left' }, 
                    typeAttributes: {label: { fieldName: 'saleOpportunityName__c' }, tooltip:{fieldName: 'saleOpportunityName__c'}, target: '_self'},sortable: true, initialWidth: 250 },
            { label: 'Sale Unit Price', fieldName: 'saleUnitPrice__c', type: 'currency', cellAttributes: { alignment: 'left' }, sortable: true, initialWidth: 150 },
			{ label: 'Sale Price', fieldName: 'saleTotalPrice__c', type: 'currency', cellAttributes: { alignment: 'left' }, sortable: true, initialWidth: 150 },
			{label: 'Buyer (Next Owner)', fieldName: 'buyerLink', type: 'url', cellAttributes: { alignment: 'left' }, 
                    typeAttributes: {label: { fieldName: 'buyerNextOwnerName__c' }, tooltip:{fieldName: 'buyerNextOwnerName__c'}, target: '_self'},sortable: true, initialWidth: 250 },
			
        ]);
    },
    //Method fires on click of cancel button.
    handleCancel: function (component, event, helper) {
		var appEvent = $A.get("e.c:applicationEventRefresh");
        appEvent.fire();
        component.destroy();
    },
    //Method fires on change of value of the search string, to fetch Well Name based on the search string
    handleKeyUp: function(component, event, helper){
        //console.log('keyup function called.');
		var searchCounter = parseInt(component.get('v.searchCounter'));
		searchCounter++;
		console.log('searchCounter value is: ' + searchCounter);
		component.set('v.searchCounter', searchCounter);
        var searchString = component.get('v.searchString');
        if(searchString.length > 1){
            helper.populateDataTable(component, event,helper);
        }	
    },
    //Method fires on click of column name of the data table
    updateSorting: function (component, event, helper) {
        
        var fieldName = event.getParam('fieldName');
        //console.log('fieldName value is: ' + fieldName);
        var sortDirection = event.getParam('sortDirection');
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection,helper);
    }, 
    updateAssociation: function(component, event, helper){
        var row = event.getParam('row');
		
		console.log(!row.disabled);
		if(!row.disabled){
			var data = component.get('v.data');
			for(var record in data){
				if(data[record].Id == row.Id){
					data[record].disabled = true;
				}
			}
			component.set('v.data', data);
			console.log('row value is: ' + JSON.stringify(row));
			var action = component.get("c.updateRecordAssociation");
			var searchType = component.get('v.searchType');
			action.setParams({
				'recordId' : component.get('v.recordId'),
				'inventoryAssetId' : row.Id, 
				'change' : row.action
			});

			action.setCallback(this, function(response){
					if(searchType == 'InventoryAsset__c'){
						helper.populateDataTable(component, event, helper);
					}else if (searchType == 'Opportunity'){
						helper.getAssetsByOpportunity(component,event,helper);
					}
					helper.sortData(component, component.get('v.sortedBy'), component.get('v.sortedDirection'),helper);
					var totalLineItems = component.get("v.data").length;
					component.set('v.totalLineItems',totalLineItems);
					var totalPages = Math.ceil(totalLineItems/component.get('v.pageSize'));
					component.set('v.totalPages',totalPages);
					helper.getPageData(component);
			});

			$A.enqueueAction(action);
		}
        
    },
    handleNext: function(component,event,helper){
        var pageNumber = component.get('v.pageNumber')+1;
        component.set('v.pageNumber',pageNumber);
        helper.getPageData(component);
    },
    handlePrev: function(component,event,helper){
        var pageNumber = component.get('v.pageNumber')-1;
        component.set('v.pageNumber',pageNumber);
        helper.getPageData(component);
    },
	handleSearchType: function(component, event, helper){
		console.log('component search type is: ' + component.get('v.searchType'));
		console.log(JSON.stringify(component.get('v.data')));
		component.set('v.data', []);
		console.log(JSON.stringify(component.get('v.data')));
		component.set('v.selectedOpps', []);
		component.set('v.oppIds', []);
		component.set('v.searchString', '');
		component.set('v.searchCoutner', 1);
		component.set('v.oppField', '');
		helper.sortData(component, component.get('v.sortedBy'), component.get('v.sortedDirection'),helper);
		var totalLineItems = component.get("v.data").length;
		component.set('v.totalLineItems',totalLineItems);
		var totalPages = Math.ceil(totalLineItems/component.get('v.pageSize'));
		component.set('v.totalPages',totalPages);
		helper.getPageData(component);
	},
	addOpportunity : function(component, event, helper) {
		var lookupId = event.getParam("value");
        var opps = [];
        opps = component.get('v.oppIds');
        opps.push(lookupId[0]);
        component.set('v.oppIds',opps);
        console.log('opps value is: ' + JSON.stringify(opps));
		if(opps.length){
        	helper.getAssetsByOpportunity(component,event,helper);
			component.set("v.oppField","");
			var opp = component.find("oppName");
			opp.reset();

        }//else{
         //   component.set('v.showTable',false);
        //}
       
	},
	handleRemove : function(component,event,helper){
        var oppId = event.getSource().get('v.name');
        var opps = [];
        component.get('v.oppIds').forEach(function(record){
            if(record !== oppId){
                opps.push(record);
            }
        });
        component.set('v.oppIds',opps);
        
        	helper.getAssetsByOpportunity(component,event,helper);
        
    },
})