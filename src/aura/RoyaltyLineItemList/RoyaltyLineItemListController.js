({
    doInit : function(component, event, helper) {        
        helper.getColumnAndAction(component);
        component.set("v.sortBy","Name");
        component.set("v.sortDirection","asc");
        helper.getData(component, helper,component.get("v.sortBy"),component.get("v.sortDirection"));
		
    },
    
    handleNext : function(component, event, helper) { 
        var pageNumber = component.get("v.pageNumber");
        component.set('v.isWaiting', true);
		component.set("v.pageNumber", pageNumber+1);
        var sortBy = component.get("v.sortBy");
        if(sortBy === 'link'){
            sortBy = 'Name';
        }else if(sortBy ==='linkProperty'){
            sortBy = 'Well__r.Name';
        }
        helper.getData(component, helper,sortBy,component.get("v.sortDirection"));
    
    },
    
    handlePrev : function(component, event, helper) {        
        var pageNumber = component.get("v.pageNumber");
        component.set('v.isWaiting', true);
		component.set("v.pageNumber", pageNumber-1);
        var sortBy = component.get("v.sortBy");
        if(sortBy === 'link'){
            sortBy = 'Name';
        }else if(sortBy ==='linkProperty'){
            sortBy = 'Well__r.Name';
        }
        helper.getData(component, helper,sortBy,component.get("v.sortDirection"));
    },
    
    handleRowAction: function (component, event, helper) {
        
        var action = event.getParam('action');
        var row = event.getParam('row');
        if(action.name==='delete'){
            helper.deleteLIRec(component,row,helper);
        }else {
            var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            url: '/lightning/r/Royalty_Check__c/'+component.get('v.recordId')+'/view',
            focus: true
        }).then(function(response) {
            workspaceAPI.openSubtab({
                parentTabId: response,
                url: '/lightning/r/Royalty_Line_Item__c/'+row.Id+'/view',
                focus: true
            });
        })
        .catch(function(error) {
            console.log(error);
        });
        }
        
    },
    createNewLI :function(component,event,helper){
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Royalty_Line_Item__c",
            "defaultFieldValues": {
                'Royalty_Check__c' : component.get('v.recordId')
            }
        });
        createRecordEvent.fire();
    },
    refreshComponent : function(component,event,helper){
        
        alert('-----');
        $A.get('e.force:refreshView').fire();
    },
    handleSort : function(component,event,helper){
        component.set('v.isWaiting', true);
		var sortBy = event.getParam("fieldName");

        var sortDirection = event.getParam("sortDirection");
        component.set("v.sortBy",sortBy);
        component.set("v.sortDirection",sortDirection);
        if(sortBy === 'link'){
            sortBy = 'Name';
        }else if(sortBy ==='linkProperty'){
            sortBy = 'Well__r.Name';
        }
        helper.getData(component, helper,sortBy,sortDirection);
    },
	 handleKeyUp: function(component, event, helper){
        console.log('keyup function called.');
		var searchCounter = parseInt(component.get('v.searchCounter'));
		searchCounter++;
		console.log('searchCounter value is: ' + searchCounter);
		component.set('v.searchCounter', searchCounter);
        var searchString = component.get('v.searchString');
        helper.getData(component, helper,component.get("v.sortBy"),component.get("v.sortDirection"));
    },
	onSearchChange: function(component, event, helper){
		helper.getData(component, helper,component.get("v.sortBy"),component.get("v.sortDirection"));
	}
})