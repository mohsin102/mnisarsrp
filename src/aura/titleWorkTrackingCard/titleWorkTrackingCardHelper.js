({
	getJobInfo: function(component, helper, titleWorkJobRecord) {
		//console.log(JSON.stringify(titleWorkJobRecord));
		var newPercent = 0;

		//console.log(titleWorkJobRecord.type__c);
		switch (titleWorkJobRecord.type__c){
			case 'Landman':
				component.set('v.landmanStatus', titleWorkJobRecord.status__c);
				newPercent = 0;
				break;
			case 'Integration Review':
				component.set('v.integrationReviewStatus', titleWorkJobRecord.status__c);
				newPercent = 33;
				break;
			case 'Attorney Review':
				component.set('v.attorneyReviewStatus', titleWorkJobRecord.status__c);
				newPercent = 67;
				break;
		}
		this.calculatePercentComplete(component, helper, newPercent);
	},
	calculatePercentComplete: function(component, helper, newPercent){
		if (newPercent > component.get('v.percentComplete')){
			component.set('v.percentComplete', newPercent);
		}
	},
	setStatusError: function(component, helper, type){
		var buttonIconClass = 'red';
		var buttonClass = 'slds-button slds-button_icon slds-progress__marker slds-progress__marker_icon';
		var icon = 'utility:error';
		var listClass = 'slds-progress__item slds-has-error';

		component.set('v.' + type + 'StatusButtonClass', buttonClass);
		component.set('v.' + type + 'StatusButtonIconClass', buttonIconClass);
		component.set('v.' + type + 'StatusButtonIcon', icon);
		component.set('v.' + type + 'StatusListClass', listClass);
		
	},
	setStatusInProgress: function(component, helper, type){
		var buttonClass = 'slds-button slds-progress__marker';
		var listClass = 'slds-progress__item slds-is-active';

		component.set('v.' + type + 'StatusButtonClass', buttonClass);
		component.set('v.' + type + 'StatusListClass', listClass);
		
	},
	setStatusComplete: function(component, helper, type){
		var buttonIconClass = 'blue';
		var buttonClass = 'slds-button slds-button_icon slds-progress__marker slds-progress__marker_icon';
		var icon = 'utility:success';
		var listClass = 'slds-progress__item slds-is-completed';

		component.set('v.' + type + 'StatusButtonClass', buttonClass);
		component.set('v.' + type + 'StatusButtonIconClass', buttonIconClass);
		component.set('v.' + type + 'StatusButtonIcon', icon);
		component.set('v.' + type + 'StatusListClass', listClass);
		
	},
	setStatusNotStarted: function(component, helper, type){
		var buttonIconClass = 'blue';
		var buttonClass = 'slds-button slds-button_icon slds-progress__marker slds-progress__marker_icon';
		var icon = 'utility:error';
		var listClass = 'slds-progress__item slds-is-completed';

		component.set('v.' + type + 'StatusButtonClass', buttonClass);
		component.set('v.' + type + 'StatusButtonIconClass', buttonIconClass);
		component.set('v.' + type + 'StatusButtonIcon', icon);
		component.set('v.' + type + 'StatusListClass', listClass);
		
	},

})