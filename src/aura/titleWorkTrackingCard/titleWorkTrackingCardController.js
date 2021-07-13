({
	doInit: function(component, event, helper) {
		var titleTracker = component.get('v.titleTrackingRecord');
		component.set('v.titleWorkStatus', titleTracker.titleWorkTracker.status__c);
		//var initialTitleWorkStatusMarker = component.find('initialTitleWorkStatusMarker');
		//$A.util.addClass(initialTitleWorkStatusMarker, 'slds-is-completed');
		for(var key in titleTracker.titleWorkJobs){
			//console.log(JSON.stringify(titleTracker.titleWorkJobs[key].titleWorkJob));
			helper.getJobInfo(component, helper, titleTracker.titleWorkJobs[key].titleWorkJob);
		}
		if(titleTracker.titleWorkTracker.status__c == 'Complete'){
			component.set('v.percentComplete', 100);
		}
		var percentComplete = component.get('v.percentComplete');
		var landmanStatus = component.get('v.landmanStatus');
		var integrationReviewStatus = component.get('v.integrationReviewStatus');
		var attorneyReviewStatus = component.get('v.attorneyReviewStatus');
		var titleWorkStatus = component.get('v.titleWorkStatus');

		switch (percentComplete){
			
			case 0:
				/*if(titleWorkStatus != 'In Progress'){
					helper.setStatusError(component, helper, 'initialTitleWork');
				}
				else{
					helper.setStatusComplete(component, helper, 'initialTitleWork');
				}*/
				if(landmanStatus == 'In Progress'){
					helper.setStatusInProgress(component, helper, 'landman');
				}
				else if(landmanStatus == 'Complete'){
					helper.setStatusComplete(component, helper, 'landman');
				}
				else if(landmanStatus == 'Not Started'){
					helper.setStatusNotStarted(component, helper, 'landman');
				}
				else {
					helper.setStatusError(component, helper, 'landman');
				}
				if(integrationReviewStatus != 'Not Created'){
					helper.setStatusError(component, helper, 'integrationReview');
				}
				if(attorneyReviewStatus != 'Not Created'){
					helper.setStatusError(component, helper, 'attorneyReview');
				}
				break;
			case 33:
				/*if(titleWorkStatus != 'In Progress'){
					helper.setStatusError(component, helper, 'initialTitleWork');
				}
				else{
					helper.setStatusComplete(component, helper, 'initialTitleWork');
				}*/
				if(landmanStatus != 'Complete'){
					helper.setStatusError(component, helper, 'landman');
				}
				else{
					helper.setStatusComplete(component, helper, 'landman');
				}
				if(integrationReviewStatus == 'In Progress'){
					helper.setStatusInProgress(component, helper, 'integrationReview');
				}
				else if(integrationReviewStatus == 'Complete'){
					helper.setStatusComplete(component, helper, 'integrationReview');
				}
				else if(integrationReviewStatus == 'Not Started'){
					helper.setStatusNotStarted(component, helper, 'integrationReview');
				}
				else{
					helper.setStatusError(component, helper, 'integrationReview');
				}
				if(attorneyReviewStatus != 'Not Created'){
					helper.setStatusError(component, helper, 'attorneyReview');
				}
				break;
			case 67:
				/*if(titleWorkStatus != 'In Progress'){
					helper.setStatusError(component, helper, 'initialTitleWork');
				}
				else{
					helper.setStatusComplete(component, helper, 'initialTitleWork');
				}*/
				if(landmanStatus != 'Complete'){
					helper.setStatusError(component, helper, 'landman');
				}
				else{
					helper.setStatusComplete(component, helper, 'landman');
				}
				if(integrationReviewStatus == 'Complete'){
					helper.setStatusComplete(component, helper, 'integrationReview');
				}
				else {
					helper.setStatusError(component, helper, 'integrationReview');
				}
				if(attorneyReviewStatus == 'In Progress'){
					helper.setStatusInProgress(component, helper, 'attorneyReview');
				}
				else if(attorneyReviewStatus == 'Complete'){
					helper.setStatusComplete(component, helper, 'attorneyReview');
				}
				else if(attorneyReviewStatus == 'Not Started'){
					helper.setStatusNotStarted(component, helper, 'attorneyReview');
				}
				else{
					helper.setStatusError(component, helper, 'attorneyReview');
				}
				break;
			case 100:
				/*if(titleWorkStatus != 'Complete'){
					helper.setStatusError(component, helper, 'initialTitleWork');
				}
				else{
					helper.setStatusComplete(component, helper, 'initialTitleWork');
				}*/
				if(landmanStatus != 'Complete'){
					helper.setStatusError(component, helper, 'landman');
				}
				else{
					helper.setStatusComplete(component, helper, 'landman');
				}
				if(integrationReviewStatus == 'Complete'){
					helper.setStatusComplete(component, helper, 'integrationReview');
				}
				else {
					helper.setStatusError(component, helper, 'integrationReview');
				}
				if(attorneyReviewStatus == 'Complete'){
					helper.setStatusComplete(component, helper, 'attorneyReview');
				}
				else{
					helper.setStatusError(component, helper, 'attorneyReview');
				}
				helper.setStatusComplete(component, helper, 'finalTitleWork');
				break;
		}

		//console.log(JSON.stringify(titleTracker));
		/*if (titleTracker.titleWorkTracker.status__c == 'In Progress'){
			//component.set('v.landmanStatus', 'Not Started');
			component.set('v.percentComplete', 25);
		}
		if (titleTracker.titleWorkTracker.landmanStartDate__c){
			component.set('v.landmanStatus', 'In Progress');
		}
		if (titleTracker.titleWorkTracker.landmanCompletionDate__c){
			component.set('v.landmanStatus', 'Complete');
			component.set('v.percentComplete', 25);
		}
		else if (titleTracker.titleWorkTracker.integrationReviewCompletionDate){
			component.set('v.landmanStatus', 'In Progress')
			component.set('v.percentComplete', 25);
		}
		if (titleTracker.titleWorkTracker.integrationReviewCompletionDate__c){
			component.set('v.integrationReviewStatus', 'Complete');
			component.set('v.percentComplete', 50);
		}
		else if (titleTracker.titleWorkTracker.integrationReviewStartDate__c){
			component.set('v.integrationReviewStatus', 'In Progress')
			component.set('v.percentComplete', 50);
		}
		if (titleTracker.titleWorkTracker.attorneyReviewCompletionDate__c){
			component.set('v.attorneyReviewStatus', 'Complete');
			component.set('v.percentComplete', 75);
		}
		else if (titleTracker.titleWorkTracker.attorneyReviewStartDate__c){
			component.set('v.attorneyReviewStatus', 'In Progress')
			component.set('v.percentComplete', 75);
		}
		if (titleTracker.titleWorkTracker.status__c == 'Complete'){
			component.set('v.titleWorkStatus', 'Complete');
			component.set('v.percentComplete', 100);
		}
		else if (titleTracker.titleWorkTracker.status__c == 'In Progress' && titleTracker.titleWorkTracker.attorneyReviewCompletionDate__c){
			component.set('v.titleWorkStatus', 'In Progress')
			component.set('v.percentComplete', 100);
		}*/
	},
	completeTitleWorkTracker : function (component, event, helper) {
		console.log('Trying to complete Title Work Tracker');
		var titleTrackingRecord = component.get("v.titleTrackingRecord.titleWorkTracker");
		var action = component.get("c.updateTitleWorkComplete");

		action.setParams({
			updateRecord: titleTrackingRecord,
			objectType:"TitleWorkTracker__c"
		});

		action.setCallback(this, function(response) {
            //console.log('Inside callback');
			var returnMessage = response.getReturnValue();
            if (returnMessage === "SUCCESS" ) {
				console.log('Succeeded');
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
	
	
	
})