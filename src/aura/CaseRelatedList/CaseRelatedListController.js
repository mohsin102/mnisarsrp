({
    doInit: function (component, event, helper) {
        component.set('v.mycolumns', [
            {
                label: 'Name',
				fieldName: 'caseNumber',
                type: 'button',
                typeAttributes: {
                    label: { fieldName: 'caseNumber' },
                    sObject: 'Case',
                    title: 'Open Case',
                    disabled: false,
                    value: 'case__c',
                    variant: 'base',
                    class: 'nameButton',
                    initialWidth: 100
                },
                sortable: true
            },
            {
                label: 'Subject',
                fieldName: 'caseSubject',
                type: 'text',
                initialWidth: 300,
                sortable: true,
                cellAttributes: { alignment: 'left' }
            },
            {
                label: 'Type',
                fieldName: 'caseType',
                type: 'text',
                sortable: true,
                cellAttributes: { alignment: 'left' }
            },
            {
                label: 'Owner',
				fieldName: 'ownerName',
                type: 'button',
                typeAttributes: {
                    label: { fieldName: 'ownerName' },
                    sObject: 'User',
                    title: 'Open Owner',
                    disabled: false,
                    value: 'ownerId',
                    variant: 'base',
                    class: 'nameButton',
                    initialWidth: 200
                },
                sortable: true
            },
            {
                label: 'Status',
                fieldName: 'caseStatus',
                type: 'text',
                sortable: true,
                cellAttributes: { alignment: 'left' }
            },
            {
                label: 'Priority',
                fieldName: 'casePriority',
                type: 'text',
                sortable: true,
                cellAttributes: { alignment: 'left' }
            },
            {
                label: 'Date/Time Opened',
                fieldName: 'caseCreateDate',
                type: 'date',
                typeAttributes: {
                    year: 'numeric',
                    month: '2-digit',
                    day: '2-digit',
                    hour: '2-digit',
                    minute: '2-digit'
                },
                sortable: true,
            },
            {
                label: 'Date/Time Closed',
                fieldName: 'caseClosedDate',
                type: 'date',
                typeAttributes: {
                    year: 'numeric',
                    month: '2-digit',
                    day: '2-digit',
                    hour: '2-digit',
                    minute: '2-digit'
                },
                sortable: true,
            }
        ]);
        helper.handleGetCases(component);
    },

    refreshCmp : function(component, event, helper) {

        var sObjectEvent = $A.get("e.force:navigateToSObject");
        sObjectEvent.setParams({
            "recordId": component.get("v.recordId")
        })
        sObjectEvent.fire();
    },

	jsLoaded: function(component, event, helper){
        //Placeholder if need to perform action after scripts are loaded.
        //console.log('javascript library has been loaded.');
    },

    handleSort: function (component, event, helper) {
        var sortBy = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
		var data = component.get('v.data');
        component.set('v.sortBy', sortBy);
        component.set('v.sortDirection', sortDirection);
		data = _srpUtility.sortArray(data, sortBy, sortDirection);
		component.set('v.data', data);
    },

    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        //console.log(action.value);
        var row = event.getParam('row');

        console.log(JSON.stringify(row));
        var workspaceAPI = component.find('workspace');
        //console.log('/lightning/r/'+component.get('v.sObjectName') + '/' +component.get('v.recordId')+'/view');
        const handleUrl = (url) => {
            window.open(url);
        };
        const handleError = (error) => {
            console.log(error);
        };
        workspaceAPI.isConsoleNavigation().then(function (response) {
            workspaceAPI
                .openTab({
                    url:
                        '/lightning/r/' +
                        component.get('v.sObjectName') +
                        '/' +
                        component.get('v.recordId') +
                        '/view',
                    focus: true
                })
                .then(function (response) {
                    //console.log('/lightning/r/'+ action.sObject+ '/'+row[action.value]+'/view');
                    workspaceAPI.openSubtab({
                        parentTabId: response,
                        url:
                            '/lightning/r/' +
                            action.sObject +
                            '/' +
                            row[action.value] +
                            '/view',
                        focus: true
                    });
                })
                .catch(function (error) {
                    var navService = component.find('navService');
                    // Sets the route to /lightning/o/Account/home
                    var pageReference = {
                        type: 'standard__recordPage',
                        attributes: {
                            objectApiName: action.sObject,
                            actionName: 'view',
                            recordId: row[action.value]
                        }
                    };
                    //console.log(pageReference);
                    component.set('v.pageReference', pageReference);
                    // Set the URL on the link or use the default if there's an error
                    var defaultUrl = '#';
                    navService.generateUrl(pageReference).then(
                        $A.getCallback(function (url) {
                            component.set('v.url', url ? url : defaultUrl);
                        }),
                        $A.getCallback(function (error) {
                            component.set('v.url', defaultUrl);
                        })
                    );
                    event.preventDefault();
                    navService.navigate(pageReference);
                });
        });
    },
    handleApplicationEvent: function(component,event,helper){
        
        helper.handleGetCases(component);
   },
});