({
	init: function (component, event, helper) {
		var viewOnly = component.get('v.viewOnly');
		var newTract = component.get('v.newTract');
		var instrumentTypeOptions = component.get('v.tractInstrumentTypeOptions');
		var netAcreageUnitsOption = component.get('v.tractNetAcreageUnitsOptions');
		//console.log(instrumentTypeOptions);
		//console.log(companyAcreageUnitsOption);
		if(viewOnly){
			if(newTract){
				component.set('v.currentTractClass', 'noTractTable');
				component.set('v.currentTractHeaderClass', 'noTractHeader');
			}
			else{
				component.set('v.currentTractClass', 'currentTractTable');
				component.set('v.currentTractHeaderClass', 'currentTractHeader');
			}
		}
		else{
			var tot = component.get('v.totData');
			if(newTract){
				component.set('v.currentTractClass', 'noTractTable');
				component.set('v.currentTractHeaderClass', 'noTractHeader');
				var newTractRecord = {sobjectType:"Tract__c", Quarter_Call__c:tot.quarterCall__c, depth__c:tot.depth__c, Instrument_Type__c:tot.instrumentType__c, Gross_Acres__c:tot.grossAc__c , netAcres__c:tot.tractsCOCalculation__c , netAcreageUnits__c:tot.measurement__c};
				var reconciliation = {sobjectType:"tractReconciliation__c", netAcreageUnitOption__c:"totValue", netAcresOption__c:"totValue", depthOption__c:"totValue", quarterCallOption__c:"totValue", instrumentTypeOption__c:"totValue", grossAcreageOption__c:"totValue"};
			}
			else{
				var priorTractData = component.get('v.priorTractData');
				var newTractRecord = {sobjectType:"Tract__c", Id:priorTractData.Id, Name:priorTractData.Name, link__c:priorTractData.link__c, Quarter_Call__c:"", depth__c:"", Instrument_Type__c:"", Gross_Acres__c:null , netAcres__c:null , netAcreageUnits__c:""};
				var reconciliation = {sobjectType:"tractReconciliation__c", netAcreageUnitOption__c:"", netAcresOption__c:"", depthOption__c:"", quarterCallOption__c:"", instrumentTypeOption__c:"", grossAcreageOption__c:""};
				component.set('v.currentTractClass', 'currentTractTable');
				component.set('v.currentTractHeaderClass', 'currentTractHeader');
			}
			component.set('v.currentTractData', newTractRecord);
			component.set('v.tractReconciliation', reconciliation);
		}
		/*var newTract = component.get('v.newTract');
		var options = [
            { value: "totValue", label: "Tot Value" },
            { value: "tractValue", label: "Tract Value", disabled:"true" },
            { value: "manual", label: "Manual Entry" }
        ];
        component.set("v.statusOptions", options);
		*/
	},

	handleCancel: function (component, event, helper) {
		//$A.get('e.force:refreshView').fire();
		var reconciliationEvent = component.getEvent('reconciliationResponse');
		reconciliationEvent.setParams({
			"status": "CANCELED",
			"succeeded":true });
		reconciliationEvent.fire();
		component.destroy();
	},

	handleSelectChange: function (component, event, helper) {
		//var selectedMenuItemValue = event.getParam("value");
		
		var menuPicked = event.getSource().getLocalId();
		var selectedValue = component.find(menuPicked).get('v.value');
		var totData = component.get('v.totData');
		var priorTractData = component.get('v.priorTractData');
		var tractReconciliation = component.get('v.tractReconciliation');
		var currentTractData = component.get('v.currentTractData');
		var fieldMapping = helper.getFieldMapping(menuPicked.replace('Select', ''));
		//console.log(selectedValue);
		//console.log(menuPicked);

		switch(selectedValue){
			case "totValue":
					currentTractData[fieldMapping.tractFieldName] = totData[fieldMapping.totFieldName];
				break;
			case "tractValue":
					currentTractData[fieldMapping.tractFieldName] = priorTractData[fieldMapping.tractFieldName];
				break;
			case "manualEntry":
					currentTractData[fieldMapping.tractFieldName] = '';
				
		}

		component.set('v.currentTractData', currentTractData);
	},

	handleSave: function(component, event, helper){
		var currentTractData = component.get('v.currentTractData');
		var newTract = component.get('v.newTract');
		var tractReconciliation = component.get('v.tractReconciliation');
		var reconciliationEvent = component.getEvent('reconciliationResponse');
		
		
		//console.log(tractReconciliation.companyAcreageUnitOption__c);
		var oldTract = component.get('v.priorTractData');
		var tot = component.get('v.totData');
		var ton = component.get('v.ton');
		var message;
		var messageHeader;
		//Use isValid to validate record can be saved on client side
		var isValid = true;//currentTractData.Instrument_Type__c === ""?false:true;
		if(!currentTractData.Instrument_Type__c){
			isValid = false;
			message = "Saved Tract must have an Instrument Type";
			messageHeader = "ERROR!";
		}

		if(!currentTractData.netAcreageUnits__c){
			isValid = false;
			message = "Saved Tract must have a Company Acreage Unit";
			messageHeader = "ERROR!";
		}
		//console.log(!tractReconciliation.companyAcreageUnitOption__c);
		//console.log(!tractReconciliation.companyAcresOption__c);
		//console.log(!tractReconciliation.depthOption__c);
		//console.log(!tractReconciliation.grossAcreageOption__c);
		//console.log(!tractReconciliation.instrumentTypeOption__c);
		//console.log(!tractReconciliation.quarterCallOption__c);
		if(!tractReconciliation.netAcreageUnitOption__c || 
		   !tractReconciliation.netAcresOption__c ||
		   !tractReconciliation.depthOption__c ||
		   !tractReconciliation.grossAcreageOption__c ||
		   !tractReconciliation.instrumentTypeOption__c ||
		   !tractReconciliation.quarterCallOption__c ){

		   isValid = false;
		   message="Please make a selection for all values.";
		   messageHeader = "INPUT ERROR!";
		}
		if(tractReconciliation.netAcreageUnitOption__c == 'manualEntry' && (!currentTractData.netAcreageUnits__c || currentTractData.netAcreageUnits__c == "")){
			isValid = false;
			message="Please Select a Company Acreage Unit";
			messageHeader = "INPUT ERROR!";
		}



		console.log(isValid);
		//If valid, save the record otherwise display error toast
		if(isValid){
			var action = component.get("c.saveTract");

			action.setParams({
				'newTract': newTract,
				'tractReconciliation': tractReconciliation,
				'oldTract': oldTract,
				'currentTract': currentTractData,
				'tot': tot,
				'ton': ton

			});

			action.setCallback(this, function(response){
				var responseValue = response.getReturnValue();
				var toastEvent = $A.get("e.force:showToast");
                if(responseValue.success){
					toastEvent.setParams({
						"title": "SUCCESS",
						"message": 'Tract Record Saved',
						"type":"success"
					});
					reconciliationEvent.setParams({
						"status": "SAVED",
						"succeeded":true });
				}
				else{
					toastEvent.setParams({
						"title": "Tract Record was not Saved",
						"message": responseValue.message,
						"type":"error",
						"mode":'sticky'

					});
					reconciliationEvent.setParams({
						"status": "ERROR",
						"succeeded":false });
				}
				reconciliationEvent.fire();
				toastEvent.fire();
				if(responseValue.success){
					//$A.get('e.force:refreshView').fire();
					component.destroy();
				}
			});

			$A.enqueueAction(action);
			console.log('Commit Save');
		}
		else{
			var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": messageHeader,
                    "message": message,
					"type":"error",
					"mode": 'sticky',
                });
			toastEvent.fire();
		}
	}


})