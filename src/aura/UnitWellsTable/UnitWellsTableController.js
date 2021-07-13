({
    doInit: function(component, event, helper) {
        component.set('v.mycolumns', [{
                label: 'Name',
                fieldName: 'linkName',
                type: 'url',
                typeAttributes: {
                    label: {
                        fieldName: 'Name'
                    },
                    target: '_self'
                },
                sortable: true,
                cellAttributes: {
                    alignment: 'left'
                }
            },
        

			 {
                label: 'Operator Account',
                fieldName: 'OperatorLink',
                type: 'url',
                typeAttributes: {
                    label: {
                        fieldName: 'OperatorName'
                    },
                    target: '_self'
                },
                sortable: true,
                cellAttributes: {
                    alignment: 'left'
                }

            },

			 {
                label: 'Original Operator',
                fieldName: 'Current_Operator_Name__c',
                type: 'text',
                sortable: true,
                cellAttributes: {
                    alignment: 'left'
                }

            },

            //{ label: 'Name', fieldName: 'Name', type: 'text', sortable: true, type: 'url', typeAttributes: {target:'_blank'}},
            //{label: 'Well', fieldName: 'linkWellName', type: 'url', 
            // typeAttributes: {label: { fieldName: 'WellName' }, target: '_blank'},sortable: true },
            //{ label: 'Well', fieldName: 'WellName', type: 'text', sortable: true },
            {
                label: 'Type',
                fieldName: 'Type__c',
                type: 'text',
                sortable: true,
                cellAttributes: {
                    alignment: 'left'
                }
            },
            {
                label: 'Total Depth',
                fieldName: 'Total_Depth__c',
                type: 'number',
                cellAttributes: {
                    alignment: 'left'
                },
                sortable: true
            },
        ]);
        //component.set("v.Spinner", true);
        var action = component.get('c.getAllWellUnits');
        var accId = component.get('v.recordId');
        action.setParams({
            acId: accId
        });
        action.setCallback(this, function(response) {
            //component.set("v.Spinner", false);
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS") {
                result.forEach(function(record) {
                    record.linkName = '/' + record.Id;
                    if (record.Current_Operator__c != undefined) {
                                      
                        record.OperatorName = record.Current_Operator__r.Name;
                        record.OperatorLink = '/' + record.Current_Operator__c;
                    }
                    //record.linkWellName = '/'+record.Well__c;
                    //if (record.Well__c) record.WellName = record.Well__r.Name;
                });
                component.set("v.unitsList", result);
                component.set("v.unitsListlength", result.length);

            }
        });
        $A.enqueueAction(action);
    },
    handleSort: function(component, event, helper) {
        var sortBy = event.getParam("fieldName");
        var sortDirection = event.getParam("sortDirection");
        component.set("v.sortBy", sortBy);
        component.set("v.sortDirection", sortDirection);
        helper.sortData(component, sortBy, sortDirection);
    },

})