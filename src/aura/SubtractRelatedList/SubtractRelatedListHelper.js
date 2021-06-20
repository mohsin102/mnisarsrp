({
    sortData : function(component,fieldName,sortDirection){
        var data = component.get("v.subtractList");
        var key = function(a) { return a[fieldName]; }
        var reverse = sortDirection == 'asc' ? 1: -1;
        
        // to handel number/currency type fields 
        if(fieldName == 'Subtract_Gross_Acres__c' || fieldName == 'Subtract_NRI__c'|| fieldName == 'Instrument__c'|| fieldName == 'Instrument_Lease_Royalty__c'){ 
            data.sort(function(a,b){
                var a = key(a) ? key(a) : '';
                var b = key(b) ? key(b) : '';
                return reverse * ((a>b) - (b>a));
            }); 
        }
        else{
            data.sort(function(a,b){ 
                var a = key(a) ? key(a).toLowerCase() : '';//To handle null values , uppercase records during sorting
                var b = key(b) ? key(b).toLowerCase() : '';
                return reverse * ((a>b) - (b>a));
            });    
        }
        component.set("v.subtractList",data);
    }
    
})