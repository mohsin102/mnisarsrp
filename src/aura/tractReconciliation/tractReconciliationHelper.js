({
	updateButtons: function (component) {
		var selectedTot = component.get('v.selectedTot');
		var selectedTract = component.get('v.selectedTract');
		var addButton = component.find('addButton');
		var compareButton = component.find('compareButton');
		//console.log(selectedTot);
		//console.log(selectedTract);
		//if only selectedTot is populated activate Add Button

		//if tot and tract selected, inactivate add button and activate compare button

		//if neither is populated inactivate both buttons
		
		switch(true){
			case selectedTot != null && selectedTract !=null:
				//console.log('Both TOT and Tract Selected.');
				component.set('v.addDisabled', true);
				component.set('v.compareDisabled', false);
				component.set('v.addIconColor', 'iconGray');
				component.set('v.compareIconColor', 'iconBlue');
				break;
			case (selectedTot != null) && (selectedTract == null):
				//console.log('Only selected Tot');
				component.set('v.addDisabled', false);
				component.set('v.compareDisabled', true);
				component.set('v.addIconColor', 'iconBlue');
				component.set('v.compareIconColor', 'iconGray');
				break;
			default:
				//console.log('Default setting for buttons.');
				component.set('v.addDisabled', true);
				component.set('v.compareDisabled', true);
				component.set('v.addIconColor', 'iconGray');
				component.set('v.compareIconColor', 'iconGray');
		}
	},

	sortTractData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.tractData");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.tractData", data);
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
	
})