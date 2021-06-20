({
	handleCancel: function (component, event, helper) {
		if(component.get('v.redirectToRecordPage')){
			//console.log('new title tracker id is: ' + response.getReturnValue().titleWorkTracker.Id);
			var navService = component.find("navService");
			// Sets the route to /lightning/o/Account/home
			var pageReference = {
				type: 'standard__recordPage',
				attributes: {
					objectApiName: 'TitleWorkTracker__c',
					actionName: 'view',
					recordId: component.get('v.recordId')
				}
			};
			navService.navigate(pageReference);
		}
		component.destroy();
		//window.history.back();
		
	},
	handleSuccess : function(component, event, helper) {
		//console.log('handleSuccess called.');
		//$A.get('e.force:refreshView').fire();
		
		
		if(component.get('v.redirectToRecordPage')){
			//console.log('new title tracker id is: ' + response.getReturnValue().titleWorkTracker.Id);
			var navService = component.find("navService");
			// Sets the route to /lightning/o/Account/home
			var pageReference = {
				type: 'standard__recordPage',
				attributes: {
					objectApiName: 'TitleWorkTracker__c',
					actionName: 'view',
					recordId: component.get('v.recordId')
				}
			};
			navService.navigate(pageReference);
		}
		else{
			$A.get('e.force:refreshView').fire();
		}
		component.destroy();			
		//window.history.back();

    },
	handleLoad: function(component, event, helper){
		//console.log('Handle load called.');
		var record = event.getParam("recordUi");
        //var fieldNames = Object.keys(record.fields);
		console.log(JSON.stringify(record));
		//console.log(fieldNames);
		//console.log(JSON.stringify(record.fields.startDate__c));
		//console.log('Record start date is: ' + record.fields.startDate__c);
		if(record.record.fields.startDate__c.value != 'undefined' && record.record.fields.startDate__c.value){
			component.set('v.startDate', record.record.fields.startDate__c.value);
		}
		component.set('v.trackerName', record.record.fields.Name.value);
		console.log('OwnerId is: ');
		console.log(JSON.stringify(record.record.fields.OwnerId));
		//if(record.record.fields.OwnerId.value != 'undefined'){
			//component.set('v.selectedOwner', record.record.fields.OwnerId.value);
			var action = component.get('c.fetchOwner');
			action.setParams({
				'ownerId': record.record.fields.OwnerId.value
			});
			action.setCallback(this, function(response) {
				var state = response.getState();
				var result = response.getReturnValue();
				if (state === "SUCCESS") {
                
					//component.set("v.selectedOwner", result);
					console.log(JSON.stringify(response.getReturnValue()[0]));
					component.set('v.selectedOwner', response.getReturnValue()[0]);
					//var srpOwnerLookup = component.find('userLookup');
					//srpOwnerLookup.set('v.selectedRecord', result);
					//console.log(srpOwnerLookup.get('v.selectedRecord'));
					//var forclose = srpOwnerLookup.find("lookup-pill");
					//$A.util.addClass(forclose, 'slds-show');
					//$A.util.removeClass(forclose, 'slds-hide');
        
					/*var forclose = srpOwnerLookup.find("searchRes");
					$A.util.addClass(forclose, 'slds-is-close');
					$A.util.removeClass(forclose, 'slds-is-open');*/
        
					//var lookUpTarget = srpOwnerLookup.find("lookupField");
					//$A.util.addClass(lookUpTarget, 'slds-hide');
					//$A.util.removeClass(lookUpTarget, 'slds-show');
					//console.log(JSON.stringify(result));

				} else {
					console.log(state);
				}
		});
		$A.enqueueAction(action);
		//}
	},
	userLookupSearch : function(component, event, helper) {
        
		//console.log('Search triggered in component controller.');
        const serverSearchAction = component.get('c.searchOwners');
        // Passes the action to the Lookup component by calling the search method
        component.find('userLookup').search(serverSearchAction);
    },
	handleSubmit: function(component, event, helper) {
        event.preventDefault();       // stop the form from submitting
		var fields = event.getParam('fields');
		if(component.get('v.selectedOwner')[0]){
			fields.OwnerId = component.get('v.selectedOwner')[0].id;
		}
		
        //fields.OwnerId = '32 Prince Street';
        component.find('titleWorkTrackerForm').submit(fields);
    },
})