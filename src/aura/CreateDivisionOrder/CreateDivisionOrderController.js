({
    handleRecordUpdated : function(component, event, helper) {

        var type = component.get('v.caseRecord').Type;
        if(type === 'Division Order'){
            component.set('v.showButton',true);
        }else{
            component.set('v.showButton',false);
        }
    },
    newDivOrder : function(component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "divisionOrder__c",
            "defaultFieldValues": {'case__c' : component.get('v.recordId')}
            //THE BELOW CAN BE USED TO SHORTCUT THE NAVIGATION TO THE NEW DIV ORDER REC AND REFRESH THE CASE PAGE
            // "navigationLocation" : "LOOKUP",
            // "panelOnDestroyCallback": function(event) {
            //     var navigateEvent = $A.get("e.force:navigateToSObject");           
            //     navigateEvent.setParams({ "recordId": component.get('v.recordId')});                
            //     navigateEvent.fire(); 
            // }
        });
        createRecordEvent.fire(); 
    }
})