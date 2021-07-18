({
    doInit: function(component, event, helper) {
        component.set('v.mycolumns', [
            {label: 'Name', fieldName: 'linkName', type: 'url', cellAttributes: { alignment: 'left' }, 
             typeAttributes: {label: { fieldName: 'Name' }, target: '_self'},sortable: true },
            { label: 'Created By', fieldName: 'CreatedBy', type: 'text', cellAttributes: { alignment: 'left' },sortable: true },
            { label: 'Created Date', fieldName: 'CreatedDate', type: 'date-local', cellAttributes: { alignment: 'left' },sortable: true },
            { label: 'Completed By', fieldName: 'CompletedBy', type: 'text', cellAttributes: { alignment: 'left' },sortable: true },
            { label: 'Completion Date', fieldName: 'Completion_Date__c', type: 'date-local', cellAttributes: { alignment: 'left' }, sortable: true }
        ]);
        //component.set("v.Spinner", true);
        var action = component.get('c.getRelatedGISUpdateRequest');
        action.setParams({
            unitId: component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            //component.set("v.Spinner", false);
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS") { 
                var boolCheck = false;
                result.forEach(function(record) {
                    record.linkName = '/' + record.Id;
                    if(record.Completed_By__c !== undefined && record.Completed_By__c !== '' && record.Completed_By__c !== null){
                        
                        record.CompletedBy = record.Completed_By__r.Name;
                    }
                    if(record.CreatedBy.Name !== undefined && record.CreatedBy.Name !== '' && record.CreatedBy.Name !== null){
                        
                        record.CreatedBy = record.CreatedBy.Name;
                    }
                    if(record.Completed_By__c === undefined || record.Completed_By__c === '' || record.Completed_By__c === null){
                        boolCheck = true;
                    }
                });
                if(result.length===0 || !boolCheck){
                    component.set('v.disabled',false);
                }else if(boolCheck){
                     component.set('v.disabled',true);
                }
              
                component.set("v.data", result);
                component.set("v.listlength", result.length);

            } else {
                alert(state);
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
       /* var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({ 
            "entityApiName": "GIS_Update_Request__c",
            "defaultFieldValues": {
            "Unit__c":component.get('v.recordId')
            }
        });
        createRecordEvent.fire();*/
        $A.createComponent("c:GIS_UpdateRequest",{"unitId":component.get("v.recordId")},
                           function(content, status) {
                               if (status === "SUCCESS") {
                                   var modalBody = content;
								   var unit = component.get("v.recordId");
								   {
										//Unit__c:unit
								   }

                                   component.find('overlayLib').showCustomModal({
                                       header: "Create GIS Update Request",
                                       body: modalBody, 
                                       showCloseButton: true,
                                       closeCallback: function(ovl) {
                                           console.log('Overlay is closing');
                                       }
                                   }).then(function(overlay){
                                       console.log("Overlay is made");
                                   });
                               }
                           });
    }
})