({
    doInit : function(component, event, helper) {
        component.set('v.sortedByT1', 'Id');
        component.set('v.sortedDirectionT1', 'ASC');
		component.set('v.sortedByT2', 'Id');
        component.set('v.sortedDirectionT2', 'ASC');

		component.set('v.searchCounter', 0);
        
        component.set('v.columns', [
            {label: 'Tract Name', fieldName: 'linkName', type: 'url', cellAttributes: { alignment: 'left' }, 
             typeAttributes: {label: { fieldName: 'Name' }, target: '_blank', tooltip:{fieldName: 'linkToolTip'}}, sortable: true},
			{ label: 'Full Legal Name', fieldName: 'Full_Legal_Name__c', type: 'textExtended', initialWidth:350, editable: false, typeAttributes:{title:{ fieldName: 'Full_Legal_Name__c' }, value:{ fieldName: 'Full_Legal_Name__c' }}, sortable: true},
			{ label: 'Quarter Call', fieldName: 'Quarter_Call__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'Quarter_Call__c' }, value:{ fieldName: 'Quarter_Call__c' }}, sortable: true},
			{ label: 'Instrument Type', fieldName: 'Instrument_Type__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'Instrument_Type__c' }, value:{ fieldName: 'Instrument_Type__c' }}, sortable: true},

            //{ label: 'Full Legal Name', fieldName: 'Full_Legal_Name__c', type: 'text', cellAttributes: { alignment: 'left' }, sortable: true},
            //{ label: 'Quarter Call', fieldName: 'Quarter_Call__c', type: 'text', cellAttributes: { alignment: 'left' }, sortable: true },
            //{ label: 'Instrument Type', fieldName: 'Instrument_Type__c', type: 'text',  cellAttributes: { alignment: 'left' }, sortable: true},
            { label: 'Gross Acres', fieldName: 'Gross_Acres__c', type: 'number',  cellAttributes: { alignment: 'left' }, sortable: true},
            { label: 'Net Acres', fieldName: 'netAcres', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'netAcres' }, value:{ fieldName: 'netAcres' }}, sortable: true},
            { label: 'Depth', fieldName: 'depth__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'depth__c' }, value:{ fieldName: 'depth__c' }}, sortable: true},
			{ label: 'Notes', fieldName: 'Notes__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'Notes__c' }, value:{ fieldName: 'Notes__c' }}, sortable: true},
			//{ label: 'Net Acres', fieldName: 'netAcres', type: 'text',  cellAttributes: { alignment: 'left' }, sortable: true},
            //{ label: 'Notes', fieldName: 'Notes__c', type: 'text',  cellAttributes: { alignment: 'left' }, sortable: true}
        ]);
        helper.getT1Data(component,event,helper);
        helper.getT2Data(component,event,helper);
        
    },
    
    addSelection : function(component, event, helper){
        if(component.get('v.t2PageChange')){
			component.set('v.t2PageChange', false);
		}
		else{
		
			var addedTracts = event.getParam('selectedRows');
		
			var componentAddedTracts = component.get('v.addedTracts');
			var currentUnassociated = component.get('v.unassociatedData');
			var unAssociatedTable = component.find('unAssociatedTable')      

			//check for unchecked values and remove from addedTracts on component.
			if(currentUnassociated && componentAddedTracts){
				for(var unAssociated in currentUnassociated){
					var currentTractId = currentUnassociated[unAssociated].Id;
					function isSelected(tract) { 
					  return tract.Id === currentTractId;
					}

					var checked = addedTracts.findIndex(isSelected);
				
					var inList = componentAddedTracts.findIndex(isSelected);
					//console.log('Tract Id ' + currentTractId + ' index value of selected is ' + checked + ' already in added value is ' + inList);
					//console.log('Tract Id ' + currentTractId + ' already in added value is ' + inList);
					//if values are both positive or both = -1, no change is needed.

					//if checked > 0 and inList < 0 - add to list
					if (checked>=0 && inList < 0){
						componentAddedTracts.push(currentUnassociated[unAssociated]);
					}
					//if not checked and inList > 0 remove from list
					if(checked < 0 && inList >=0){
						//console.log(componentAddedTracts);
						componentAddedTracts.splice(inList, 1);
						//console.log(componentAddedTracts);
					}
				}
			}
			else{
				componentAddedTracts = addedTracts;
			
			}

			if(componentAddedTracts.length > 0){
				component.set("v.showAddTract",true);
			}else{
				component.set("v.showAddTract",false);
			}

			//console.log(componentAddedTracts);
			component.set('v.addedTracts',componentAddedTracts);
			//console.log(componentAddedTracts);
		}
    },
    removeSelection : function(component, event, helper){
		//console.log('removeSelection called');
		//console.log(component.get('v.removedTracts'));
        if(component.get('v.t1PageChange')){
			component.set('v.t1PageChange', false);
		}
		else{
		
			var removedTracts = event.getParam('selectedRows');
		
			var componentRemovedTracts = component.get('v.removedTracts');
			//console.log('Controller line 96 value of componentRemovedTracts is');
			//console.log(componentRemovedTracts);
			var currentAssociated = component.get('v.associatedData');
			console.log('Controller line 99 value of currentAssociated is');
			console.log(currentAssociated);
			var unAssociatedTable = component.find('unAssociatedTable')
			//console.log('Controller line 102 value of unAssociatedTable is');
			//console.log(unAssociatedTable);      

			//check for unchecked values and remove from addedTracts on component.
			if(currentAssociated && componentRemovedTracts){
				for(var associated in currentAssociated){
					var currentTractId = currentAssociated[associated].Id;
					function isSelected(tract) { 
					  return tract.Id === currentTractId;
					}


					var checked = removedTracts.findIndex(isSelected);
					console.log('Checked value is: ' + checked);
					var inList = componentRemovedTracts.findIndex(isSelected);
					console.log('inList value is: ' + inList);
					//console.log('Tract Id ' + currentTractId + ' index value of selected is ' + checked + ' already in added value is ' + inList);
					//console.log('Tract Id ' + currentTractId + ' already in added value is ' + inList);
					//if values are both positive or both = -1, no change is needed.

					//if checked > 0 and inList < 0 - add to list
					if (checked>=0 && inList < 0){
						componentRemovedTracts.push(currentAssociated[associated]);
					}
					//if not checked and inList > 0 remove from list
					if(checked < 0 && inList >=0){
						//console.log(componentAddedTracts);
						componentRemovedTracts.splice(inList, 1);
						//console.log(componentAddedTracts);
					}
				}
			}
			else{
				console.log('Controller line 137 value of removedTracts is');
				console.log(removedTracts);
				componentRemovedTracts = removedTracts;
			
			}

			if(componentRemovedTracts.length > 0){
				component.set("v.showRemoveTract",true);
			}else{
				component.set("v.showRemoveTract",false);
			}

			//console.log(componentAddedTracts);
			//console.log('Controller line 146 value of componentRemovedTracts is');
			//console.log(componentRemovedTracts);
			//component.set('v.removedTracts', []);
			component.set('v.removedTracts',componentRemovedTracts);
			//console.log(component.get('v.removedTracts'));
		}
		/*var removedTracts = event.getParam('selectedRows');
        if(removedTracts.length > 0){
            component.set("v.showRemoveTract",true);
        }else{
            component.set("v.showRemoveTract",false);
        }
        component.set('v.removedTracts',removedTracts);
		*/
    },
    addTracts : function(component,event,helper){
		//console.log('addTracts called.');
        var action = component.get('c.addTract');
        action.setParams({
            oppId : component.get('v.recordId'),
            tracts : component.get('v.addedTracts')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.populateDataTables(component, event);
				component.set('v.addedTracts', []);
				component.set("v.showAddTract",false);
				$A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    },
    removeTracts : function(component,event,helper){
        var action = component.get('c.removeTract');
        action.setParams({
            oppId : component.get('v.recordId'),
            tracts : component.get('v.removedTracts')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.populateDataTables(component, event);
				//console.log('clearing removedTracts');
				component.set('v.removedTracts', []);
				component.set("v.showRemoveTract",false);
				$A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    },
    handleNextT1 : function(component, event, helper) { 
        var pageNumber = component.get("v.pageNumberT1");
		component.set('v.t1PageChange', true);
		//console.log('handle next T1 called.');
		//console.log(component.get('v.addedTracts'));
        component.set("v.pageNumberT1", pageNumber+1);
        helper.getT1Data(component,event,helper);
		/*var fieldName = component.get("v.sortedByT1");
        var sortDirection = component.get("v.sortedDirectionT1");
		helper.sortData(component, fieldName, sortDirection,'T1');*/
    },
    
    handlePrevT1 : function(component, event, helper) {       
		//console.log('remove tracts value at controller line 210.');
		//console.log(component.get('v.removedTracts'));		 
        var pageNumber = component.get("v.pageNumberT1");
        component.set('v.t1PageChange', true);
		component.set("v.pageNumberT1", pageNumber-1);
		//console.log('handle previous T1 called.');
		//console.log(component.get('v.addedTracts'));
        helper.getT1Data(component,event, helper);
		/*var fieldName = component.get("v.sortedByT1");
        var sortDirection = component.get("v.sortedDirectionT1");
		helper.sortData(component, fieldName, sortDirection,'T1');*/
    },
    handleNextT2 : function(component, event, helper) { 
        var pageNumber = component.get("v.pageNumberT2");
		component.set('v.t2PageChange', true);
        component.set("v.pageNumberT2", pageNumber+1);
        helper.getT2Data(component,event, helper);
		var fieldName = component.get("v.sortedByT2");
        var sortDirection = component.get("v.sortedDirectionT2");
		helper.sortData(component, fieldName, sortDirection,'T2');
    },
    
    handlePrevT2 : function(component, event, helper) {        
        var pageNumber = component.get("v.pageNumberT2");
		component.set('v.t2PageChange', true);
        component.set("v.pageNumberT2", pageNumber-1);
        helper.getT2Data(component,event, helper);
		var fieldName = component.get("v.sortedByT2");
        var sortDirection = component.get("v.sortedDirectionT2");
		helper.sortData(component, fieldName, sortDirection,'T2');
    },
    closeModal: function(component, event, helper) {
        var mEvent = component.getEvent('modalEvent');
        mEvent.fire();
        component.destroy();
    },
    
    updateSortingT1: function (component, event, helper) {
        
        var fieldName = event.getParam('fieldName');
        //console.log('fieldName value is: ' + fieldName);
        var sortDirection = event.getParam('sortDirection');
        component.set("v.sortedByT1", fieldName);
        component.set("v.sortedDirectionT1", sortDirection);
        helper.sortData(component, fieldName, sortDirection,'T1');
    },
    updateSortingT2: function (component, event, helper) {
        
        var fieldName = event.getParam('fieldName');
        //console.log('fieldName value is: ' + fieldName);
        var sortDirection = event.getParam('sortDirection');
        component.set("v.sortedByT2", fieldName);
        component.set("v.sortedDirectionT2", sortDirection);
        helper.sortData(component, fieldName, sortDirection,'T2');
    },
	handleKeyUp: function(component, event, helper){
		//console.log('keyup function called.');
		//var searchString = component.get('v.searchString');
		//if(searchString.length > 1){
			helper.populateDataTables(component, event);
		//}	
	},
	checkClear: function(component, event, helper){
		var searchString = component.get('v.searchString');
		if (searchString.length == 0){
			helper.getT1Data(component, event, helper);
			helper.getT2Data(component, event, helper);
		}
	}
	/*handleSelectedLandGridTract: function (component, event, helper){
		console.log('Update list selected id is: ' + event.getParam('selId') + 'parentId is: ' + event.getParam('parentId'));
		switch(event.getParam('parentId')) {
		  case "unAssociated":
			helper.getT1Data(component, event);
			break;
		  case "associated":
			helper.getT2Data(component, event);
			break;
		  default:
			// code block
		}
	}*/
    
})