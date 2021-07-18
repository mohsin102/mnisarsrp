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
    getData: function(component,event,helper){
        var action = component.get('c.getRecords');
        var recordId = component.get('v.recordId');
        action.setParams({
            recordId: recordId,
            uaId: component.get('v.suaId')
        });
        action.setCallback(this, function(response) {
            //component.set("v.Spinner", false);
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS") {
			   component.set("v.excludeRevenue", result.excludedSrpRevenue);
			   component.set("v.savedExcludeRevenue",result.excludedSrpRevenue);
                var boolCheck = true;
                result.oirList.forEach(function(record) {
                    boolCheck = false;
                    record.linkName = '/' + record.Id;
                    if(record.Owner_Entity__c!=undefined){
                    	record.ownerEntityLink =  '/' + record.Owner_Entity__c;
            			record.ownerEntityName = record.Owner_Entity__r.Name;
                    }
                });
                //component.set("v.disabled",boolCheck);
                
                component.set("v.data", result.oirList);
                component.set("v.listlength", result.oirList.length);
                component.set("v.ownerNetRevenueValue", result.ownerNetRevenueValue);
             
                
            var sortBy = component.get("v.sortedBy");
        	var sortedDirection = component.set("v.sortedDirection");
            helper.sortData(component, sortBy, sortedDirection);

            } else {
                alert(state);
            }
        });
        $A.enqueueAction(action);
    }
    
})