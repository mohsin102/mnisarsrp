({
    doInit: function (component, event, helper) {
        component.set('v.columns', [
            {
                label: 'Division Order',
                fieldName: 'Name',
                type: 'button',
                typeAttributes: {
                    label: { fieldName: 'Name' },
                    sObject: 'divisionOrder__c',
                    title: { fieldName: 'Name'},
                    disabled: false,
                    value: 'Id',
                    variant: 'base',
                },
                sortable: true,
                initialWidth: 120
            },
            {
                label: 'Account',
                fieldName: 'accountName',
                type: 'button',
                typeAttributes: {
                    label: { fieldName: 'accountName' },
                    sObject: 'Account',
                    title: { fieldName: 'accountName'},
                    disabled: false,
                    value: 'accountId',
                    variant: 'base',
                },
                sortable: true,
                initialWidth: 150
            },
            {
                label: 'Created By',
                fieldName: 'createdByName',
                type: 'button',
                typeAttributes: {
                    label: { fieldName: 'createdByName' },
                    sObject: 'User',
                    title: { fieldName: 'createdByName'},
                    disabled: false,
                    value: 'CreatedById',
                    variant: 'base',
                },
                sortable: true,
                initialWidth: 100
            },
            {
                label: 'Created Date',
                fieldName: 'CreatedDate',
                type: 'date',
                typeAttributes: {
                    year: 'numeric',
                    month: '2-digit',
                    day: '2-digit',
                    hour: '2-digit',
                    minute: '2-digit',
                },
                sortable: true,
                initialWidth: 130
            },
            {
                label: 'Date Confirmed',
                fieldName: 'dateConfirmed__c',
                type: 'date',
                typeAttributes: {
                    year: 'numeric',
                    month: '2-digit',
                    day: '2-digit',
                    hour: '2-digit',
                    minute: '2-digit'
                },
                sortable: true,
                initialWidth: 140
            },
            {
                label: 'Date Received From Operator',
                fieldName: 'dateReceivedFromOperator__c',
                type: 'date',
                typeAttributes: {
                    year: 'numeric',
                    month: '2-digit',
                    day: '2-digit',
                    hour: '2-digit',
                    minute: '2-digit'
                },
                sortable: true,
                initialWidth: 240
            },
            {
                label: 'Date Returned From Operator',
                fieldName: 'dateReturnedToOperator__c',
                type: 'date',
                typeAttributes: {
                    year: 'numeric',
                    month: '2-digit',
                    day: '2-digit',
                    hour: '2-digit',
                    minute: '2-digit'
                },
                sortable: true,
                initialWidth: 240
            },
            {
                label: 'Operator',
                fieldName: 'operatorName',
                type: 'button',
                typeAttributes: {
                    label: { fieldName: 'operatorName' },
                    sObject: 'Account',
                    title: { fieldName: 'operatorName'},
                    disabled: false,
                    value: 'operator__c',
                    variant: 'base',
                },
                sortable: true,
                initialWidth: 100
            },
            {
                label: 'Status',
                fieldName: 'status__c',
                type: 'text',
                sortable: true,
                cellAttributes: { alignment: 'left'},
                initialWidth: 100
            },
            {
                label: 'Priority',
                fieldName: 'priority__c',
                type: 'text',
                sortable: true,
                cellAttributes: { alignment: 'left'},
                initialWidth: 100
            },
            {
                label: 'Owner',
                fieldName: 'ownerName',
                type: 'button',
                typeAttributes: {
                    label: { fieldName: 'ownerName' },
                    sObject: 'User',
                    title: { fieldName: 'ownerName'},
                    disabled: false,
                    value: 'OwnerId',
                    variant: 'base'
                },
                sortable: true,
                initialWidth: 100
            },
            {
                label: 'Shared Drive Path',
                fieldName: 'sharedDrivePath__c',
                type: 'text',
                sortable: false,
                cellAttributes: { alignment: 'left'},
                initialWidth: 160
            }
        ]);
        
        var action0 = component.get('c.getDivisionOrders');
        
        action0.setParams({ recordId: component.get('v.recordId') });
        action0.setCallback(this, function (response) {
            var state0 = response.getState();
            var result0 = response.getReturnValue();
            
            console.log(`result0 is ------------> ${JSON.stringify(result0)}`);
            if (state0 === 'SUCCESS') {
                var divOrdList = result0;
                if(divOrdList.length>10){
                    var scrollerdiv = component.find("scrollerdiv");
                    $A.util.removeClass(scrollerdiv, 'scrollerSize');
                    $A.util.addClass(scrollerdiv, 'maxHeight');
                }
                
                divOrdList.some(function (record) {
                    record.linkName = '/' + record.Id;
                    record.ownerLink = '/' + record.OwnerId;
                    record.ownerName = record.Owner.Name;
                    record.createdByName = record.CreatedBy.Name;
                    
                    if(record.operator__c !== undefined && (record.operator__c)){
                        record.operatorName = record.operator__r.Name;
                    }
                    if(record.case__r.Account !== undefined){
                        record.accountId = record.case__r.AccountId;
                        record.accountName = record.case__r.Account.Name;
                    }
                    console.log(`passed the IFs`);
                });
                component.set('v.data', divOrdList);
                component.set('v.listlength', divOrdList.length);
            }
        });
        $A.enqueueAction(action0);
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
        var row = event.getParam('row');
        var workspaceAPI = component.find('workspace');
        
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
                // Sets the route to /lightning/o/sobject/home
                var pageReference = {
                    type: 'standard__recordPage',
                    attributes: {
                        objectApiName: action.sObject,
                        actionName: 'view',
                        recordId: row[action.value]
                    }
                };
                
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
    }
});