({
    getColumnAndAction : function(component) {
        var actions = [
            {label: 'Delete', name: 'delete'}
        ];
        component.set('v.columns', [
            {label: 'Name', fieldName: 'Name', type: "button",
                typeAttributes: {label: {fieldName: 'Name'}, 
                name: {fieldName: 'Name'}, title: 'Open RLI', disabled: false,
                value: {fieldName: 'name'}, variant: 'base', initialWidth: 200 }, sortable: true},
            {label: 'Property Name', fieldName: 'propertyName__c', type: 'string',sortable: true},
            //{label: 'Property Name', fieldName: 'linkProperty', type: 'url',sortable: true, 
             //typeAttributes: {label: { fieldName: 'propertyName__c' }, target: '_blank'}, initialWidth: 300 },
            {label: 'Well Name', fieldName: 'wellNames__c', type: 'string',sortable: true},
            {label: 'Production Month', fieldName: 'production_Month__c', type: 'date-local',cellAttributes: { alignment: 'center' },sortable: true},
            {label: 'Product Category', fieldName: 'product_Category__c', type: 'string',sortable: true},
            {label: 'Line Item Decimal', fieldName: 'lineItemDecimal__c', type: 'number', typeAttributes: { minimumFractionDigits : '8' }, cellAttributes: { alignment: 'right' }},
           	{label: 'Gross Volume', fieldName: 'grossVolumeActual__c', type: 'number',cellAttributes: { alignment: 'right' }},
            {label: 'Gross Value', fieldName: 'grossValueActual__c', type: 'currency', typeAttributes: { currencyCode: 'USD'},cellAttributes: { alignment: 'right' }},
            {label: 'Gross Taxes', fieldName: 'grossTaxesActual__c', type: 'currency', typeAttributes: { currencyCode: 'USD'},cellAttributes: { alignment: 'right' }},
            {label: 'Gross Adjustment', fieldName: 'grossAdjustmentsActual__c',  type: 'currency', typeAttributes: { currencyCode: 'USD'},cellAttributes: { alignment: 'right' }},
            {label: 'Line Item Net Value', fieldName: 'ownerNetValueActual__c',  type: 'currency', typeAttributes: { currencyCode: 'USD'},cellAttributes: { alignment: 'right' },sortable: true},
            {label: 'Revenue Allocated', fieldName: 'revenueAllocated__c', cellAttributes: { alignment: 'center' }, type: 'boolean',sortable: true},
            {label: ' ', type: 'action', typeAttributes: { rowActions: actions } }
        ]);
    },
	getFilteredData : function(component, helper) {
        var action = component.get("c.getFilteredRecords");
        var pageSize = '10';
        var pageNumber = '1';
        if(component.get("v.pageSize")!=undefined){
            pageSize = component.get("v.pageSize").toString();
        }
        if(component.get("v.pageNumber")!=undefined){
            pageNumber = component.get("v.pageNumber").toString();
        }
		var fieldName = component.get('v.sortBy');
		var sortDirection = component.get('v.sortDirection');
		var searchString = component.get('v.searchString');
		var searchCounter = component.get('v.searchCounter');
        action.setParams({
            'rcId':component.get('v.recordId'),
            'pageSize' : pageSize,
            'pageNum' : pageNumber,
            'fieldName' : fieldName,
            'sortDirection': sortDirection,
			'searchTerm': searchString,
			'searchCounter':searchCounter
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
				if(component.get('v.searchCounter') == response.getReturnValue().searchCounter){
					var resultData = response.getReturnValue().royaltyLineItems;
				
					component.set("v.totalPages",response.getReturnValue().totalPages);
					//component.set("v.totalRevenueAllocated",response.getReturnValue().totalRevenueAllocated);
					component.set("v.totalLineItems",response.getReturnValue().totalLineItems);
					component.set("v.totalAllocatedLineItems",response.getReturnValue().totalAllocatedLineItems);
					if(resultData.length < component.get("v.pageSize")){
						component.set("v.isLastPage", true);
					} else{
						component.set("v.isLastPage", false);
					}
					component.set("v.dataSize", resultData.length);
                
					resultData.forEach(function(record){
								record.link = '/'+record.Id;
						if(record.Well__c!==undefined &&record.Well__c!==null && record.Well__c!==''){
             					record.linkProperty = '/'+record.Well__c;
            					if (record.Well__c) record.PropertyName = record.Well__r.Name;
						}
							});
					component.set("v.data", resultData);
					component.set('v.isWaiting', false);
                }
                
            }
        });
        $A.enqueueAction(action);
    },
    
    getData : function(component, helper,fieldName,sortDirection) {
        var searchString = component.get('v.searchString');
        if(searchString.length > 1){
			helper.getFilteredData(component, helper);
		}
		else{
			var action = component.get("c.getRecords");
			var pageSize = '10';
			var pageNumber = '1';
			if(component.get("v.pageSize")!=undefined){
				pageSize = component.get("v.pageSize").toString();
			}
			if(component.get("v.pageNumber")!=undefined){
				pageNumber = component.get("v.pageNumber").toString();
			}
			action.setParams({
				'rcId':component.get('v.recordId'),
				'pageSize' : pageSize,
				'pageNum' : pageNumber,
				'fieldName' : fieldName,
				'sortDirection': sortDirection
			});
			action.setCallback(this,function(response) {
				var state = response.getState();
            
				if (state === "SUCCESS") {
					var resultData = response.getReturnValue().royaltyLineItems;
					component.set("v.totalPages",response.getReturnValue().totalPages);
					component.set("v.totalRevenueAllocated",response.getReturnValue().totalRevenueAllocated);
					component.set("v.totalLineItems",response.getReturnValue().totalLineItems);
					component.set("v.totalAllocatedLineItems",response.getReturnValue().totalAllocatedLineItems);
					if(resultData.length < component.get("v.pageSize")){
						component.set("v.isLastPage", true);
					} else{
						component.set("v.isLastPage", false);
					}
					component.set("v.dataSize", resultData.length);
                
					resultData.forEach(function(record){
								record.link = '/'+record.Id;
						if(record.Well__c!==undefined &&record.Well__c!==null && record.Well__c!==''){
             					record.linkProperty = '/'+record.Well__c;
            					if (record.Well__c) record.PropertyName = record.Well__r.Name;
						}
							});
					component.set("v.data", resultData);
					component.set('v.isWaiting', false);
                
				}
			});
			$A.enqueueAction(action);
		}
    },
    showUpdateWir: function(component,row){
        
    },
    deleteLIRec : function(component,row,helper){
        var action = component.get('c.deleteLineItem');
        action.setParams({
            'liId':row.Id
        });
        action.setCallback(this,function(response) {
            var state = response.getState();                    
            if (state === "SUCCESS") {
                helper.getData(component, helper);
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    },
    sortData : function(component,fieldName,sortDirection){
        var data = component.get("v.data");
        //function to return the value stored in the field
        var key = function(a) { return a[fieldName]; }
        var reverse = sortDirection == 'asc' ? 1: -1;
        
        // to handel number/currency type fields 
        if(fieldName == 'ownerNetValueActual__c'||fieldName =='production_Month__c'){ 
            data.sort(function(a,b){
                var a = key(a) ? key(a) : '';
                var b = key(b) ? key(b) : '';
                return reverse * ((a>b) - (b>a));
            }); 
        }
        if(fieldName == 'link'){
            var key = function(a) { return a['Name']; }
            data.sort(function(a,b){ 
                var a = key(a) ? key(a).toLowerCase() : '';//To handle null values , uppercase records during sorting
                var b = key(b) ? key(b).toLowerCase() : '';
                return reverse * ((a>b) - (b>a));
            });
        }
        if(fieldName == 'linkProperty'){
            var key = function(a) { return a['PropertyName']; }
            data.sort(function(a,b){ 
                var a = key(a) ? key(a).toLowerCase() : '';//To handle null values , uppercase records during sorting
                var b = key(b) ? key(b).toLowerCase() : '';
                return reverse * ((a>b) - (b>a));
            });//Product_Category__c
        }
        if(fieldName == 'product_Category__c'){
            data.sort(function(a,b){ 
                var a = key(a) ? key(a).toLowerCase() : '';//To handle null values , uppercase records during sorting
                var b = key(b) ? key(b).toLowerCase() : '';
                return reverse * ((a>b) - (b>a));
            });
        }
        if(fieldName == 'revenueAllocated__c'){
            data.sort(function(a,b){ 
                if(reverse===-1){
                    return (key(a) === key(b))? 1 : key(a)? 1 : -1;
                }else{
                    return (key(a) === key(b))? 1 : key(a)? -1 : 1;
                }
            });
        }
        component.set("v.data",data);
    }
})