({
    sortData : function(component,fieldName,sortDirection){
        var data = component.get("v.wellInterstList");
        var key = function(a) { return a[fieldName]; }
        var reverse = sortDirection == 'asc' ? 1: -1;
        
        // to handel number/currency type fields 
        if(fieldName == 'Allocation_Factor_Computed__c' || fieldName == 'Well_Interest_NRI__c' || fieldName=='Total_Revenue_Calc__c' || fieldName=='Est_Gas_Revenue__c' || fieldName=='Est_Oil_Revenue__c'||fieldName=='Monthly_Production__c'){ 
            data.sort(function(a,b){
                var a = key(a) ? key(a) : '';
                var b = key(b) ? key(b) : '';
                return reverse * ((a>b) - (b>a));
            }); 
        }else if(fieldName=='SRP_Owned__c'){
           data.sort(function(a,b){ 
                if(reverse===-1){
                    return (key(a) === key(b))? 1 : key(a)? 1 : -1;
                }else{
                    return (key(a) === key(b))? 1 : key(a)? -1 : 1;
                }
            }); 
        }
        else{
            data.sort(function(a,b){ 
                var a = key(a) ? key(a).toLowerCase() : '';//To handle null values , uppercase records during sorting
                var b = key(b) ? key(b).toLowerCase() : '';
                return reverse * ((a>b) - (b>a));
            });    
        }
        component.set("v.wellInterstList",data);
    }
    
})