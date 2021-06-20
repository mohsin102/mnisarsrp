({
    getCasesByCaseId: function (component, event, helper) {

        let action = component.get('c.getCaseSearchResults');
        
        action.setParams({
            caseIds: component.get('v.caseIds'),
            recordId: component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            let responseValue = response.getReturnValue();
            if(responseValue === null){ console.log(`Apex returned NULL on insert of Opportunity Case`);}
            
            helper.updateRecord(component, responseValue);

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
    },

    updateRecord: function (component, recordLst) {
        let recordId = component.get('v.recordId');
        console.log(`In the updateRecord func, the recordId value is: ------------> ${recordId}`);
        console.log(`In the updateRecord func, the record value is: ------------> ${JSON.stringify(recordLst)}`);

        recordLst.forEach(function (record) {

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
    component.set('v.data', recordLst);
    component.set('v.listlength', recordLst.length);
    },

    getPageData: function (component) {
        let pageNumber = component.get('v.pageNumber');
        let data = component.get('v.data');
        let pageSize = component.get('v.pageSize');
        let pageData = data.slice(
            (pageNumber - 1) * pageSize,
            pageNumber * pageSize
        );
        pageData = data.slice(
            (pageNumber - 1) * pageSize,
            pageNumber * pageSize
        );
        component.set('v.pageData', pageData);
        console.log(
            'Total pages is: ' +
                component.get('v.totalPages') +
                'pageNumber is: ' +
                pageNumber
        );
        if (component.get('v.totalPages') === pageNumber) {
            component.set('v.isLastPage', true);
        } else {
            component.set('v.isLastPage', false);
        }
    },

    sortData: function (cmp, fieldName, sortDirection, helper) {
        let data;
        data = cmp.get('v.data');
        helper.getPageData(cmp);
        let reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse));
        cmp.set('v.data', data);
        helper.getPageData(cmp);
    },
    sortBy: function (field, reverse, primer) {
        let key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return (
                (a = key(a) ? key(a) : ''),
                (b = key(b) ? key(b) : ''),
                reverse * ((a > b) - (b > a))
            );
        };
    }
});