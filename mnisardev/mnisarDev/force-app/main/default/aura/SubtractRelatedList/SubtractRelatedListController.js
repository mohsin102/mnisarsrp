({
    doInit : function(component, event, helper) {
        component.set('v.mycolumns', [
            {label: 'Name', fieldName: 'linkName', type: 'url', cellAttributes: { alignment: 'left' }, 
             typeAttributes: {label: { fieldName: 'Name' }, target: '_self'},sortable: true, initialWidth:150 },
			{ label: 'Quarter Call', fieldName: 'Subtract_Quarter_Call__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'Subtract_Quarter_Call__c' }, value:{ fieldName: 'Subtract_Quarter_Call__c' }}, sortable: true, initialWidth:150},
			{ label: 'Gross Acres', fieldName: 'Subtract_Gross_Acres__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'Subtract_Gross_Acres__c' }, value:{ fieldName: 'Subtract_Gross_Acres__c' }}, sortable: true, initialWidth:150},
			{ label: 'Net Acres', fieldName: 'Subtract_Acres__c', type: 'textExtended', editable: false, typeAttributes:{title:{ fieldName: 'Subtract_Acres__c' }, value:{ fieldName: 'Subtract_Acres__c' }}, sortable: true, initialWidth:100},
            {label: 'Instrument', fieldName: 'linkInstrumentName', type: 'url', cellAttributes: { alignment: 'left' }, 
             typeAttributes: {label: { fieldName: 'InstrumentName' }, target: '_blank'},sortable: true, initialWidth:150 },
            { label: 'Lease Royalty', fieldName: 'Instrument_Lease_Royalty__c', type: 'number', typeAttributes: { minimumFractionDigits : '4' }, cellAttributes: { alignment: 'left' }, sortable: true, initialWidth:150 },
            //{ label: 'Gross Acres', fieldName: 'Subtract_Gross_Acres__c', type: 'number', cellAttributes: { alignment: 'left' }, sortable: true, initialWidth:100 },
            { label: 'Subtract NRI', fieldName: 'subtractNRI', type: 'number', typeAttributes: { minimumFractionDigits : '8' }, cellAttributes: { alignment: 'left' }, sortable: true, initialWidth:150 },
        ]);
            //component.set("v.Spinner", true);
            var action = component.get('c.getSubtracts');
            var tId= component.get('v.recordId');
            action.setParams({
            tractId : tId
            });
            action.setCallback(this, function (response) {
            //component.set("v.Spinner", false);
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS") {
            result.forEach(function(record){
            record.linkName = '/'+record.Id;
            if(record.Instrument__c!=undefined && record.Instrument__c!=null && record.Instrument__c!=''){
            record.linkInstrumentName = '/'+record.Instrument__c;
            record.InstrumentName = record.Instrument__r.Name;
            }
            if(record.Subtract_NRI__c!==''&&record.Subtract_NRI__c!==undefined){
            record.subtractNRI = record.Subtract_NRI__c.toString();
            }
            });
            component.set("v.subtractList", result);
            component.set("v.subtractListlength", result.length);
            }else{
            alert(state);
            } 
			if(result.length>10){
				//console.log('Length is greater than 10');
				var tableDiv = component.find("tableDiv");
				//console.log(tableDiv);
				$A.util.addClass(tableDiv, 'maxHeight');
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
            
            createNewSubtract :function(component,event,helper){
            
            var createSubtractEvent = $A.get("e.force:createRecord");
            createSubtractEvent.setParams({
            "entityApiName": "Subtract__c",
            "defaultFieldValues": {
            'Tract__c' : component.get('v.recordId')
            }
            });
            createSubtractEvent.fire();
            /*var actionAPI = component.find("quickActionAPI");
            var fields = { tractId : { Id : "Tract__c.Id" } };
            var args = { actionName : "Subtract__c.Clone",  // Clone action on the Subtract object
            entityName : "Subtract__c", targetFields : fields };
            actionAPI.setActionFieldValues(args).then(function(result) {
            actionAPI.invokeAction(args);
            
            }).catch(function(e) {
            console.error(e.errors);
            });*/
            }
            })