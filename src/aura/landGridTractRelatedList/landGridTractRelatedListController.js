({
    doInit: function(component, event, helper) {
        component.set('v.isWaiting', true);
        switch(component.get('v.relatedObject')) {
		  case "TitleWorkJob__c":
			component.set('v.columns', [
            {label: 'Name', fieldName: 'linkName', type: 'url', cellAttributes: { alignment: 'left' }, 
             typeAttributes: {label: { fieldName: 'Name' }, target: '_blank', tooltip:'Open Title Work Job in a new tab'},sortable: true },
			{label: 'Project AOI', fieldName: 'projectLink', type: 'url', cellAttributes: { alignment: 'left' }, 
             typeAttributes: {label: { fieldName: 'projectAOIName' }, target: '_blank', tooltip:'Open Project AOI in a new tab'},sortable: true },
            //{ label: 'Project AOI', fieldName: 'TON_Name__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'TON_Name__c' }, value:{ fieldName: 'TON_Name__c' }}, sortable: true, initialWidth:250},
            { label: 'Type', fieldName: 'Type__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'Type__c' }, value:{ fieldName: 'Type__c' }}, sortable: true},
            { label: 'Status', fieldName: 'Landman_Status__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'Landman_Status__c' }, value:{ fieldName: 'Landman_Status__c' }}, sortable: true},
            { label: 'Landman Start Date', fieldName: 'Landman_Start_Date__c', type: 'date-local', cellAttributes: { alignment: 'left'}, sortable: true },
            { label: 'Landman Completion Date', fieldName: 'Landman_Completion_Date__c', type: 'date-local', cellAttributes: { alignment: 'left'}, sortable: true },
            { label: 'Landman', fieldName: 'landman', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'landman' }, value:{ fieldName: 'landman' }}, sortable: true},
            { label: 'Integration Reviewer', fieldName: 'integrationReviewerName', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'integrationReviewerName' }, value:{ fieldName: 'integrationReviewerName' }}, sortable: true},
			]);
			break;
		  case "Tract__c":
			component.set('v.columns', [
			{label: 'Name', fieldName: 'linkName', type: 'url', cellAttributes: { alignment: 'left' }, 
             typeAttributes: {label: { fieldName: 'Name' }, target: '_blank', tooltip:'Open Tract in a new tab'},sortable: true , initialWidth: 100 },
            { label: 'Full Legal Name', fieldName: 'Full_Legal_Name__c', type: 'textExtended', typeAttributes:{title:{ fieldName: 'Full_Legal_Name__c' }, value:{ fieldName: 'Full_Legal_Name__c' }}, sortable: true, initialWidth: 200},
            { label: 'Depth', fieldName: 'depth__c', type: 'textExtended', typeAttributes:{title:{ fieldName: 'depth__c' }, value:{ fieldName: 'depth__c' }}, sortable: true,initialWidth: 100},
			{ label: 'Notes', fieldName: 'Notes__c', type: 'textExtended', typeAttributes:{title:{ fieldName: 'Notes__c' }, value:{ fieldName: 'Notes__c' }}, sortable: true,initialWidth: 200},
            { label: 'Instrument', fieldName: 'Instrument_Type__c', type: 'textExtended', typeAttributes:{title:{ fieldName: 'Instrument_Type__c' }, value:{ fieldName: 'Instrument_Type__c' }}, sortable: true,initialWidth: 100},
            { label: 'Acres', fieldName: 'acres', type: 'textExtended', typeAttributes:{title:{ fieldName: 'acres' }, value:{ fieldName: 'acres' }}, sortable: true, initialWidth: 90},
			{ label: 'Total Cost', fieldName: 'Total_Cost__c', type: 'currency', sortable: true, initialWidth: 120, },
			{ label: '% Covered by AOI Pricing', fieldName: 'percentCovered__c', type: 'percent', sortable: true, initialWidth: 190,},
			{ label: 'Target OTG Cost Per Acre', fieldName: 'targetPPA__c', type: 'currency', sortable: true, initialWidth: 190,},
			{ label: 'Total Target OTG Cost', fieldName: 'targetPrice__c', type: 'currency', sortable: true, initialWidth: 190,},
			{ label: 'Max OTG Price Per Acre', fieldName: 'maxPPA__c', type: 'currency', sortable: true, initialWidth: 190,},
			{ label: 'Max OTG Total Cost', fieldName: 'maxPrice__c', type: 'currency', sortable: true, initialWidth: 190,},
			]);
			break;
			case "TitleWorkTracker__c":
			component.set('v.columns', [
			{label: 'Name', fieldName: 'linkName', type: 'url', cellAttributes: { alignment: 'left' }, 
             typeAttributes: {label: { fieldName: 'Name' }, target: '_blank', tooltip:'Open Tract in a new tab'},sortable: true },
            { label: 'Status', fieldName: 'status__c', type: 'textExtended', typeAttributes:{title:{ fieldName: 'status__c' }, value:{ fieldName: 'status__c' }}, sortable: true},
			{ label: 'Start Date', fieldName: 'startDate__c', type: 'date-local', cellAttributes: { alignment: 'left'}, sortable: true },
			{ label: 'Completion Date', fieldName: 'completionDate__c', type: 'date-local', cellAttributes: { alignment: 'left'}, sortable: true },
			]);
			break;
		  default:
			// code block
		}
		helper.getData(component);
    },
	refreshData: function(component, event, helper){
		helper.getData(component);
	},
    handleSort: function(component, event, helper) {
        var sortBy = event.getParam("fieldName");
        var sortedDirection = event.getParam("sortDirection");
        component.set("v.sortedBy", sortBy);
        component.set("v.sortedDirection", sortedDirection);
        helper.sortData(component, sortBy, sortedDirection);
        
    },

	buttonClick: function(component, event, helper){
		if(component.get('v.customButtonAction')){
			switch(component.get('v.relatedObject')) {
				case "TitleWorkTracker__c":
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
				break;

				default:
			}
		}
		else{
			var actionAPI = component.find("quickActionAPI");
			var buttonAction = "LandGridTract__c." + component.get('v.buttonAction');
			var args = { actionName : buttonAction, 
                    
						};
			actionAPI.selectAction(args).then(function(result) {
				console.log(JSON.stringify(result));
				// Action selected; show data and set field values
			}).catch(function(e) {
				if (e.errors) {
					console.log('Error called');
					// If the specified action isn't found on the page, 
					// show an error message in the my component 
				}
			});
		}
	},
})