({
	doInit : function(component, event, helper) {
        component.destroy();
        window.open('https://'+window.location.hostname+'/dataImporter/dataimporter.app?objectSelection=Royalty_Line_Item__c');
		component.destroy();
    }
})