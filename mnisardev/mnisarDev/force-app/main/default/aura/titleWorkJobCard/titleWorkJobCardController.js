({
	doInit: function(component, event, helper) {
		var statusMessage = '';
		var titleWorkJobRecord = component.get('v.titleWorkJobRecord');
		if (titleWorkJobRecord.titleWorkJob.status__c == 'Complete'){
			if(titleWorkJobRecord.titleWorkJob.Owner.FirstName != 'undefined' && titleWorkJobRecord.titleWorkJob.Owner.FirstName){
				statusMessage = titleWorkJobRecord.titleWorkJob.Owner.FirstName + "'s work is complete";
			}
			else{
				statusMessage = titleWorkJobRecord.titleWorkJob.Owner.Name + "'s work is complete";
			}
		}
		else{
			var today = new Date(); 
			var startDate = new Date(titleWorkJobRecord.titleWorkJob.startDate__c); 
			//console.log(startDate);
			if(startDate != 'Invalid Date'){
				// To calculate the time difference of two dates 
				var differenceInTime = today.getTime() - startDate.getTime(); 
  
				// To calculate the no. of days between two dates 
				var differenceInDate = differenceInTime / (1000 * 3600 * 24);
				if( titleWorkJobRecord.titleWorkJob.Owner.FirstName != 'undefined' && titleWorkJobRecord.titleWorkJob.Owner.FirstName){
					statusMessage = titleWorkJobRecord.titleWorkJob.Owner.FirstName + "'s work has been in process for " + Math.floor(differenceInDate) + ' days';
				}
				else{
					statusMessage = titleWorkJobRecord.titleWorkJob.Owner.Name + "'s work has been in process for " + Math.floor(differenceInDate) + ' days';
				}
			}
			else{
				if(titleWorkJobRecord.titleWorkJob.Owner.FirstName != 'undefined' && titleWorkJobRecord.titleWorkJob.Owner.FirstName){
				statusMessage = titleWorkJobRecord.titleWorkJob.Owner.FirstName + "'s work has not been started";
			}
			else{
				statusMessage = titleWorkJobRecord.titleWorkJob.Owner.Name + "'s work has not been started";
			}
			}
		}
		component.set('v.statusMessage', statusMessage);
	},
	goToJob : function (component, event, helper) {
		var navService = component.find("navService");
		// Sets the route to /lightning/o/Account/home
		var pageReference = {
			type: 'standard__recordPage',
			attributes: {
				objectApiName: 'TitleWorkJob__c',
				actionName: 'view',
				recordId: component.get('v.titleWorkJobRecord.titleWorkJob').Id
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
	},
	openJobModal : function (component, event, helper){
		var integrationCount = component.get('v.titleWorkJobRecord.titleIntegrations.length');
		var hasIntegrations = integrationCount > 0?true:false;
		//console.log('Integration length is: ' + hasIntegrations);
		$A.createComponent( 'c:titleWorkJobUpdateModal', {
					'recordId': component.get('v.titleWorkJobRecord.titleWorkJob').Id,
					'hasIntegrations' : hasIntegrations
				},
				function(modalComponent, status, errorMessage) {
					//console.log('Callback called');
					if (status === "SUCCESS") {
						//console.log('Success');
						//Appending the newly created component in div
						var body = component.find( 'modalArea' ).get("v.body");
						body.push(modalComponent);
						//console.log(body);
						component.find( 'modalArea' ).set("v.body", body);
					} else if (status === "INCOMPLETE") {
                		//console.log('Server issue or client is offline.');
					} else if (status === "ERROR") {
                		console.log('error');
					}
				}
			);

	},
	createTitleIntegrationJob : function (component, event, helper) {
		var landGridTractId = component.get('v.titleWorkJobRecord.titleWorkJob').landGridTract__c;
		//console.log('landGridTractId value is: ' + landGridTractId);
		var landGridTractName = component .get('v.titleWorkJobRecord.titleWorkJob').landGridTract__r.Name;
		//console.log('landGridTractName value is: ' + landGridTractName);
		var titleWorkJobName = component.get('v.titleWorkJobRecord.titleWorkJob').Name;
		//console.log('titleWorkJobName value is: ' + titleWorkJobName);
		//console.log('title work job default status is: ' + component.get('v.titleWorkJobRecord.tijDefaultStatus'));
		
		$A.createComponent( 'c:newTitleIntegrationJobModal', {
					'status':component.get('v.titleWorkJobRecord.tijDefaultStatus'),
					'title': 'New Title Integration Job for Title Work Job ' + component.get('v.titleWorkJobRecord.titleWorkJob').Name,
					'landGridTractId': component.get('v.titleWorkJobRecord.titleWorkJob').landGridTract__c,
					'landGridTractName': component .get('v.titleWorkJobRecord.titleWorkJob').landGridTract__r.Name,
					'titleWorkJobId': component.get('v.titleWorkJobRecord.titleWorkJob').Id
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
						//console.log(body);
						component.find( 'modalArea' ).set("v.body", body);
					} else if (status === "INCOMPLETE") {
                		//console.log('Server issue or client is offline.');
					} else if (status === "ERROR") {
                		console.log('error');
					}
				}
			);
		/*console.log('Record Id value is: ' + component.get('v.recordId'));
		var createRecordEvent = $A.get("e.force:createRecord");

		var landGridTractId = component.get('v.titleWorkJobRecord.titleWorkJob').landGridTract__c;
		var twjId = component.get('v.titleWorkJobRecord.titleWorkJob').Id
		createRecordEvent.setParams({
			"entityApiName": "TitleIntegrationJob__c",
			"defaultFieldValues": {
				'landGridTract__c' : landGridTractId,
				'titleWorkJob__c' : twjId
			}
		});
		createRecordEvent.fire();*/
	},
	completeTitleWorkJob : function (component, event, helper) {
		//console.log('Trying to complete Title Work Tracker');
		var titleTrackingRecord = component.get("v.titleWorkJobRecord.titleWorkJob");
		var action = component.get("c.updateTitleWorkComplete");

		action.setParams({
			updateRecord: titleTrackingRecord,
			objectType: "TitleWorkJob__c"
		});

		action.setCallback(this, function(response) {
            //console.log('Inside callback');
			var returnMessage = response.getReturnValue();
            if (returnMessage === "SUCCESS" ) {
				//console.log('Succeeded');
				$A.get('e.force:refreshView').fire();
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": returnMessage,
					"type":"error",
					 "mode": 'sticky'
                });
                toastEvent.fire();
            }
        });

		$A.enqueueAction(action);
	},
	createTitleWorkJob : function (component, event, helper) {
		var currentJobType = component.get('v.titleWorkJobRecord.titleWorkJob').type__c;
		//console.log('currentJobType value is: ' + currentJobType);
		var newJobType;
		switch(currentJobType) {
		  case 'Landman':
			newJobType = 'Integration Review';
			break;
		  case 'Integration Review':
			newJobType = 'Attorney Review';
			break;
		  default:
			newJobType = '';
		}
		//console.log('newJobType is: ' + newJobType);
		$A.createComponent( 'c:newTitleWorkTrackerModal', {
					'titleTrackerId':component.get('v.titleWorkTrackerId'),
					'title': 'New Title Work Job for Title Tracker ' + component.get('v.titleWorkTrackerName'),
					'createTitleWorkTracker': false,
					'redirectToRecordPage':false,
					'selectedWorkJobType': newJobType,
					'landGridTractId': component.get('v.titleWorkJobRecord.titleWorkJob').landGridTract__c,
					'showLandGridTractLookup': false
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
						//console.log(body);
						component.find( 'modalArea' ).set("v.body", body);
					} else if (status === "INCOMPLETE") {
                		//console.log('Server issue or client is offline.');
					} else if (status === "ERROR") {
                		console.log('error');
					}
				}
			);
	},
	handleClick: function(component, event, helper){
		//console.log('Handle click called.');
	},
	startJob: function(component, event, helper){
		//console.log('Trying to start Title Work Job');
		var titleTrackingRecord = component.get("v.titleWorkJobRecord.titleWorkJob");
		var action = component.get("c.startTitleWorkjob");

		action.setParams({
			updateRecord: titleTrackingRecord,
			objectType: "TitleWorkJob__c"
		});

		action.setCallback(this, function(response) {
            //console.log('Inside callback');
			var returnMessage = response.getReturnValue();
            if (returnMessage === "SUCCESS" ) {
				console.log('Succeeded');
				$A.get('e.force:refreshView').fire();
				console.log('Attempted to fire refresh');
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": returnMessage,
					"type":"error",
					 "mode": 'sticky'
                });
                toastEvent.fire();
            }
        });

		$A.enqueueAction(action);
	},
})