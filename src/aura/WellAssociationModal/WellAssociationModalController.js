({
    //Method fires on load of componenet. If Royalty Line Items are associated, List of RLI related to the Property name are displayed in a table,
    // else a search bar is displayed to search for the correct Well within salesforce and associate it.
    init : function(component, event, helper) {
        component.set('v.searchString',component.get('v.propertyName'));
        if(component.get('v.isAssociated')===false){
            component.set('v.columns', [
                {label: 'Action', fieldName: 'add', type: "button",
                 typeAttributes: {label: {fieldName: 'add'}, 
                                  name: {fieldName: 'add'}, title: 'Add', disabled: false,
                                  value: {fieldName: 'add'}, variant: 'base' }},
                {label: 'Salesforce Well Name', fieldName: 'Name', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'Name' }, value:{ fieldName: 'Name' }}, sortable: true},
                {label: 'API10', fieldName: 'API10__c', type: 'textExtended', editable: false, sortable: true},
                {label: 'Operator Name', fieldName: 'Current_Operator_Name__c', type: 'textExtended', editable: false, sortable: true},
                {label: 'County', fieldName: 'County__c', type: 'textExtended', editable: false, sortable: true},
                {label: 'State', fieldName: 'State__c', type: 'textExtended', editable: false, sortable: true},
            ]);
                
                helper.populateDataTable(component, event,helper);
                }else{
                component.set('v.rliColumns', [
                {label: 'Name', fieldName: 'link', type: 'url',sortable: true,
                typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
                {label: 'Property Name', fieldName: 'propertyName__c', type: 'string',sortable: true},
                {label: 'Well Name', fieldName: 'linkProperty', type: 'url',sortable: true, 
                typeAttributes: {label: { fieldName: 'PropertyName' }, target: '_blank'}},
                {label: 'Property ID', fieldName: 'Property_Id__c', type: 'string',sortable: true},
                {label: 'Production Month', fieldName: 'Production_Month__c', type: 'date-local',cellAttributes: { alignment: 'left' },sortable: true},
                {label: 'Product Category', fieldName: 'Product_Category__c', type: 'string',sortable: true},
                {label: 'Line Item Decimal', fieldName: 'Line_Item_Decimal__c', type: 'number', typeAttributes: { minimumFractionDigits : '8' }, cellAttributes: { alignment: 'left' }},
                {label: 'Gross Value', fieldName: 'grossValueActual__c', type: 'currency', typeAttributes: { currencyCode: 'USD'},cellAttributes: { alignment: 'left' }},
                {label: 'Gross Taxes', fieldName: 'grossTaxesActual__c', type: 'currency', typeAttributes: { currencyCode: 'USD'},cellAttributes: { alignment: 'left' }},
                {label: 'Gross Adjustment', fieldName: 'grossAdjustmentsActual__c',  type: 'currency', typeAttributes: { currencyCode: 'USD'},cellAttributes: { alignment: 'left' }},
                {label: 'Line Item Net Value', fieldName: 'ownerNetValueActual__c',  type: 'currency', typeAttributes: { currencyCode: 'USD'},cellAttributes: { alignment: 'left' },sortable: true},
                {label: 'Revenue Allocated', fieldName: 'Revenue_Allocated__c', type: 'boolean',sortable: true}
            ]);
            helper.populateRLIDataTable(component, event);
        }
    },
    //Method fires on click of cancel button.
    handleCancel: function (component, event, helper) {
        
        console.log('Inside if');
        var navService = component.find("navService");
        // Sets the route to /lightning/o/Account/home
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                objectApiName: 'Royalty_Check__c',
                actionName: 'view',
                recordId: component.get('v.rcid')
            }
        };
        //console.log(pageReference);
        component.set("v.pageReference", pageReference);
        // Set the URL on the link or use the default if there's an error
        var defaultUrl = "#";
        navService.generateUrl(pageReference)
        .then($A.getCallback(function(url) {
            component.set("v.url", url ? url : defaultUrl);
        }), $A.getCallback(function(error) {
            component.set("v.url", defaultUrl);
        }));
        event.preventDefault();
        navService.navigate(pageReference);
        
        component.destroy();
    },
    //Method fires on change of value of the search string, to fetch Well Name based on the search string
    handleKeyUp: function(component, event, helper){
        //console.log('keyup function called.');
        var searchString = component.get('v.searchString');
        if(searchString.length > 1){
            helper.populateDataTable(component, event,helper);
        }	
    },
    //Method fires on click of column name of the data table
    updateSorting: function (component, event, helper) {
        
        var fieldName = event.getParam('fieldName');
        console.log('fieldName value is: ' + fieldName);
        var sortDirection = event.getParam('sortDirection');
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection,helper);
    },
    //Mwthod fires on click of x button on the search bar. 
    clearSearchString: function(component, event, helper){
        var searchString = component.get('v.searchString');
        if(!searchString){
            component.set('v.pageData', []);

        }
    }, 
    //Method fires on click of Associate button. to associate Well Id with the Royalty Line Item using a server side action.
    handleSave: function(component, event, helper){
        var selection = component.get('v.selection');
        var wellSet = [];
        selection.forEach(function(record){
            wellSet.push(record.Id);
        });
        var action = component.get("c.associateWells");
        
        action.setParams({ 
            'wellIds': wellSet,
            'propertyName': component.get('v.propertyName'),
            'rliIds': component.get('v.rliIds'),
            'isNonWellItem':component.get('v.nonWellItem')
        });
        
        action.setCallback(this, function(response){
            var responseValue = response.getReturnValue();
            var cmpEvent = component.getEvent("mdlEvent");
            cmpEvent.fire();
            component.destroy();
        });
        $A.enqueueAction(action);
    },
    displayModal: function(component, event, helper){
        var action = event.getParam('action');
        var row = event.getParam('row');
        var wells = component.get('v.selection');
        var hasWell = 0;
        wells.forEach(function(record){
            if(record.Id === row.Id){
            hasWell = 1;
            }
        });
        if(hasWell===0){
            wells.push(row);
        }

        component.set('v.selection',wells);
    },
    handleRemove:function(component,event,helper){
        var selectedItem = event.target.id; // Get the target object
    },
    handleNext: function(component,event,helper){
        var pageNumber = component.get('v.pageNumber')+1;
        component.set('v.pageNumber',pageNumber);
        helper.getPageData(component);
    },
    handlePrev: function(component,event,helper){
        var pageNumber = component.get('v.pageNumber')-1;
        component.set('v.pageNumber',pageNumber);
        helper.getPageData(component);
    }
})