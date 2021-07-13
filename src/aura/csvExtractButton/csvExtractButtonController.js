({
	exportData: function (component, event, helper) {
		//console.log('exportData called.');
		//console.log(JSON.stringify(component.get('v.columns')));
		//console.log(JSON.stringify(component.get('v.data')));
		console.log('Entering export at: ' + new Date());
		component.set('v.isExporting', true);
		helper.exportData(component, helper);
		//component.set('v.isExporting', false);
		//window.open(encodedUri);

	}
})