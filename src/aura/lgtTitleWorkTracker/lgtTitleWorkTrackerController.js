({
	doInit: function(component, event, helper) {
		helper.getData(component, true);
		//var data = component.get('v.data');
		//component.set('v.activeSection', data[0].titleWorkTracker.Id);
	},
	refreshData: function(component, event, helper){
		helper.getData(component, true);
	},
	/*createTitleWorkJob: function(component, event, helper) {
		var actionAPI = component.find("quickActionAPI");
		var buttonAction = "LandGridTract__c.New_Title_Work_Job";
		//var fields = {status__c: {value: "In Progress"}};
        var args = { actionName : buttonAction, 
					targetFields:{status__c: {value: "In Progress"}},
                    
                    };
		actionAPI.setActionFieldValues(args).then(function(result) {
			console.log(JSON.stringify(result));
            // Action selected; show data and set field values
        }).catch(function(e) {
            if (e.errors) {
				console.log('Error called');
                // If the specified action isn't found on the page, 
                // show an error message in the my component 
            }
        });

	},*/
	
	createTitleTracker: function(component, event, helper){
		
		$A.createComponent( 'c:newTitleWorkTrackerModal', {
					'landGridTractId':component.get('v.recordId'),
					'selectedWorkJobType': 'Landman',
					'showLandGridTractLookup': false,
					'createTitleTracker':true
					//'tonId':ton.Id,
					//'canAssociate':false
				},
				function(modalComponent, status, errorMessage) {
					//console.log('Callback called');
					if (status === "SUCCESS") {
						//console.log('Success');
						//Appending the newly created component in div
						var body = component.find( 'modalArea' ).get("v.body");
						body.push(modalComponent);
						console.log(body);
						component.find( 'modalArea' ).set("v.body", body);
					} else if (status === "INCOMPLETE") {
                		//console.log('Server issue or client is offline.');
					} else if (status === "ERROR") {
                		console.log('error');
						console.log(errorMessage);
					}
				}
			);
	},
	handleSectionToggle: function (cmp, event) {
        var openSections = event.getParam('openSections');

        /*if (openSections.length === 0) {
            cmp.set('v.activeSectionsMessage', "All sections are closed");
        } else {
            cmp.set('v.activeSectionsMessage', "Open sections: " + openSections.join(', '));
        }*/
    },
})