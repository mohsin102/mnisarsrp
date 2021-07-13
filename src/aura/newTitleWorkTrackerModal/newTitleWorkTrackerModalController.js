({
	init: function (component, event, helper) {
		var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
		component.set('v.selectedStartDate', today);
		component.set('v.selectedCompletionDate', today);
		//component.set('v.selectedOwner', $A.get( "$SObjectType.CurrentUser.Id" ));
		console.log('Current user record is: ' + $A.get( "$SObjectType.CurrentUser.Id" ));

		var action = component.get('c.getTitleWorkJobSelectOptions');
		action.setParams({
			'titleWorkTrackerId': component.get('v.titleTrackerId')
		});
		action.setCallback(this, function(response) {
			var state = response.getState();
			var result = response.getReturnValue();
			if (state === "SUCCESS") {
				component.set("v.workJobTypes", result.workJobTypes);
				component.set("v.workJobStatuses", result.workJobStatuses);
				console.log('selectedWorkJobStatus value is: '+ component.get('v.selectedWorkJobType'));
				if(component.get('v.selectedWorkJobType') == '' || component.get('v.selectedWorkJobType') == undefined){
					component.set('v.selectedWorkJobType', result.defaultType);
				}
				component.set('v.selectedWorkJobStatus', result.defaultStatus);
				//console.log('SelectedWorkJobType value is: ' + component.get('v.selectedWorkJobType'));
				//console.log(JSON.stringify(result));

			} else {
				alert(state);
			}
		});
		var action2 = component.get('c.fetchUser');
		action2.setCallback(this, function(response) {
			var state = response.getState();
			var result = response.getReturnValue();
			if (state === "SUCCESS") {
                
				//component.set("v.selectedOwner", result);
				console.log(response.getReturnValue()[0]);
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
				alert(state);
			}
		});
		$A.enqueueAction(action);
		$A.enqueueAction(action2);
		
	},
	handleCancel: function (component, event, helper) {
		
		if(component.get('v.redirectToRecordPage') && component.get('v.createTitleWorkTracker')){
			//console.log('new title tracker id is: ' + response.getReturnValue().titleWorkTracker.Id);
			var navService = component.find("navService");
			// Sets the route to /lightning/o/Account/home
			var pageReference = {
				type: 'standard__objectPage',
				attributes: {
					objectApiName: 'TitleWorkTracker__c',
					actionName: 'home',
				}
			};
			navService.navigate(pageReference);
		}
		component.destroy();
		//window.history.back();
		
	},
	ownerSelected: function(component, event, helper){
		console.log('Owner selected with id: ' + component.get('v.ownerId'));
	},
	handleSave: function (component, event, helper) {
		console.log('handleSave called.');
		//Check for required inputs
		var startDate = component.get('v.selectedStartDate');
		var completionDate = component.get('v.selectedCompletionDate');
		var owner ='';
		if(component.get('v.selectedOwner')[0]){
			owner = component.get('v.selectedOwner')[0].id;
		}
		console.log('selected owner id value is: ' + owner);
		var workJobType = component.get('v.selectedWorkJobType');
		var workJobStatus = component.get('v.selectedWorkJobStatus');
		var landGridTractId = component.get('v.landGridTractId');
		var hasError = false;
		var errorMessage = '';
		
		if(landGridTractId === ''){
			hasError = true;
			errorMessage = helper.appendErrorMessage(errorMessage, 'Please Select a Land Grid Tract.');
		}
		if(!component.get('v.createTitleWorkTracker')){
			if ( !startDate){
				//console.log('Date is empty');
				hasError = true;
				errorMessage = helper.appendErrorMessage(errorMessage, 'Please enter a Start Date.');

			}
			if(workJobType === ''){
				//console.log('Job Type not selected');
				hasError = true;
				errorMessage = helper.appendErrorMessage(errorMessage, 'Please select a Work Job Type.');
			}
		}
		//console.log(helper.isEmpty(owner));
		if(helper.isEmpty(owner)){
			//console.log('Owner not selected');
			hasError = true;
			errorMessage = helper.appendErrorMessage(errorMessage, 'Please select an Owner.');
		}
		
		if(hasError){
			component.set('v.hasError', true);
			component.set('v.errorMessage', errorMessage);
		}
		

		else{
			component.set('v.hasError', false);
			//Enter code to actually save the record here.
			console.log('Saving Record');
			console.log('workJobType is ' + workJobType);
			var action = component.get("c.createTitleWorkTracker");
			if(helper.isEmpty(component.get('v.selectedProjectAOI'))){
				action.setParams({
					"landGridTractId": component.get('v.landGridTractId'),
					"workJobType":workJobType,
					"ownerId": owner,
					"startDate": startDate,
					"createTitleTracker": component.get('v.createTitleWorkTracker'),
					"titleTrackerId": component.get('v.titleTrackerId'),
					"workJobStatus":workJobStatus,
					"completionDate": completionDate
				});
			}
			else{
				//console.log(component.get('v.selectedProjectAOI').Id);
				action.setParams({
					"landGridTractId": component.get('v.landGridTractId'),
					"projectAOIId": component.get('v.selectedProjectAOI')[0].id,
					"workJobType":workJobType,
					"ownerId": owner,
					"startDate": startDate,
					"createTitleTracker":component.get('v.createTitleWorkTracker'),
					"titleTrackerId": component.get('v.titleTrackerId'),
					"workJobStatus":workJobStatus,
					"completionDate": completionDate
				});
			}
			
			action.setCallback(this, function(response) {
				var state = response.getState();
				if (state === "SUCCESS" ) {
					console.log(response.getReturnValue().returnMessage);
                
					var toastEvent = $A.get("e.force:showToast");
					console.log('Return message value is: ' + response.getReturnValue().returnMessage);
					if(response.getReturnValue().returnMessage == 'SUCCESS'){
						if(component.get('v.redirectToRecordPage')){
							console.log('new title tracker id is: ' + response.getReturnValue().titleWorkTracker.Id);
							var navService = component.find("navService");
							// Sets the route to /lightning/o/Account/home
							var pageReference = {
								type: 'standard__recordPage',
								attributes: {
									objectApiName: 'TitleWorkTracker__c',
									actionName: 'view',
									recordId: response.getReturnValue().titleWorkTracker.Id
								}
							};
							navService.navigate(pageReference);
						}
						component.destroy();
						$A.get('e.force:refreshView').fire();
					}
					else{
						toastEvent.setParams({
							"title": "Save Failed!",
							"message": response.getReturnValue().returnMessage,
							"type":"error",
							mode: 'sticky'
						});
						toastEvent.fire();
					}
                    
                       
                
				
				}else{
					var toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
						"title": "Error!",
						"message": "Error creating Title Work Tracker, please contact the Salesforce Admin",
						"type":"error",
						mode: 'sticky',
					});
					toastEvent.fire();
				}
				
				
				 
			
			});
			$A.enqueueAction(action);
		}
		//console.log(errorMessage);
		
		
	},
	
	updateLandGridTractId: function (component, event, helper){
		if(component.get('v.selectedLandGridTract')[0]){
			console.log(component.get('v.selectedLandGridTract')[0].id);
			component.set('v.landGridTractId', component.get('v.selectedLandGridTract')[0].id);
		}
		else{
			component.set('v.landGridTractId', '');
		}
	},

	lgtLookupSearch : function(component, event, helper) {
        
		console.log('Search triggered in component controller.');
        const serverSearchAction = component.get('c.searchLandGridTracts');
        // Passes the action to the Lookup component by calling the search method
        component.find('landGridTractLookup').search(serverSearchAction);
    },

	projectAOILookupSearch : function(component, event, helper) {
        
		console.log('Search triggered in component controller.');
        const serverSearchAction = component.get('c.searchProjectAOIs');
        // Passes the action to the Lookup component by calling the search method
        component.find('projectAOILookup').search(serverSearchAction);
    },

	userLookupSearch : function(component, event, helper) {
        
		//console.log('Search triggered in component controller.');
        const serverSearchAction = component.get('c.searchOwners');
        // Passes the action to the Lookup component by calling the search method
        component.find('userLookup').search(serverSearchAction);
    },


})