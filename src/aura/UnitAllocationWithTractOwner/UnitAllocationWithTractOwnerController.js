({
    doInit : function(component, event, helper) {
        
        component.set('v.columns', [{
            label: 'Tract Owner',
            fieldName: 'ownerLink',
            type: 'url',
            typeAttributes: {
                label: {
                    fieldName: 'ownerName'
                },
                target: '_self'
            },
            cellAttributes: {
                alignment: 'left'
            }
        },{
            label: 'Total Unit Allocations',
            fieldName: 'count',
            type: 'String',
            cellAttributes: {
                alignment: 'left'
            }
        }
                                   ]);
        
        var action = component.get('c.getUAwithTractOwner');
        action.setParams({
            recordId: component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            //component.set("v.Spinner", false);
            var state = response.getState();
            var result = response.getReturnValue();
            
            if (state === "SUCCESS") {
                result.forEach(function(record) {
                    
                    record.ownerLink = '/' + record.ownerId;
                    component.set("v.url",record.reportURL);
                });
                component.set("v.data",response.getReturnValue());
                
                
            }
        });
        $A.enqueueAction(action);
    }
})