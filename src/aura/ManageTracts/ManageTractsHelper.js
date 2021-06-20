({
    getT2Data : function(component,event,helper) {
		//T2 Data is unAssociated.
        var action = component.get('c.getUnassociatedTract');
		var filtered = component.get('v.searchString').length>1;
		//console.log('Pagesize value is: ' + component.get('v.pageSizeT1'));
        action.setParams({
            oppId : component.get('v.recordId'),
            pageNumber : component.get('v.pageNumberT2'),
            pageSize : component.get('v.pageSizeT2'),
			filtered : filtered,
			searchString : component.get('v.searchString')
        });
		//console.log(event.getParam('selId'));
		/*if(event.getParam('selId') && event.getParam('selId') != ''){
			console.log('selId value is: ' + event.getParam('selId'));
			action.setParam('landGridTractId', event.getParam('selId'));	
		}*/
        action.setCallback(this, function (response) {
            var state = response.getState();
            var resultData = response.getReturnValue();
            var addedTracts = component.get('v.addedTracts');
			var selectedRows = [];
			var unAssociatedTable = component.find('unAssociatedTable');
			if (state === "SUCCESS") {
                //console.log(JSON.stringify(resultData));
                resultData.forEach(function(record){
                    //console.log(JSON.stringify(record));
                    //console.log(record);
                    record.linkName = '/'+record.Id;
					record.linkToolTip = 'Open tract ' + record.Name + ' in a new tab.';
					//console.log(record.linkToolTip);
                    if(record.netAcres__c != undefined && record.netAcres__c != null){
                        //console.log('record.netAcres__c value is: ' + record.netAcres__c + ' js type is: ' + typeof(record.netAcres__c));// + ' if undefined statement: ' + record.netAcres__c != 'undefined');
                        record.netAcres = parseFloat(record.netAcres__c).toFixed(2)+' '+record.netAcreageUnits__c;
                    }
					var currentTractId = record.Id;
					function isSelected(tract) { 
					  return tract.Id === currentTractId;
					}
					if(addedTracts){
						var isChecked = addedTracts.findIndex(isSelected);
						if(isChecked >=0){
							selectedRows.push(record.Id);
						}
					}

                });
                component.set('v.unassociatedData',resultData);
				
				unAssociatedTable.set('v.selectedRows', selectedRows);
                if(resultData.length < component.get("v.pageSizeT2")){
                    component.set("v.isLastPageT2", true);
                } else{
                    component.set("v.isLastPageT2", false);
                }
                component.set("v.dataSizeT2", resultData.length);
				var fieldName = component.get("v.sortedByT2");
				var sortDirection = component.get("v.sortedDirectionT2");
				//console.log('fieldName value is: ' + fieldName + ' sortDirection value is: ' + sortDirection);
				this.sortData(component, fieldName, sortDirection,'T2');
				component.set('v.t2PageChange', false);
            }
        });
        $A.enqueueAction(action);
    },
    getT1Data : function(component,event,helper) {
        var action = component.get('c.getAssociatedTract');
		var filtered = component.get('v.searchString').length>1;
		//console.log('Remove Tracts at Helper line 63');
		//console.log(component.get('v.removedTracts'));
        action.setParams({
            oppId : component.get('v.recordId'),
            pageNumber : component.get('v.pageNumberT1'),
            pageSize : component.get('v.pageSizeT1'),
			filtered : filtered,
			searchString : component.get('v.searchString')
        });
		//console.log(event.getParam('selId'));
		/*if(event.getParam('selId') && event.getParam('selId') != ''){
			console.log('Setting landGridTractId to: ' + event.getParam('selId'));
			action.setParam('landGridTractId', event.getParam('selId'));	
		}*/
        action.setCallback(this, function (response) {
            var state = response.getState();
            var resultData = response.getReturnValue();
			var removedTracts = component.get('v.removedTracts');
			//console.log('removedTracts value at Helper line 78');
			//console.log(removedTracts);
			var associatedTable = component.find('associatedTable');
			var selectedRows = [];
            if (state === "SUCCESS") {
                resultData.forEach(function(record){
                    record.linkName = '/'+record.Id;
					record.linkToolTip = 'Open tract ' + record.Name + ' in a new tab.';
					 if(record.netAcres__c != undefined && record.netAcres__c !=null){
                    record.netAcres = parseFloat(record.netAcres__c).toFixed(2)+' '+record.netAcreageUnits__c;
					}
					var currentTractId = record.Id;
					function isSelected(tract) { 
					  return tract.Id === currentTractId;
					}
					if(removedTracts){
						//console.log(removedTracts);
						var isChecked = removedTracts.findIndex(isSelected);
						if(isChecked >=0){
							selectedRows.push(record.Id);
						}
					}
					/*var currentTractId = record.Id;
					function isSelected(tract) { 
					  return tract.Id === currentTractId;
					}
					var isChecked = addedTracts.findIndex(isSelected);
					if(isChecked >=0){
						unAssociatedTable.selectedRows.push(record);
					}*/
                });
                component.set('v.associatedData',resultData);
				associatedTable.set('v.selectedRows', selectedRows);
                if(resultData.length < component.get("v.pageSizeT1")){
                    component.set("v.isLastPageT1", true);
                } else{
                    component.set("v.isLastPageT1", false);
                }
                component.set("v.dataSizeT1", resultData.length);
				var fieldName = component.get("v.sortedByT1");
				var sortDirection = component.get("v.sortedDirectionT1");
				//console.log('fieldName value is: ' + fieldName + ' sortDirection value is: ' + sortDirection);
				this.sortData(component, fieldName, sortDirection,'T1');
				component.set('v.t1PageChange', false);
            }
        });
        $A.enqueueAction(action);
    },
    sortData: function (component, fieldName, sortDirection,tableNo) {
        var data =[];
        if(tableNo==='T1'){
            data = component.get("v.associatedData");
        }else{
            data = component.get("v.unassociatedData");
        }
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse))
        if(tableNo==='T1'){
            component.set("v.associatedData", data);
        }else{
            component.set("v.unassociatedData", data);
        }
        
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
        function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a)?key(a):'', b = key(b)?key(b):'', reverse * ((a > b) - (b > a));
        }
    },
	populateDataTables: function(component, event){
		component.set('v.pageNumberT1', 1);
		component.set('v.pageSizeT1', 10);
		component.set('v.pageNumberT2', 1);
		component.set('v.pageSizeT2', 10);
		var searchString = component.get('v.searchString');
		var searchCounter = component.get('v.searchCounter');
		//console.log('searchCounter value is: ' + searchCounter);
		var oppId = component.get('v.recordId');
		searchCounter++;
		component.set('v.searchCounter', searchCounter);
		var action = component.get("c.getFilteredTracts");

		action.setParams({
			'searchCount': searchCounter,
			'searchTerm': searchString,
			'oppId': oppId,
			'pageNumber' : component.get('v.pageNumberT1'),
            'pageSize' : component.get('v.pageSizeT1')

		});

		action.setCallback(this, function(response){
			var resultData = response.getReturnValue();
			var currentSearchCounter = component.get('v.searchCounter');
			if(currentSearchCounter == resultData.searchCounter  && response.getState() === "SUCCESS") {
                //console.log(JSON.stringify(resultData));
                resultData.unassociatedTracts.forEach(function(record){
                    record.linkName = '/'+record.Id;
                    if(record.netAcres__c != undefined && record.netAcres__c != null){
                        record.netAcres = parseFloat(record.netAcres__c).toFixed(2)+' '+record.netAcreageUnits__c;
                    }
                });
				resultData.associatedTracts.forEach(function(record){
                    record.linkName = '/'+record.Id;
                    if(record.netAcres__c != undefined && record.netAcres__c != null){
                        record.netAcres = parseFloat(record.netAcres__c).toFixed(2)+' '+record.netAcreageUnits__c;
                    }
                });
                component.set('v.unassociatedData',resultData.unassociatedTracts);
				component.set('v.associatedData',resultData.associatedTracts);
                //console.log(JSON.stringify(component.get('v.unassociatedData')));
				/*console.log('unassociatedData length: ' + resultData.unassociatedData.length);
				//console.log('associatedData length: ' + resultData.associatedData.length);
                if(resultData.unassociatedData.length < component.get("v.pageSizeT1")){
                    component.set("v.isLastPageT1", true);
                } else{
                    component.set("v.isLastPageT1", false);
                }
				if(resultData.associatedData.length < component.get("v.pageSizeT1")){
                    component.set("v.isLastPageT2", true);
                } else{
                    component.set("v.isLastPageT2", false);
                }
                component.set("v.dataSizeT1", resultData.unassociatedData.length);
				component.set("v.dataSizeT2", resultData.associatedData.length);
				*/
            }
		});

		$A.enqueueAction(action);

		//console.log('Make call to controller to get top ten account records for: ' + searchString + ' searchCounter set to: ' + searchCounter);
	},
    
})