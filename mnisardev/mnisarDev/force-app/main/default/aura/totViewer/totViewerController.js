({
    init: function (component, event, helper) {
		component.set('v.isWaiting', true);
        component.set('v.newTotData', null);
		component.set('v.torSortedBy', 'Id');
		component.set('v.torSortedDirection', 'ASC');
		component.set('v.totSortedBy', 'Id');
		component.set('v.totSortedDirection', 'ASC');

		component.set('v.readOnlyColumns', [
			{type: 'text', editable: false,  initialWidth:32},
			{label: 'TOR Group', fieldName: 'torGroupNum__c', type: 'number', editable: false, typeAttributes: { required: true, maximumFractionDigits:0 }, sortable: true, initialWidth:125},
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

		component.set('v.totReadOnlyColumns', [
			{label: 'TOR Group', fieldName: 'torGroupNum__c', type: 'number', editable: false, typeAttributes: { required: true, maximumFractionDigits:0 }, sortable: true, initialWidth:125},
			{label: 'TOT Name', fieldName: 'link__c', type: 'url',typeAttributes: {label: { fieldName: 'Name' }, target: '_blank', tooltip:'Open TOT in a new tab'}, sortable: true, initialWidth:150},
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
			{label: 'Book/Page', fieldName: 'bookPageTOT__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'bookPageTOT__c' }, value:{ fieldName: 'bookPageTOT__c' }}, sortable: true, initialWidth:100},
			{label: 'County', fieldName: 'county__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'county__c' }, value:{ fieldName: 'county__c' }}, sortable: true, initialWidth:100},
        ]);

		var columns = component.get("v.readOnlyColumns");
		var tableWidth = 0;
		for(var column in columns){
			tableWidth = tableWidth + columns[column].initialWidth;
		}
		tableWidth = tableWidth;
		component.set('v.tableWidth', tableWidth);

		var recordId = component.get("v.recordId");
		var action = component.get("c.getSavedTots2");



		action.setParams({
			tonRecordId: recordId

		});

		action.setCallback(this, function(response){
			var responseValue = response.getReturnValue();
			console.log(responseValue);
			if(responseValue){
				var allTots = responseValue.allTots;
				var savedTots = responseValue.savedTots;
				var hasLockedTots;
				for(var tot in allTots){
					if(allTots[tot].locked__c){
						component.set('v.hasLockedTot', true);
					}
					allTots[tot].quarterCallNote = 'Area from TOR was: ' + allTots[tot].area__c;
				}
				component.set('v.totData', allTots);
				component.set("v.savedTotData", savedTots);
			}
			else{
				component.set('v.totData', []);
				component.set('v.savedTotData', []);
			}
			component.set('v.isWaiting', false);
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
	setWaiting:  function(component, event, helper){
		component.set('v.isWaiting', true);
	}
});