({
	doInit: function(component, event, helper) {
		var relatedType = component.get('v.relatedType');
		var relatedField = '';
		switch(relatedType){
			case 'Asset Acquisition':
				component.set('v.relatedField', 'assetAcquisition__c');
				break;
			case 'Asset Acquisition Override':
				component.set('v.relatedField', 'assetAcquisitionOverride__c');
				break;
			case 'Asset Sale':
				component.set('v.relatedField', 'assetSale__c');
				break;
			case 'Asset Sale Override':
				component.set('v.relatedField', 'assetSaleOverride__c');
				break;
		}
		helper.getData(component, event, helper, component.get('v.relatedField'));
	},
	recordUpdated: function (component, event, helper) {
        helper.getData(component, event, helper, component.get('v.relatedField'));
	},
})