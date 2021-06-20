({
	init: function (component, event, helper) {
		document.addEventListener("rowcheckaction", function(event) {
			var accounts = component.get('v.data');
			var currentAccount = event.detail.rowId;
			var checked = event.detail.checked;
			console.log('rowcheckaction called from parent with rowId value: ' + currentAccount + ' checked value: ' + checked);

			for (var account in accounts){
				
				if( accounts[account].Id == currentAccount){
					if(checked){
						accounts[account].accountSelected = true;
						component.set('v.selectedAccountId', accounts[account].Id);
						component.set('v.associateButtonInactive', false);
					}
					else{
						accounts[account].accountSelected = false;
						component.set('v.selectedAccountId', []);
						component.set('v.associateButtonInactive', true);

					}
				}
				else{
						accounts[account].accountSelected = false;
						
					}
				console.log('Account Id: ' + accounts[account].Id + ' set to ' + accounts[account].accountSelected);
			}
			console.log('Selected Account set to: ' + component.get('v.selectedAccountId'));
			component.set('v.data', accounts);
			
		  });

		//set instruction font color based on canAssociate
		var canAssociate = component.get('v.canAssociate');
		if(canAssociate){
			component.set('v.instructionClass', 'fontBlack');
		}

		var navService = component.find("navService");
        // Sets the route to /lightning/o/Account/home
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                objectApiName: 'TargetOwnershipName__c',
                actionName: 'view',
				recordId: component.get('v.tonId')
            }
        };
		//console.log(pageReference);
        component.set("v.pageReference", pageReference);
        // Set the URL on the link or use the default if there's an error
        var defaultUrl = "#";
        navService.generateUrl(pageReference)
            .then($A.getCallback(function(url) {
                component.set("v.url", url ? url : defaultUrl);
            }), $A.getCallback(function(error) {
                component.set("v.url", defaultUrl);
            }));
		component.set('v.sortedBy', 'Id');
		component.set('v.sortedDirection', 'ASC');
		component.set('v.searchCounter', 0);
		
		component.set('v.columns', [
			{fieldName: 'accountSelected', type: 'checkBoxExtended', editable: true, typeAttributes:{checked:{fieldName: 'accountSelected'}, value:{fieldName: 'Id'}}, fixedWidth:50},
			{label: 'Salesforce Account Name', fieldName: 'Name', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'Name' }, value:{ fieldName: 'Name' }}, sortable: true},
			{label: 'Billing Address', fieldName: 'BillingAddress', type: 'addressExtended', editable: false, typeAttributes:{street:{ fieldName: 'BillingStreet' }, city:{ fieldName: 'BillingCity' }, country:{fieldName:'BillingCountry'}, postalCode:{fieldName:'BillingPostalCode'}}, sortable: true},
			//{label: 'Billing Address', fieldName: 'address__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'address__c' }, value:{ fieldName: 'address__c' }}, sortable: true},
		]);
		var searchString = component.get('v.searchString');
		helper.populateDataTable(component, event);



	},
	handleCancel: function (component, event, helper) {
		var canAssociate=component.get('v.canAssociate');

		
		if(canAssociate){
			console.log('Inside if');
			var navService = component.find("navService");
			// Sets the route to /lightning/o/Account/home
			var pageReference = {
				type: 'standard__recordPage',
				attributes: {
					objectApiName: 'TitleIntegrationJob__c',
					actionName: 'view',
					recordId: component.get('v.ton').jobId__c
				}
			};
			//console.log(pageReference);
			component.set("v.pageReference", pageReference);
			// Set the URL on the link or use the default if there's an error
			var defaultUrl = "#";
			navService.generateUrl(pageReference)
				.then($A.getCallback(function(url) {
					component.set("v.url", url ? url : defaultUrl);
				}), $A.getCallback(function(error) {
					component.set("v.url", defaultUrl);
				}));
			event.preventDefault();
			navService.navigate(pageReference);
		}
		
		component.destroy();
	},
	handleKeyUp: function(component, event, helper){
		//console.log('keyup function called.');
		var searchString = component.get('v.searchString');
		if(searchString.length > 1){
			helper.populateDataTable(component, event);
		}	
	},
	updateSorting: function (component, event, helper) {
		
        var fieldName = event.getParam('fieldName');
		console.log('fieldName value is: ' + fieldName);
        var sortDirection = event.getParam('sortDirection');
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
    },
	clearSearchString: function(component, event, helper){
		var searchString = component.get('v.searchString');
		if(!searchString){
			component.set('v.data', []);
		}
	},
	handleSave: function(component, event, helper){
		var action = component.get("c.linkTONToAccount");
		var tonId = component.get('v.tonId');
		var accountId = component.get('v.selectedAccountId');
		console.log('accountId is: ' + accountId);

		if(accountId){
			if(accountId != '0'){
				action.setParams({
					'tonId': tonId,
					'accountId': accountId
				});

				action.setCallback(this, function(response){
					var responseValue = response.getReturnValue();
					if (responseValue){
					
						//console.log(responseValue);
						var navService = component.find("navService");
						// Uses the pageReference definition in the init handler
						var pageReference = component.get("v.pageReference");
						event.preventDefault();
						navService.navigate(pageReference);
						$A.get('e.force:refreshView').fire();
						component.destroy();
					}

				});

				$A.enqueueAction(action);
			}
			else{
				var modalEvent = component.getEvent('createAccount');
				modalEvent.setParams({
					"action": "AddAccount"
				 });
				modalEvent.fire();
				component.destroy();
			}
		}
	},

	goTotBuilder: function(component, event, helper){
		var navService = component.find("navService");
		// Uses the pageReference definition in the init handler
		var pageReference = component.get("v.pageReference");
		event.preventDefault();
		navService.navigate(pageReference);
		component.destroy();
	},

	handleUnlink: function(component, event, helper){
		console.log('Handle unlink called.');
		var tonId = component.get('v.tonId');
		var action = component.get("c.unlinkAccount");
		action.setParams({
				'tonRecordId': tonId
			});

		action.setCallback(this, function(response){
				var responseValue = response.getReturnValue();
				if (responseValue){	
					component.set('v.canAssociate', true);
					$A.get('e.force:refreshView').fire();
				}

			});

		$A.enqueueAction(action);
	}
})