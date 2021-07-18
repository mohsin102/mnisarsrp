({
    handleUploadFinished : function(component, event, helper) {
        debugger;
        var uploadedFiles = event.getParam("files");
        var spin = component.find("spinner");
        var fileType = component.find('select').get('v.value');
        $A.util.removeClass(spin,'slds-hide');
        var action = component.get("c.importRecords");
        component.set('v.message','');
        action.setParams({
            "contentDocId": uploadedFiles[0].documentId,
            "fileType": fileType,
            "rcId": component.get('v.recordId'),
            "logId":null
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" ) {
                if(fileType ==='Flat'){
                    $A.util.addClass(spin,'slds-hide');
                    
                    if(response.getReturnValue().status === 'Error'){
                        component.set('v.message',response.getReturnValue().errorMessage);
                    }else{
                        component.set('v.isImporting',true);
                        component.set('v.batchJobId',response.getReturnValue().batchJobId);
                        component.set('v.totalLineItems',response.getReturnValue().totalLineItems);
                        var method = component.get('c.showBatchDetails');
                        $A.enqueueAction(method);
                    }
                }else{
                    window.location.reload();
                }
                
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Error while Importing the Line Items. Please contact the admin"
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    showBatchDetails :function(component){
        
        var spin = component.find("spinner");
        $A.util.removeClass(spin,'slds-hide');
        var action = component.get("c.getJobDetails");
        action.setParams({
            "batchJobId": component.get('v.batchJobId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state ==='SUCCESS'){
                $A.util.addClass(spin,'slds-hide');
                var result = response.getReturnValue();
                component.set('v.jobDetails',result);
                if(result.ExtendedStatus !== '' && result.ExtendedStatus !== null
                   && result.ExtendedStatus !==undefined){
                    component.set('v.overallStatus','Failed');
                    component.set('v.hasError',true);
                    component.set('v.errorMessage',result.ExtendedStatus);
                    var JobItemsProcessed = (result.JobItemsProcessed-result.NumberOfErrors)*10;
                    component.set('v.partialSuccess',JobItemsProcessed);
                }else{
                    component.set('v.overallStatus',result.Status);
                }
                if(component.get('v.overallStatus')==='Completed'){
                    window.location.reload();
                }
                var completionPercentage = ((result.JobItemsProcessed/result.TotalJobItems)*100).toFixed(0);
                if(result.JobItemsProcessed===0){
                    completionPercentage=0;
                }
                component.set('v.completion',completionPercentage);
                if(completionPercentage===100){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Import Complete"
                    });
                    toastEvent.fire();
                    window.location.reload();
                }
            }
        });
        $A.enqueueAction(action);
    }
    
})