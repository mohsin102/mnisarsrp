({
	init: function (component, event, helper) {
		component.set('v.sortBy', 'Id');
		component.set('v.sortDirection', 'ASC');
		
		
		component.set('v.columns', [
			{label: 'Project AOI', fieldName: 'projectLink', type: 'url',typeAttributes: {label: { fieldName: 'projectName' }, target: '_blank', tooltip:'Open Project AOI in a new tab'}, sortable: true, initialWidth:150},
			{label: 'Project AOI Tract', fieldName: 'projectTractLink', type: 'url',typeAttributes: {label: { fieldName: 'Name' }, target: '_blank', tooltip:'Open Project AOI Tract in a new tab'}, sortable: true, initialWidth:150},
			{label: '% in AOI', fieldName: 'percentageOfAcreageInAoi__c', type: 'percent', editable: false, typeAttributes:{maximumFractionDigits:"0", minimumFractionDigits:"0"}, sortable: true, cellAttributes:{alignment: 'left'}},
			{label: 'Acres in AOI', fieldName: 'netAcresWithinAoi__c', type: 'number', editable: false, typeAttributes:{maximumFractionDigits:"7", minimumFractionDigits:"7"}, sortable: true, cellAttributes:{alignment: 'left'}},
			//{label: 'AOI Sugg. OTG $/Acre', fieldName: 'aoiSuggPPA', type: 'number', editable: false, typeAttributes:{maximumFractionDigits:"2", minimumFractionDigits:"2"}, sortable: true, cellAttributes:{alignment: 'right'}},
			{label: 'AOI Target OTG $/Acre', fieldName: 'aoiTargetOtgPricePerAcre__c', type: 'number', editable: false, typeAttributes:{maximumFractionDigits:"2", minimumFractionDigits:"2"}, sortable: true, cellAttributes:{alignment: 'right'}},
			{label: 'AOI Tract Target OTG $', fieldName: 'aoiTargetOtgPrice__c', type: 'number', editable: false, typeAttributes:{maximumFractionDigits:"2", minimumFractionDigits:"2"}, sortable: true, cellAttributes:{alignment: 'right'}},
			{label: 'AOI Max OTG $/Acre', fieldName: 'aoiMaxOtgPricePerAcre__c', type: 'number', editable: false, typeAttributes:{maximumFractionDigits:"2", minimumFractionDigits:"2"}, sortable: true, cellAttributes:{alignment: 'right'}},
			{label: 'AOI Tract Max OTG $', fieldName: 'aoiMaxOtgPrice__c', type: 'number', editable: false, typeAttributes:{maximumFractionDigits:"2", minimumFractionDigits:"2"}, sortable: true, cellAttributes:{alignment: 'right'}},
			//{label: 'AOI Tract Sugg. OTG $', fieldName: 'aoiTractTargetPrice', type: 'number', editable: false, typeAttributes:{maximumFractionDigits:"2", minimumFractionDigits:"2"}, sortable: true, cellAttributes:{alignment: 'right'}},
			
		]);

	var action = component.get("c.getTractProjectAOIs");

		action.setParams({
			'recordId': component.get('v.recordId')
		});

		action.setCallback(this, function(response){
			var responseValue = response.getReturnValue();
			console.log(JSON.stringify(responseValue));
			var data = responseValue.projectTracts;
			data.forEach(function(row){
                    row.percentageOfAcreageInAoi__c = row.percentageOfAcreageInAoi__c/100;
					row.projectLink = '/' + row.projectAoi__c;
					row.projectTractLink  = '/' + row.Id;
					row.projectName = row.projectAoi__r.Name;
                });
			component.set('v.data', data);
			component.set('v.percentCovered', responseValue.sumPercentAcres.toFixed(2));
			component.set('v.targetPrice', responseValue.sumTargetPrice.toFixed(2));
			component.set('v.maxPrice', responseValue.sumMaxPrice.toFixed(2));
			component.set('v.netAcres', responseValue.sumNetAcres.toFixed(5));
			component.set('v.targetPPA', responseValue.targetPPA.toFixed(2));
			component.set('v.maxPPA', responseValue.maxPPA.toFixed(2));
			//console.log(JSON.stringify(responseValue.pricingResults));
			//console.log(JSON.stringify(responseValue.percentAcres));
            //component.set('v.data', torData);
			component.set('v.isWaiting', false);
		});

		$A.enqueueAction(action);
	},
	handleSort: function (component, event, helper) {
		
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.sortBy", fieldName);
        component.set("v.sortDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
    },
})