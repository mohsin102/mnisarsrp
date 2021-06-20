({
    doInit: function (component, event, helper) {
        component.set('v.mycolumns', [
            {
                label: 'Opportunity',
                fieldName: 'oppLink',
                type: 'url',
				cellAttributes: { 
					alignment: 'left' 
				},
                typeAttributes: {
                    label: { fieldName: 'oppName' },
                    target: '_self',
                    title: 'Open Opportunity',
                },
                initialWidth: 300,
                sortable: true
            },
            {
                label: 'Seller',
                fieldName: 'sellerLink',
                type: 'url',
				cellAttributes: { 
					alignment: 'left' 
				},
                typeAttributes: {
                    label: { fieldName: 'sellerName' },
                    target: '_self',
                    title: 'Open Opportunity',
                },
                initialWidth: 300,
                sortable: true
            },
            {
                label: 'Buyer',
                fieldName: 'buyerLink',
                type: 'url',
				cellAttributes: { 
					alignment: 'left' 
				},
                typeAttributes: {
                    label: { fieldName: 'buyerName' },
                    target: '_self',
                    title: 'Open Opportunity',
                },
                initialWidth: 300,
                sortable: true
            },
            {
                label: 'Stage',
                fieldName: 'stageName',
                sortable: true,
                initialWidth: 130
            },
            {
                label: 'Type',
                fieldName: 'oppType',
                initialWidth: 120
            },
            {
                label: 'Effective Date',
                fieldName: 'oppEffectiveDate',
                type: 'date-local',
                typeAttributes: {
                    month: '2-digit',
                    day: '2-digit',
                    year: '2-digit'
                },
                sortable: true,
                initialWidth: 120
            },
            {
                label: 'PSA Date',
                fieldName: 'oppPSADate',
                type: 'date-local',
                sortable: true,
                initialWidth: 140
            },
            {
                label: 'Close Date',
                fieldName: 'oppCloseDate',
                type: 'date-local',
                typeAttributes: {
                    month: '2-digit',
                    day: '2-digit',
                    year: '2-digit'
                },
                sortable: true,
                initialWidth: 120
            },
            {
                label: 'Owner',
                fieldName: 'ownerLink',
                type: 'url',
				cellAttributes: { 
					alignment: 'left' 
				},
                typeAttributes: {
                    label: { fieldName: 'oppOwnerName' },
                    target: '_self',
                    title: 'Open Opportunity',
                },
                initialWidth: 300,
                sortable: true
            },
            {
                label: 'Total Price Per Acre',
                fieldName: 'oppTotalPricePerAcre',
                type: 'currency',
                cellAttributes: { alignment: 'left' },
                sortable: true,
                initialWidth: 120
            },
            {
                label: 'Total Price',
                fieldName: 'oppTotalPrice',
                type: 'currency',
                cellAttributes: { alignment: 'left' },
                sortable: true,
                initialWidth: 120,
                editable: false
            },
            {
                label: 'Ask Total Price Per Acre',
                fieldName: 'oppAskTotalPricePerAcre',
                type: 'currency',
                cellAttributes: { alignment: 'left' },
                sortable: true,
                initialWidth: 140
            },
            {
                label: 'Ask Total Price',
                fieldName: 'oppAskTotalPrice',
                type: 'currency',
                cellAttributes: { alignment: 'left' },
                sortable: true,
                initialWidth: 140,
                editable: false
            }
        ]);
		helper.getData(component);
        /*var action = component.get('c.getCaseOpps');

        action.setParams({
            recordId: component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var result = response.getReturnValue();
                                                                                        console.log('state-------------------->' + component.get('v.recordId'));
                                                                                        console.log('state-------------------->' + state);
                                                                                        console.log('result-------------------->' + JSON.stringify(result));
            if (state === 'SUCCESS') {
                var oppCaseList = result;

				if(oppCaseList.length>10){
                    var scrollerDiv = component.find("scrollerDiv");
                    $A.util.addClass(scrollerDiv, 'maxHeight');
                }

                oppCaseList.forEach(function (record) {
                                                                                            console.log('oppCaseList record-------------------->' + record);
                    record.linkName = '/' + record.Id;
                    record.ownerLink = '/' + record.opportunity__r.Owner.Id;
					
					record.ownerId = record.opportunity__r.Owner.Id;
					record.oppName = record.opportunity__r.Name;
                    record.sellerName = record.opportunity__r.Account.Name;
                    record.buyerName = record.opportunity__r.Acquiring_Entity__r.Name;
                    record.oppStageName = record.opportunity__r.StageName;
                    record.oppType = record.opportunity__r.Type;
                    record.oppEffectiveDate = record.opportunity__r.Effective_Date__c;
                    record.oppPSADate = record.opportunity__r.PSA_Date__c;
                    record.oppCloseDate = record.opportunity__r.CloseDate;
                    record.oppOwnerName = record.opportunity__r.Owner.Name;
                    record.oppTotalPricePerAcre = record.opportunity__r.totalPricePerAcre__c;
                    record.oppTotalPrice = record.opportunity__r.totalPrice__c;
                    record.oppAskTotalPricePerAcre = record.opportunity__r.askTotalPricePerAcre__;
                    record.oppAskTotalPrice = record.opportunity__r.askTotalPrice__c;
                });
                component.set('v.data', oppCaseList);
                component.set('v.listlength', oppCaseList.length);
            }
        });
        $A.enqueueAction(action);*/
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
        var urlLookups = {oppLink:'oppName', sellerLink:'sellerName', buyerLink:'buyerName', ownerLink:'oppOwnerName' };
		var fieldName = event.getParam('fieldName');
        if(typeof urlLookups[fieldName] != 'undefined'){
			fieldName = urlLookups[fieldName];
			//console.log ('Sort field should be updated to: ' + fieldName);
		}
		var sortDirection = event.getParam('sortDirection');
        var data = component.get('v.data');
		console.log('fieldName value is: ' + fieldName);
		console.log('sortDirection value is: ' + sortDirection);
		component.set("v.sortedBy", event.getParam('fieldName'));
        component.set("v.sortedDirection", sortDirection);
		data = _srpUtility.sortArray(data, fieldName, sortDirection);
		component.set('v.data', data);
    },

    /*handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        //console.log(action.value);
        var row = event.getParam('row');
		console.log('JSON row value is:');
        console.log(JSON.stringify(row));
		console.log('action value is: ' + JSON.stringify(action.value) + ' row record is: ' + row[action.value]);
		console.log(row['opportunity__r'].OwnerId);
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
    },*/
    handleApplicationEvent: function(component,event,helper){
        helper.getData(component);
		/*var action = component.get('c.getCaseOpps');

        action.setParams({
            recordId: component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === 'SUCCESS') {
                var oppCaseList = result;

				if(oppCaseList.length>10){
                    var scrollerDiv = component.find("scrollerDiv");
                    $A.util.addClass(scrollerDiv, 'maxHeight');
                }

                oppCaseList.forEach(function (record) {
                                                                                                    console.log('oppCaseList record-------------------->' + record);
                    record.linkName = '/' + record.Id;
                    record.ownerLink = '/' + record.opportunity__r.Owner.Id;

					record.ownerId = record.opportunity__r.Owner.Id;
					record.oppName = record.opportunity__r.Name;
                    record.sellerName = record.opportunity__r.Account.Name;
                    record.buyerName = record.opportunity__r.Acquiring_Entity__r.Name;
                    record.oppStageName = record.opportunity__r.StageName;
                    record.oppType = record.opportunity__r.Type;
                    record.oppEffectiveDate = record.opportunity__r.Effective_Date__c;
                    record.oppPSADate = record.opportunity__r.PSA_Date__c;
                    record.oppCloseDate = record.opportunity__r.CloseDate;
                    record.oppOwnerName = record.opportunity__r.Owner.Name;
                    record.oppTotalPricePerAcre = record.opportunity__r.totalPricePerAcre__c;
                    record.oppTotalPrice = record.opportunity__r.totalPrice__c;
                    record.oppAskTotalPricePerAcre = record.opportunity__r.askTotalPricePerAcre__;
                    record.oppAskTotalPrice = record.opportunity__r.askTotalPrice__c;
                });
                component.set('v.data', oppCaseList);
                component.set('v.listlength', oppCaseList.length);
            }
        });
        $A.enqueueAction(action);*/
   },
});