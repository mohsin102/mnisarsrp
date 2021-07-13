({
    doInit : function(component, event, helper) {
        component.set('v.mycolumns', [
            {label: 'Name', fieldName: 'linkName', type: 'url', 
            typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'},sortable: true },
            { label: 'Account Name', fieldName: 'Account_Name__c', type: 'text', sortable: true },
            { label: 'OTG Cost', fieldName: 'OTG_Cost__c', type: 'number', cellAttributes: { alignment: 'left' }, sortable: true },
            {label: 'Tract', fieldName: 'tractLink', type: 'url', 
            typeAttributes: {label: { fieldName: 'tractName' }, target: '_blank'},sortable: true }
        ]);
                //component.set("v.Spinner", true);
                var action = component.get('c.getOppTracts');
                var oId= component.get('v.recordId');
                action.setParams({
                    oppId : oId
                });
                action.setCallback(this, function (response) {
                   //component.set("v.Spinner", false);
                    var state = response.getState();
                    var result = response.getReturnValue();
                    if (state === "SUCCESS") {
                        result.forEach(function(record){
                            record.linkName = '/'+record.Id;
                            record.tractLink='/'+record.Tract__c;
                            record.tractName=record.Tract__r.Name;
                        });
                        component.set("v.oppTractList", result);
            			component.set("v.oppTractListlength", result.length);
            
                        }else{
                          alert(state);
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
    createNewOppTract :function(component,event,helper){
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Opportunity_Tract__c",
            "defaultFieldValues": {
                'Opportunity__c' : component.get('v.recordId')
            }
        });
        createRecordEvent.fire();
    }

})