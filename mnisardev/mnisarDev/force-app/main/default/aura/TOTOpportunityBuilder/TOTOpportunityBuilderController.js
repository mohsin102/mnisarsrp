({
	init : function(component, event, helper) {
		 helper.getAccountID(component, event, helper); 

		component.set('v.columns', [
            {label: 'Name', fieldName: 'linkName', type: 'url', cellAttributes: { alignment: 'left' }, 
             typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'},sortable: true },
            { label: 'Acquiring Entity', fieldName: 'acquiringEntity', type: 'text', cellAttributes: { alignment: 'left' }, sortable: true },
            { label: 'Type', fieldName: 'Type', type: 'text', cellAttributes: { alignment: 'left' }, sortable: true },
            { label: 'PSA Date', fieldName: 'PSA_Date__c', type: 'date-local', cellAttributes: { alignment: 'left' }, sortable: true },
            { label: 'Close Date', fieldName: 'CloseDate', type: 'date-local', cellAttributes: { alignment: 'left' }, sortable: true },
            { label: 'Effective Date', fieldName: 'Effective_Date__c', type: 'date-local', cellAttributes: { alignment: 'left' }, sortable: true },
            { label: 'Stage Name', fieldName: 'StageName', type: 'text', cellAttributes: { alignment: 'left' }, sortable: true },
            { label: 'Total Acreage', fieldName: 'Total_Acreage__c', type: 'number', cellAttributes: { alignment: 'left' }, sortable: true },
            { label: 'Total OTG Cost', fieldName: 'Total_OTG_Cost__c', type: 'number', cellAttributes: { alignment: 'left' }, sortable: true },
            { label: 'Total Cose', fieldName: 'Total_Cost__c', type: 'number', cellAttributes: { alignment: 'left' }, sortable: true }
        ]);

		
        //component.set("v.Spinner", true);
            var action = component.get('c.getOppRecords');
            var tId= component.get('v.recordId');
            action.setParams({
            tonRecordId : tId
            });
            action.setCallback(this, function (response) {
            //component.set("v.Spinner", false);
                var state = response.getState();
                var result = response.getReturnValue();
                if (state === "SUCCESS") {
                    result.forEach(function(record){
                        record.linkName = '/'+record.Id;
                        if(record.Acquiring_Entity__r.Name!=undefined && record.Acquiring_Entity__r.Name!=null && record.Acquiring_Entity__r.Name!=''){
                        
                            record.acquiringEntity = record.Acquiring_Entity__r.Name;
                        }
                    });
                
                    component.set("v.data", result);
                }
            });
            $A.enqueueAction(action);
	},
			
    updateOppSorting: function (component, event, helper) {
		
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.oppSortedBy", fieldName);
        component.set("v.oppSortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
    },
    handleCreateOpp:function(component,event,helper){
        
		var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Opportunity",
			"defaultFieldValues": {
            'AccountId' : component.get('v.accountId')}
        });
        createRecordEvent.fire();
    },
})