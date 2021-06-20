({
    doInit : function(component, event, helper) {
        //var style="height:"+component.get("v.height")+"px;width:"+component.get("v.width")+"px;";
        // alert(style);
        //component.set("v.styl", style);
        component.set('v.mycolumns', [
            /*{label: 'Name', fieldName: 'linkName', type: 'url', cellAttributes: { alignment: 'left' }, 
             typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}, cellAttributes: { alignment: 'left' },sortable: true },*/
			 {label: 'Name',  type: "button", typeAttributes: {label: {fieldName: 'Name'}, sObject:'Evaluation__c',
				title: 'Open Evaluation', disabled: false, value: 'Id', variant: 'base', class:'nameButton', initialWidth: 200 }, sortable: true},
			 {label: 'Owner',  type: "button", typeAttributes: {label: {fieldName: 'ownerName'}, sObject:'User',
				title: 'Open Owner', disabled: false, value: 'OwnerId', variant: 'base', class:'nameButton', initialWidth: 200 }, sortable: true},
			{label: 'Inv Team Reviewer',  type: "button", typeAttributes: {label: {fieldName: 'reviewerName'}, sObject:'User',
				title: 'Open Investment Team Reviewer', disabled: false, value: 'srpInvestmentTeamReviewer__c', variant: 'base', class:'nameButton', initialWidth: 200 }, sortable: true},
			 /*{label: 'Inv Team Rvwr', fieldName: 'reviewerLink', type: 'url', cellAttributes: { alignment: 'left' }, 
             typeAttributes: {label: { fieldName: 'reviewerName' }, target: '_blank'}, cellAttributes: { alignment: 'left' },sortable: true },*/
            { label: 'Status', fieldName: 'Status__c', type: 'text', sortable: true, cellAttributes: { alignment: 'left'}},
			{label: 'Start date', fieldName: 'startDate__c', type: 'date-local'},
			{label: 'End date', fieldName: 'completionDate__c', type: 'date-local'}
        ]);
        var action = component.get('c.getEvaluationRecords');
        
        action.setParams({
            'recordId':component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            //component.set("v.Spinner", false);
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS") {
                var eList = result.evalList;
                eList.forEach(function(record){
					console.log(record);
                    record.linkName = '/'+record.Id;
					record.ownerLink = '/' + record.OwnerId;
					record.ownerName = record.Owner.Name;
					
					//console.log('Owner Name is: ' + record.ownerName + ' owner link is: ' + record.ownerLink + ' record ownerId is: ' + record.OwnerId);

					if(record.srpInvestmentTeamReviewer__c){
						record.reviewerName = record.srpInvestmentTeamReviewer__r.Name;
						record.reviewerLink = '/' + record.srpInvestmentTeamReviewer__c;
					}
                });
                component.set("v.data", eList);
                component.set("v.listlength", eList.length);
                component.set("v.object",result.sObjectType);
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

    createEvaluation : function(component,event,helper){
        var createRecordEvent = $A.get("e.force:createRecord");
        if(component.get('v.object')==='Case'){
            createRecordEvent.setParams({
                "entityApiName": "Evaluation__c",
                "defaultFieldValues": {
                    'case__c' : component.get('v.recordId')
                }
            });
        }else if(component.get('v.object')==='Opportunity'){
            createRecordEvent.setParams({
                "entityApiName": "Evaluation__c",
                "defaultFieldValues": {
                    'opportunity__c' : component.get('v.recordId')
                }
            });
        }
        createRecordEvent.fire();
    },
	handleRowAction: function (component, event, helper) {
        
        var action = event.getParam('action');
		//console.log(action.value);
        var row = event.getParam('row');
		//console.log(JSON.stringify(row));
		var workspaceAPI = component.find("workspace");
		//console.log('/lightning/r/'+component.get('v.sObjectName') + '/' +component.get('v.recordId')+'/view');
		const handleUrl = (url) => {
            window.open(url);
        };
        const handleError = (error) => {
            console.log(error);
        };
		workspaceAPI.isConsoleNavigation().then(function(response) {
			console.log('Inside console navigation');
			workspaceAPI.getFocusedTabInfo().then(function(response){
				console.log(JSON.stringify(response));
				var parentTabId;
				if(response.isSubtab){
					parentTabId = response.parentTabId;
				}
				else{
					parentTabId = response.tabId;
				}
				console.log('subtab to open is: /lightning/r/'+ action.sObject+ '/'+row[action.value]+'/view');
				workspaceAPI.openSubtab({
					parentTabId: parentTabId,
					url: '/lightning/r/'+ action.sObject+ '/'+row[action.value]+'/view',
					focus: true
				});
				//console.log('subtab opened');
			})
			.catch(function(error) {
				var navService = component.find("navService");
				// Sets the route to /lightning/o/Account/home
				var pageReference = {
					type: 'standard__recordPage',
					attributes: {
						objectApiName: action.sObject,
						actionName: 'view',
						recordId: row[action.value]
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
			});
        })
        
        
    },
        
    })