({
	init: function (component, event, helper) {
		component.set('v.isWaiting', true);
		component.set('v.sortedBy', 'tonName');
		component.set('v.sortedDirection', 'ASC');

		
		component.set('v.columns', [
			{label: 'Name', fieldName: 'tonName', type: "button", typeAttributes: {label: {fieldName: 'tonName'}, name: {fieldName: 'tonName'}, title: 'Associate TON with Account', disabled: false, value: {fieldName: 'tonId'}, variant: 'base' }, sortable: true},
			{label: 'Account Name', fieldName: 'tonAccountName', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'tonAccountName' }, value:{ fieldName: 'tonAccountName' }}, sortable: true},
			{label: 'Party Address', fieldName: 'tonPartyAddress', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'tonPartyAddress' }, value:{ fieldName: 'tonPartyAddress' }}, sortable: true},
			{label: 'Notes', fieldName: 'tonNotes', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'tonNotes' }, value:{ fieldName: 'tonNotes' }}, sortable: true},
			{label: '# TOR Records', fieldName: 'tonTORCount' , type: 'numberExtended', editable: false, typeAttributes:{title:{ fieldName: 'tonTORCount' }, value:{ fieldName: 'tonTORCount' }, className:'alignCenter'}, sortable: true, initialWidth:150, cellAttributes:{alignment: 'center'}},
			{label: '# TOT Records', fieldName: 'tonTOTCount' , type: 'numberExtended', editable: false, typeAttributes:{title:{ fieldName: 'tonTOTCount' }, value:{ fieldName: 'tonTOTCount' }, className:'alignCenter'}, sortable: true, initialWidth:150, cellAttributes:{alignment: 'center'}},
			{label: '# Tracts Created', fieldName: 'tonTractCreatedCount' , type: 'numberExtended', editable: false, typeAttributes:{title:{ fieldName: 'tonTractCreatedCount' }, value:{ fieldName: 'tonTractCreatedCount' }, className:'alignCenter'}, sortable: true, initialWidth:150, cellAttributes:{alignment: 'center'}},
			{label: '# Tracts Matched', fieldName: 'tonTractMatchedCount' , type: 'numberExtended', editable: false, typeAttributes:{title:{ fieldName: 'tonTractMatchedCount' }, value:{ fieldName: 'tonTractMatchedCount' }, className:'alignCenter'}, sortable: true, initialWidth:150, cellAttributes:{alignment: 'center'}},
		]);

		var recordId = component.get("v.recordId");
		var action = component.get("c.getTONs");

		action.setParams({
			tpjRecordId: recordId
		});

		action.setCallback(this, function(response){
			var responseValue = response.getReturnValue();
            component.set('v.data', responseValue);
			component.set('v.isWaiting', false);
		});

		$A.enqueueAction(action);

    },

	displayModal: function(component, event, helper){
		//console.log('Row action called');
		//var action = event.getParam('action');
		var row = event.getParam('row');
		//console.log(row);
		var tonRecords = component.get('v.data');
		var tonHasAccount = false;
		//console.log('row.Id value is: ' + row.tonId);
		component.set('v.selectedTonId', row.tonId);

		for(var ton in tonRecords){
			if(tonRecords[ton].ton.Id == row.tonId){
				if(tonRecords[ton].ton.account__c){
					tonHasAccount = true;
				}
			}
		}

		//console.log('tonId value passed is: ' + row.Id);
		//console.log('Called Display Modal');
		//console.log(JSON.stringify(action.name));
		//console.log(JSON.stringify(row));
		if(tonHasAccount){
			//navigate to tonpage
			var navService = component.find("navService");
			// Sets the route to /lightning/o/Account/home
			var pageReference = {
				type: 'standard__recordPage',
				attributes: {
					objectApiName: 'TargetOwnershipName__c',
					actionName: 'view',
					recordId: component.get('v.selectedTonId')
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
		else{
			//display modal
			console.log(JSON.stringify(row));
			console.log('tonAccountName is: ' + row.tonName);
			console.log('tonId value is: ' + row.tonId);
			$A.createComponent( 'c:tpjTONAssociationModal', {
					'searchString':row.tonName,
					'tonId':row.tonId,
					'canAssociate':true
				},
				function(modalComponent, status, errorMessage) {
					//console.log('Callback called');
					if (status === "SUCCESS") {
						//console.log('Success');
						//Appending the newly created component in div
						var body = component.find( 'tpjTONAssociationModal' ).get("v.body");
						body.push(modalComponent);
						console.log(body);
						component.find( 'tpjTONAssociationModal' ).set("v.body", body);
					} else if (status === "INCOMPLETE") {
                		//console.log('Server issue or client is offline.');
					} else if (status === "ERROR") {
                		console.log('error');
					}
				}
			);
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

	handleAddAccount: function(component, event, helper){
		var tonId = component.get('v.selectedTonId');
		$A.createComponent( 'c:tonAddAccountModal', {
					'tonId': tonId
				},
				function(modalComponent, status, errorMessage) {
					//console.log('Callback called');
					if (status === "SUCCESS") {
						//console.log('Success');
						//Appending the newly created component in div
						var body = component.find( 'tpjTONAssociationModal' ).get("v.body");
						body.push(modalComponent);
						console.log(body);
						component.find( 'tpjTONAssociationModal' ).set("v.body", body);
					} else if (status === "INCOMPLETE") {
                		//console.log('Server issue or client is offline.');
					} else if (status === "ERROR") {
                		console.log('error');
					}
				}
		);
	}
})