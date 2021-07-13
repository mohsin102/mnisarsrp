({
	init: function (component,event, helper){
		component.set('v.isWaiting', true);
		console.log('RecordId value is: ' + component.get('v.recordId'));
		var workspaceAPI = component.find("workspace");
		workspaceAPI.isConsoleNavigation().then(function(response) {
				console.log('Is console navigation from init call');
				console.log(response);
				if(response){
					workspaceAPI.getTabInfo().then(function(response) {
							var focusedTabId = response.tabId;
							component.set('v.consoleTabId', focusedTabId);
						})
						.catch(function(error) {
							console.log(error);
						});
					workspaceAPI.getFocusedTabInfo().then(function(response) {
						if(component.get('v.recordId') == '' || component.get('v.recordId') == undefined){
							workspaceAPI.setTabLabel({
								tabId: focusedTabId,
								label: "GIS Map"
							});
							workspaceAPI.setTabIcon({
								tabId: focusedTabId,
								icon: "action:map",
								iconAlt: "GIS Map"
							});
						}
						})
						.catch(function(error) {
							console.log(error);
						});
				}
			})
			.catch(function(error) {
				console.log(error);
			});
	},
	loadMap: function (component, event, helper) {
		if(component.get('v.selectedAccount')[0]){
			component.set('v.recordId2', component.get('v.selectedAccount')[0].id);
			component.set('v.sObjectName', 'Account');
			helper.loadMap(component, helper);
		}
		else{
			component.set('v.recordId2', '');
			helper.resetMap(component);
		}
		
	},
    jsLoaded: function(component, event, helper) {
		component.set('v.jsLoaded', true);
		if(component.get('v.recordId') != ''){
			console.log('recordId value is: ' + component.get('v.recordId'));
			component.set('v.recordId2', component.get('v.recordId'));
			//helper.loadMap(component, helper);
		}
		else{
			component.set('v.isWaiting', false);
		}
    },
	autoLoadMap: function(component, event, helper){
		if(component.get('v.jsLoaded') && component.get('v.recordLoaded') && (component.get('v.recordLoadError')==undefined || component.get('v.recordLoadError')=='')){
			helper.loadMap(component, helper);
		}
	},

	addLayer: function(component, event, helper){
		var source = event.getSource().get('v.value');
		var checked = event.getParam('checked');
		var layerGroup = component.get('v.layerGroup');
		var map = component.get('v.map');
		if(source == 'lgt' || source == 'well' || 'aoiPricing'){
			if(checked){
				map.addLayer(component.get('v.' + source + 'Layer'));
			}
			else{
				map.removeLayer(component.get('v.' + source + 'Layer'));
			}
		}
		else{
			if(checked){
				layerGroup.addLayer(component.get('v.' + source + 'Layer'));

			}
			else{
				layerGroup.removeLayer(component.get('v.' + source + 'Layer'));
			}
		}
	},

	removeLayer: function(component, event, helper){
		var layerGroup = component.get('v.layerGroup');
		layerGroup.removeLayer(component.get('v.unitLayer'));
	},
	handleScopedChange: function (component, event, helper) {
        // This will contain the string of the "value" attribute of the selected option
        var selectedOptionValue = event.getParam("value");
		var selectedOptionLabel;
		var scopedSelectedOptions = component.get('v.scopedSelectedOptions');
		var scopedOptions = component.get('v.scopedOptions');
		var layerGroup = component.get('v.layerGroup');
		var optionIncluded = false;
		for(var option in scopedSelectedOptions){
			if(scopedSelectedOptions[option].name == selectedOptionValue){
				optionIncluded = true;
			}
		}
		if(!optionIncluded){
			for(var option in scopedOptions){
				if(scopedOptions[option].value == selectedOptionValue){
					selectedOptionLabel = scopedOptions[option].label;
				}
			}
			layerGroup.addLayer(component.get('v.' + selectedOptionValue + 'Layer'));
			scopedSelectedOptions.push({'label': selectedOptionLabel, 'name': selectedOptionValue});
			component.set('v.scopedSelectedOptions', scopedSelectedOptions);
		}
		component.find("scopedSelectItem").set("v.value", "");
    },
	handleGeneralChange: function (component, event, helper) {
        // This will contain the string of the "value" attribute of the selected option
        var selectedOptionValue = event.getParam("value");
		var selectedOptionLabel;
		var generalSelectedOptions = component.get('v.generalSelectedOptions');
		var generalOptions = component.get('v.generalOptions');
		var map = component.get('v.map');
		var optionIncluded = false;
		for(var option in generalSelectedOptions){
			if(generalSelectedOptions[option].name == selectedOptionValue){
				optionIncluded = true;
			}
		}
		if(!optionIncluded){
			for(var option in generalOptions){
				if(generalOptions[option].value == selectedOptionValue){
					selectedOptionLabel = generalOptions[option].label;
				}
			}
			map.addLayer(component.get('v.' + selectedOptionValue + 'Layer'));
			if(selectedOptionValue === 'lgt'){
				map.addLayer(component.get('v.customTilesLayer'));
			}
			generalSelectedOptions.push({'label': selectedOptionLabel, 'name': selectedOptionValue});
			component.set('v.generalSelectedOptions', generalSelectedOptions);
		}
		component.find("generalSelectItem").set("v.value", "");
    },
	layerLoaded: function(component, event, helper){
		var hasTractLayer = component.get('v.hasTractLayer');
		var hasSubtractLayer = component.get('v.hasSubtractLayer');
		var hasHorizontalUnitLayer = component.get('v.hasHorizontalUnitLayer');
		var hasVerticalUnitLayer = component.get('v.hasVerticalUnitLayer');
		var hasHorizontalProducingWellLayer = component.get('v.hasHorizontalProducingWellLayer');
		var hasHorizontalPermitWellLayer = component.get('v.hasHorizontalPermitWellLayer');
		var hasHorizontalDUCWellLayer = component.get('v.hasHorizontalDUCWellLayer');
		var hasVerticalWellLayer = component.get('v.hasVerticalWellLayer');
		var hasInactiveSubtractLayer = component.get('v.hasInactiveSubtractLayer');
		var hasActiveSubtractLayer = component.get('v.hasActiveSubtractLayer');

		var tractLayerLoaded = component.get('v.tractLayerLoaded');
		var subtractLayerLoaded = component.get('v.subtractLayerLoaded');
		var horizontalUnitLayerLoaded = component.get('v.horizontalUnitLayerLoaded');
		var verticalUnitLayerLoaded = component.get('v.verticalUnitLayerLoaded');
		var horizontalProducingWellLayerLoaded = component.get('v.horizontalProducingWellLayerLoaded');
		var horizontalPermitWellLayerLoaded = component.get('v.horizontalPermitWellLayerLoaded');
		var horizontalDUCWellLayerLoaded = component.get('v.horizontalDUCWellLayerLoaded');
		var verticalWellLayerLoaded = component.get('v.verticalWellLayerLoaded');
		var inactiveSubtractLayerLoaded = component.get('v.inactiveSubtractLayerLoaded');
		var activeSubtractLayerLoaded = component.get('v.activeSubtractLayerLoaded');

		if(((hasTractLayer && tractLayerLoaded)||!hasTractLayer) && 
		   ((hasSubtractLayer && subtractLayerLoaded)||!hasSubtractLayer) &&
		   ((hasHorizontalUnitLayer && horizontalUnitLayerLoaded)||!hasHorizontalUnitLayer) &&
		   //((hasVerticalUnitLayer && verticalUnitLayerLoaded)||!hasVerticalUnitLayer) &&
		   ((hasHorizontalProducingWellLayer && horizontalProducingWellLayerLoaded)||!hasHorizontalProducingWellLayer) &&
		   ((hasHorizontalPermitWellLayer && horizontalPermitWellLayerLoaded)||!hasHorizontalPermitWellLayer) &&
		   ((hasHorizontalDUCWellLayer && horizontalDUCWellLayerLoaded)||!hasHorizontalDUCWellLayer) &&
		   //((hasVerticalWellLayer && verticalWellLayerLoaded)||!hasVerticalWellLayer) &&
		   ((hasInactiveSubtractLayer && inactiveSubtractLayerLoaded)||!hasInactiveSubtractLayer) &&
		   ((hasActiveSubtractLayer && activeSubtractLayerLoaded)||!hasActiveSubtractLayer)){
			
			component.set('v.allLayersLoaded', true);
		}

	},
	buildMap: function(component, event, helper){
		var layersLoaded = component.get('v.allLayersLoaded');
		if(layersLoaded){
			component.set('v.isWaiting', false);
		}
	},
	accountLookupSearch : function(component, event, helper) {
        
		//console.log('Search triggered in component controller.');
        const serverSearchAction = component.get('c.searchAccounts');
        // Passes the action to the Lookup component by calling the search method
        component.find('accountLookup').search(serverSearchAction);
    },
	handleScopedRemove: function(component, event, helper){
		var selectedOptionValue = event.getParam("item").name;
		var scopedSelectedOptions = component.get('v.scopedSelectedOptions');
		//console.log('selectedOptionValue is: ' + selectedOptionValue + ' scopedSelectedOptions are: ' );
		//console.log(scopedSelectedOptions);
		var layerGroup = component.get('v.layerGroup');
		var optionIncluded = false;
        for(var option in scopedSelectedOptions){
			if(scopedSelectedOptions[option].name == selectedOptionValue){
				optionIncluded = true;
			}
		}
		if(optionIncluded){
			layerGroup.removeLayer(component.get('v.' + selectedOptionValue + 'Layer'));
			var item = event.getParam("index");
			scopedSelectedOptions.splice(item,1);
			component.set('v.scopedSelectedOptions', scopedSelectedOptions);
		}
	},
	handleGeneralRemove: function(component, event, helper){
		var selectedOptionValue = event.getParam("item").name;
		var generalSelectedOptions = component.get('v.generalSelectedOptions');
		//console.log('selectedOptionValue is: ' + selectedOptionValue + ' generalSelectedOptions are: ' );
		//console.log(generalSelectedOptions);
		var map = component.get('v.map');
		var optionIncluded = false;
        for(var option in generalSelectedOptions){
			if(generalSelectedOptions[option].name == selectedOptionValue){
				optionIncluded = true;
			}
		}
		if(optionIncluded){
			map.removeLayer(component.get('v.' + selectedOptionValue + 'Layer'));
			//if removing Land Grid Tracts Layer, also need to remove the Custom Tiles Layer.
			if(selectedOptionValue === 'lgt'){
				map.removeLayer(component.get('v.customTilesLayer'));
			}
			var item = event.getParam("index");
			generalSelectedOptions.splice(item,1);
			//console.log(generalSelectedOptions);
			component.set('v.generalSelectedOptions', generalSelectedOptions);
		}
		//alert("General Removed with value: '" + selectedOptionValue + "'");
	},
	recordUpdated: function (component, event, helper) {
		component.set('v.recordLoaded', true);
		console.log('Record is loaded and result of error query is: ' + component.get('v.recordLoadError'));

	},
})