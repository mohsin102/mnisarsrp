({
    doInit : function(component, event, helper) {
        component.set('v.mycolumns', [
            {label: 'Name', fieldName: 'linkName', type: 'url', 
            typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'},sortable: true },
            //{ label: 'Name', fieldName: 'Name', type: 'text', sortable: true, type: 'url', typeAttributes: {target:'_blank'}},
            //{label: 'Well', fieldName: 'linkWellName', type: 'url', 
           // typeAttributes: {label: { fieldName: 'WellName' }, target: '_blank'},sortable: true },
            //{ label: 'Well', fieldName: 'WellName', type: 'text', sortable: true },
            { label: 'Operator Name', fieldName: 'Operator_Name__c', type: 'text', sortable: true },
            //{ label: 'Block Township', fieldName: 'Block_Township__c', type: 'text', sortable: true },
			//{ label: 'SRP Status', fieldName: 'SRP_Status__c', type: 'text', sortable: true },
        ]);
                //component.set("v.Spinner", true);
                var action = component.get('c.getAllAccountsTracts');
                var accId= component.get('v.recordId');
                action.setParams({
                    accID : accId
                });
                action.setCallback(this, function (response) {
                   //component.set("v.Spinner", false);
                    var state = response.getState();
                    var result = response.getReturnValue();
                    if (state === "SUCCESS") {
                        result.forEach(function(record){
                            record.linkName = '/'+record.Id;
             				//record.linkWellName = '/'+record.Well__c;
            				//if (record.Well__c) record.WellName = record.Well__r.Name;
                        });
                        component.set("v.tractsList", result);
            			component.set("v.tractListlength", result.length);
            
                        } 
                });
                $A.enqueueAction(action);
    },
    handleSort : function(component,event,helper){
        var sortBy = event.getParam("fieldName");
        var sortDirection = event.getParam("sortDirection");
        component.set("v.sortBy",sortBy);
        component.set("v.sortDirection",sortDirection);
        helper.sortData(component,sortBy,sortDirection);
    },

})