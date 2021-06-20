({
    sortData: function (component, fieldName, sortedDirection) {
        var data = component.get("v.tableData");
        var reverse = sortedDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        console.log('---11---'+sortedDirection);
        data.sort(this.sortBy(fieldName, reverse))
        component.set("v.tableData", data);
    },
    sortBy: function (field, reverse, primer) {
        console.log('---2---'+reverse);
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a)?key(a):'', b = key(b)?key(b):'', reverse * ((a > b) - (b > a));
        }
	},
	getData: function (component, helper){
    component.set('v.mycolumns', [
           /*{label: 'Account', fieldName: 'AccountLink', type: 'url', cellAttributes: { alignment: 'left' }, 
                         typeAttributes: {label: { fieldName: 'AccountName' }, target: '_self'},sortable: true },*/
		    {label: 'Tract', fieldName: 'TractLink', type: 'url', cellAttributes: { alignment: 'left' }, 
             typeAttributes: {label: { fieldName: 'TractName' }, target: '_self'},sortable: true },
        
			 {label: 'Subtract', fieldName: 'linkSubtractName', type: 'url', cellAttributes: { alignment: 'left' }, 
             typeAttributes: {label: { fieldName: 'SubtractName' }, target: '_self'},sortable: true },
			{label: 'Unit Allocation', fieldName: 'linkName', type: 'url', cellAttributes: { alignment: 'left' }, 
             typeAttributes: {label: { fieldName: 'Name' }, target: '_self'},sortable: true },
			{label: 'Unit Name', fieldName: 'linkUnitName', type: 'url', cellAttributes: { alignment: 'left' }, 
              typeAttributes: {label: { fieldName: 'UnitName' }, target: '_self'},sortable: true},
            { label: 'GIS Unit Name', fieldName: 'gisName', type: 'string', cellAttributes: { alignment: 'left' }, sortable: true },
			{ label: 'Unit Type', fieldName: 'unitType', type: 'string', cellAttributes: { alignment: 'left' }, sortable: true },
            //{ label: 'Unit Gross Acres', fieldName: 'unitGrossAcres__c', type: 'number', cellAttributes: { alignment: 'left' },typeAttributes: { minimumFractionDigits : '8' }, sortable: true },
            { label: 'Allocation Percent', fieldName: 'allocationPercentage__c', type: 'number', cellAttributes: { alignment: 'left' },typeAttributes: { minimumFractionDigits : '8' }, sortable: true },
			{ label: 'Unit NRI', fieldName: 'uaNRI__c', type: 'number', cellAttributes: { alignment: 'left' },typeAttributes: { minimumFractionDigits : '8' }, sortable: true }
                    ]);
        //component.set("v.Spinner", true);
        var action = component.get('c.getRecords');
        var recordId = component.get('v.recordId'); 
        action.setParams({
            recordId: recordId, acctName:component.get('v.acctName')
        });
        action.setCallback(this, function(response) {
            //component.set("v.Spinner", false);
            var state = response.getState();
            var result = response.getReturnValue().uaList;
            if (state === "SUCCESS") {
                //if(result.length > 4){
                //    component.set('v.isScrollable',true);
                //}
				console.log('Result length is: ' + result.length);
				if(result.length>10){
                    var dataTable = component.find("dataTable");
                    $A.util.addClass(dataTable, 'maxHeight');
                }
                if(response.getReturnValue().sObjectName == 'GIS_Update_Request__c'){
                    component.set('v.mycolumns', [
                        {label: 'Name', fieldName: 'linkName', type: 'url', cellAttributes: { alignment: 'left' }, 
                         typeAttributes: {label: { fieldName: 'Name' }, target: '_self'},sortable: true },
                        {label: 'Account', fieldName: 'AccountLink', type: 'url', cellAttributes: { alignment: 'left' }, 
                         typeAttributes: {label: { fieldName: 'AccountName' }, target: '_self'},sortable: true },
                        {label: 'Tract', fieldName: 'TractLink', type: 'url', cellAttributes: { alignment: 'left' }, 
                         typeAttributes: {label: { fieldName: 'TractName' }, target: '_self'},sortable: true },
                         {label: 'Subtract', fieldName: 'linkSubtractName', type: 'url', cellAttributes: { alignment: 'left' }, 
                        typeAttributes: {label: { fieldName: 'SubtractName' }, target: '_self'},sortable: true },
                        { label: 'Unit NRI', fieldName: 'unitNRI__c', type: 'number', cellAttributes: { alignment: 'left' },typeAttributes: { minimumFractionDigits : '8' }, sortable: true },
                        { label: 'Allocation Factor Computed', fieldName: 'allocationFactorComputed__c', type: 'number', cellAttributes: { alignment: 'left' },typeAttributes: { minimumFractionDigits : '8' }, sortable: true },
                       { label: 'Inactive', fieldName: 'Inactive__c', type: 'boolean', cellAttributes: { alignment: 'left' }, sortable: true },
                        { label: 'Created Date', fieldName: 'CreatedDate', type: 'date-local', cellAttributes: { alignment: 'left' }, sortable: true },
                        { label: 'Last Modified', fieldName: 'LastModifiedDate', type: 'date-local', cellAttributes: { alignment: 'left' }, sortable: true }
                        
                        
                    ]); 
                }
                var finalArray = [];
                result.forEach(function(record) {
                    
                    record.linkName = '/' + record.Id;
                    
					if (record.unit__r.GIS_Unit_Name__c !=undefined && record.unit__r.GIS_Unit_Name__c !=null && record.unit__r.GIS_Unit_Name__c !=''){
						record.gisName = record.unit__r.GIS_Unit_Name__c;
					}
                    
                    if (record.subtract__c != undefined && record.subtract__c != null && record.subtract__c != '') {
                        record.linkSubtractName = '/' + record.subtract__c;
                        record.SubtractName = record.subtract__r.Name;
                        if(record.subtract__r.Tract__c!=undefined){
                            record.TractName= record.subtract__r.Tract__r.Name;
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
                        //console.log('unit----'+record.unit__r.Unit_Type__c);
                    }
                    var type = component.get('v.Type');
                    
                    if(type === 'Active'){
                        if(record.Inactive__c === false){
                            finalArray.push(record);
                        }
                    }else if( type === 'Inactive'){
                        
                        if(record.Inactive__c === true){
                            finalArray.push(record);
                        }
                    }else{
                        finalArray.push(record);
                    }
                });
				//var startTime = new Date();
				//console.log('Starting data table result set statement at ' + startTime);
                
				
				component.set("v.data", result);
				component.set('v.tableData', result.slice(0,component.get('v.rowsToLoad')));
				component.set('v.loadedRows', component.get('v.tableData').length); 
				//var endTime = new Date();
				//console.log('Finished at ' + endTime + ' time difference is ' + (endTime-startTime));
                component.set("v.totalNumberOfRows", result.length);
				helper.setStatusMessage(component, helper);

            } else {
                //alert(state);
            }
			component.set('v.isWaiting', false);
        });
        $A.enqueueAction(action);

    },

	setStatusMessage:function(component, helper){
		var statusMessage = 'Displaying ' + component.get('v.loadedRows') + ' of ' + component.get('v.totalNumberOfRows') + ' rows.';
		var statusMessage = ((component.get('v.loadedRows') < component.get('v.totalNumberOfRows'))? statusMessage + '  Scroll down to load more.': statusMessage + '  All data is loaded.'); 
		component.set('v.loadMoreStatus', statusMessage);
	}
})