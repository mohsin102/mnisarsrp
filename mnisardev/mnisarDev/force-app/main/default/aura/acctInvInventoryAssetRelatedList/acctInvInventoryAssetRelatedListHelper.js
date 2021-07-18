({
	sortData: function (component, fieldName, sortedDirection) {
        var data = component.get("v.data");
        var reverse = sortedDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        console.log('---11---'+sortedDirection);
        data.sort(this.sortBy(fieldName, reverse))
        component.set("v.data", data);
    },
    sortBy: function (field, reverse, primer) {
        console.log('---2---'+reverse);
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a)?key(a):'', b = key(b)?key(b):'', reverse * ((a > b) - (b > a));
        }
	},
	getData: function (component){
        component.set('v.mycolumns', [
            {label: 'Inventory Asset', fieldName: 'link', type: 'url', cellAttributes: { alignment: 'left' }, 
                    typeAttributes: {label: { fieldName: 'Name' }, tooltip:{fieldName: 'Name'}, target: '_self'},sortable: true, initialWidth: 150 },
            {label: 'Inventory Owner', fieldName: 'ownerLink', type: 'url', cellAttributes: { alignment: 'left' }, 
                    typeAttributes: {label: { fieldName: 'inventoryOwnerName__c' }, tooltip:{fieldName: 'inventoryOwnerName__c'}, target: '_self'},sortable: true, initialWidth: 200 },
            { label: 'Acq Close Date', fieldName: 'acquistionCloseDate__c', type: 'date-local', sortable: true, initialWidth: 150},
			{ label: 'Acq Effective Date', fieldName: 'acquisitionEffectiveDate__c', type: 'date-local', sortable: true, initialWidth: 150 },
			{label: 'Acq Opportunity', fieldName: 'acquisitionOpportunityLink', type: 'url', cellAttributes: { alignment: 'left' }, 
                    typeAttributes: {label: { fieldName: 'acquisitionOpportunityName__c' }, tooltip:{fieldName: 'acquisitionOpportunityName__c'}, target: '_self'},sortable: true, initialWidth: 250 },
            { label: 'Acq Unit Price', fieldName: 'acquisitionUnitPrice__c', type: 'currency', cellAttributes: { alignment: 'left' }, sortable: true, initialWidth: 150 },
			{ label: 'Acq Total Price', fieldName: 'acquisitionTotalPrice__c', type: 'currency', cellAttributes: { alignment: 'left' }, sortable: true, initialWidth: 150 },
			{label: 'Seller (Previous Owner)', fieldName: 'sellerLink', type: 'url', cellAttributes: { alignment: 'left' }, 
                    typeAttributes: {label: { fieldName: 'sellerPreviousOwnerName__c' }, tooltip:{fieldName: 'sellerPreviousOwnerName__c'}, target: '_self'},sortable: true, initialWidth: 250 },

            { label: 'Sale Close Date', fieldName: 'saleCloseDate__c', type: 'date-local', sortable: true, initialWidth: 150 },
			{ label: 'Sale Effective Date', fieldName: 'saleEffectiveDate__c', type: 'date-local', sortable: true, initialWidth: 150 },
			{label: 'Sale Opportunity', fieldName: 'saleOpportunityLink', type: 'url', cellAttributes: { alignment: 'left' }, 
                    typeAttributes: {label: { fieldName: 'saleOpportunityName__c' }, tooltip:{fieldName: 'saleOpportunityName__c'}, target: '_self'},sortable: true, initialWidth: 250 },
            { label: 'Sale Unit Price', fieldName: 'saleUnitPrice__c', type: 'currency', cellAttributes: { alignment: 'left' }, sortable: true, initialWidth: 150 },
			{ label: 'Sale Total Price', fieldName: 'saleTotalPrice__c', type: 'currency', cellAttributes: { alignment: 'left' }, sortable: true, initialWidth: 150 },
			{label: 'Buyer (Next Owner)', fieldName: 'buyerLink', type: 'url', cellAttributes: { alignment: 'left' }, 
                    typeAttributes: {label: { fieldName: 'buyerNextOwnerName__c' }, tooltip:{fieldName: 'buyerNextOwnerName__c'}, target: '_self'},sortable: true, initialWidth: 250 },
			
        ]);
        var action = component.get('c.getInventoryAssets');
        var recordId = component.get('v.recordId'); 
        action.setParams({
            recordId: recordId
        });
        action.setCallback(this, function(response) {
            //component.set("v.Spinner", false);
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS") {
                result.forEach(function(record) {
					record.link =  '/' + record.Id;
					record.ownerLink = record.inventoryOwnerId__c?'/' + record.inventoryOwnerId__c:''; 
					record.acquisitionOpportunityLink = record.acquisitionOpportunityId__c?'/' + record.acquisitionOpportunityId__c:'';
					record.saleOpportunityLink = record.saleOpportunityId__c?'/' + record.saleOpportunityId__c:'';
					record.sellerLink = record.sellerPreviousOwnerId__c?'/' + record.sellerPreviousOwnerId__c:'';
					record.buyerLink = record.buyerNextOwnerId__c?'/' + record.buyerNextOwnerId__c:'';
                    /*record.otLink = '/' + record.Id;
                    if(record.Opportunity__c != undefined && record.Opportunity__c != null){
                        record.oppName = record.Opportunity__r.Name;
                        record.oppLink = '/' + record.Opportunity__c;
                        record.closeDate = record.Opportunity__r.CloseDate;
                    }
                    if(record.Tract__c != undefined && record.Tract__c != null){
                        record.tractLink = '/' + record.Tract__c;
                        record.tractName = record.Tract__r.Name;
                    }*/
                });
                component.set("v.data", result);
                
            }
        });
            $A.enqueueAction(action);
    }
})