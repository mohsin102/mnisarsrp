({
    handleRecordLoad: function(component, event, helper) {
        component.set('v.mycolumns', [
            { label: 'API10', fieldName: 'api10', type: 'text', cellAttributes: { alignment: 'left' },sortable: true },
            {label: 'Operator', fieldName: 'operatorName', type: 'text', cellAttributes: { alignment: 'left' }, 
             typeAttributes: {label: { fieldName: 'operatorName' }, target: '_self'},sortable: true },
            { label: 'Well Status', fieldName: 'wellStatus', type: 'text', cellAttributes: { alignment: 'left' }, sortable: true },
			{ label: 'Split Percent', fieldName: 'splitPercent', type: 'number', cellAttributes: { alignment: 'left' }, sortable: true }
        ]);
        //component.set("v.Spinner", true);
        var action = component.get('c.getWellList');
        action.setParams({
            recordId:component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            //component.set("v.Spinner", false);
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS") { 
                
                result.forEach(function(record) {	
                   /* if(record.well.Current_Operator__c !== undefined && record.well.Current_Operator__c !== '' && record.well.Current_Operator__c !== null){
                        record.operatorLink = '/' + record.well.Current_Operator_Name__c;
                        record.operatorName = record.well.Current_Operator__r.Name;
						
                    }*/
                    record.operatorName = record.well.Current_Operator_Name__c;
                    record.api10 = record.well.API10__c;
					record.wellStatus = record.well.wellStatus__c;
                    
                });
              
                component.set("v.data", result);
                component.set("v.listlength", result.length);

            } else {
                component.set('v.error',true);
            }
        });
        $A.enqueueAction(action);
    },
    handleSort: function(component, event, helper) {
        var sortBy = event.getParam("fieldName");
        var sortedDirection = event.getParam("sortDirection");
        component.set("v.sortedBy", sortBy);
        component.set("v.sortedDirection", sortedDirection);
        helper.sortData(component, sortBy, sortedDirection);
        
    },
    createNew: function(component,event,helper){
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({ 
            "entityApiName": "GIS_Update_Request__c",
            "defaultFieldValues": {
            "Unit__c":component.get('v.recordId')
            }
        });
        createRecordEvent.fire();
    }
})