({
	init: function (component, event, helper) {
		helper.setForm(component, event);
	},
	showModal: function(component, event, helper){
		var ton = component.get('v.ton');
		$A.createComponent( 'c:tpjTONAssociationModal', {
					'searchString':ton.ownerName__c,
					'tonId':ton.Id,
					'canAssociate':false
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
	},
	handleAddAccount: function(component, event, helper){
		var ton = component.get('v.ton');
		$A.createComponent( 'c:tonAddAccountModal', {
					'tonId': ton.Id
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
	},
	processUpdate: function(component, event, helper){
		var forceRecord = component.find('forceRecord');
		forceRecord.set('v.recordId', component.get('v.ton').Id);
		helper.setForm(component, event);
	}
})