({
    handleRecordUpdated: function (component, event, helper) {
		var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
			console.log('Record Id value is: ' + component.get('v.recordId'));
			var createRecordEvent = $A.get("e.force:createRecord");

			var landGridTractId = component.get('v.twjRecord').landGridTract__c;
			createRecordEvent.setParams({
				"entityApiName": "TitleIntegrationJob__c",
				"defaultFieldValues": {
					'landGridTract__c' : landGridTractId
				}
			});
			createRecordEvent.fire();
		}
		else{
			console.log('Create Error Handling');
		}

	},
})