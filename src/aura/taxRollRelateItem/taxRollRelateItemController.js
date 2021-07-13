({
	init: function (component, event, helper) {
		var recordId = component.get('v.recordId');
		var searchObject = component.get('v.relatedObject');
		var action = component.get("c.getInitialResults");

		action.setParams({
			'recordId': recordId,
			'searchObject': searchObject
		});

		action.setCallback(this, function(response){
			var responseValue = response.getReturnValue();
			var addAccount = {sobjectType:"taxRollRelateItemAura.accountSearchResult", Id:"addAccount", Name:"Add Account", accountSelected:false};
			console.log(responseValue);
			responseValue.accounts.push(addAccount);
			component.set('v.currentInterest', responseValue.currentInterest);
			component.set('v.currentOwner', responseValue.currentOwner);
			component.set('v.relatedObjectLabel', responseValue.searchObjectLabel);
			component.set('v.responseValue', responseValue);
			component.set('v.searchCounter', responseValue.searchCounter);
			component.set('v.selectedRecordId', responseValue.selectedRecord);
			console.log('Selected Record Id value set to: ' + responseValue.selectedRecord);
			switch(searchObject){
				case 'diTexasPermitWithAcreage__c':
					console.log('diPermits length is: ' + responseValue.diPermits.length);
					component.set('v.data', responseValue.diPermits);
					component.set('v.columns', [
						{fieldName: 'permitSelected', type: 'checkBoxExtended', editable: true, typeAttributes:{checked:{fieldName: 'permitSelected'}, value:{fieldName: 'Id'}}, fixedWidth:50},
						//{label: 'RRC Lease Number', fieldName: 'rrcLeaseNumber', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'rrcLeaseNumber' }, value:{ fieldName: 'rrcLeaseNumber' }}, sortable: true},
						{label: 'API10', fieldName: 'api10', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'api10' }, value:{ fieldName: 'api10' }}, sortable: true, initialWidth:100},
						{label: 'LeaseName', fieldName: 'leaseName', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'leaseName' }, value:{ fieldName: 'leaseName' }}, sortable: true, initialWidth:200},
						{label: 'Permit #', fieldName: 'permitNumber', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'permitNumber' }, value:{ fieldName: 'permitNumber' }}, sortable: true, initialWidth:100},
						{label: 'Permitted Acres', fieldName: 'permittedAcres', type: 'numberExtended', editable: false, typeAttributes:{title:{ fieldName: 'permittedAcres' }, value:{ fieldName: 'permittedAcres' }, maximumFractionDigits:"10"}, sortable: true, initialWidth:150, cellAttributes:{alignment: 'left'}, },
						{label: 'Name', fieldName: 'Name', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'Name' }, value:{ fieldName: 'Name' }}, sortable: true, initialWidth:125},
						//{label: 'Billing Address', fieldName: 'address__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'address__c' }, value:{ fieldName: 'address__c' }}, sortable: true},
					]);
					component.set('v.updateRecordId', responseValue.currentLease.Id);
					break;
				case 'Account':
					component.set('v.showSearchString', true);
					
					component.set('v.searchString', responseValue.currentOwner.ownerName__c);
					component.set('v.labelSuffix', ' based on search string "' + responseValue.currentOwner.ownerName__c + '"');
					component.set('v.data', responseValue.accounts)
					component.set('v.columns', [
						{fieldName: 'accountSelected', type: 'checkBoxExtended', editable: true, typeAttributes:{checked:{fieldName: 'accountSelected'}, value:{fieldName: 'Id'}}, fixedWidth:50},
						{label: 'Salesforce Account Name', fieldName: 'Name', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'Name' }, value:{ fieldName: 'Name' }}, sortable: true},
						{label: 'Billing Address', fieldName: 'BillingAddress', type: 'addressExtended', editable: false, typeAttributes:{street:{ fieldName: 'BillingStreet' }, city:{ fieldName: 'BillingCity' }, country:{fieldName:'BillingCountry'}, postalCode:{fieldName:'BillingPostalCode'}}, sortable: true},
					]);
					component.set('v.updateRecordId', responseValue.currentOwner.Id);
					console.log('updateRecordId set to ' + component.get('v.updateRecordId'));
					break;
					
				default:
			}
			component.set('v.isWaiting', false);
			if(component.get('v.data') && component.get('v.data').length>10){
				//console.log('Length is greater than 10');
				var tableDiv = component.find("tableDiv");
				//console.log(tableDiv);
				$A.util.addClass(tableDiv, 'maxHeight');
			}
			//component.set('v.canUnlink', !responseValue.hasLockedTots);
		});

		$A.enqueueAction(action);


	},
	rowCheckAction: function(component, event, helper){
		//console.log('rowCheckAction called in controller.');
		var data = component.get('v.data');
		var searchObject = component.get('v.relatedObject');
		//console.log(event.getParam('rowId'));
		var selectedRecord = event.getParam('rowId');
		var checked = event.getParam('checked');
		console.log('Checked value is: ' + checked);
		if(checked){
			component.set('v.selectedRecordId',  selectedRecord);
		}
		else{
			component.set('v.selectedRecordId',  '');
		}
		//console.log('rowcheckaction called from parent with rowId value: ' + selectedRecord + ' checked value: ' + checked);
		for (var record in data){
			//console.log('record Id is: ' + data[record].Id + ' selected Record Id is: ' + selectedRecord); 
			if( data[record].Id == selectedRecord){
				if(checked){
					switch(searchObject){
						case 'diTexasPermitWithAcreage__c':
								data[record].permitSelected = true;
							break;
						case 'Account':
								data[record].accountSelected = true;
							break;
						default:
					}
					//component.set('v.associateButtonInactive', false);
				}
				else{
					switch(searchObject){
						case 'diTexasPermitWithAcreage__c':
								data[record].permitSelected = false;
							break;
						case 'Account':
								data[record].accountSelected = false;
							break;
						default:
					}
					//console.log('Clearing selectedRecord');
					//component.set('v.selectedRecordId', '');
					//component.set('v.associateButtonInactive', true);

				}
			}
			else{
					switch(searchObject){
						case 'diTexasPermitWithAcreage__c':
								data[record].permitSelected = false;
							break;
						case 'Account':
								data[record].accountSelected = false;
							break;
						default:
					}
						
				}
				//console.log('After row check completed.');
				//console.log(data[record]);
			//console.log('Account Id: ' + accounts[account].Id + ' set to ' + accounts[account].accountSelected);
		}
		//console.log('Selected Account set to: ' + component.get('v.selectedAccountId'));
		component.set('v.data', data);
		
	},
	/*handleCancel: function (component, event, helper) {
		var canAssociate=component.get('v.canAssociate');

		
		if(canAssociate){
			console.log('Inside if');
			var navService = component.find("navService");
			// Sets the route to /lightning/o/Account/home
			var pageReference = {
				type: 'standard__recordPage',
				attributes: {
					objectApiName: 'Title_Processing_Job__c',
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
	},*/
	handleKeyUp: function(component, event, helper){
		//console.log('keyup function called.');
		var searchString = component.get('v.searchString');
		if(searchString.length > 1){
			helper.populateDataTable(component, event);
		}	
	},
	handleSort: function(component, event, helper) {
        var sortBy = event.getParam("fieldName");
        var sortedDirection = event.getParam("sortDirection");
        component.set("v.sortedBy", sortBy);
        component.set("v.sortedDirection", sortedDirection);
        helper.sortData(component, sortBy, sortedDirection);
        
    },
	clearSearchString: function(component, event, helper){
		var searchString = component.get('v.searchString');
		component.set('v.labelSuffix', '');
		if(!searchString){
			component.set('v.data', []);
		}
	},
	updateRelatedRecord: function(component, event, helper){
		console.log('updateRelatedRecord called with Id: ' + component.get('v.updateRecordId'));
		console.log('selectedRecordId is: ' + component.get('v.selectedRecordId'));
		var recordId = component.get('v.updateRecordId');
		var updateField = component.get('v.relatedFieldName');
		var selectedRecord = component.get('v.selectedRecordId');
		if(component.get('v.selectedRecordId') == 'addAccount'){
			
			 
			$A.createComponent( 'c:taxRollOwnerAddAccountModal', {
					'taxRollOwner': component.get('v.currentOwner'),
					'taxRollOwnerId': recordId,
					'relatedFieldName' : component.get('v.relatedFieldName')
				},
				function(modalComponent, status, errorMessage) {
					//console.log('Callback called');
					if (status === "SUCCESS") {
						//console.log('Success');
						//Appending the newly created component in div
						/*var data = component.get('v.data');
						for(var record in data){
							data[record].accountSelected = false;
							console.log('data record is: ' + data[record].Id + ' Name is: ' + data[record].Name + ' accountSelected value is: ' + data[record].accountSelected);
						}	
						component.set('v.data', data);
						var updatedData = component.get('v.data');
						for(var record2 in updatedData){
							//data[record].accountSelected = false;
							console.log('data record is: ' + updatedData[record2].Id + ' Name is: ' + updatedData[record2].Name + ' accountSelected value is: ' + updatedData[record2].accountSelected);
						}	
						component.set('v.selectedRecordId', '');*/
						var body = component.find( 'taxRollOwnerAccountModal' ).get("v.body");
						body.push(modalComponent);
						//console.log(body);
						component.find( 'taxRollOwnerAccountModal' ).set("v.body", body);
					} else if (status === "INCOMPLETE") {
                		//console.log('Server issue or client is offline.');
					} else if (status === "ERROR") {
                		console.log('error');
					}
				}
			);
		}
		else{
			var action = component.get("c.setRelatedRecord");


			action.setParams({
				'recordId': recordId,
				'relatedRecordId': selectedRecord,
				'updateField': updateField
			});

			action.setCallback(this, function(response){
				var responseValue = response.getReturnValue();
				console.log(responseValue);
				$A.get('e.force:refreshView').fire();
			});

			$A.enqueueAction(action);
		}
		
	}
	/*handleSave: function(component, event, helper){
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
	},*/

	/*goTotBuilder: function(component, event, helper){
		var navService = component.find("navService");
		// Uses the pageReference definition in the init handler
		var pageReference = component.get("v.pageReference");
		event.preventDefault();
		navService.navigate(pageReference);
		component.destroy();
	},*/

	/*handleUnlink: function(component, event, helper){
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
	},
	handleUnlink: function(component, event, helper){
		
	}*/
})