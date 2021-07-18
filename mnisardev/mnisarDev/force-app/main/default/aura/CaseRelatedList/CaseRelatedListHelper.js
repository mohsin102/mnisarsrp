({
    // sortData : function(component,fieldName,sortDirection){
    //     var data = component.get("v.data");
    //     var key = function(a) { return a[fieldName]; }
    //     var reverse = sortDirection == 'asc' ? 1: -1;
        
    //     // to handel number/currency type fields 
    //     if(fieldName == 'Allocation_Factor_Computed__c' || fieldName == 'Well_Interest_NRI__c'){ 
    //         data.sort(function(a,b){
    //             var a = key(a) ? key(a) : '';
    //             var b = key(b) ? key(b) : '';
    //             return reverse * ((a>b) - (b>a));
    //         }); 
    //     }
    //     else{
    //         data.sort(function(a,b){ 
    //             var a = key(a) ? key(a).toLowerCase() : '';//To handle null values , uppercase records during sorting
    //             var b = key(b) ? key(b).toLowerCase() : '';
    //             return reverse * ((a>b) - (b>a));
    //         });    
    //     }
    //     component.set("v.data",data);
    // },

    handleGetCases : function(component){
        var action = component.get('c.getCases');

        action.setParams({
            recordId: component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            //component.set("v.Spinner", false);
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === 'SUCCESS') {
                var caseList = result;

				if(caseList.length>10){
                    var scrollerDiv = component.find("scrollerDiv");
                    $A.util.addClass(scrollerDiv, 'maxHeight');
                }

                caseList.forEach(function (record) {
                    console.log(record);
                    record.linkName = '/' + record.Id;
                    record.ownerLink = '/' + record.case__r.Owner.Id;
					record.ownerId = record.case__r.Owner.Id;

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
            }
        });
        $A.enqueueAction(action);
    }
    
})