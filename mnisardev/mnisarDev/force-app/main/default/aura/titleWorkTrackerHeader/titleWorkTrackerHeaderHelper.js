({
	updateTracker: function (component, status, complete, recordId, trackerName, type ) {
	console.log('trackerName is: ' + trackerName);
	var completionDate;
	if(complete){
		completionDate = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
	}
	else{
		completionDate = null;
	}
	var startDate;
	startDate = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
	$A.createComponent( 'c:titleWorkTrackerUpdateModal', {
					'recordId': recordId,
					'status':status,
					'completeOnly': complete,
					'trackerName':trackerName,
					'startDate':startDate,
					'type': type,
					'completionDate':completionDate,
					'redirectToRecordPage':false,
					
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
})