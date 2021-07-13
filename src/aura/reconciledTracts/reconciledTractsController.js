({
	init: function (component, event, helper) {
		component.set('v.sortedBy', 'reconciliationId');
		component.set('v.sortedDirection', 'ASC');
        
		component.set('v.totColumns', [
			//{type: "button", typeAttributes: {label: 'View', name: {fieldName: 'reconciliationId'}, title: 'View', disabled: false, value: 'view', iconPosition: 'left', variant: 'base' }},
			{label: 'Quarter Call', fieldName: 'totQuarterCall', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'totQuarterCallNote' }, value:{ fieldName: 'totQuarterCall' }}, sortable: true, class:"tableRow"},
			{label: 'Depth', fieldName: 'totDepth', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'totDepth' }, value:{ fieldName: 'totDepth' }}, sortable: true},
			{label: 'Instrument Type', fieldName: 'totInstrumentType', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'totInstrumentType' }, value:{ fieldName: 'totInstrumentType' }}, sortable: true},
			{label: 'Gross Acreage', fieldName: 'totGrossAc', type: 'numberExtended', editable: false, typeAttributes:{title:{ fieldName: 'totGrossAc' }, value:{ fieldName: 'totGrossAc' }, maximumFractionDigits:"8"}, sortable: true, cellAttributes:{alignment: 'left'}},
			{label: 'Acres', fieldName: 'acres', type: 'text', editable: false, sortable: true, cellAttributes:{alignment: 'left'}}
            //{label: 'Acres', fieldName: 'totTractsCOCalculation', type: 'numberExtended', editable: false, typeAttributes:{title:{ fieldName: 'totTractsCOCalculation' }, value:{ fieldName: 'totTractsCOCalculation' }, maximumFractionDigits:"10"}, sortable: true,  cellAttributes:{alignment: 'left'}},
			//{label: 'Acreage Unit', fieldName: 'totMeasurement', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'totMeasurement' }, value:{ fieldName: 'totMeasurement' }}, sortable: true}
			//{label: 'TOT Name', fieldName: 'totLink', type: 'url',typeAttributes: {label: { fieldName: 'totName' }, target: '_blank', tooltip:'Open TOT in a new tab'}, sortable: true},
		]);

		component.set('v.tractColumns', [
			{label: 'Quarter Call', fieldName: 'tractQuarterCall', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'tractQuarterCall' }, value:{ fieldName: 'tractQuarterCall' }}, sortable: true},
			{label: 'Depth', fieldName: 'tractDepth', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'tractDepth' }, value:{ fieldName: 'tractDepth' }}, sortable: true},
			{label: 'Instrument Type', fieldName: 'tractInstrumentType', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'tractInstrumentType' }, value:{ fieldName: 'tractInstrumentType' }}, sortable: true},
			{label: 'Gross Acreage', fieldName: 'tractGrossAcres', type: 'numberExtended', editable: false, typeAttributes:{title:{ fieldName: 'tractGrossAcres' }, value:{ fieldName: 'tractGrossAcres' }, maximumFractionDigits:"8"}, sortable: true, cellAttributes:{alignment: 'left'}},
			{label: 'Net Acres', fieldName: 'netAcres', type: 'numberExtended', maximumFractionDigits:"8", editable: false, sortable: true, cellAttributes:{alignment: 'left'}},
            //{label: 'Net Acres', fieldName: 'tractCompanyAcres', type: 'numberExtended', editable: false, typeAttributes:{title:{ fieldName: 'tractCompanyAcres' }, value:{ fieldName: 'tractCompanyAcres' }, maximumFractionDigits:"10"}, sortable: true, cellAttributes:{alignment: 'left'}},
			//{label: 'Company Acreage Unit', fieldName: 'tractCompanyAcreageUnits', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'tractCompanyAcreageUnits' }, value:{ fieldName: 'tractCompanyAcreageUnits' }}, sortable: true},
			{label: 'Tract Name', fieldName: 'tractLink', type: 'url',typeAttributes: {label: { fieldName: 'tractName' }, target: '_blank', tooltip:'Open Tract in a new tab'}, sortable: true},
		]);

		component.set('v.reconciledColumns', [
			{type: 'button-icon', fieldName: 'reconciliationId', typeAttributes:{iconName:{fieldName: 'tractAction'} , iconClass:"iconGreen tableRow", alternativeText:"View Saved Reconciliation", variant:"bare", size:"medium"}, fixedWidth:"40px", cellAttributes:{alignment: 'center'}},
			//{type: 'buttonIconExtended', fieldName: 'tractAction', typeAttributes:{iconName:{fieldName: 'tractAction'} , iconClass:"iconGreen slds-align_absolute-center", alternativeText:"Tract Action", variant:"bare", size:"medium"}, fixedWidth:"20px", cellAttributes:{alignment: 'center'}},
			
			//{type: 'rowIconGroupButton', fieldName: 'tractAction', typeAttributes:{icon1Name:'utility:link', icon2Name:{fieldName:'tractAction'}, className:"iconGreen tableRow", title:"Click to view Reconciliation", rowId:{fieldName:'reconciliationId'}, variant:"bare"}, fixedWidth:"20px", cellAttributes:{alignment: 'center'}},
		]);

		var recordId = component.get("v.recordId");
		var action = component.get("c.getReconciledRecords");

		action.setParams({
			recordId: recordId
		});

		action.setCallback(this, function(response){
			var responseValue = response.getReturnValue();
			//console.log(responseValue);
			//var totData = responseValue.reconciledTonTotRecords;
			//var tractData = responseValue.reconciledTonTractRecords;
			var ton = responseValue.tonRecord;
			var reconciliationData = responseValue.reconciliationRecords;
			//component.set("v.totData", totData);
			//component.set("v.tractData", tractData);
            component.set("v.ton", ton);
			component.set("v.reconciliationData", reconciliationData);
			if(reconciliationData.length >0){
				component.set('v.hasReconciledItems', true);
			}
			//console.log('reconciliationData size is: ' + reconciliationData.length);
			component.set('v.isWaiting', false);
		});

		$A.enqueueAction(action);
	},

	updateSorting: function (component, event, helper) {
		
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
    },

	displayModal:function (component, event, helper) {
		//console.log(displayModal called);
		//var action = event.getParam('action');
		var row = event.getParam('row');
		//console.log('Called Display Modal');
		//console.log(JSON.stringify(action.name));
		//console.log(JSON.stringify(row));

		//var reconciliations = component.get('v.reconciliationData');
		var currentTon = component.get('v.ton');
		var newTract = ((row.tractAction == 'utility:add')? true:false);
		//console.log(newTract);
		var totRecord = {sobjectType:"TitleOwnershipDetail__c", area__c:row.totArea, quarterCall__c:row.totQuarterCall, depth__c:row.totDepth, instrumentType__c:row.totInstrumentType, grossAc__c:row.totGrossAc , tractsCOCalculation__c:row.totTractsCOCalculation, measurement__c:row.totMeasurement, link__c:row.totLink, Name:row.totName};
		var reconciledTractRecord = {sobjectType:"Tract__c", Quarter_Call__c:row.tractQuarterCall, depth__c:row.tractDepth, Instrument_Type__c:row.tractInstrumentType, Gross_Acres__c:row.tractGrossAcres , netAcres__c:row.tractNetAcres , netAcreageUnits__c:row.tractNetAcreageUnits, link__c:row.tractLink, Name:row.tractName};
		var preTractRecord = {sobjectType:"Tract__c", Quarter_Call__c:row.preTractQuarterCall, depth__c:row.preTractDepth, Instrument_Type__c:row.preTractInstrumentType, Gross_Acres__c:row.preTractGrossAcres , netAcres__c:row.preTractNetAcres , netAcreageUnits__c:row.preTractNetAcreageUnits, link__c:row.preTractLink, Name:row.preTractName};
		var tractReconciliation = {sobjectType: "tractReconciliation__c", depthOption__c:row.depthOption , grossAcreageOption__c:row.grossAcreageOption , instrumentTypeOption__c:row.instrumentTypeOption , quarterCallOption__c:row.quarterCallOption , netAcreageUnitOption__c:row.netAcreageUnitOption , netAcresOption__c:row.netAcresOption };
		$A.createComponent( 'c:tractReconciliationModal', {
                'headerText' : 'Reconciled Tract for ' + currentTon.account__r.Name,
				'newTract':newTract,
				'viewOnly': true,
				'totData': totRecord,
				'priorTractData':preTractRecord,
				'tractReconciliation':tractReconciliation,
				'currentTractData':reconciledTractRecord
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
	}

})