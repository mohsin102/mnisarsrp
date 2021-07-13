({	
    //Method fires on load of the component
    doInit : function(component, event, helper) {        
        helper.getColumnAndAction(component);
        helper.getData(component, helper);
    },
    
    //Method fires on click of the Property Name. creates Aura componenet and pushes the body in the royaltyWellAssociationModal Div
    displayModal: function(component, event, helper){
        var row = event.getParam('row');
        var isAssociated = false;
        if(row.wellName!==undefined && row.wellName!=='' && row.wellName!==null){
            isAssociated = true;
        }
        $A.createComponent( 'c:royaltyLineItemWellAssociationModal', {
            'propertyName':row.name,
            'rcid':component.get('v.recordId'),
            'rliIds':row.rliIds,
            'isAssociated':isAssociated,
            'revenueProperty':row.revenueProperty,
            'payorName':component.get("v.payorName"),
            'payorAccName':component.get("v.payorAccName")
        },
                           function(modalComponent, status, errorMessage) {
                               //console.log('Callback called');
                               if (status === "SUCCESS") {
                                   //console.log('Success');
                                   //Appending the newly created component in div
                                   var body = component.find( 'royaltyWellAssociationModal' ).get("v.body");
                                   body.push(modalComponent);
                                   console.log(body);
                                   component.find( 'royaltyWellAssociationModal' ).set("v.body", body);
                               } else if (status === "INCOMPLETE") {
                                   //console.log('Server issue or client is offline.');
                               } else if (status === "ERROR") {
                                   console.log('error');
                               }
                           }
                          );
    },
    
    //Method fires on click on the column name of the data table
    updateSorting: function (component, event, helper) {
        
        var fieldName = event.getParam('fieldName');
        console.log('fieldName value is: ' + fieldName);
        var sortDirection = event.getParam('sortDirection');
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
        helper.getPageData(component);
    },
    
    //Method fires on closing the Associatino modal(2nd screen) with the help of component event
    handleComponentEvent: function(component,event,helper){
        helper.getData(component, helper);
    }
})