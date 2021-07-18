({
    init: function (component, event, helper) {
        component.set('v.newTotData', null);
		component.set('v.torSortedBy', 'Id');
		component.set('v.torSortedDirection', 'ASC');
		component.set('v.totSortedBy', 'Id');
		component.set('v.totSortedDirection', 'ASC');

		
		component.set('v.columns', [
			{label: 'TOR Group', fieldName: 'torGroupNum__c', type: 'number', editable: true, typeAttributes: { required: false, maximumFractionDigits:0, step:1 }, sortable: true, initialWidth:125},
			{label: 'TOR Name', fieldName: 'link__c', type: 'url',typeAttributes: {label: { fieldName: 'Name' }, target: '_blank', tooltip:'Open TOR in a new tab'}, sortable: true, initialWidth:150},
			{label: 'Name', fieldName: 'tonName__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'tonName__c' }, value:{ fieldName: 'tonName__c' }}, sortable: true, initialWidth:250},
			{label: 'Inst', fieldName: 'instrumentType__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'instrumentType__c' }, value:{ fieldName: 'instrumentType__c' }}, sortable: true, initialWidth:75},
			//{label: 'Area', fieldName: 'area__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'area__c' }, value:{ fieldName: 'area__c' }}, sortable: true, initialWidth:100},
			{label: 'Quarter Call', fieldName: 'quarterCall__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'quarterCallNote' }, value:{ fieldName: 'quarterCall__c' }}, sortable: true, initialWidth:100},
			{label: 'Depth', fieldName: 'depth__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'depth__c' }, value:{ fieldName: 'depth__c' }}, sortable: true, initialWidth:200},
			{label: 'Executive', fieldName: 'executive__c', type: 'numberExtended', editable: false, typeAttributes:{title:{ fieldName: 'executive__c' }, value:{ fieldName: 'executive__c' }, maximumFractionDigits:"10"}, sortable: true, initialWidth:100, cellAttributes:{alignment: 'left'}},
			{label: 'Bonus', fieldName: 'bonus__c', type: 'numberExtended', editable: false, typeAttributes:{title:{ fieldName: 'bonus__c' }, value:{ fieldName: 'bonus__c' }, maximumFractionDigits:"10"}, sortable: true, initialWidth:100, cellAttributes:{alignment: 'left'}},
			{label: 'Royalty', fieldName: 'royalty__c', type: 'numberExtended', editable: false, typeAttributes:{title:{ fieldName: 'royalty__c' }, value:{ fieldName: 'royalty__c' }, maximumFractionDigits:"10"}, sortable: true, initialWidth:100, cellAttributes:{alignment: 'left'}},
			{label: 'WI', fieldName: 'wi__c', type: 'numberExtended', editable: false, typeAttributes:{title:{ fieldName: 'wi__c' }, value:{ fieldName: 'wi__c' }, maximumFractionDigits:"10"}, sortable: true, initialWidth:100, cellAttributes:{alignment: 'left'}},
			{label: 'NRI', fieldName: 'nri__c', type: 'numberExtended', editable: false, typeAttributes:{title:{ fieldName: 'nri__c' }, value:{ fieldName: 'nri__c' }, maximumFractionDigits:"10"}, sortable: true, initialWidth:100, cellAttributes:{alignment: 'left'}},
			{label: 'LOR', fieldName: 'lor__c', type: 'numberExtended', editable: false, typeAttributes:{title:{ fieldName: 'lor__c' }, value:{ fieldName: 'lor__c' }, maximumFractionDigits:"10"}, sortable: true, initialWidth:100, cellAttributes:{alignment: 'left'}},
			{label: 'OI', fieldName: 'oi__c', type: 'numberExtended', editable: false, typeAttributes:{title:{ fieldName: 'oi__c' }, value:{ fieldName: 'oi__c' }, maximumFractionDigits:"10"}, sortable: true, initialWidth:100, cellAttributes:{alignment: 'left'}},
			{label: 'Gross Ac', fieldName: 'grossAc__c', type: 'numberExtended', editable: false, typeAttributes:{title:{ fieldName: 'grossAc__c' }, value:{ fieldName: 'grossAc__c' }, maximumFractionDigits:"10"}, sortable: true, initialWidth:100, cellAttributes:{alignment: 'left'}},
			{label: 'Lease LOR', fieldName: 'leaseLOR__c', type: 'numberExtended', editable: false, typeAttributes:{title:{ fieldName: 'leaseLOR__c' }, value:{ fieldName: 'leaseLOR__c' }, maximumFractionDigits:"10"}, sortable: true, initialWidth:100, cellAttributes:{alignment: 'left'}},
			{label: 'Lease', fieldName: 'lease__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'lease__c' }, value:{ fieldName: 'lease__c' }}, sortable: true, initialWidth:100},
			{label: 'Book/Page', fieldName: 'bookPageFrm__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'bookPageFrm__c' }, value:{ fieldName: 'bookPageFrm__c' }}, sortable: true, initialWidth:100},
			{label: 'County', fieldName: 'county__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'county__c' }, value:{ fieldName: 'county__c' }}, sortable: true, initialWidth:100},
		]);

		component.set('v.readOnlyColumns', [
			{type: 'text', editable: false,  initialWidth:32},
			{label: 'TOR Group', fieldName: 'torGroupNum__c', type: 'number', editable: false, typeAttributes: { required: true, maximumFractionDigits:0 }, sortable: true, initialWidth:125},
			{label: 'TOR Name', fieldName: 'link__c', type: 'url',typeAttributes: {label: { fieldName: 'Name' }, target: '_blank', tooltip:'Open TOR in a new tab'}, sortable: true, initialWidth:150},
			{label: 'Name', fieldName: 'tonName__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'tonName__c' }, value:{ fieldName: 'TargetOwnershipName__r.Name' }}, sortable: true, initialWidth:250},
			{label: 'Inst', fieldName: 'instrumentType__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'instrumentType__c' }, value:{ fieldName: 'instrumentType__c' }}, sortable: true, initialWidth:75},
			{label: 'Quarter Call', fieldName: 'quarterCall__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'quarterCallNote' }, value:{ fieldName: 'quarterCall__c' }}, sortable: true, initialWidth:100},
			//{label: 'Area', fieldName: 'area__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'area__c' }, value:{ fieldName: 'area__c' }}, sortable: true, initialWidth:100},
			{label: 'Depth', fieldName: 'depth__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'depth__c' }, value:{ fieldName: 'depth__c' }}, sortable: true, initialWidth:200},
			{label: 'Executive', fieldName: 'executive__c', type: 'numberExtended', editable: false, typeAttributes:{title:{ fieldName: 'executive__c' }, value:{ fieldName: 'executive__c' }, maximumFractionDigits:"10"}, sortable: true, initialWidth:100, cellAttributes:{alignment: 'left'}},
			{label: 'Bonus', fieldName: 'bonus__c', type: 'numberExtended', editable: false, typeAttributes:{title:{ fieldName: 'bonus__c' }, value:{ fieldName: 'bonus__c' }, maximumFractionDigits:"10"}, sortable: true, initialWidth:100, cellAttributes:{alignment: 'left'}},
			{label: 'Royalty', fieldName: 'royalty__c', type: 'numberExtended', editable: false, typeAttributes:{title:{ fieldName: 'royalty__c' }, value:{ fieldName: 'royalty__c' }, maximumFractionDigits:"10"}, sortable: true, initialWidth:100, cellAttributes:{alignment: 'left'}},
			{label: 'WI', fieldName: 'wi__c', type: 'numberExtended', editable: false, typeAttributes:{title:{ fieldName: 'wi__c' }, value:{ fieldName: 'wi__c' }, maximumFractionDigits:"10"}, sortable: true, initialWidth:100, cellAttributes:{alignment: 'left'}},
			{label: 'NRI', fieldName: 'nri__c', type: 'numberExtended', editable: false, typeAttributes:{title:{ fieldName: 'nri__c' }, value:{ fieldName: 'nri__c' }, maximumFractionDigits:"10"}, sortable: true, initialWidth:100, cellAttributes:{alignment: 'left'}},
			{label: 'LOR', fieldName: 'lor__c', type: 'numberExtended', editable: false, typeAttributes:{title:{ fieldName: 'lor__c' }, value:{ fieldName: 'lor__c' }, maximumFractionDigits:"10"}, sortable: true, initialWidth:100, cellAttributes:{alignment: 'left'}},
			{label: 'OI', fieldName: 'oi__c', type: 'numberExtended', editable: false, typeAttributes:{title:{ fieldName: 'oi__c' }, value:{ fieldName: 'oi__c' }, maximumFractionDigits:"10"}, sortable: true, initialWidth:100, cellAttributes:{alignment: 'left'}},
			{label: 'Gross Ac', fieldName: 'grossAc__c', type: 'numberExtended', editable: false, typeAttributes:{title:{ fieldName: 'grossAc__c' }, value:{ fieldName: 'grossAc__c' }, maximumFractionDigits:"10"}, sortable: true, initialWidth:100, cellAttributes:{alignment: 'left'}},
			{label: 'Lease LOR', fieldName: 'leaseLOR__c', type: 'numberExtended', editable: false, typeAttributes:{title:{ fieldName: 'leaseLOR__c' }, value:{ fieldName: 'leaseLOR__c' }, maximumFractionDigits:"10"}, sortable: true, initialWidth:100, cellAttributes:{alignment: 'left'}},
			{label: 'Lease', fieldName: 'lease__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'lease__c' }, value:{ fieldName: 'lease__c' }}, sortable: true, initialWidth:100},
			{label: 'Book/Page', fieldName: 'bookPageFrm__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'bookPageFrm__c' }, value:{ fieldName: 'bookPageFrm__c' }}, sortable: true, initialWidth:100},
			{label: 'County', fieldName: 'county__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'county__c' }, value:{ fieldName: 'county__c' }}, sortable: true, initialWidth:100},
        ]);

		var columns = component.get("v.columns");
		var tableWidth = 0;
		for(var column in columns){
			tableWidth = tableWidth + columns[column].initialWidth;
		}
		tableWidth = tableWidth + 52;
		component.set('v.tableWidth', tableWidth);

		var recordId = component.get("v.recordId");
		var action = component.get("c.getBuilderData");

		action.setParams({
			tonRecordId: recordId
		});

		action.setCallback(this, function(response){
			var responseValue = response.getReturnValue();
			console.log(responseValue);
			var torData = responseValue.allTors;
			var totData = responseValue.allTots;
			component.set("v.data", torData);
			component.set("v.totData", totData);
			helper.setUsedTOTGroups(component);
            var usedTOTGroups = component.get('v.usedTOTGroups');
            var torData = component.get('v.data');
            for(var tor in torData){
                if(usedTOTGroups.includes(torData[tor].torGroupNum__c)){
                	torData[tor].torGroupNum__c = '';   
                }   
				torData[tor].quarterCallNote = 'Area value is: ' + torData[tor].area__c;
            }
            component.set('v.data', torData);
			component.set('v.isWaiting', false);
		});

		$A.enqueueAction(action);

    },
    handleCreateTots: function (component, event, helper) {
		component.set("v.isWaiting", true);
		component.set('v.autoScroll', true);
		var currentData = component.get("v.data");
		var action = component.get("c.getNewTots2");

		action.setParams({
			inputTorLines: currentData

		});

		action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
    
                var responseValue = response.getReturnValue();
                component.set("v.newTotData", response.getReturnValue());
                component.set("v.isWaiting", false);
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "An error has occurred. Please contact your Salesforce Admin"
                });
                toastEvent.fire();
            }
			
		});

		$A.enqueueAction(action);
    },
	handleSaveTots: function (component, event, helper) {
		component.set("v.isWaiting", true);
		var newTotData = component.get("v.newTotData");
		var action = component.get("c.saveNewTots");

		action.setParams({
			inputTotGroups: component.get("v.newTotData")

		});

		action.setCallback(this, function(response){
			var responseValue = response.getReturnValue();
            if(responseValue==='Success'){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "title":"success",
                    "message": "TOTS saved Successfully"
                });
                toastEvent.fire();
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type" : "error",
                    "message": "An error has occurred. Please contact your Salesforce Admin"+responseValue
                });
                toastEvent.fire();
            }
			$A.get('e.force:refreshView').fire();
		});

		$A.enqueueAction(action);
    },
	handleDeleteTots: function (component, event, helper) {
		component.set("v.isWaiting", true);
        console.log('Delete tots called.');
		var action = component.get("c.deleteTots");

		action.setParams({
			selectedTotIds: component.get('v.selectedTOTIds')

		});

		action.setCallback(this, function(response){
			var responseValue = response.getReturnValue();
			var totTable = component.find("relatedTotRecordsTable");
			totTable.set('v.selectedRows', []);
			component.set('v.selectedTOTIds',[]);
			component.set('v.totsSelected', false);
			$A.get('e.force:refreshView').fire();
            helper.setUsedTOTGroups(component);
		});
		$A.enqueueAction(action);

	},
	updateDataValues: function (component, event, helper) {
		var currentData = event.getParam('draftValues');
		var componentData = component.get("v.data");
		var usedTOTGroups = component.get('v.usedTOTGroups');
		var errorMessage;
		var errorValue = false;
		var recordNumber = currentData[0].id.replace('row-', '');
		var rowId = currentData[0].id;
		console.log('rowId value is: ' + rowId);
		
		//Check for invalid TOR lines.
		if(componentData[recordNumber].instrumentType__c.includes("INVALID")){
			errorValue = true;
			errorMessage = 'TOR Group cannot be created unless the Instrument Type is Valid';
		}
		//Next loop through to see if another record already has this group number.  
		//If so, make sure the instrument types match.

		for(var torEntry in componentData){
			if (typeof componentData[torEntry].torGroupNum__c !=='undefined'&& componentData[torEntry].torGroupNum__c !=='' && componentData[torEntry].torGroupNum__c == currentData[0].torGroupNum__c  && componentData[torEntry].instrumentType__c != componentData[recordNumber].instrumentType__c){
				errorValue = true;
                console.log('Selected value is: ' + currentData[0].torGroupNum__c + ' matching line row is: ' + torEntry);
				errorMessage = 'TOR Group cannot be used for multiple Instrument Types';
			}
		}
		if(!isNaN(currentData[0].torGroupNum__c)){
			if(!Number.isInteger(Number(currentData[0].torGroupNum__c))){
				errorValue = true;
				errorMessage = 'TOR Group must be an Integer value';
			}
			else if(usedTOTGroups.includes(Number(currentData[0].torGroupNum__c))){
			console.log('Evaluated to true');
			errorValue = true;
			errorMessage = 'TOR Group has already been used';
			}
		}
		
		



		if(errorValue){
			component.set('v.errors', {
				rows: {
					[rowId]: {
						'title': 'TOR Group Error',
						messages: [
							errorMessage
						],
						fieldNames: ['torGroupNum__c']
					}
				},
				table: {
					title: 'Your entry cannot be saved. Fix the errors and try again.',
					messages: [
						errorMessage
					]
				}
			});
			componentData[recordNumber].torGroupNum__c = null;

		}
		else{
			componentData[recordNumber].torGroupNum__c = currentData[0].torGroupNum__c;
			
			component.set('v.errors', []);
		}
		component.set("v.draftValues", []);
		component.set("v.data", componentData);
    },
    updateTORSorting: function (component, event, helper) {
		
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.torSortedBy", fieldName);
        component.set("v.torSortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
    },
	updateTOTSorting: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.totSortedBy", fieldName);
        component.set("v.totSortedDirection", sortDirection);
        helper.sortTotData(component, fieldName, sortDirection);
    },
	updateTOTDelete: function(component, event, helper){
		var selectedRows = event.getParam('selectedRows');
		var selectedTOTIds = new Array();
		for(var tot in selectedRows){
			selectedTOTIds.push(selectedRows[tot].Id);
		}
		if(selectedRows.length >0){
			component.set('v.totsSelected', true);
		}
		else{
			component.set('v.totsSelected', false);
		}
		component.set('v.selectedTOTIds', selectedTOTIds);
		console.log(selectedTOTIds);
	}, 
	scrollDown: function(component, event, helper){
		var newTotData = component.get('v.newTotData');
		var autoScroll = component.get('v.autoScroll');
		if(autoScroll){
			if(newTotData){
				var newTOTArea = component.find('newTOTArea');
				if(newTOTArea != null){
					window.scrollTo(0,newTOTArea.getElement().offsetTop + 272.44);
					component.set('v.autoScroll', false);
				}
			}
		}
	}
});