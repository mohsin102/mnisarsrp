({
    
    
    inlineEditPhone : function(component,event,helper){   
        // show the name edit field popup 
        component.set("v.phoneEditMode", true); 
        // after the 100 millisecond set focus to input field   
        setTimeout(function(){ 
            component.find("phoneId").focus();
        }, 100);
    },
    
    onPhoneChange : function(component,event,helper){ 
        // if edit field value changed and field not equal to blank,
        // then show save and cancel button by set attribute to true
        if(event.getSource().get("v.value").trim() != ''){ 
            var cmpEvent = component.getEvent("cmpEvent");
            cmpEvent.fire();
        }
    },
    
    closePhoneBox : function (component, event, helper) {
        // on focus out, close the input section by setting the 'phoneEditMode' att. as false   
        component.set("v.phoneEditMode", false); 
        // check if change/update Name field is blank, then add error class to column -
        // by setting the 'showErrorClass' att. as True , else remove error class by setting it False   
        
    }, 
    
    onTypeChange : function(component,event,helper){ 
        // if edit field value changed and field not equal to blank,
        // then show save and cancel button by set attribute to true
        var cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.fire();
    },
    
    inlineEditAddress : function(component,event,helper){   
        // show the name edit field popup 
        component.set("v.addressEditMode", true); 
        // after the 100 millisecond set focus to input field   
        setTimeout(function(){component.find("addressId").focus();}, 100);
    },
    
    onAddressChange : function(component,event,helper){ 
        // if edit field value changed and field not equal to blank,
        // then show save and cancel button by set attribute to true
        var address = component.find('addressId');
        component.set('v.singleRec.Street',address.get('v.street'));
        component.set('v.singleRec.State',address.get('v.province'));
        component.set('v.singleRec.City',address.get('v.city'));
        component.set('v.singleRec.Country',address.get('v.country'));
        component.set('v.singleRec.Zipcode',address.get('v.postalCode'));
        
        var addressStr='';
        addressStr += address.get('v.street')!=''?address.get('v.street')+', ':'';
        addressStr += address.get('v.province')!=''?address.get('v.province')+', ':'';
        addressStr += address.get('v.city')!=''?address.get('v.city')+', ':'';
        addressStr += address.get('v.country')!=''?address.get('v.country')+', ':'';
        addressStr += address.get('v.postalCode')!=''?address.get('v.postalCode')+', ':'';
        
        component.set('v.singleRec.address',addressStr);
        
        var cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.fire();
    },
    
    closeAddressBox : function (component, event, helper) {
        // on focus out, close the input section by setting the 'addressEditMode' att. as false
        
        component.set("v.addressEditMode", false); 
        // check if change/update Name field is blank, then add error class to column -
        // by setting the 'showErrorClass' att. as True , else remove error class by setting it False   
        
    }, 
    
    inlineEditPrimary : function(component,event,helper){   
        // show the name edit field popup 
        component.set("v.primaryEditMode", true); 
        // after the 100 millisecond set focus to input field   
        setTimeout(function(){ 
            component.find("primaryId").focus();
        }, 100);
    },
    
    onPrimaryChange : function(component,event,helper){ 
        
        
        var cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.fire();
    },
    
    closePrimaryBox : function (component, event, helper) {
        // on focus out, close the input section by setting the 'primaryEditMode' att. as false   
        component.set("v.primaryEditMode", false); 
        // check if change/update Name field is blank, then add error class to column -
        // by setting the 'showErrorClass' att. as True , else remove error class by setting it False   
    }, 

    inlineEditStatus : function(component,event,helper){   
        // show the name edit field popup 
        component.set("v.statusEditMode", true); 
        // after the 100 millisecond set focus to input field   
        setTimeout(function(){ 
            component.find("statusId").focus();
        }, 100);
    },
    
    onStatusChange : function(component,event,helper){ 
        
        
        var cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.fire();
    },
    
    closeStatusBox : function (component, event, helper) {
        // on focus out, close the input section by setting the 'statusEditMode' att. as false   
        component.set("v.statusEditMode", false); 
        // check if change/update Name field is blank, then add error class to column -
        // by setting the 'showErrorClass' att. as True , else remove error class by setting it False   
    },
    inlineEditNotes : function(component,event,helper){   
        // show the name edit field popup 
        component.set("v.notesEditMode", true); 
        // after the 100 millisecond set focus to input field   
        setTimeout(function(){ 
            component.find("notesId").focus();
        }, 100);
    },
    
    onNotesChange : function(component,event,helper){ 
        
        var cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.fire();
    },
    
    closeNotesBox : function (component, event, helper) {
        // on focus out, close the input section by setting the 'statusEditMode' att. as false   
        component.set("v.notesEditMode", false); 
        // check if change/update Name field is blank, then add error class to column -
        // by setting the 'showErrorClass' att. as True , else remove error class by setting it False   
    },
    deleteRow: function(component,event,helper){
        var deleteEvent = component.getEvent("deleteEvent");
        deleteEvent.setParams({
            "row" : component.get('v.singleRec') ,
            "rowIndex":component.get('v.sNo')
        });

        deleteEvent.fire();
    },
    doNothing : function (component, event, helper) {
    }
})