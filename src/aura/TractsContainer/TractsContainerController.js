({
	doInit : function(component, event, helper) {
        
	},
	
	showManageTracts : function(component, event, helper) {
		//display modal
			$A.createComponent( 'c:ManageTracts', {
					'recordId':component.get('v.recordId')
				},
				function(modalComponent, status, errorMessage) {
					//console.log('Callback called');
					if (status === "SUCCESS") {
						//console.log('Success');
						//Appending the newly created component in div
						var body = component.find( 'tractModal' ).get("v.body");
						body.push(modalComponent);
						console.log(body);
						component.find( 'tractModal' ).set("v.body", body);
					} else if (status === "INCOMPLETE") {
                		//console.log('Server issue or client is offline.');
					} else if (status === "ERROR") {
                		console.log('error');
					}
				}
			);
	},
    handleCloseModal : function(component,event,helper){
        component.find("relatedList").forceRefreshInitiated();
    },
	getValuesFromLwc : function(component, event, helper) {
		component.set("v.data",event.getParam('data'));
		component.set("v.columns",event.getParam('columns'));
		console.log('getValuesfromLwc called.');
		console.log(JSON.stringify(event.getParam('columns')));
	}
})