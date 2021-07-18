({
    doInit: function(component, event, helper) {
        component.set('v.isWaiting', true);
		component.set('v.columns', [
			{ label: 'Date', fieldName: 'historyCreatedDate__c', type: 'date',typeAttributes:{year: "numeric", month: "long", day: "2-digit", hour: "2-digit", minute: "2-digit"}, sortable:true},
            { label: 'Field', fieldName: 'fieldLabel__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'fieldLabel__c' }, value:{ fieldName: 'fieldLabel__c' }}, sortable: true},
			{label: 'User', fieldName: 'userName', type: "button",
                typeAttributes: {label: {fieldName: 'userName'}, 
                name: {fieldName: 'userName'}, title: 'Open User', disabled: false,
                value: {fieldName: 'userName'}, variant: 'base', class:'nameButton', initialWidth: 200 }, sortable: true},
			//{label: 'User', fieldName: 'userLink', type: 'url', cellAttributes: { alignment: 'left' }, typeAttributes: {label: { fieldName: 'userName' }, target: '_blank', tooltip:{fieldName:'userName'}},sortable: true },
			//{ label: 'User', fieldName: 'userName', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'userName' }, value:{ fieldName: 'userName' }}, sortable: true},
			{ label: 'Original Value', fieldName: 'oldValue__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'oldValue__c' }, value:{ fieldName: 'oldValue__c' }}, sortable: true},
			{ label: 'New Value', fieldName: 'newValue__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'newValue__c' }, value:{ fieldName: 'newValue__c' }}, sortable: true},
			]);
		helper.getData(component);
		var width = component.get('v.width');
		console.log('Inner width value is: ' + width);
		var workspaceAPI = component.find("workspace");
        workspaceAPI.isConsoleNavigation().then(function(response) {
            console.log(response);
        })
        .catch(function(error) {
            console.log(error);
        });
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
	handleRowAction: function (component, event, helper) {
        
        var action = event.getParam('action');
        var row = event.getParam('row');
		var workspaceAPI = component.find("workspace");
		workspaceAPI.isConsoleNavigation().then(function(response) {
			workspaceAPI.openTab({
				url: '/lightning/r/'+component.get('v.sObjectName') + '/' +component.get('v.recordId')+'/view',
				focus: true
			}).then(function(response) {
				console.log('/lightning/r/User/'+row.changedBy__c+'/view');
				workspaceAPI.openSubtab({
					parentTabId: response,
					url: '/lightning/r/User/'+row.changedBy__c+'/view',
					focus: true
				});
			})
			.catch(function(error) {
				var navService = component.find("navService");
				// Sets the route to /lightning/o/Account/home
				var pageReference = {
					type: 'standard__recordPage',
					attributes: {
						objectApiName: 'User',
						actionName: 'view',
						recordId: row.changedBy__c
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
			});
        })
        
        
    },
	handleUserClick:function (component, event, helper) {
        
        var userId = event.getSource().get('v.value');
		var workspaceAPI = component.find("workspace");
		workspaceAPI.isConsoleNavigation().then(function(response) {
			workspaceAPI.openTab({
				url: '/lightning/r/'+component.get('v.sObjectName') + '/' +component.get('v.recordId')+'/view',
				focus: true
			}).then(function(response) {
				console.log('/lightning/r/User/'+userId+'/view');
				workspaceAPI.openSubtab({
					parentTabId: response,
					url: '/lightning/r/User/'+userId+'/view',
					focus: true
				});
			})
			.catch(function(error) {
				var navService = component.find("navService");
				// Sets the route to /lightning/o/Account/home
				var pageReference = {
					type: 'standard__recordPage',
					attributes: {
						objectApiName: 'User',
						actionName: 'view',
						recordId: userId
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
			});
        })
        
        
    }

})