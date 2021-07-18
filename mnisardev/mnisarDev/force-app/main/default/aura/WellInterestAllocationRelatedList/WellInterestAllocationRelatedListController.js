({
    doInit : function(component, event, helper) {
        //var style="height:"+component.get("v.height")+"px;width:"+component.get("v.width")+"px;";
       // alert(style);
        //component.set("v.styl", style);
        component.set('v.mycolumns', [
            {label: 'Name', fieldName: 'linkName', type: 'url', cellAttributes: { alignment: 'left' }, 
            typeAttributes: {label: { fieldName: 'Name' }, target: '_self'}, cellAttributes: { alignment: 'left' },sortable: true },
            //{ label: 'Name', fieldName: 'Name', type: 'text', sortable: true, type: 'url', typeAttributes: {target:'_blank'}},
            {label: 'Well', fieldName: 'linkWellName', type: 'url', 
            typeAttributes: {label: { fieldName: 'WellName' }, target: '_self'}, cellAttributes: { alignment: 'left' },sortable: true },
            //{ label: 'Well', fieldName: 'WellName', type: 'text', sortable: true },
            { label: 'Allocation Factor Computed', fieldName: 'Allocation_Factor_Computed__c', type: 'number', typeAttributes: { minimumFractionDigits : '8' }, sortable: true, cellAttributes: { alignment: 'left'}},
            { label: 'Well Interest NRI', fieldName: 'Well_Interest_NRI__c', type: 'number', typeAttributes: { minimumFractionDigits : '8' }, sortable: true , cellAttributes: { alignment: 'left' } },
        ]);
                //component.set("v.Spinner", true);
                var action = component.get('c.getAllWellInterestAllocations');
                
                 action.setParams({
            'lineItem':component.get('v.recordId')
        });
                action.setCallback(this, function (response) {
                   //component.set("v.Spinner", false);
                    var state = response.getState();
                    var result = response.getReturnValue();
                    if (state === "SUCCESS") {
                        result.forEach(function(record){
                            record.linkName = '/'+record.Id;
             				record.linkWellName = '/'+record.Well__c;
            				if (record.Well__c) record.WellName = record.Well__r.Name;
                        });
                        component.set("v.wellInterstList", result);
            			component.set("v.WellListlength", result.length);
            
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