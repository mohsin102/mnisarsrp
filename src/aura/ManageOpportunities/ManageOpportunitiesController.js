({
    init: function (component, event, helper) {
        component.set('v.columns', [
            {
                label: 'Action',
                fieldName: 'action',
                type: 'button',
                typeAttributes: {
                    label: { fieldName: 'action' },
                    name: { fieldName: 'action' },
                    title: 'Remove Record',
                    disabled: { fieldName: 'disabled' },
                    value: { fieldName: 'fn2' },
                    variant: 'destructive-text'
                },
                initialWidth: 100
            },
            {
                label: 'Opportunity',
                fieldName: 'oppName',
                type: 'button',
                typeAttributes: {
                    label: { fieldName: 'oppName' },
                    sObject: 'Opportunity',
                    title: 'Open Opportunity',
                    disabled: false,
                    value: 'opportunity__c',
                    variant: 'base',
                    class: 'nameButton'
                },
                initialWidth: 300,
                sortable: true
            },
            {
                label: 'Seller',
                fieldName: 'sellerName',
                type: 'button',
                typeAttributes: {
                    label: { fieldName: 'sellerName' },
                    sObject: 'Account',
                    title: 'Open Seller Account',
                    disabled: false,
                    value: 'opportunity__r.Account.Id',
                    variant: 'base',
                    class: 'nameButton'
                },
                initialWidth: 300,
                sortable: true
            },
            {
                label: 'Buyer',
                fieldName: 'buyerName',
                type: 'button',
                typeAttributes: {
                    label: { fieldName: 'buyerName' },
                    sObject: 'Account',
                    title: 'Open Buyer Account',
                    disabled: false,
                    value: 'opportunity__r.Acquiring_Entity__c',
                    variant: 'base',
                    class: 'nameButton'
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
                fieldName: 'oppOwnerName',
                type: 'button',
                typeAttributes: {
                    label: { fieldName: 'oppOwnerName' },
                    sObject: 'User',
                    title: 'Open Owner Record',
                    disabled: false,
                    value: 'opportunity__r.Owner.Id',
                    variant: 'base',
                    class: 'nameButton'
                },
                initialWidth: 130,
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
        let action = component.get('c.getOpportunities');

        action.setParams({
            recordId: component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            let result = response.getReturnValue();

            if (state === 'SUCCESS') {
                let oppList = result;

                if (oppList.length > 10) {
                    let scrollerDiv = component.find('scrollerDiv');
                    $A.util.addClass(scrollerDiv, 'maxHeight');
                }

                oppList.forEach(function (record) {

                    record.action = 'Remove';
                    record.disabled = false;
                    record.OppLink = '/' + record.opportunity__r.Id;
                    record.SellerLink = '/' + record.opportunity__r.Account.Id;
                    record.BuyerLink = '/' + record.opportunity__r.Acquiring_Entity__r.Id;

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
                component.set('v.data', oppList);

                component.set('v.listlength', oppList.length);

                helper.sortData(
                    component,
                    component.get('v.sortedBy'),
                    component.get('v.sortedDirection'),
                    helper
                );
                let totalLineItems = component.get('v.data').length;
                component.set('v.totalLineItems', totalLineItems);
                let totalPages = Math.ceil(
                    totalLineItems / component.get('v.pageSize')
                );
                component.set('v.totalPages', totalPages);
                helper.getPageData(component);
            }
        });
        $A.enqueueAction(action);
    },


    addOpportunity: function (component, event, helper) {
        let lookupId = event.getParam('value');
        let opportunities = [];
        opportunities = component.get('v.opportunityIds');
        opportunities.push(lookupId[0]);
        component.set('v.opportunityIds', opportunities);

        if (opportunities.length) {
            helper.getOpportunitiesByOpportunityId(component, event, helper);
            component.set('v.opportunityField', '');
            component.set('v.opportunityIds', []);
            opportunities = [];
            let opp = component.find('opportunityName');
            opp.reset();
        } else {
            component.set('v.showTable', false);
        }
    },


    updateSorting: function (component, event, helper) {
        let fieldName = event.getParam('fieldName');
        let sortDirection = event.getParam('sortDirection');
        component.set('v.sortedBy', fieldName);
        component.set('v.sortedDirection', sortDirection);
        helper.sortData(component, fieldName, sortDirection, helper);
    },


    updateAssociation: function (component, event, helper) {
        let row = event.getParam('row');
        let actionName = event.getParam('action').label.fieldName;

        if ( actionName == 'oppName') {
            let viewRecordEvent = $A.get("e.force:navigateToURL");
            viewRecordEvent.setParams({
                "url": "/" + row.opportunity__r.Id
            });
            viewRecordEvent.fire();
        } else if(actionName == 'sellerName') {
            let viewRecordEvent = $A.get("e.force:navigateToURL");
            viewRecordEvent.setParams({
                "url": "/" + row.opportunity__r.Account
            });
            viewRecordEvent.fire();
        } else if(actionName == 'buyerName') {
            let viewRecordEvent = $A.get("e.force:navigateToURL");
            viewRecordEvent.setParams({
                "url": "/" + row.opportunity__r.Acquiring_Entity__c
            });
            viewRecordEvent.fire();
        } else if(actionName == 'oppOwnerName') {
            let viewRecordEvent = $A.get("e.force:navigateToURL");
            viewRecordEvent.setParams({
                "url": "/" + row.opportunity__r.Owner.Id
            });
            viewRecordEvent.fire();
        } else{
            let action = component.get('c.updateRecordAssociation');
            action.setParams({
                recordId: component.get('v.recordId'),
                oppCaseId: row.Id
            });
            action.setCallback(this, function (response) {
                let oppList = response.getReturnValue();

                if (oppList === null) {console.log(`Apex returned NULL on Delete of Opportunity Case`);}

                oppList.forEach(function (record) {

                    record.action = 'Remove';
                    record.disabled = false;
                    record.OppLink = '/' + record.opportunity__r.Id;
                    record.SellerLink = '/' + record.opportunity__r.Account.Id;
                    record.BuyerLink = '/' + record.opportunity__r.Acquiring_Entity__r.Id;

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
                component.set('v.data', oppList);
                component.set('v.listlength', oppList.length);
                
                helper.sortData(
                    component,
                    component.get('v.sortedBy'),
                    component.get('v.sortedDirection'),
                    helper
                );
                let totalLineItems = component.get('v.data').length;
                component.set('v.totalLineItems', totalLineItems);
                let totalPages = Math.ceil(
                    totalLineItems / component.get('v.pageSize')
                );
                component.set('v.totalPages', totalPages);

                helper.getPageData(component);
            });
            $A.enqueueAction(action);
        }
    },
    handleNext: function (component, event, helper) {
        let pageNumber = component.get('v.pageNumber') + 1;
        component.set('v.pageNumber', pageNumber);
        helper.getPageData(component);
    },
    handlePrev: function (component, event, helper) {
        let pageNumber = component.get('v.pageNumber') - 1;
        component.set('v.pageNumber', pageNumber);
        helper.getPageData(component);
    },
    handleCancel: function (component, event, helper) {
        let appEvent = $A.get('e.c:applicationEventRefresh');
        appEvent.fire();
        component.destroy();
    }
});