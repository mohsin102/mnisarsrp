({
	completeClick : function(component, event, helper) {
		var action = component.get("c.markAsComplete");
        action.setParams({ recordId : component.get("v.recordId") });
 
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                $A.get('e.force:refreshView').fire();
                //$A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
	},

	shapeUpdatedClick : function(component, event, helper) {
		console.log('Shape updated called');
		var action = component.get("c.shapeUpdated");
        action.setParams({ recordId : component.get("v.recordId") });
 
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('call success');
                $A.get('e.force:refreshView').fire();
                //$A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
	},

	handleRecordUpdated: function(component, event, helper){
			console.log('Record Loaded');
			var currentRecord = component.get('v.gisUpdateRequestRecord');
			if(currentRecord.Completion_Date__c != null){
				component.set('v.statusIcon', 'task2');
				component.set('v.canComplete', false);
				component.set('v.canUpdateShape', false);
				component.set('v.status', 'Complete');
			}
			else if(currentRecord.Shape_Updated_Date__c != null){
				component.set('v.statusIcon', 'output');
				component.set('v.canComplete', true);
				component.set('v.canUpdateShape', false);
				component.set('v.status', 'Shape Updated');
			}
			else if(currentRecord.Shape_Updated_Date__c == null && currentRecord.Completion_Date__c == null){
				console.log('setting open values');
				component.set('v.statusIcon', 'order_item');
				component.set('v.canComplete', false);
				component.set('v.canUpdateShape', true);
				component.set('v.status', 'Open');
			}
	},

})