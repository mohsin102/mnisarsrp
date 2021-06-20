({
    //Mehod to set columns for data table
    getColumnAndAction : function(component) {
        
        component.set('v.columns', [
            {label: 'Property Name', fieldName: 'name', type: "button",
                typeAttributes: {label: {fieldName: 'name'}, 
                name: {fieldName: 'name'}, title: 'Associate Line Item with Well', disabled: false,
                value: {fieldName: 'name'}, variant: 'base' }, sortable: true},
            {label: 'Well Name', fieldName: 'wellName', type: 'textExtended', 
                editable: false, typeAttributes:{title:{ fieldName: 'wellName' }, 
                value:{ fieldName: 'wellName' }}, sortable: true},
            {label: '# Royalty Line Items', fieldName: 'numberOfLineItems' , type: 'numberExtended', 
                editable: false, typeAttributes:{title:{ fieldName: 'numberOfLineItems' }, 
                value:{ fieldName: 'numberOfLineItems' }, className:'alignCenter'}, sortable: true, 
                initialWidth:150, cellAttributes:{alignment: 'center'}}
        ]);
    },
    
    //Method to fetch royalty line items based on the Royalty Check Id
    getData : function(component, helper,fieldName,sortDirection) {
        var action = component.get("c.getRecordsForAssociation");
        
        action.setParams({
            'rcId':component.get('v.recordId')
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") { 
                var resultData = response.getReturnValue();
                component.set("v.data", resultData);
                component.set("v.payorName",resultData[0].payorName);
                component.set("v.payorAccName",resultData[0].payorAccName);
                
                
            }
        });
        $A.enqueueAction(action);
    },
    
    //Method to sort data on Data table
    sortData: function (component, fieldName, sortDirection,helper) {
        var data = component.get("v.data");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse))
        component.set("v.data", data);
        //helper.getPageData(component);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a)?key(a):'', b = key(b)?key(b):'', reverse * ((a > b) - (b > a));
        }
    },

	 getPageData:function  (component){
        var pageNumber = component.get('v.pageNumber')
        var data = component.get('v.data');
        var pageSize = component.get('v.pageSize');
        var pageData= data.slice((pageNumber - 1) * pageSize, pageNumber * pageSize);
        pageData = data.slice((pageNumber - 1) * pageSize, pageNumber * pageSize);
        component.set('v.pageData',pageData);
        if(component.get('v.totalPages') === pageNumber){
            component.set('v.isLastPage',true);
        }
    }
})