({
	init: function (component, event, helper) {
		
		component.set('v.tractSortedBy', 'Id');
		component.set('v.tractSortedDirection', 'ASC');
		component.set('v.totSortedBy', 'Id');
		component.set('v.totSortedDirection', 'ASC');
		
		
		component.set('v.totColumns', [
			//{type:'radioInput', fieldName: 'locked__c', editable: false},
			{label: 'Quarter Call', fieldName: 'quarterCall__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'quarterCallNote' }, value:{ fieldName: 'quarterCall__c' }}, sortable: true},
			//{label: 'Area', fieldName: 'area__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'area__c' }, value:{ fieldName: 'area__c' }}, sortable: true},
			{label: 'Depth', fieldName: 'depth__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'depth__c' }, value:{ fieldName: 'depth__c' }}, sortable: true},
			{label: 'Instrument Type', fieldName: 'instrumentType__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'instrumentType__c' }, value:{ fieldName: 'instrumentType__c' }}, sortable: true},
			{label: 'Gross Acreage', fieldName: 'grossAc__c', type: 'numberExtended', editable: false, typeAttributes:{title:{ fieldName: 'grossAc__c' }, value:{ fieldName: 'grossAc__c' }, maximumFractionDigits:"8"}, sortable: true, cellAttributes:{alignment: 'left'}},
			{label: 'Acres', fieldName: 'acres', type: 'text', editable: false, sortable: true, cellAttributes:{alignment: 'left'}}
            //{label: 'Acres', fieldName: 'tractsCOCalculation__c', type: 'numberExtended', editable: false, typeAttributes:{title:{ fieldName: 'tractsCOCalculation__c' }, value:{ fieldName: 'tractsCOCalculation__c' }, maximumFractionDigits:"10"}, sortable: true,  cellAttributes:{alignment: 'left'}},
			//{label: 'Acreage Unit', fieldName: 'measurement__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'measurement__c' }, value:{ fieldName: 'measurement__c' }}, sortable: true}
			//{label: 'TOT Name', fieldName: 'link__c', type: 'url',typeAttributes: {label: { fieldName: 'Name' }, target: '_blank', tooltip:'Open TOT in a new tab'}, sortable: true},
		]);

		component.set('v.tractColumns', [
			{label: 'Quarter Call', fieldName: 'Quarter_Call__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'Quarter_Call__c' }, value:{ fieldName: 'Quarter_Call__c' }}, sortable: true},
			{label: 'Depth', fieldName: 'depth__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'depth__c' }, value:{ fieldName: 'depth__c' }}, sortable: true},
			{label: 'Instrument Type', fieldName: 'Instrument_Type__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'Instrument_Type__c' }, value:{ fieldName: 'Instrument_Type__c' }}, sortable: true},
			{label: 'Gross Acreage', fieldName: 'Gross_Acres__c', type: 'numberExtended', editable: false, typeAttributes:{title:{ fieldName: 'Gross_Acres__c' }, value:{ fieldName: 'Gross_Acres__c' }, maximumFractionDigits:"8"}, sortable: true, cellAttributes:{alignment: 'left'}},
            {label: 'Net Acres', fieldName: 'acres', type: 'text', editable: false, sortable: true, cellAttributes:{alignment: 'left'}},
            //{label: 'Net Acres', fieldName: 'netAcres__c', type: 'numberExtended', editable: false, typeAttributes:{title:{ fieldName: 'netAcres__c' }, value:{ fieldName: 'netAcres__c' }, maximumFractionDigits:"10"}, sortable: true, cellAttributes:{alignment: 'left'}}
			//{label: 'Company Acreage Unit', fieldName: 'Company_Acreage_Units__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'Company_Acreage_Units__c' }, value:{ fieldName: 'Company_Acreage_Units__c' }}, sortable: true},
			{label: 'Tract Name', fieldName: 'link__c', type: 'url',typeAttributes: {label: { fieldName: 'Name' }, target: '_blank', tooltip:'Open Tract in a new tab'}, sortable: true},
		]);


		var recordId = component.get("v.recordId");
		var action = component.get("c.getReconciliationRecords");

		action.setParams({
			recordId: recordId
		});

		action.setCallback(this, function(response){
			var responseValue = response.getReturnValue();
			//console.log(responseValue);
			var totData = responseValue.tonTotRecords;
			var tractData = responseValue.tonTractRecords;
			var ton = responseValue.tonRecord;
			var tractInstrumentTypeOptions = responseValue.tractInstrumentTypePicklist;
			//console.log(tractInstrumentTypeOptions);
			var tractNetAcreageUnitsOptions = responseValue.tractNetAcreageUnitsPicklist;
			//console.log(tractCompanyAcreageUnitsOptions);
			var reconciliationData = responseValue.reconciliationRecords;
            totData.forEach(function(record){
                if(record.tractsCOCalculation__c != undefined && record.tractsCOCalculation__c != null){
                	record.acres = record.tractsCOCalculation__c.toFixed(8)+' '+record.measurement__c;
                }
				record.quarterCallNote = 'Area from TOR was: ' + record.area__c;
            });
            tractData.forEach(function(record){
                if(record.netAcres__c != undefined && record.netAcres__c != null){
                	record.acres = record.netAcres__c.toFixed(8)+' '+record.netAcreageUnits__c;
                }
            });
            component.set("v.totData", totData);
			component.set("v.tractData", tractData);
			component.set("v.ton", ton);
			component.set("v.reconciliationData", reconciliationData);
			component.set('v.tractInstrumentTypeOptions', tractInstrumentTypeOptions);
			component.set('v.tractNetAcreageUnitsOptions', tractNetAcreageUnitsOptions);
			if(ton.account__c){
				component.set('v.tonHasAccount', true);
			}
			component.set('v.isWaiting', false);
		});

		$A.enqueueAction(action);
	},
	
	updateTotSelection: function(component, event, helper){
		//console.log(event);
		var selectedRows = event.getParam('selectedRows');
		//console.log(selectedRows);
		var selectedTot = component.get('v.selectedTot');
		var totTable = component.find('totTable');
		if(selectedTot != null && selectedRows.length<=2){
			switch(true){
				case (selectedRows.length == 1):
					var currentRow = [selectedRows[0].Id];
					var newSelection = selectedRows[0];
					break;
				case (selectedRows.length == 2):
					for(var selectedRow in selectedRows){
						if(selectedRows[selectedRow].Id != selectedTot.Id){
							var currentRow = [selectedRows[selectedRow].Id];
							var newSelection = selectedRows[selectedRow];	
						}	
					}
					break;
				default:
					var currentRow = [];
					var newSelection = null;
				
			}
		}
		else{
			var currentRow = [selectedRows[0].Id];
			var newSelection = selectedRows[0];
		}
		//var currentRow = [selectedRow[0].Id];
		//console.log(currentRow);
		totTable.set('v.selectedRows', currentRow);
		//console.log(checked);
		component.set('v.selectedTot', newSelection);
		helper.updateButtons(component);
		//console.log(selectedRows);
	},

	updateTractSelection: function(component, event, helper){
		//console.log(event);
		var selectedRows = event.getParam('selectedRows');
		//console.log(selectedRows);
		var selectedTract = component.get('v.selectedTract');
		var tractTable = component.find('tractTable');
		if(selectedTract != null && selectedRows.length<=2){
			switch(true){
				case (selectedRows.length == 1):
					var currentRow = [selectedRows[0].Id];
					var newSelection = selectedRows[0];
					break;
				case (selectedRows.length>1):
					for(var selectedRow in selectedRows){
						if(selectedRows[selectedRow].Id != selectedTract.Id){
							var currentRow = [selectedRows[selectedRow].Id];
							var newSelection = selectedRows[selectedRow];	
						}	
					}
					break;
				default:
					var currentRow = [];
					var newSelection = null;
				
			}
		}
		else{
			var currentRow = [selectedRows[0].Id];
			var newSelection = selectedRows[0];
		}
		//var currentRow = [selectedRow[0].Id];
		//console.log(currentRow);
		tractTable.set('v.selectedRows', currentRow);
		//console.log(newSelection);
		component.set('v.selectedTract', newSelection);
		helper.updateButtons(component);
		//console.log(selectedRows);
	},

	addTract: function(component, event, helper){
		component.set('v.isWaiting', true);
		//console.log('Called Add Tract');
		var currentTot = component.get('v.selectedTot');
		var currentTon = component.get('v.ton');
		var tractInstrumentTypeOptions = component.get('v.tractInstrumentTypeOptions');
		var tractNetAcreageUnitsOptions = component.get('v.tractNetAcreageUnitsOptions');

		$A.createComponent( 'c:tractReconciliationModal', {
                'headerText' : 'Create New Tract for ' + currentTon.account__r.Name,
				'newTract' : true,
				'totData' : currentTot,
				'tractInstrumentTypeOptions' : tractInstrumentTypeOptions,
				'tractNetAcreageUnitsOptions' : tractNetAcreageUnitsOptions,
				'ton':currentTon
            },
            function(modalComponent, status, errorMessage) {
                if (status === "SUCCESS") {
                    //Appending the newly created component in div
                    var body = component.find( 'reconciliationModal' ).get("v.body");
                    body.push(modalComponent);
                    component.find( 'reconciliationModal' ).set("v.body", body);
                } else if (status === "INCOMPLETE") {
                	console.log('Server issue or client is offline.');
                } else if (status === "ERROR") {
                	console.log('error');
                }
            }
        );
	},

	compareTract: function(component, event, helper){
		//console.log('Called Compare Tract');
		component.set('v.isWaiting', true);
		var currentTot = component.get('v.selectedTot');
		var currentTract = component.get('v.selectedTract');
		var currentTon = component.get('v.ton');
		var tractInstrumentTypeOptions = component.get('v.tractInstrumentTypeOptions');
		var tractNetAcreageUnitsOptions = component.get('v.tractNetAcreageUnitsOptions');
		$A.createComponent( 'c:tractReconciliationModal', {
                'headerText' : 'Revise Tract for ' + currentTon.account__r.Name,
				'newTract': false,
				'totData': currentTot,
				'priorTractData':currentTract,
				'tractInstrumentTypeOptions' : tractInstrumentTypeOptions,
				'tractNetAcreageUnitsOptions' : tractNetAcreageUnitsOptions,
				'ton':currentTon
            },
            function(modalComponent, status, errorMessage) {
				//console.log('Callback called');
                if (status === "SUCCESS") {
                    //Appending the newly created component in div
                    var body = component.find( 'reconciliationModal' ).get("v.body");
                    body.push(modalComponent);
                    component.find( 'reconciliationModal' ).set("v.body", body);
                } else if (status === "INCOMPLETE") {
                	console.log('Server issue or client is offline.');
                } else if (status === "ERROR") {
                	console.log('error');
                }
            }
        );
	},

	updateTractSorting: function (component, event, helper) {
		
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.tractSortedBy", fieldName);
        component.set("v.tractSortedDirection", sortDirection);
        helper.sortTractData(component, fieldName, sortDirection);
    },
	updateTOTSorting: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.totSortedBy", fieldName);
        component.set("v.totSortedDirection", sortDirection);
        helper.sortTotData(component, fieldName, sortDirection);
    },

	populateCheckBoxes: function(component, event, helper){
		//console.log('Populate called');
		var isWaiting= component.get('v.isWaiting');
		if(!isWaiting){
			var tractTable = component.find('tractTable');
			var totTable = component.find('totTable');
			var selectedTract = component.get('v.selectedTract');
			//console.log(selectedTract);
			var selectedTot = component.get('v.selectedTot');
			//console.log(selectedTot);
			if(selectedTract){
				tractTable.set('v.selectedRows', [selectedTract.Id]);
			}
			//console.log(newSelection);
			if(selectedTot){
				totTable.set('v.selectedRows', [selectedTot.Id]);
			}
		}
	},

	handleModalClose: function(component, event, helper){
		var status = event.getParam("status");
		var succeeded = event.getParam("succeeded");

		switch(status){
				case ('SAVED'):
					component.set('v.selectedTot', null);
					component.set('v.selectedTract', null);
					helper.updateButtons(component);
					$A.get('e.force:refreshView').fire();
					break;
				default:
					component.set('v.isWaiting', false);
		}
		

	}

})