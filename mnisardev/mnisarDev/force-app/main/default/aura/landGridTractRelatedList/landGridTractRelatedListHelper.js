({
    sortData: function (component, fieldName, sortedDirection) {
        var data = component.get("v.data");
        var reverse = sortedDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        console.log('---11---'+sortedDirection);
        data.sort(this.sortBy(fieldName, reverse))
        component.set("v.data", data);
    },
    sortBy: function (field, reverse, primer) {
        console.log('---2---'+reverse);
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a)?key(a):'', b = key(b)?key(b):'', reverse * ((a > b) - (b > a));
        }
    },
	getData: function(component){
		switch(component.get('v.relatedObject')) {
		  case "TitleWorkJob__c":
			component.set('v.isWaiting', true);
			var action = component.get('c.getTitleWorkJobs');
			var recordId = component.get('v.recordId');
			action.setParams({
				recordId: recordId
			});
			action.setCallback(this, function(response) {
				//component.set("v.Spinner", false);
				var state = response.getState();
				var result = response.getReturnValue();
				if (state === "SUCCESS") {
                
					result.forEach(function(record) {
						record.linkName = '/' + record.Id;
						if(record.Integration_Reviewer__c){
							record.integrationReviewerName = record.Integration_Reviewer__r.Name;
						}
						if(record.Landman__c){
							record.landman = record.Landman__r.Name;
						}
						if(record.Project_AOI__c){
							record.projectAOIName = record.Project_AOI__r.Name;
							record.projectLink = '/' + record.Project_AOI__c;
						}
					
					});
					component.set("v.data", result);
					component.set("v.listlength", result.length);
				

				} else {
					alert(state);
				}
				component.set('v.isWaiting', false);
				if(result.length>10){
					//console.log('Length is greater than 10');
					var tableDiv = component.find("tableDiv");
					//console.log(tableDiv);
					$A.util.addClass(tableDiv, 'maxHeight');
				}
				//alert('Table should be refreshed.');
			});
			$A.enqueueAction(action);
			break;
		  case "TitleWorkTracker__c":
			component.set('v.isWaiting', true);
			var action = component.get('c.getTitleWorkTrackers');
			var recordId = component.get('v.recordId');
			action.setParams({
				recordId: recordId
			});
			action.setCallback(this, function(response) {
				//component.set("v.Spinner", false);
				var state = response.getState();
				var result = response.getReturnValue();
				if (state === "SUCCESS") {
                
					result.forEach(function(record) {
						record.linkName = '/' + record.Id;
						if(record.status__c == "In Progress"){
							component.set('v.buttonDisabled', true);
							component.set('v.buttonMessage', 'Mark In Progress Tracker complete to be able to create new Tracker.');
						}
					});
					component.set("v.data", result);
					component.set("v.listlength", result.length);
				

				} else {
					alert(state);
				}
				component.set('v.isWaiting', false);
				if(result.length>10){
					//console.log('Length is greater than 10');
					var tableDiv = component.find("tableDiv");
					//console.log(tableDiv);
					$A.util.addClass(tableDiv, 'maxHeight');
				}
				//alert('Table should be refreshed.');
			});
			$A.enqueueAction(action);
			break;
			case "Tract__c":
			component.set('v.isWaiting', true);
			var action = component.get('c.getTracts');
			var recordId = component.get('v.recordId');
			action.setParams({
				recordId: recordId
			});
			action.setCallback(this, function(response) {
				//component.set("v.Spinner", false);
				var state = response.getState();
				var result = response.getReturnValue();
				if (state === "SUCCESS") {
                
					result.forEach(function(record) {
						record.linkName = '/' + record.Id;
						if(record['Id']){
							if(record['netAcreageUnits__c']){
								record.acres = record['netAcres__c'] + ' ' + record['netAcreageUnits__c'];
							}
							else{
								record.acres = record['netAcres__c'] + ' ?';
							}
						}
					
					});
					component.set("v.data", result);
					component.set("v.listlength", result.length);
				

				} else {
					alert(state);
				}
				component.set('v.isWaiting', false);
				if(result.length>10){
					//console.log('Length is greater than 10');
					var tableDiv = component.find("tableDiv");
					//console.log(tableDiv);
					$A.util.addClass(tableDiv, 'maxHeight');
				}
				//alert('Table should be refreshed.');
			});
			$A.enqueueAction(action);
			break;
		  default:
		}
	},
    
})