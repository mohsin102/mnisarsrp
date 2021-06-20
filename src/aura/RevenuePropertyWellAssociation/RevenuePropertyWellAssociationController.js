({
    handleRecordUpdated: function (component, event, helper) {
        component.set('v.searchString', component.get('v.revenuePropertyRecord').propertyName__c);
        if(component.get('v.revenuePropertyRecord').api10__c ==='NONWELLITEM'){
            component.set('v.nonWellItem',true);
        }
        component.set('v.columns', [{
                label: 'Action',
                fieldName: 'add',
                type: "button",
                typeAttributes: {
                    label: {
                        fieldName: 'add'
                    },
                    name: {
                        fieldName: 'add'
                    },
                    title: 'Add',
                    disabled: false,
                    value: {
                        fieldName: 'add'
                    },
                    variant: 'base'
                }
            },
            {
                label: 'Salesforce Well Name',
                fieldName: 'Name',
                type: 'textExtended',
                editable: false,
                typeAttributes: {
                    title: {
                        fieldName: 'Name'
                    },
                    value: {
                        fieldName: 'Name'
                    }
                },
                sortable: true
            },
            {
                label: 'API10',
                fieldName: 'API10__c',
                type: 'textExtended',
                editable: false,
                sortable: true
            },
            {
                label: 'Operator Name',
                fieldName: 'Current_Operator_Name__c',
                type: 'textExtended',
                editable: false,
                sortable: true
            },
            {
                label: 'County',
                fieldName: 'County__c',
                type: 'textExtended',
                editable: false,
                sortable: true
            },
            {
                label: 'State',
                fieldName: 'State__c',
                type: 'textExtended',
                editable: false,
                sortable: true
            },
        ]);
        helper.populateDataTable(component, event, helper);
        	helper.populateSelectedValues(component,event,helper);
                                   
        

    },
    clearSearchString: function (component, event, helper) {
        var searchString = component.get('v.searchString');
        if (!searchString) {
            component.set('v.pageData', []);

        }
    },
    handleKeyUp: function (component, event, helper) {
        //console.log('keyup function called.');
        var searchString = component.get('v.searchString');
        if (searchString.length > 1) {
            helper.populateDataTable(component, event, helper);
        }
    },
    displayModal: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        var wells = component.get('v.selection');
        var hasWell = 0;
        wells.forEach(function (record) {
            if (record.Id === row.Id) {
                hasWell = 1;
            }
        });
        if (hasWell === 0) {
            wells.push(row);
        }

        component.set('v.selection', wells);
    },
    //Method fires on click of column name of the data table
    updateSorting: function (component, event, helper) {

        var fieldName = event.getParam('fieldName');
        console.log('fieldName value is: ' + fieldName);
        var sortDirection = event.getParam('sortDirection');
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection, helper);
    },
    removeItem: function (component, event, helper) {
        var rowId = event.getSource().get("v.name");
        var wells = component.get('v.selection');
        var updatedWells = [];
        var hasWell = 0;
        wells.forEach(function (record) {
            if (record.Id !== rowId) {
                updatedWells.push(record);
            }
        });
        component.set('v.selection', updatedWells);
    },
    handleNext: function (component, event, helper) {
        var pageNumber = component.get('v.pageNumber') + 1;
        component.set('v.pageNumber', pageNumber);
        helper.getPageData(component);
    },
    handlePrev: function (component, event, helper) {
        var pageNumber = component.get('v.pageNumber') - 1;
        component.set('v.pageNumber', pageNumber);
        helper.getPageData(component);
    },
    updateRevProperty: function(component,event,handler){
        var selection = component.get('v.selection');
        var wellSet = [];
        selection.forEach(function(record){
            wellSet.push(record.Id);
        });
        var action = component.get('c.updateRevenueProperty');
        
        action.setParams({ 
            'recordId': component.get('v.recordId'),
            'wellIds': wellSet,
            'isNonWellItem': component.get('v.nonWellItem')
        });
        
        action.setCallback(this, function(response){
            var responseValue = response.getReturnValue();
            //console.log('------'+responseValue);
            $A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(action);
    }
})