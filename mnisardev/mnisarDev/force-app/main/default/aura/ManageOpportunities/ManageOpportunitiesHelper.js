({
    getOpportunitiesByOpportunityId: function (component, event, helper) {

        let action = component.get('c.getOpportunitySearchResults');
        
        action.setParams({
            oppIds: component.get('v.opportunityIds'),
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