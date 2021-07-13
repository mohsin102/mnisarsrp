({
	init: function (component, event, helper) {
		helper.getData(component);

	},
	recordUpdated: function (component, event, helper) {
		$A.get('e.force:refreshView').fire();
	},
})