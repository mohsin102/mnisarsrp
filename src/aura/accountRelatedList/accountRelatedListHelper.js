({
	getData : function(component, helper) {
        var action = component.get("c.getData");
		var recordOffset = component.get("v.currentCount");
		var recordId = component.get("v.recordId");
		var relatedObject = component.get('v.relatedObject');
		if(recordOffset <= 2000){
			var toastEvent = $A.get("e.force:showToast");
			action.setParams({
				"recordId": recordId,
				"recordOffset": recordOffset,
				"relatedObject": relatedObject
			});
			action.setCallback(this, function(response) {
				var state = response.getState();
			
				if (state === "SUCCESS" ) {
					console.log('Inside Success');
					var resultData = response.getReturnValue();
					console.log(resultData);
					resultData.forEach(function(record) {
						helper.configureData(component, record);
					});
				
					if(!component.get('v.data')){
						component.set('v.data', resultData);
					}
					else {
						var currentData = component.get('v.data');
						var newData = currentData.concat(resultData);
						component.set('v.data', newData);
						component.set('v.loadMoreStatus', 'Please scroll down to load more data');
					}
					console.log('data length is: ' + component.get('v.data').length + 'totalNumberOfRows is: ' + component.get('v.totalNumberOfRows'));
					if (component.get('v.data').length == component.get('v.totalNumberOfRows')) {
						component.set('v.enableInfiniteLoading', false);
						component.set('v.loadMoreStatus', 'No more data to load');
					} 

					component.set("v.currentCount", component.get('v.currentCount') + resultData.length);
					//console.log('finishing getTracts and currentCount is now set to: ' + component.get('v.currentCount'));
					component.set('v.isWaiting', false);
					component.find('datatable').set('v.isLoading', false);
				}
				else{
					console.log('response value is:');
					console.log(response.getError()[0].message);
					alert('Could not retrieve related records, please contact the Salesforce team.\r\n\r\nResponse from Server was:\r\n\r\n' + response.getError()[0].message);
				}
			
			});
			$A.enqueueAction(action);
		}
		else{
			component.set('v.enableInfiniteLoading', false);
			component.find('datatable').set('v.isLoading', false);
			component.set('v.loadMoreStatus', 'Maximum number of records has been loaded.  Total count of Loaded Records is: ' + recordOffset + '.  Please run a report to see all results.' );
		}
    },

    getTotalNumberOfRecords : function(component) {
		var relatedObject = component.get('v.relatedObject');
        var action = component.get("c.getTotalTractCount");
        action.setParams({"recordId": component.get("v.recordId"), "relatedObject":relatedObject});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" ) {
                var resultData = response.getReturnValue();
                component.set("v.totalNumberOfRows", resultData);
            }
        });
        $A.enqueueAction(action);
    },
     
    getColumns : function(component) {
        switch(component.get('v.relatedObject')) {
			case 'Tract__c':
				component.set('v.columns', [
					{ label: 'Tract', fieldName: 'TractLink', sortable: true, type:'url', typeAttributes:
							{value: {fieldName: 'TractLink'}, label: {fieldName: 'Name'}, tooltip: 'View Tract'},
						initialWidth: 100, sortable: true},
					{ label: 'Full Legal Name', fieldName: 'Full_Legal_Name__c', sortable: true, initialWidth: 200, sortable: true},
					{ label: 'Depth', fieldName: 'depth__c', initialWidth: 100, sortable: true},
					{ label: 'Title Source', fieldName: 'titleSourceType__c', initialWidth: 150, sortable: true},
					{ label: 'Notes', fieldName: 'Notes__c', initialWidth: 200, sortable: true},
					{ label: 'Instrument', fieldName: 'Instrument_Type__c', initialWidth: 100, sortable: true},
					{ label: 'Acres', fieldName: 'Acres', type: 'textExtended', typeAttributes:{title:{ fieldName: 'Acres' }, value:{ fieldName: 'Acres' }}, sortable: true, initialWidth: 90},
					{ label: 'Total Cost', fieldName: 'Total_Cost__c', type: 'currency', sortable: true, initialWidth: 120, },
					{ label: '% Covered by AOI Pricing', fieldName: 'percentCovered__c', type: 'percent', sortable: true, initialWidth: 190,},
					{ label: 'Target OTG Cost Per Acre', fieldName: 'targetPPA__c', type: 'currency', sortable: true, initialWidth: 190,},
					{ label: 'Total Target OTG Cost', fieldName: 'targetPrice__c', type: 'currency', sortable: true, initialWidth: 190,},
					{ label: 'Max OTG Price Per Acre', fieldName: 'maxPPA__c', type: 'currency', sortable: true, initialWidth: 190,},
					{ label: 'Max OTG Total Cost', fieldName: 'maxPrice__c', type: 'currency', sortable: true, initialWidth: 190,},
				]);
				break;
			case 'unitAllocation__c':
				component.set('v.columns', [
					//{label: 'Account', fieldName: 'AccountLink', type: 'url', cellAttributes: { alignment: 'left' }, 
					//	typeAttributes: {label: { fieldName: 'AccountName' }, target: '_self'},sortable: true },
					{label: 'Tract',  fieldName: 'TractLink', type: 'url', cellAttributes: { alignment: 'left' }, 
						typeAttributes: {label: { fieldName: 'TractName' }, tooltip: 'View Tract'},initialWidth: 100, sortable: true },
					{label: 'Subtract', fieldName: 'linkSubtractName', type: 'url', cellAttributes: { alignment: 'left' }, 
						typeAttributes: {label: { fieldName: 'SubtractName' }, tooltip: 'View Subtract'},initialWidth: 150,sortable: true },
					{label: 'Unit Allocation', fieldName: 'linkName', type: 'url', cellAttributes: { alignment: 'left' }, 
						typeAttributes: {label: { fieldName: 'Name' }, tooltip: 'View Unit Allocation'},initialWidth: 150,sortable: true },
					{label: 'Unit Name', fieldName: 'linkUnitName', type: 'url', cellAttributes: { alignment: 'left' }, 
						typeAttributes: {label: { fieldName: 'UnitName' }, tooltip: 'View Unit'},initialWidth: 150,sortable: true},
					{ label: 'GIS Unit Name', fieldName: 'gisName', type: 'string', cellAttributes: { alignment: 'left' }, initialWidth:150, sortable: true },
					{ label: 'Unit Type', fieldName: 'unitType', type: 'string', cellAttributes: { alignment: 'left' }, initialWidth:100, sortable: true },
					{ label: 'Allocation Percentage', fieldName: 'allocationPercentage__c', type: 'number', cellAttributes: { iconName :'utility:percent', alignment: 'left',iconPosition: 'right' },typeAttributes: {minimumFractionDigits:'7', maximumFractionDigits : '7' }, initialWidth:150, sortable: true },
					{ label: 'Unit NRI', fieldName: 'unitNRI__c', type: 'number', cellAttributes: { alignment: 'left' },typeAttributes: { minimumFractionDigits : '8' }, initialWidth:125, sortable: true }
				]);
				break;
		}
    },
     
    /*sortData: function (component, fieldName, sortDirection) {
        var data = component.get("v.data");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse))
        component.set("v.data", data);
    },
     
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
        function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },*/

	configureData: function(component, record){
		switch(component.get('v.relatedObject')) {
			case 'Tract__c':
				record.TractLink='/' + record.Id;
				if(typeof(record['netAcres__c']) == 'string'){
					record['netAcres__c'] = parseFloat(record['netAcres__c']);
				}
				if(record['Id'] && typeof(record['netAcres__c'])!='undefined'){
					if(record['netAcreageUnits__c']){
						record.Acres = record['netAcres__c'].toFixed(1) + ' ' + record['netAcreageUnits__c'];
					}
					else{
						record.Acres = record['netAcres__c'].toFixed(1) + ' ?';
					}
				}
				break;
			case 'unitAllocation__c':
				record.linkName = '/' + record.Id;
                    
				if (record.unit__r.GIS_Unit_Name__c !=undefined && record.unit__r.GIS_Unit_Name__c !=null && record.unit__r.GIS_Unit_Name__c !=''){
					record.gisName = record.unit__r.GIS_Unit_Name__c;
				}
                    
				if (record.subtract__c != undefined && record.subtract__c != null && record.subtract__c != '') {
					record.linkSubtractName = '/' + record.subtract__c;
					record.SubtractName = record.subtract__r.Name;
					if(record.subtract__r.Tract__c!=undefined){
						record.TractName= record.subtract__r.Tract__r.Name;
						record.TractCreatedDate = record.subtract__r.Tract__r.CreatedDate;
						record.TractLink= '/'+record.subtract__r.Tract__c;
						if(record.subtract__r.Tract__r.Account__c!=undefined){
							record.AccountName= record.subtract__r.Tract__r.Account__r.Name;
							record.AccountLink= '/'+record.subtract__r.Tract__r.Account__c;
						}
					}
				}
				if (record.unit__c != undefined && record.unit__c != null && record.unit__c != '') {
					record.linkUnitName = '/' + record.unit__c;
					record.UnitName = record.unit__r.Name;
					record.unitType = record.unit__r.Unit_Type__c;
					record.allocationPercentage = record.unit__r.allocationPercentage__c;
				}
				break;
		}


		return record;
	}
})