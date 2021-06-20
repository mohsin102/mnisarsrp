({
	goToJob : function (component, event, helper) {
		var navService = component.find("navService");
		// Sets the route to /lightning/o/Account/home
		var pageReference = {
			type: 'standard__recordPage',
			attributes: {
				objectApiName: 'TitleIntegrationJob__c',
				actionName: 'view',
				recordId: component.get('v.tijRecord').Id
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
	completeTitleIntegrationJob: function (component, event, helper){
		
	}
})