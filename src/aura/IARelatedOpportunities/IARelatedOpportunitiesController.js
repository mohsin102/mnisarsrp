({
	doInit: function(component, event, helper) {
		//Need to write functionality to populate relatedTypes from concatenatedRelatedTypes which can be set in Lightning Page Editor.
	},
    handleSectionToggle: function (cmp, event) {
        var openSections = event.getParam('openSections');

        if (openSections.length === 0) {
            cmp.set('v.activeSectionsMessage', "All sections are closed");
        } else {
            cmp.set('v.activeSectionsMessage', "Open sections: " + openSections.join(', '));
        }
    },
	handleComponentEvent: function(component, event, helper) {
		var sectionName = event.getParam('sectionName');
		//console.log('sectionName value is: ' + sectionName);
		var activeSections = component.get('v.activeSections');
		activeSections.push(sectionName);
		component.set('v.activeSections', activeSections);
		//console.log(JSON.stringify(activeSections));
	},
});