({
	editTracker: function(component, event, helper){
		console.log('Attempting to edit tracker');
		var currentStatus = component.get('v.currentStatus');
		helper.updateTracker(component, currentStatus, false, component.get('v.recordId'), component.get('v.trackerName'), 'Edit');
	},
	completeTracker: function(component, event, helper){
		console.log('Attempting to complete tracker');
		helper.updateTracker(component, 'Complete', true, component.get('v.recordId'), component.get('v.trackerName'), 'Complete');
	},
	startTracker: function(component, event, helper){
		//helper.updateTracker(component, 'In Progress', false, component.get('v.recordId'), component.get('v.trackerName'), 'Start');
		
		var newJobType = 'Landman';
		$A.createComponent( 'c:newTitleWorkTrackerModal', {
					'titleTrackerId':component.get('v.recordId'),
					'title': 'Start Title Tracker ' + component.get('v.trackerName'),
					'createTitleWorkTracker': false,
					'selectedWorkJobType': newJobType,
					'landGridTractId': component.get('v.landGridTractid'),
					'showLandGridTractLookup': false,
					'redirectToRecordPage':false,
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
					}
				}
			);
	},
	
	handleLoad: function (component, event, helper) {
        console.log('handleLoad called.');
		var record = event.getParam("recordUi");
		//console.log(JSON.stringify(record.record.fields));
		component.set('v.currentStatus', record.record.fields.status__c.value);
		component.set('v.trackerName', record.record.fields.Name.value);
		component.set('v.landGridTractId', record.record.fields.landGridTract__c.value);
		//console.log(record.record.titleIntegrationJobs__r.length);
		//if((record.record.fields.type__c.value == "Integration Review" || record.record.fields.type__c.value == "Attorney Review") && !component.get('v.hasIntegrations')){
		//	component.set('v.canDelete', true);
		//}
		//console.log('recordEditForm is loaded.');
		/*	var payload = event.getParams();
            var record = event.getParam("recordUi");
            var recordId = Object.keys(record);
            var fields = record[recordId].fields;
            var fieldValue = fields.status__c;
			var trackerName = fields.Name;
			console.log(trackerName);
			component.set('v.currentStatus', fieldValue);
			component.set('v.trackerName', trackerName);
			component.set('v.landGridTractId', fields.landGridTract__c);*/
    },
	recordUpdated: function (component, event, helper) {
		//component.set('v.recordLoaded', true);
		console.log('Record has been updated');

	},
	forceRefresh: function (component, event, helper) {
		//component.set('v.recordLoaded', true);
		console.log('force refresh called');
		var recordId = component.get('v.recordId');
		component.find('recordLoader').reloadRecord(true);
		//trackerInfo.set('v.recordId', '');
		//trackerInfo.set('v.recordId', component.get('v.recordId'));
		//component.set("v.reloadForm", false);
        //component.set("v.reloadForm", true);
		//var trackerInfo = component.find('titleWorkTrackerHeaderForm'); //the aura:id of my component
        //if(trackerInfo){
		//	var auraMethodResult = trackerInfo.refresh();
		//	console.log('Called refresh on form.');
		//}
	},
})