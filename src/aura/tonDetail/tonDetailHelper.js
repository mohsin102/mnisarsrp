({
	setForm: function (component, event) {
		var tonId = component.get('v.recordId');
		var action = component.get("c.getCurrentTon2");
		action.setParams({
				'tonRecordId': tonId
			});

		action.setCallback(this, function(response){
				var responseValue = response.getReturnValue();
				component.set('v.ton', responseValue);
				if (responseValue.account__c){
					
					component.set('v.hasAssociation', true);
					

				}
				else{
					component.set('v.hasAssociation', false);
				}

			});

		$A.enqueueAction(action);
	}
})