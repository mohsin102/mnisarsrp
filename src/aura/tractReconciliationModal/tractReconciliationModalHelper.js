({
	sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.data");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.data", data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a)?key(a):'', b = key(b)?key(b):'', reverse * ((a > b) - (b > a));
        }
    },
	sortTotData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.totData");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.totData", data);
    },
    setUsedTOTGroups: function(component){
        var totRecords = component.get('v.totData')
        var usedTOTGroups = new Array();
        for(var tot in totRecords){
            usedTOTGroups.push(totRecords[tot].torGroupNum__c);
        }
        component.set('v.usedTOTGroups', usedTOTGroups);
    },

	getFieldMapping: function(modalField){
		var totField;
		var tractField;
		
		switch(modalField){
			case "quarterCall":
				totField = "quarterCall__c";
				tractField = "Quarter_Call__c";
				break;
			case "depth":
				totField = "depth__c";
				tractField = "depth__c";
				break;
			case "instrumentType":
				totField = "instrumentType__c";
				tractField = "Instrument_Type__c";
				break;
			case "grossAcreage":
				totField = "grossAc__c";
				tractField = "Gross_Acres__c";
				break;
			case "netAcres":
				totField = "tractsCOCalculation__c";
				tractField = "netAcres__c";
				break;
			case "netAcreageUnit":
				totField = "measurement__c";
				tractField = "netAcreageUnits__c";
				break;
			default:
				totField = "";
				tractField = "";
		}

	var mapping = {modalFieldName:modalField, totFieldName:totField, tractFieldName:tractField};
	return mapping;
	},
});