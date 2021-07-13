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
                    value: 'OwnerId',
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
                }
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
                }
            }
        ]);
        let action = component.get('c.getCases');

        action.setParams({
            recordId: component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            let result = response.getReturnValue();

            if (state === 'SUCCESS') {
                let caseList = result;

                if (caseList.length > 10) {
                    let scrollerDiv = component.find('scrollerDiv');
                    $A.util.addClass(scrollerDiv, 'maxHeight');
                }

                caseList.forEach(function (record) {

                    record.action = 'Remove';
                    record.disabled = false;
                    record.linkName = '/' + record.Id;
                    record.ownerLink = '/' + record.case__r.Owner.Id;

                    record.caseNumber = record.case__r.CaseNumber;
                    record.caseSubject = record.case__r.Subject;
                    record.caseType = record.case__r.Type;
                    record.ownerName = record.case__r.Owner.Name;
                    record.caseStatus = record.case__r.Status;
                    record.casePriority = record.case__r.Priority;
                    record.caseCreateDate = record.case__r.CreatedDate;
                    record.caseClosedDate = record.case__r.ClosedDate;
                });
                component.set('v.data', caseList);

                component.set('v.listlength', caseList.length);

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
    addCase: function (component, event, helper) {
        let lookupId = event.getParam('value');
        let cases = [];
        cases = component.get('v.caseIds');
        cases.push(lookupId[0]);
        component.set('v.caseIds', cases);

        if (cases.length) {
            helper.getCasesByCaseId(component, event, helper);
            component.set('v.caseField', '');
            component.set('v.caseIds', []);
            cases = [];
            let cse = component.find('caseName');
            cse.reset();
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

        if ( actionName == 'caseNumber') {
            let viewRecordEvent = $A.get("e.force:navigateToURL");
            viewRecordEvent.setParams({
                "url": "/" + row.case__r.Id
            });
            viewRecordEvent.fire();
        } else if(actionName == 'ownerName') {
            let viewRecordEvent = $A.get("e.force:navigateToURL");
            viewRecordEvent.setParams({
                "url": "/" + row.case__r.Owner.Id
            });
            viewRecordEvent.fire();
        } else{
            let action = component.get('c.updateRecordAssociation');
            action.setParams({
                recordId: component.get('v.recordId'),
                oppCaseId: row.Id
            });
            action.setCallback(this, function (response) {
                let caseList = response.getReturnValue();

                if (caseList === null) {console.log(`Apex returned NULL on Delete of Opportunity Case`);}

                caseList.forEach(function (record) {

                    record.action = 'Remove';
                    record.disabled = false;
                    record.linkName = '/' + record.Id;
                    record.ownerLink = '/' + record.case__r.Owner.Id;

                    record.caseNumber = record.case__r.CaseNumber;
                    record.caseSubject = record.case__r.Subject;
                    record.caseType = record.case__r.Type;
                    record.ownerName = record.case__r.Owner.Name;
                    record.caseStatus = record.case__r.Status;
                    record.casePriority = record.case__r.Priority;
                    record.caseCreateDate = record.case__r.CreatedDate;
                    record.caseClosedDate = record.case__r.ClosedDate;
                });
                component.set('v.data', caseList);
                component.set('v.listlength', caseList.length);
                
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