({
	init: function (component, event, helper) {
		var originalTotData = component.get("v.totData");
		var newTotData = Object.assign({},originalTotData);
		var columns = component.get("v.torColumns");
		var tableWidth = 0;
		for(var column in columns){
			tableWidth = tableWidth + columns[column].initialWidth;
		}
		component.set('v.tableWidth', tableWidth);
		component.set("v.viewTotData", newTotData);

		//Get Initial values and create quarterCallNote field for display
		var torData = component.get('v.torData');
		var totData = component.get('v.totData');
		for(var tor in torData){
			torData[tor].quarterCallNote = 'Area value is: ' + torData[tor].area__c;
        }
		for(var tot in totData){
			totData[0].quarterCallNote = 'Area from TOR was: ' + totData[tot].area__c;
        }

	},
	handleSelect: function(component, event, helper) {
		var selectedMenuItemValue = event.getParam("value");
		var menuLabel = event.getParam("value");
		var menuPicked = event.getSource().getLocalId();
		var menu = component.find(menuPicked);
		menu.set("v.label", menuLabel);
		var baseName = menuPicked.replace('Select', '');
		var operatorField = menuPicked.replace('Select', 'Operator__c');
		var valueField = menuPicked.replace('Select', '__c');
		var outputField = menuPicked.replace('Select', '__c');
		if(valueField == 'bookPageFrm__c'){
			outputField = 'bookPageTOT__c';
			operatorField = 'bookPageOperator__c';
		}
		if(baseName == 'bookPageFrm'){
			baseName = 'bookPage';
		}
		var currentTORs = component.get('v.torData');
		var currentTOT = component.get('v.totData');
		var totDraftValues = {};
		var combinedValue = '';
		var keyFound = false

		switch(selectedMenuItemValue){
			case "Sum":
				component.set('v.' + baseName + 'Manual', false);
				break;
			case "Concatenate":
				component.set('v.' + baseName + 'Manual', false);
				break;
			case "Manual":
				component.set('v.' + baseName + 'Manual', true);
				break;
			default:
				component.set('v.' + baseName + 'Manual', false);
		}

		for (var i=0; i<currentTORs.length; i++) {
			for(var key in currentTORs[i]){
				if(key === valueField){
					switch(selectedMenuItemValue){
						case "Sum":
							combinedValue = Number(combinedValue) + Number(currentTORs[i][key]);
							break;
						case "Concatenate":
							combinedValue = combinedValue + ',' + currentTORs[i][key];
							break;
						case "Manual":
							break;
						default:
							combinedValue = currentTORs[0].key;
					}
				}
			}
			
		}
		switch(selectedMenuItemValue){
			case "Sum":
				currentTOT[0][operatorField] = 'Sum';
				currentTOT[0][outputField] = combinedValue;

				break;
			case "Concatenate":
				currentTOT[0][operatorField] = 'Concatenate';
				currentTOT[0][outputField] = combinedValue.substr(1);
				break;
			case "Manual":
				currentTOT[0][operatorField] = 'Manual';
				currentTOT[0][outputField] = null;
				break;
			default:
				currentTOT[0][operatorField] = 'First';
				currentTOT[0][outputField] = currentTORs[0][valueField];
				
		}
		//quarterCall also defines behavior for area field.  Set area field values when quarterCall is selected
		console.log('baseName value is: ' + baseName);
		if(baseName == 'quarterCall'){
			valueField = 'area__c';
			operatorField = 'areaOperator__c';
			outputField = 'area__c'; 
			combinedValue = '';
			for (var i=0; i<currentTORs.length; i++) {
				for(var key in currentTORs[i]){
					if(key === valueField){
						switch(selectedMenuItemValue){
							case "Sum":
								combinedValue = Number(combinedValue) + Number(currentTORs[i][key]);
								break;
							case "Concatenate":
								combinedValue = combinedValue + ',' + currentTORs[i][key];
								break;
							case "Manual":
								break;
							default:
								combinedValue = currentTORs[0].key;
						}
					}
				}
			
			}
			
			
			switch(selectedMenuItemValue){
				case "Sum":
					currentTOT[0][operatorField] = 'Sum';
					currentTOT[0][outputField] = combinedValue;

					break;
				case "Concatenate":
					currentTOT[0][operatorField] = 'Concatenate';
					currentTOT[0][outputField] = combinedValue.substr(1);
					break;
				case "Manual":
					currentTOT[0][operatorField] = 'Manual';
					currentTOT[0][outputField] = 'Manual Override';
					break;
				default:
					currentTOT[0][operatorField] = 'First';
					currentTOT[0][outputField] = currentTORs[0][valueField];	
			}
			currentTOT[0].quarterCallNote = 'Area from TOR was: ' + currentTOT[0].area__c;
		}
		component.set('v.totData', currentTOT);
		
	},
	updateTORSorting: function (component, event, helper) {
		
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.torSortedBy", fieldName);
        component.set("v.torSortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
    },
	handleDeleteTot: function (component, event, helper) {
		//component.set("v.isWaiting", true);
		var deleteId = [event.getSource().get('v.value')];
        console.log('Delete tot called.');
		var action = component.get("c.deleteTots");

		action.setParams({
			selectedTotIds: deleteId

		});

		action.setCallback(this, function(response){
			var responseValue = response.getReturnValue();
			var p = component.get("v.parent");
			console.log('Made it here');
			p.setWaiting();
			$A.get('e.force:refreshView').fire();
			//component.set("v.isWaiting", false);
		});
		$A.enqueueAction(action);

	},
})