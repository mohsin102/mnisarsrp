({
    setMapToken : function(component, helper) {
        if (component.get('v.token') == undefined || component.get('v.token') == '') {
            var action = component.get("c.getClientToken");
            var tokenResult = component.get("v.token");
            return new Promise(function (resolve, reject) {
                action.setCallback(this,function(response) {
					var state = response.getState();
					if (state === "SUCCESS") {
						// Get the token and set it on the attribute
						var result = response.getReturnValue();
						component.set("v.token",result);
						resolve(result);
					}
					else if (state === "INCOMPLETE") {
							alert('result incomplete');
					}
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + errors[0].message);
                                reject(errors);
                            }
                        } else {
                                console.log("Unknown error");
                        }
                    }
                });
                $A.enqueueAction(action);
            });
        }
    },

    drawMap : function(component, helper) {
        var map;
        var rec = component.get('v.recordId2');
        var sObjName = component.get("v.sObjectName");
        var authToken = component.get('v.token');
		//console.log('Record Id value is' + rec + ' sObjectName is: ' + sObjName);
        //var tlCustom = 'https://maps.strongholdresourcepartners.com/arcgis/rest/services/SRP/Landgrid_LS/MapServer/tile/{z}/{y}/{x}?token=' + authToken;
        var action = component.get("c.getMaps");

        action.setParam("objId",rec);
        action.setParam("objTypeName",sObjName);
        action.setCallback(this,function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				// Extract map from GeoJSON and show it
				var mapFound = false;
				var result = response.getReturnValue();
				var tractURL;
				var tractWhereClause;
				var subtractURL;
				var subtractWhereClause;
				var verticalUnitURL;
				var verticalUnitWhereClause;
				var horizontalUnitURL;
				var horizontalUnitWhereClause;
				var horizontalProducingWellURL;
				var horizontalProducingWellWhereClause;
				var horizontalPermitWellURL;
				var horizontalPermitWellWhereClause;
				var horizontalDUCWellURL;
				var horizontalDUCWellWhereClause;
				var verticalWellURL;
				var verticalWellWhereClause;
				var activeSubtractURL;
				var activeSubtractWhereClause;
				var inactiveSubtractURL;
				var inactiveSubtractWhereClause;
				var info = [];
				var bounds = L.latLngBounds([]);
				var scopedSelectedOptions = component.get('v.scopedSelectedOptions');
				var scopedOptions = component.get('v.scopedOptions');
				for(var responseItem in result){
					if(!result[responseItem].hasError){
						if(result[responseItem].requestURL != null && 
						   result[responseItem].requestURL != undefined){
						   console.log('mapType is: ' + result[responseItem].mapType + ' bounds are: ' + result[responseItem].bounds);
						   var resultBounds = JSON.parse(result[responseItem].bounds);
						   console.log(resultBounds);
						   if(!isNaN(resultBounds.extent.ymin) && !isNaN(resultBounds.extent.xmin) && !isNaN(resultBounds.extent.ymax) && !isNaN(resultBounds.extent.xmax)){
							   var corner1 = L.latLng(resultBounds.extent.ymin, resultBounds.extent.xmin);
							   var corner2 = L.latLng(resultBounds.extent.ymax, resultBounds.extent.xmax);
							   bounds.extend(L.latLngBounds(corner1, corner2));
							}
							if(result[responseItem].mapType == 'Tract'){
								tractURL = result[responseItem].requestURL;
								tractWhereClause = result[responseItem].whereClause;
								var tractInfo = result[responseItem].tractInfo;
								component.set('v.hasTractLayer', true);
								scopedSelectedOptions.push({'label': 'Tracts', 'name': 'tract'});
								scopedOptions.push({'label': 'Tracts', 'value': 'tract'});
							}
							if(result[responseItem].mapType == 'Subtract'){
								subtractURL = result[responseItem].requestURL;
								subtractWhereClause = result[responseItem].whereClause;
								var subtractInfo = result[responseItem].subtractInfo;
								component.set('v.hasSubtractLayer', true);
								scopedSelectedOptions.push({'label': 'Subtracts', 'name': 'subtract'});
								scopedOptions.push({'label': 'Subtracts', 'value': 'subtract'});
							}
							if(result[responseItem].mapType == 'VerticalUnit'){
								verticalUnitURL = result[responseItem].requestURL;
								verticalUnitWhereClause = result[responseItem].whereClause;
								var verticalUnitInfo = result[responseItem].verticalUnitInfo;
								component.set('v.hasVerticalUnitLayer', true);
								//scopedSelectedOptions.push({'label': 'Vt Units', 'name': 'verticalUnit'});
								scopedOptions.push({'label': 'Vt Units', 'value': 'verticalUnit'});
							}
							if(result[responseItem].mapType == 'HorizontalUnit'){
								horizontalUnitURL = result[responseItem].requestURL;
								horizontalUnitWhereClause = result[responseItem].whereClause;
								var horizontalUnitInfo = result[responseItem].horizontalUnitInfo;
								component.set('v.hasHorizontalUnitLayer', true);
								scopedSelectedOptions.push({'label': 'Hz Units', 'name': 'horizontalUnit'});
								scopedOptions.push({'label': 'Hz Units', 'value': 'horizontalUnit'});
							}
							if(result[responseItem].mapType == 'HorizontalProducingWell'){
								horizontalProducingWellURL = result[responseItem].requestURL;
								horizontalProducingWellWhereClause = result[responseItem].whereClause;
								var horizontalProducingWellInfo = result[responseItem].horizontalProducingWellInfo;
								component.set('v.hasHorizontalProducingWellLayer', true);
								scopedSelectedOptions.push({'label': 'Hz Producing Wells', 'name': 'horizontalProducingWell'});
								scopedOptions.push({'label': 'Hz Producing Wells', 'value': 'horizontalProducingWell'});
							}
							
							if(result[responseItem].mapType == 'HorizontalPermitWell'){
								horizontalPermitWellURL = result[responseItem].requestURL;
								horizontalPermitWellWhereClause = result[responseItem].whereClause;
								var horizontalPermitWellInfo = result[responseItem].horizontalPermitWellInfo;
								component.set('v.hasHorizontalPermitWellLayer', true);
								scopedSelectedOptions.push({'label': 'Hz Permit Wells', 'name': 'horizontalPermitWell'});
								scopedOptions.push({'label': 'Hz Permit Wells', 'value': 'horizontalPermitWell'});
							}
							if(result[responseItem].mapType == 'HorizontalDUCWell'){
								horizontalDUCWellURL = result[responseItem].requestURL;
								horizontalDUCWellWhereClause = result[responseItem].whereClause;
								var horizontalDUCWellInfo = result[responseItem].horizontalDUCWellInfo;
								component.set('v.hasHorizontalDUCWellLayer', true);
								scopedSelectedOptions.push({'label': 'Hz DUC Wells', 'name': 'horizontalDUCWell'});
								scopedOptions.push({'label': 'Hz DUC Wells', 'value': 'horizontalDUCWell'});
							}
							if(result[responseItem].mapType == 'VerticalWell'){
								verticalWellURL = result[responseItem].requestURL;
								verticalWellWhereClause = result[responseItem].whereClause;
								var verticalWellInfo = result[responseItem].verticalWellInfo;
								component.set('v.hasVerticalWellLayer', true);
								//scopedSelectedOptions.push({'label': 'Vt Wells', 'name': 'verticalWell'});
								scopedOptions.push({'label': 'Vt Wells', 'value': 'verticalWell'});
							}
							if(result[responseItem].mapType == 'inactiveUASubtract'){
								inactiveSubtractURL = result[responseItem].requestURL;
								inactiveSubtractWhereClause = result[responseItem].whereClause;
								var inactiveSubtractInfo = result[responseItem].inactiveSubtractInfo;
								component.set('v.hasInactiveSubtractLayer', true);
								scopedSelectedOptions.push({'label': 'Inactive Subtracts', 'name': 'inactiveSubtract'});
								scopedOptions.push({'label': 'Inactive Subtracts', 'value': 'inactiveSubtract'});
							}
							if(result[responseItem].mapType == 'activeUASubtract'){
								activeSubtractURL = result[responseItem].requestURL;
								activeSubtractWhereClause = result[responseItem].whereClause;
								var activeSubtractInfo = result[responseItem].activeSubtractInfo;
								component.set('v.hasActiveSubtractLayer', true);
								scopedSelectedOptions.push({'label': 'Active Subtracts', 'name': 'activeSubtract'});
								scopedOptions.push({'label': 'Active Subtracts', 'value': 'activeSubtract'});
							}
						}

					}
				}
				var consoleTabId = component.get('v.consoleTabId');
				console.log('consoleTabId value is: ' + consoleTabId);
				map = helper.genMap(rec, component.get('v.consoleTabId'));
				console.log('map should be generated');
				component.set('v.map', map);
				var layerGroup = L.layerGroup();
				component.set('v.layerGroup', layerGroup);
				component.set('v.generalOptions', [
					{'label': 'Land Grid Tracts', 'value': 'lgt'},
					{'label': 'Wells/Permits', 'value': 'well'},
					{'label': 'AOI Pricing', 'value': 'aoiPricing'},
					{'label': 'Rigs', 'value': 'rigs'},
					{'label': 'Type Curve', 'value': 'typeCurve'},
					{'label': 'Tiers', 'value': 'tiers'},

				]);
				component.set('v.generalSelectedOptions', [
					{'label': 'Land Grid Tracts', 'name': 'lgt'},
					//{'label': 'Rigs', 'name': 'rigs'},
					{'label': 'AOI Pricing', 'name': 'aoiPricing'}
				]);

				if ((tractURL == null || tractURL == undefined)&&
					(subtractURL == null || subtractURL == undefined)&&
					(verticalUnitURL == null || verticalUnitURL == undefined)&&
					(horizontalUnitURL == null || horizontalUnitURL == undefined)&&
					(horizontalProducingWellURL == null || horizontalProducingWellURL == undefined)&&
					(horizontalPermitWellURL == null || horizontalPermitWellURL == undefined)&&
					(horizontalDUCWellURL == null || horizontalDUCWellURL == undefined)&&
					(verticalWellURL == null || verticalWellURL == undefined)&&
					(activeSubtractURL == null || activeSubtractURL == undefined)&&
					(inactiveSubtractURL == null || inactiveSubtractURL == undefined)
					) {
					component.set('v.noMap', true);
				}
				console.log('bounds are: ' );
				console.log(Object.keys(bounds).length);
				if(Object.keys(bounds).length > 0){
					map.fitBounds(bounds);
				}
				else{
					tractURL = null;
					subtractURL = null;
					verticalUnitURL = null;
					horizontalUnitURL = null;
					horizontalProducingWellURL = null;
					horizontalPermitWellURL = null;
					horizontalDUCWellURL = null;
					verticalWellURL = null;
					activeSubtractURL = null;
					inactiveSubtractURL = null;
					component.set('v.noMap', true);
				}
				if (component.get('v.noMap')){
					console.log('no map');
					map.setView([32.0291332,-102.1922769], 6);
					bounds = map.getBounds();
					var marker = new L.marker([32.0291332,-102.1922769], { opacity: 0.01 }); //opacity may be set to zero
					marker.bindTooltip("No Tracts, Subtracts, Wells, or Units Found", {permanent: true, className: "my-label", offset: [0, 0] });
					marker.addTo(map);
					
					component.set('v.allLayersLoaded', true);
				}
				else{
					component.set('v.scopedSelectedOptions', scopedSelectedOptions);
					info.push({verticalUnitInfo:verticalUnitInfo, 
							   tractInfo:tractInfo, 
							   subtractInfo:subtractInfo, 
							   horizontalUnitInfo:horizontalUnitInfo, 
							   horizontalProducingWellInfo: horizontalProducingWellInfo,
							   horizontalPermitWellInfo: horizontalPermitWellInfo,
							   horizontalDUCWellInfo: horizontalDUCWellInfo, 
							   verticalWellInfo: verticalWellInfo, 
							   inactiveSubtractInfo: inactiveSubtractInfo, 
							   activeSubtractInfo: activeSubtractInfo
							   });
					component.set('v.scopedOptions', scopedOptions);
					
			
					
				}
				

				
					
				
				// Add custom SRP tiles
				//var customTiles = L.tileLayer(tlCustom);
				
				//component.set('v.customTilesLayer', customTiles);
				//layerGroup.addLayer(customTiles);
				/*var mapRefresh = setInterval(function() {
				   var action = component.get("c.getClientToken");
				   if (action)
				   {
						action.setCallback(this,function(response) {
							var state = response.getState();
							if (state === "SUCCESS") {
								// Get the token and set it on the attribute
								var result = response.getReturnValue();
								component.set("v.token",result);
								//console.log('set a token' + result);
								var layerGroup = component.get('v.layerGroup');
								layerGroup.removeLayer(component.get('v.customTilesLayer'));
								tlCustom = 'https://maps.strongholdresourcepartners.com/arcgis/rest/services/SRP/Landgrid_LS/MapServer/tile/{z}/{y}/{x}?token=' + result;
								customTiles = L.tileLayer(tlCustom);
								component.set('v.customTilesLayer', customTiles);
								layerGroup.addLayer(customTiles);
							}
							else if (state === "INCOMPLETE") {
								alert('result incomplete');
							}
							else if (state === "ERROR") {
								var errors = response.getError();
								if (errors) {
									if (errors[0] && errors[0].message) {
										console.log("Error message: " + errors[0].message);
										reject(errors);
									}
									} else {
										console.log("Unknown error");
										}
								}
							});
						$A.enqueueAction(action);
				   }
				   else
				   {
					   clearInterval(mapRefresh);
				   }
				//},3000); // for testing
				},1500000); // reset the layer every 25 minutes
				*/
				var tractColor = '#006AFF';
				var tractFillColor = '#3388ff';
				var subtractColor = '#3BC48B';
				var subtractFillColor = '#62D0A2';
				var verticalWellColor = '#906f8f';
				var verticalWellFillColor = '#A68CA5';
				var horizontalWellColor = '#56A964'
				var horizontalWellFillColor = '#78BA83'
				var inactiveSubtractColor = '#F3B50C';
				var inactiveSubtractFillColor = '#F5C43D';
				var unitColor = '#A600FF';
				var unitFillColor = '#B833FF';
				var highlightColor = '#f9f9ae';
				var tractGLayer;
				var subtractGLayer;
				var horizontalUnitGLayer;
				var verticalUnitGLayer;
				var verticalWellGLayer;
				var horizontalProducingWellGLayer;
				var horizontalPermitWellGLayer;
				var horizontalDUCWellGLayer;
				var activeSubtractGLayer;
				var inactiveSubtractGLayer;

				var tractStyle = {
                    "color": tractColor,
                    "fillColor" : tractFillColor,
                    "weight": 2,
                    "fillOpacity": .15
                };
				var subtractStyle = {
                    "color": subtractColor,
                    "fillColor" : subtractFillColor,
                    "weight": 2,
                    "fillOpacity": .15
                };
				var unitStyle = {
                    "color": unitColor,
                    "fillColor" : unitFillColor,
                    "weight": 2,
                    "fillOpacity": .15
                };
				var inactiveSubtractStyle = {
                    "color": inactiveSubtractColor,
                    "fillColor" : inactiveSubtractFillColor,
                    "weight": 2,
                    "fillOpacity": .15
                };

				var verticalWellStyle = {
                    "color": verticalWellColor,
                    "fillColor" : verticalWellFillColor,
                    "weight": 2,
                    "fillOpacity": .15
                };

				var horizontalProducingWellStyle = {
                    "color": horizontalWellColor,
                    "fillColor" : horizontalWellFillColor,
                    "weight": 2,
                    "fillOpacity": .15
                };
				
				var horizontalPermitWellStyle = {
                    "color": horizontalWellColor,
                    "fillColor" : horizontalWellFillColor,
                    "weight": 2,
                    "fillOpacity": .15, 
					"dashArray": 8
                };

				var horizontalDUCWellStyle = {
                    "color": horizontalWellColor,
                    "fillColor" : horizontalWellFillColor,
                    "weight": 2,
                    "fillOpacity": .15, 
					"dashArray": 8
                };
				//map.setView([32.0291332,-102.1922769], 6);
				
				//map.zoomOut(1);
				//var bounds = L.latLngBounds([]);
				//bounds.extend(map.getBounds());
				
				if (verticalUnitURL) {
					console.log('Buidling verticalUnit layer and url value is: ' + verticalUnitURL);
					var verticalUnitGLayer = helper.drawLayer(component, helper, verticalUnitURL, verticalUnitWhereClause, unitStyle, info, 'verticalUnit', layerGroup);
					verticalUnitGLayer.once('load', function (evt) {
						component.set('v.verticalUnitLayerLoaded', true);
						/*verticalUnitGLayer.eachFeature(function (layer) {
							// get the bounds of an individual feature
							console.log('Calling Layer get bounds from verticalUnitGLayer');
							//var layerBounds = layer.getBounds();
							// extend the bounds of the collection to fit the bounds of the new feature
							//bounds.extend(layerBounds);
						});*/
					});
					//var verticalUnitGLayer = helper.drawLayer(component, helper, map, verticalUnitGEOJSON, unitStyle, info, 'verticalUnit', layerGroup);
					component.set('v.verticalUnitLayer', verticalUnitGLayer);
					component.set('v.hasVerticalUnitlayer', true);
					//layerGroup.addLayer(verticalUnitGLayer);
				}
				if (horizontalUnitURL) {
					console.log('Buidling horizontalUnit layer and url value is: ' + horizontalUnitURL);
					var horizontalUnitGLayer = helper.drawLayer(component, helper, horizontalUnitURL, horizontalUnitWhereClause, unitStyle, info, 'horizontalUnit', layerGroup );
					horizontalUnitGLayer.once('load', function (evt) {
						component.set('v.horizontalUnitLayerLoaded', true);
						/*horizontalUnitGLayer.eachFeature(function (layer) {
							// get the bounds of an individual feature
							console.log('Calling Layer get bounds from horizontalUnitGLayer');
							//var layerBounds = layer.getBounds();
							// extend the bounds of the collection to fit the bounds of the new feature
							//bounds.extend(layerBounds);
						});*/
					});
					//var horizontalUnitGLayer = helper.drawLayer(component, helper, map, horizontalUnitGEOJSON, unitStyle, info, 'horizontalUnit',  layerGroup);
					component.set('v.horizontalUnitLayer', horizontalUnitGLayer);
					component.set('v.hasHorizontalUnitLayer', true);
					layerGroup.addLayer(horizontalUnitGLayer);		
				}
				if (subtractURL) {
					console.log('Buidling subtract layer and url value is: ' + subtractURL);
					var subtractGLayer = helper.drawLayer(component, helper, subtractURL, subtractWhereClause, subtractStyle, info, 'subtract', layerGroup);
					subtractGLayer.once('load', function (evt) {
						component.set('v.subtractLayerLoaded', true);
						/*subtractGLayer.eachFeature(function (layer) {
							// get the bounds of an individual feature
							console.log('Calling Layer get bounds from subtractGLayer');
							//var layerBounds = layer.getBounds();
							// extend the bounds of the collection to fit the bounds of the new feature
							//bounds.extend(layerBounds);
						});*/
					});
					//var subtractGLayer = helper.drawLayer(component, helper, map, subtractGEOJSON, subtractStyle, info, 'subtract', layerGroup);
					component.set('v.subtractLayer', subtractGLayer);
					component.set('v.hasSubtractLayer', true);
					layerGroup.addLayer(subtractGLayer);	
				}
				if (tractURL) {
					console.log('Buidling tract layer and url value is: ' + tractURL);
					var tractGLayer = helper.drawLayer(component, helper, tractURL, tractWhereClause, tractStyle, info, 'tract', layerGroup);
					console.log('tractGLayer value is :');
					console.log(tractGLayer);
					tractGLayer.once('load', function (evt) {
						console.log('Inside TractLayer load and value is: ');
						console.log(tractGLayer);
						//console.log('tractGLayer value loaded, return value size is :' + Object.size(tractGLayer._layers));
						component.set('v.tractLayerLoaded', true);
						/*var featureCount = 0;
						tractGLayer.eachFeature(function (layer) {
							// get the bounds of an individual feature
							featureCount++;
							console.log('Calling Layer get bounds from tractGLayer');
							//var layerBounds = layer.getBounds();
							// extend the bounds of the collection to fit the bounds of the new feature
							//bounds.extend(layerBounds);
						});
						console.log('featureCount value is: ' + featureCount + ' expectedCount is: ' + tractCount );*/
					});
					component.set('v.tractLayer', tractGLayer);
					component.set('v.hasTractLayer', true);
					layerGroup.addLayer(tractGLayer);		
				}
				if (horizontalProducingWellURL) {
					console.log('Buidling horizontalProducingWell layer and url value is: ' + horizontalProducingWellURL);
					var horizontalProducingWellGLayer = helper.drawLayer(component, helper, horizontalProducingWellURL, horizontalProducingWellWhereClause, horizontalProducingWellStyle, info, 'horizontalProducingWell', layerGroup);
					horizontalProducingWellGLayer.once('load', function (evt) {
						component.set('v.horizontalProducingWellLayerLoaded', true);
						/*horizontalProducingWellGLayer.eachFeature(function (layer) {
							// get the bounds of an individual feature
							console.log('Calling Layer get bounds from horizontalProducingWellGLayer');
							//var layerBounds = layer.getBounds();
							// extend the bounds of the collection to fit the bounds of the new feature
							//bounds.extend(layerBounds);
						});*/
					});
					//var horizontalProducingWellGLayer = helper.drawLayer(component, helper, map, horizontalProducingWellGEOJSON, horizontalProducingWellStyle, info, 'horizontalProducingWell', layerGroup);
					component.set('v.horizontalProducingWellLayer', horizontalProducingWellGLayer);
					component.set('v.hasHorizontalProducingWellLayer', true);
					layerGroup.addLayer(horizontalProducingWellGLayer);	
				}
				
				if (horizontalPermitWellURL) {
					console.log('Buidling horizontalPermitWell layer and url value is: ' + horizontalPermitWellURL);
					var horizontalPermitWellGLayer = helper.drawLayer(component, helper, horizontalPermitWellURL, horizontalPermitWellWhereClause, horizontalPermitWellStyle, info, 'horizontalPermitWell', layerGroup);
					horizontalPermitWellGLayer.once('load', function (evt) {
						component.set('v.horizontalPermitWellLayerLoaded', true);
						/*horizontalPermitWellGLayer.eachFeature(function (layer) {
							// get the bounds of an individual feature
							console.log('Calling Layer get bounds from horizontalPermitWellGLayer');
							//var layerBounds = layer.getBounds();
							// extend the bounds of the collection to fit the bounds of the new feature
							//bounds.extend(layerBounds);
						});*/
					});
					//var horizontalPermitWellGLayer = helper.drawLayer(component, helper, map, horizontalPermitWellGEOJSON, horizontalPermitWellStyle, info, 'horizontalPermitWell', layerGroup);
					component.set('v.horizontalPermitWellLayer', horizontalPermitWellGLayer);
					component.set('v.hasHorizontalPermitWellLayer', true);
					layerGroup.addLayer(horizontalPermitWellGLayer);	
				}

				if (horizontalDUCWellURL) {
					console.log('Buidling horizontalDUCWell layer and url value is: ' + horizontalDUCWellURL);
					var horizontalDUCWellGLayer = helper.drawLayer(component, helper, horizontalDUCWellURL, horizontalDUCWellWhereClause, horizontalDUCWellStyle, info, 'horizontalDUCWell', layerGroup);
					horizontalDUCWellGLayer.once('load', function (evt) {
						component.set('v.horizontalDUCWellLayerLoaded', true);
						/*horizontalDUCWellGLayer.eachFeature(function (layer) {
							// get the bounds of an individual feature
							console.log('Calling Layer get bounds from horizontalDUCWellGLayer');
							//var layerBounds = layer.getBounds();
							// extend the bounds of the collection to fit the bounds of the new feature
							//bounds.extend(layerBounds);
						});*/
					});
					//var horizontalDUCWellGLayer = helper.drawLayer(component, helper, map, horizontalDUCWellGEOJSON, horizontalDUCWellStyle, info, 'horizontalDUCWell', layerGroup);
					component.set('v.horizontalDUCWellLayer', horizontalDUCWellGLayer);
					component.set('v.hasHorizontalDUCWellLayer', true);
					layerGroup.addLayer(horizontalDUCWellGLayer);	
				}

				if (verticalWellURL) {
					console.log('Buidling verticalWell layer and url value is: ' + verticalWellURL);
					var verticalWellGLayer = helper.drawLayer(component, helper, verticalWellURL, verticalWellWhereClause, verticalWellStyle, info, 'verticalWell', layerGroup);
					verticalWellGLayer.once('load', function (evt) {
						component.set('v.verticalWellLayerLoaded', true);
						/*verticalWellGLayer.eachFeature(function (layer) {
							console.log(layer);
							// get the bounds of an individual feature
							console.log('Calling Layer get bounds from verticalWellGLayer');
							//var layerBounds = layer.getBounds();
							// extend the bounds of the collection to fit the bounds of the new feature
							//bounds.extend(layerBounds);
						});*/
					});
					//var verticalWellGLayer = helper.drawLayer(component, helper, map, verticalWellGEOJSON, verticalWellStyle, info, 'verticalWell', layerGroup);
					component.set('v.verticalWellLayer', verticalWellGLayer);
					component.set('v.hasVerticalWellLayer', true);
					//layerGroup.addLayer(verticalWellGLayer);	
				}

				if (activeSubtractURL) {
					console.log('Buidling activeSubtract layer and url value is: ' + activeSubtractURL);
					var activeSubtractGLayer = helper.drawLayer(component, helper, activeSubtractURL, activeSubtractWhereClause, subtractStyle, info, 'activeSubtract', layerGroup);
					activeSubtractGLayer.once('load', function (evt) {
						component.set('v.activeSubtractLayerLoaded', true);
						/*activeSubtractGLayer.eachFeature(function (layer) {
							// get the bounds of an individual feature
							console.log('Calling Layer get bounds from activeSubtractGLayer');
							//var layerBounds = layer.getBounds();
							// extend the bounds of the collection to fit the bounds of the new feature
							//bounds.extend(layerBounds);
						});*/
					});
					//var activeSubtractGLayer = helper.drawLayer(component, helper, map, activeSubtractGEOJSON, subtractStyle, info, 'activeSubtract',  layerGroup);
					component.set('v.activeSubtractLayer', activeSubtractGLayer);
					component.set('v.hasActiveSubtractLayer', true);
					layerGroup.addLayer(activeSubtractGLayer);	
				}
				
				if (inactiveSubtractURL) {
					console.log('Buidling inactiveSubtract layer and url value is: ' + inactiveSubtractURL);
					var inactiveSubtractGLayer = helper.drawLayer(component, helper, inactiveSubtractURL, inactiveSubtractWhereClause, inactiveSubtractStyle, info, 'inactiveSubtract', layerGroup);
					inactiveSubtractGLayer.once('load', function (evt) {
						component.set('v.inactiveSubtractLayerLoaded', true);
						/*inactiveSubtractGLayer.eachFeature(function (layer) {
							// get the bounds of an individual feature
							console.log('Calling Layer get bounds from inactiveSubtractGLayer');
							//var layerBounds = layer.getBounds();
							// extend the bounds of the collection to fit the bounds of the new feature
							//bounds.extend(layerBounds);
						});*/
					});
					//var inactiveSubtractGLayer = helper.drawLayer(component, helper, map, inactiveSubtractGEOJSON, inactiveSubtractStyle, info, 'inactiveSubtract', layerGroup);
					component.set('v.inactiveSubtractLayer', inactiveSubtractGLayer);
					component.set('v.hasInactiveSubtractLayer', true);
					layerGroup.addLayer(inactiveSubtractGLayer);	
				}
				layerGroup.addTo(map);
				// Add the tract overlay
				var customTilesLayer = L.esri.tiledMapLayer({
				  url: 'https://maps.strongholdresourcepartners.com/arcgis/rest/services/SRP/Landgrid_LS/MapServer',
				  token: authToken,
				  maxZoom: 12
				}).addTo(map);
				component.set('v.customTilesLayer', customTilesLayer);
				var lgtLayer = L.esri.dynamicMapLayer({
					url: 'https://maps.strongholdresourcepartners.com/arcgis/rest/services/SRP/Landgrid_HS/MapServer',
					opacity: 0.7,
					token: authToken,
					minZoom: 13,
					maxZoom: 16
				  }).addTo(map);
				component.set('v.lgtLayer', lgtLayer);
				// Add the wells/permits/etc. layer
				var dynMapWells = L.esri.dynamicMapLayer({
					  url: 'https://maps.strongholdresourcepartners.com/arcgis/rest/services/AppServices/SF_Proximity/MapServer',
					  opacity: 0.45,
					  token: authToken,
					  layers:[0,1,2,3]
					});
				component.set('v.wellLayer', dynMapWells);
				var aoiPricingLayer = L.esri.dynamicMapLayer({
					  url: 'https://maps.strongholdresourcepartners.com/arcgis/rest/services/SRP/SRPMidlandBasinAMI/MapServer',
					  opacity: 0.45,
					  token: authToken,
					  layers:[8]
					}).addTo(map);
				component.set('v.aoiPricingLayer', aoiPricingLayer);
				var rigsLayer = L.esri.dynamicMapLayer({
					  url: 'https://maps.strongholdresourcepartners.com/arcgis/rest/services/AppServices/SF_Proximity/MapServer',
					  opacity: 0.45,
					  token: authToken,
					  layers:[4]
					});
				component.set('v.rigsLayer', rigsLayer);
				var typeCurveLayer = L.esri.dynamicMapLayer({
					  url: 'https://maps.strongholdresourcepartners.com/arcgis/rest/services/AppServices/SF_Areas/MapServer',
					  opacity: 0.45,
					  token: authToken,
					  layers:[0]
					});
				component.set('v.typeCurveLayer', typeCurveLayer);
				var tiersLayer = L.esri.dynamicMapLayer({
					  url: 'https://maps.strongholdresourcepartners.com/arcgis/rest/services/AppServices/SF_Areas/MapServer',
					  opacity: 0.45,
					  token: authToken,
					  layers:[1]
					});
				component.set('v.tiersLayer', tiersLayer);
				//dynMapWells.bringToFront();

				// Add popups for well/permit clicks
				dynMapWells.bindPopup(function (error, featureCollection) {

					if(error || featureCollection.features.length === 0) {
					  console.log(JSON.stringify(featureCollection));
					  return false;
					} else {
						L.DomUtil.addClass(map._container,'crosshair-cursor-enabled');
						var props = featureCollection.features[0].properties;
						if (props.WellName)
						{
							var popString = 'WELL<br />';
							popString += 'Name: ' + props.WellName + '<BR />';
							popString += 'Operator: ' + props.CurrentOperatorName + '<BR />';
							popString += '<div style="width: 100%; height: 120px; overflow-y: scroll;">';
							var allItems = Object.entries(props);
							for (var i=0;i<allItems.length;i++) {
								popString += String(allItems[i]).replace(/,/g,': ') + '<br />';
							}
							popString +='</div>';
							return popString;
						}
						else if (props.permit_id)
						{
							var popString = 'PERMIT<br />';
							popString += 'ID: ' + props.permit_id + '<BR />';
							popString += 'Operator: ' + props.operator + '<BR />';
							popString += '<div style="width: 100%; height: 120px; overflow-y: scroll;">';
							var allItems = Object.entries(props);
							for (var i=0;i<allItems.length;i++) {
								popString += String(allItems[i]).replace(/,/g,': ') + '<br />';
							}
							popString +='</div>';
							return popString;

						}
						else
						{
							return JSON.stringify(props);
						}

					}
				  });

				aoiPricingLayer.bindPopup(function (error, featureCollection) {
					
					if(error || featureCollection.features.length === 0) {
					  console.log(JSON.stringify(featureCollection));
					  return false;
					} else {
						L.DomUtil.addClass(map._container,'crosshair-cursor-enabled');
						var props = featureCollection.features[0].properties;
						var popString = 'AOI<br />';
						popString += 'Name: ' + props.NAME + '<br />';
						popString += 'Acres: ' + props.ACRES + '<br />';
						popString += 'Target Price: ' + props.TargetAOIPrice + '<br />';
						popString += 'Max OTG Price : ' + props.AOIMaxOTGPrice + '<br />';
						return popString;
					}
				  });

				  rigsLayer.bindPopup(function (error, featureCollection) {
					
					if(error || featureCollection.features.length === 0) {
					  console.log(JSON.stringify(featureCollection));
					  return false;
					} else {
						L.DomUtil.addClass(map._container,'crosshair-cursor-enabled');
						var props = featureCollection.features[0].properties;
						var popString = 'Rig<br />';
						popString += 'API10: ' + props.API10 + '<br />';
						popString += 'Active Name: ' + props.ActiveCommonName + '<br />';
						popString += 'Contractor Name: ' + props.ContractorName + '<br />';
						popString += 'Spud Date: ' + props.SpudDate + '<br />';
						return popString;
					}
				  });

				  typeCurveLayer.bindPopup(function (error, featureCollection) {
					
					if(error || featureCollection.features.length === 0) {
					  console.log(JSON.stringify(featureCollection));
					  return false;
					} else {
						L.DomUtil.addClass(map._container,'crosshair-cursor-enabled');
						var props = featureCollection.features[0].properties;
						var popString = 'Type Curve<br />';
						popString += 'AOI: ' + props.Polygon_Name + '<br />';
						popString += 'Owner: ' + props.Source + '<br />';
						popString += '<a target="_blank" href="http://sf01-2016.ad.srp-ok.com/spotfire/wp/OpenAnalysis?file=/AnalysisFiles/Engineering/MCS%20-%20Manuel/WEPLA_v1.0">Type Curve Library</a><br />';
						return popString;
					}
				  });

				  tiersLayer.bindPopup(function (error, featureCollection) {
					
					if(error || featureCollection.features.length === 0) {
					  console.log(JSON.stringify(featureCollection));
					  return false;
					} else {
						L.DomUtil.addClass(map._container,'crosshair-cursor-enabled');
						var props = featureCollection.features[0].properties;
						var popString = 'Basin Tier<br />';
						popString += 'Basin: ' + props.BASIN + '<br />';
						popString += 'SubBasin: ' + props.SUBBASIN + '<br />';
						popString += 'Name: ' + props.NAME + '<br />';
						//popString += '<a target="_blank" href="http://sf01-2016.ad.srp-ok.com/spotfire/wp/OpenAnalysis?file=/AnalysisFiles/Engineering/MCS%20-%20Manuel/WEPLA_v1.0">Type Curve Library</a><br />';
						return popString;
					}
				  });

				map.options.minZoom=7;
				//console.log(tractGLayer);
				
				/*if (tractGLayer) {
					tractGLayer.query().bounds(function(error, latlngbounds){
																if(error){
																	console.log('Error running "Query" operation on Tract Bounds: ' + error);
																 }
																 console.log(latlngbounds);
																 map.fitBounds(latlngbounds);
																});
				}
					
				else if (subtractGLayer) {
					map.fitBounds(subtractGLayer.getBounds());
					if (subtractGEOJSON.features.length <= 2) {
						map.zoomOut(1);
					}
				}
				else if (horizontalUnitGLayer) {
					map.fitBounds(horizontalUnitGLayer.getBounds());
					if (horizontalUnitGEOJSON.features.length <= 2) {
						map.zoomOut(1);
					}
				}
				else if (verticalUnitGLayer) {
					map.fitBounds(verticalUnitGLayer.getBounds());
					if (verticalUnitGEOJSON.features.length <= 2) {
						map.zoomOut(1);
					}
				}
				else {
					map.setView([32.0291332,-102.1922769], 6);
					var marker = new L.marker([32.0291332,-102.1922769], { opacity: 0.01 }); //opacity may be set to zero
					marker.bindTooltip("No Tracts, Subtracts, or Units Found", {permanent: true, className: "my-label", offset: [0, 0] });
					marker.addTo(map);
				}*/

		   }
		   else if (state === "INCOMPLETE") {
			   alert('result incomplete');
		   }
		   else if (state === "ERROR") {
			   var errors = response.getError();
			   if (errors) {
				   if (errors[0] && errors[0].message) {
					   console.log("Error message: " + errors[0].message);
				   }
				}else {
					console.log("Unknown error");
				}
			}
			//component.set('v.isWaiting', false);
		   });
       $A.enqueueAction(action);

    },
 
	drawLayer : function(component, helper, urlAddress, whereClause, mapStyle, info, mapType, layerGroup){
		var highlightColor = '#f9f9ae';
		var geojsonMarkerOptions = {
			radius: 1,
			fillColor: mapStyle.fillColor,
			color: mapStyle.color,
			weight: 1,
			opacity: 1,
			fillOpacity: 0.8
		};
		//console.log('url is: ' + urlAddress);
		//console.log('whereClause is: ' + whereClause);
		var gLayer = L.esri.featureLayer({url:urlAddress, where:whereClause, style: mapStyle, token: component.get('v.token'), pointToLayer: function(feature, latlng){
																			return L.circleMarker(latlng, geojsonMarkerOptions);
																		}
						, onEachFeature: function(feature,layer) {							
							layer.on({mouseover: function(){helper.highlightObject(feature, layer, highlightColor); console.log('mouseover event for mapType: ' + mapType);},
								mouseout: function(e) {
									if(info){
										helper.resetHighlight(e,mapStyle);
									}
								},
								click: function(e){
									var popupProps = helper.buildProps(e, feature, layer, layerGroup,info, mapType, component, helper, urlAddress, whereClause);
									if(popupProps.length > 1){
										popupProps.sort(function (a,b){
															var typeA = a.type;
															var typeB = b.type;

															if(typeA == 'Tract' && typeB != 'Tract'){
																return -1;
															}
															if(typeB == 'Tract' && typeA != 'Tract'){
																return 1;
															}
															if(typeA == 'Subtract' && typeB != 'Subtract'){
																return -1;
															}
															if(typeB == 'Subtract' && typeA != 'Subtract'){
																return 1;
															}
															if(typeA == 'activeSubtract' && typeB != 'activeSubtract'){
																return -1;
															}
															if(typeB == 'activeSubtract' && typeA != 'activeSubtract'){
																return 1;
															}
															if(typeA == 'inactiveSubtract' && typeB != 'inactiveSubtract'){
																return -1;
															}
															if(typeB == 'inactiveSubtract' && typeA != 'inactiveSubtract'){
																return 1;
															}
															if(typeA == 'HorizontalUnit' && typeB != 'HorizontalUnit'){
																return -1;
															}
															if(typeB == 'HorizontalUnit' && typeA != 'HorizontalUnit'){
																return 1;
															}
															if(typeA == 'VerticalUnit' && typeB != 'VerticalUnit'){
																return -1;
															}
															if(typeB == 'VerticalUnit' && typeA != 'VerticalUnit'){
																return 1;
															}
															if(typeA == 'HorizontalProducingWell' && typeB != 'HorizontalProducingWell'){
																return -1;
															}
															if(typeB == 'HorizontalProducingWell' && typeA != 'HorizontalProducingWell'){
																return 1;
															}
															if(typeA == 'HorizontalPermitWell' && typeB != 'HorizontalPermitWell'){
																return -1;
															}
															if(typeB == 'HorizontalPermitWell' && typeA != 'HorizontalPermitWell'){
																return 1;
															}
															if(typeA == 'HorizontalDUCWell' && typeB != 'HorizontalDUCWell'){
																return -1;
															}
															if(typeB == 'HorizontalDUCWell' && typeA != 'HorizontalDUCWell'){
																return 1;
															}
															if(typeA == 'VerticalWell' && typeB != 'VerticalWell'){
																return -1;
															}
															if(typeB == 'VerticalWell' && typeA != 'VerticalWell'){
																return 1;
															}
															return 0;

														});
									}
									var popupText = helper.buildPopup(popupProps);
									if(popupText != ''){
										layer.bindPopup(popupText).openPopup();
									}
								}

							});
					}})
		return gLayer;
	},
	buildPopup :function (props){
			var otgCost = '';
			var popupText = '';
			for(var prop in props){
				if(popupText != ''){
					popupText +='<br /><br />';
				}
				if(props[prop] && (props[prop].type == 'Tract' || props[prop].type == 'Subtract' || props[prop].type == 'activeSubtract' || props[prop].type == 'inactiveSubtract')){
					if (props[prop] && props[prop].otgCost) {
						otgCost = '  OTG Cost: <em>$' + props[prop].otgCost.toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,') + '</em>';
					}
					popupText += (props[prop] ?
						'<strong>' + props[prop].name + '</strong><br />' + props[prop].legalName + '<br />' +
						'Acres: <em>' + props[prop].netAcres + '</em> Gross Acres: <em>' + props[prop].grossAcres +
						'</em><br />' + otgCost
						: '');
				}
				else if(props[prop] && (props[prop].type == 'HorizontalProducingWell' || props[prop].type == 'HorizontalPermitWell' ||props[prop].type == 'HorizontalDUCWell')){
					
					popupText += (props[prop] ?
						'<strong>Horizontal Well</strong><br />'+ 
						'<strong>' + props[prop].name + '</strong><br />' + 
						'API10: <em>' + props[prop].API10 + '</em><br />' +
						'API14: <em>' + props[prop].API14 + '</em><br />' +
						'Operator: <em>' + props[prop].currentOperator + '</em><br />' +
						'Basin: <em>' + props[prop].BasinName + '</em><br />' +
						'SubBasin: <em>' + props[prop].SubBasinName + '</em><br />' +
						'County: <em>' + props[prop].County + '</em><br />' +
						'Well Status: <em>' + props[prop].wellStatus + '</em><br />'
						: '');
				}
				else if(props[prop] && props[prop].type == 'VerticalWell'){
					popupText += (props[prop] ?
						'<strong>Vertical Well</strong><br />'+ 
						'<strong>' + props[prop].name + '</strong><br />' + 
						'API10: <em>' + props[prop].API10 + '</em><br />' +
						'API14: <em>' + props[prop].API14 + '</em><br />' +
						'Operator: <em>' + props[prop].currentOperator + '</em><br />' +
						'Basin: <em>' + props[prop].BasinName + '</em><br />' +
						'SubBasin: <em>' + props[prop].SubBasinName + '</em><br />' +
						'County: <em>' + props[prop].County + '</em><br />'
						: '');
				}
				else if(props[prop] && (props[prop].type == 'HorizontalUnit' || props[prop].type == 'VerticalUnit')){
					popupText += (props[prop] ?
						'<strong>' + props[prop].name + '</strong><br />'+
						'Unit Type: <em>' + props[prop].unitType + '</em><br/>' + 
						'Gross Acres: <em>' + props[prop].grossAcres +
						'</em>'
						: '');
				}
			}
			return popupText;
		},

		resetHighlight: function (e,style) {
			var layer = e.target;
				layer.setStyle(style);
		},

		highlightObject:function (feature, layer, highlightColor) {
			layer.setStyle({
				weight: 2,
				fillColor: highlightColor,
				dashArray: '',
				fillOpacity: .55
			})
		},

		buildProps : function(e, feature, currentLayer, layerGroup,info, mapType, component, helper, urlAddress, whereClause){
			//console.log('inside build props');
			var props = [];
			var subtractLayer = component.get('v.subtractLayer');
			var activeSubtractLayer = component.get('v.activeSubtractLayer');
			var inactiveSubtractLayer = component.get('v.inactiveSubtractLayer');
			layerGroup.eachLayer(function(layer){
				for(const itemLayer in layer._layers){
					var currentLayer = layer._layers[itemLayer];
					if(currentLayer.feature.geometry.type == 'Polygon'){
						if(helper.isMarkerInsidePolygon(e.latlng, currentLayer)){
							if (currentLayer.feature.properties.Tract_ID != null && currentLayer.feature.properties.Tract_ID != undefined && currentLayer.feature.properties.Tract_ID.substring(0,3) == 'a00') {
								var ti = info[0].tractInfo[currentLayer.feature.properties.Tract_ID];
								props.push({name:currentLayer.feature.properties.Tract_Name,
									legalName: ti.Full_Legal_Name__c,
									netAcres: ti.netAcres__c,
									grossAcres: ti.Gross_Acres__c,
									otgCost: ti.OTG_Cost__c,
									type:'Tract'
								});
							}
							else if (currentLayer.feature.properties.Tract_ID != null && currentLayer.feature.properties.Tract_ID != undefined && currentLayer.feature.properties.Tract_ID.substring(0,3) == 'a01') {
								var sti;
								if(info[0].subtractInfo && info[0].subtractInfo != undefined && info[0].subtractInfo[currentLayer.feature.properties.Tract_ID] && info[0].subtractInfo[currentLayer.feature.properties.Tract_ID] != undefined){
									sti =  info[0].subtractInfo[currentLayer.feature.properties.Tract_ID];
								}
								else if(info[0].inactiveSubtractInfo && info[0].inactiveSubtractInfo != undefined && info[0].inactiveSubtractInfo[currentLayer.feature.properties.Tract_ID] && info[0].inactiveSubtractInfo[currentLayer.feature.properties.Tract_ID] != undefined){
									sti =  info[0].inactiveSubtractInfo[currentLayer.feature.properties.Tract_ID];
								}
								else if(info[0].activeSubtractInfo && info[0].activeSubtractInfo != undefined && info[0].activeSubtractInfo[currentLayer.feature.properties.Tract_ID] && info[0].activeSubtractInfo[currentLayer.feature.properties.Tract_ID] != undefined){
									sti =  info[0].activeSubtractInfo[currentLayer.feature.properties.Tract_ID];
								}
								props.push({name:currentLayer.feature.properties.Tract_Name,
									legalName: (sti.Subtract_Quarter_Call__c != undefined ? sti.Subtract_Quarter_Call__c + ' '  : '') + (sti.Subtract_Full_Legal_Description__c ? sti.Subtract_Full_Legal_Description__c : ''),
									netAcres: (sti.Subtract_Acres__c ? sti.Subtract_Acres__c : ''),
									grossAcres: (sti.Subtract_Gross_Acres__c ? sti.Subtract_Gross_Acres__c : ''),
									otgCost:null,
									type:'Subtract'
								});
							}
							else if((currentLayer.feature.properties.UnitType != null && currentLayer.feature.properties.UnitType != undefined && currentLayer.feature.properties.UnitType == 'Vertical')){
								var ui =  info[0].verticalUnitInfo[currentLayer.feature.id];
								props.push({name:ui.Name,
									grossAcres: (ui.Gross_Acres__c ? ui.Gross_Acres__c : ''),
									gISNumber: currentLayer.feature.properties.OBJECTID,
									gISNumberSF: ui.GIS_Unit_Name__c,
									type:'VerticalUnit',
									unitType: (currentLayer.feature.properties.UnitType? currentLayer.feature.properties.UnitType: '')
								});
							}
							else if((currentLayer.feature.properties.UnitType != null && currentLayer.feature.properties.UnitType != undefined && currentLayer.feature.properties.UnitType == 'Horizontal')){
								var ui =  info[0].horizontalUnitInfo[currentLayer.feature.id];
								props.push({name:ui.Name,
									grossAcres: (ui.Gross_Acres__c ? ui.Gross_Acres__c : ''),
									gISNumber: currentLayer.feature.properties.OBJECTID,
									gISNumberSF: ui.GIS_Unit_Name__c,
									type:'HorizontalUnit',
									unitType: (currentLayer.feature.properties.UnitType? currentLayer.feature.properties.UnitType: '')
								});
							}
						}
					}
					else if(currentLayer.feature.geometry.type == 'Point'){
						if(helper.isMarkerPoint(e.latlng, currentLayer)){
							var wi = info[0].verticalWellInfo[currentLayer.feature.properties.UWI];
							//console.log(wi);
							if(wi != null && wi != undefined){
								props.push({name:wi.Name,
									API10: (wi.API10__c ? wi.API10__c : ''),
									API14: (wi.API14__c ? wi.API14__c : ''),
									currentOperator: currentLayer.feature.properties.CurrentOperatorName,
									BasinName: currentLayer.feature.properties.BasinName,
									SubBasinName: currentLayer.feature.properties.SubBasinName,
									County: currentLayer.feature.properties.CountyName,
									wellStatus: (wi.wellStatus__c ? wi.wellStatus__c : ''),
									type:'VerticalWell'
								});
							}
						}
					}
					else if(currentLayer.feature.geometry.type == 'LineString' && mapType == 'horizontalProducingWell'){
						if(helper.isMarkerOnLine(e.latlng, currentLayer, helper)){
							//console.log(feature);
							//console.log(info);
							var wi = info[0].horizontalProducingWellInfo[currentLayer.feature.properties.UWI];
							//console.log(wi);
							if(wi != null && wi != undefined){
								props.push({name:wi.Name,
									API10: (wi.API10__c ? wi.API10__c : ''),
									API14: (wi.API14__c ? wi.API14__c : ''),
									currentOperator: currentLayer.feature.properties.CurrentOperatorName,
									BasinName: currentLayer.feature.properties.BasinName,
									SubBasinName: currentLayer.feature.properties.SubBasinName,
									County: currentLayer.feature.properties.CountyName,
									wellStatus: (wi.wellStatus__c ? wi.wellStatus__c : ''),
									type:'HorizontalProducingWell'
								});
							}
						}
					}
					else if(currentLayer.feature.geometry.type == 'LineString' && mapType == 'horizontalDUCWell'){
						if(helper.isMarkerOnLine(e.latlng, currentLayer, helper)){
							//console.log(feature);
							//console.log(info);
							var wi = info[0].horizontalDUCWellInfo[currentLayer.feature.properties.UWI];
							//console.log(wi);
							if(wi != null && wi != undefined){
								props.push({name:wi.Name,
									API10: (wi.API10__c ? wi.API10__c : ''),
									API14: (wi.API14__c ? wi.API14__c : ''),
									currentOperator: currentLayer.feature.properties.CurrentOperatorName,
									BasinName: currentLayer.feature.properties.BasinName,
									SubBasinName: currentLayer.feature.properties.SubBasinName,
									County: currentLayer.feature.properties.CountyName,
									wellStatus: (wi.wellStatus__c ? wi.wellStatus__c : ''),
									type:'HorizontalDUCWell'
								});
							}
						}
					}
					else if(currentLayer.feature.geometry.type == 'LineString' && mapType == 'horizontalPermitWell'){
						//console.log('Inside Buidling Props for horizontalPermitWell.  latlng value is: ' + e.latlng);
						//console.log('evaluation of isMarkerOnLine value is: ' + helper.isMarkerOnLine(e.latlng, layer));
						if(helper.isMarkerOnLine(e.latlng, currentLayer, helper)){
							//console.log(feature);
							//console.log(info);
							var wi = info[0].horizontalPermitWellInfo[currentLayer.feature.properties.UWI];
							//console.log(wi);
							if(wi != null && wi != undefined){
								props.push({name:wi.Name,
									API10: (wi.API10__c ? wi.API10__c : ''),
									API14: (wi.API14__c ? wi.API14__c : ''),
									currentOperator: currentLayer.feature.properties.CurrentOperatorName,
									BasinName: currentLayer.feature.properties.BasinName,
									SubBasinName: currentLayer.feature.properties.SubBasinName,
									County: currentLayer.feature.properties.CountyName,
									wellStatus: (wi.wellStatus__c ? wi.wellStatus__c : ''),
									type:'HorizontalPermitWell'
								});
							}
						}
					}
				}
			});
			return props;
		},
		

		

		isMarkerInsidePolygon : function (marker, poly) {
			var returnPoly = poly.getLatLngs();   
			var polyPoints = returnPoly[0];  
			var x = marker.lat;
			var y = marker.lng;
			var inside = false;
			for (var i = 0, j = polyPoints.length - 1; i < polyPoints.length; j = i++) {
				var xi = polyPoints[i].lat, yi = polyPoints[i].lng;
				var xj = polyPoints[j].lat, yj = polyPoints[j].lng;

				var intersect = ((yi > y) != (yj > y))
					&& (x < (xj - xi) * (y - yi) / (yj - yi) + xi);
				if (intersect) inside = !inside;
			}
			return inside;
		},

		isMarkerPoint : function (marker, point) {
			var isPoint = false;
			var x = marker.lat;
			var y = marker.lng;
			var pointX = point._latlng.lat;
			var pointY = point._latlng.lng;

			//Check to see if click point is close enough to current point to include
			var difference = 0.0002;
			if(x< pointX + difference && x > pointX - difference && y < pointY + difference && y > pointY - difference){
				isPoint = true;
			} 
			return isPoint;
		},

		isMarkerOnLine : function (marker, line, helper) {
			//console.log('Inside isMarkerOnLine');
			//console.log(marker);
			//console.log(line);
			var isOnLine = false;
			var x = marker.lat;
			var y = marker.lng;
			var linePoints = line._latlngs;
			//console.log(linePoints);
			var difference = 0.0002;

			if(linePoints.length > 2){
				for(var coordinates in linePoints){
					if(x< linePoints[coordinates].lat + difference && x > linePoints[coordinates].lat - difference && y < linePoints[coordinates].lng + difference && y > linePoints[coordinates].lng - difference){
						isOnLine = true;
					}
				}
			}
			else{

				for(var i=0; i+1 < linePoints.length; i++){
					var coordinates = i;
					var nextCoordinate = i + 1;

					//console.log('coordinates value is: ' + coordinates);
					//console.log('nextCoordinate value is: ' + nextCoordinate);
					//console.log('linePoints size is: ' + linePoints.length);
					//console.log('line1 x value is: ' + linePoints[coordinates].lat + ' y value is: ' + linePoints[coordinates].lng);
					//console.log('line2 x value is: ' + linePoints[nextCoordinate].lat + ' y value is: ' + linePoints[nextCoordinate].lng);
					var line1 = {x:linePoints[coordinates].lat, y:linePoints[coordinates].lng};
					var line2 = {x:linePoints[nextCoordinate].lat, y:linePoints[nextCoordinate].lng};
					var point = {x:linePoints[nextCoordinate].lat, y:linePoints[nextCoordinate].lng};
					var point = {x:marker.lat, y:marker.lng};
					isOnLine = this.calcIsInsideThickLineSegment(line1, line2, point, difference);
					//console.log('isOnLine value is: ' + isOnLine);
					if(isOnLine){
						break;
					}
					//if(x< linePoints[coordinates].lat + difference && x > linePoints[coordinates].lat - difference && y < linePoints[coordinates].lng + difference && y > linePoints[coordinates].lng - difference){
						//isOnLine = true;
					//}
				}
			}
			return isOnLine;
			//var returnPoly = poly.getLatLngs();   
			//var polyPoints = returnPoly[0];  
			//var x = marker.lat;
			//var y = marker.lng;
			//var inside = false;
			//for (var i = 0, j = polyPoints.length - 1; i < polyPoints.length; j = i++) {
			//	var xi = polyPoints[i].lat, yi = polyPoints[i].lng;
			//	var xj = polyPoints[j].lat, yj = polyPoints[j].lng;
			//
			//	var intersect = ((yi > y) != (yj > y))
			//		&& (x < (xj - xi) * (y - yi) / (yj - yi) + xi);
			//	if (intersect) inside = !inside;
			//}
			//return inside;
		},

		//The most useful function. Returns bool true, if the mouse point is actually inside the (finite) line, given a line thickness from the theoretical line away. It also assumes that the line end points are circular, not square.
		calcIsInsideThickLineSegment: function (line1, line2, point, lineThickness) {
			//console.log('Inside calcIsInsideThickLineSegment');
			var L2 = ( ((line2.x - line1.x) * (line2.x - line1.x)) + ((line2.y - line1.y) * (line2.y - line1.y)) );
			if(L2 == 0) return false;
			var r = ( ((point.x - line1.x) * (line2.x - line1.x)) + ((point.y - line1.y) * (line2.y - line1.y)) ) / L2;
			//console.log('L2 value is: ' + L2 + ' r value is: ' + r);

			//Assume line thickness is circular
			if(r < 0) {
				//Outside line1
				return (Math.sqrt(( (line1.x - point.x) * (line1.x - point.x) ) + ( (line1.y - point.y) * (line1.y - point.y) )) <= lineThickness);
			} else if((0 <= r) && (r <= 1)) {
				//On the line segment
				var s = (((line1.y - point.y) * (line2.x - line1.x)) - ((line1.x - point.x) * (line2.y - line1.y))) / L2;
				return (Math.abs(s) * Math.sqrt(L2) <= lineThickness);
			} else {
				//Outside line2
				return (Math.sqrt(( (line2.x - point.x) * (line2.x - point.x) ) + ( (line2.y - point.y) * (line2.y - point.y) )) <= lineThickness);
			}
		},


		genMap: function (rec, tabId) {
			//var map = L.map('map').setView([37.75, -122.45], 12);
			console.log('Inside genMap function and tabId value is: ' + tabId);
			//L.esri.basemapLayer('Topographic').addTo(map);
            var map = L.map('map'+rec+tabId, {zoomControl: false, dragging: !L.Browser.mobile, tap: false, touchZoom: L.Browser.mobile, layers:[
                L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}')
            ]});
			return map;
        },

		resetMap: function(component){
			var map = component.get('v.map');
			map.remove();
			component.set('v.tractLayer', {});
			component.set('v.subtractLayer', {});
			component.set('v.horizontalUnitLayer', {});
			component.set('v.verticalUnitLayer', {});
			component.set('v.wellLayer', {});
			component.set('v.horizontalProducingWellLayer', {});
			component.set('v.horizontalPermitWellLayer', {});
			component.set('v.horizontalDUCWellLayer', {});
			component.set('v.verticalWellLayer', {});
			component.set('v.inactiveSubtractLayer', {});
			component.set('v.activeSubtractLayer', {});
			component.set('v.lgtLayer', {});
			component.set('v.aoiPricingLayer', {});
			component.set('v.customTilesLayer', {});
			component.set('v.rigsLayer', {});
			component.set('v.typeCurveLayer', {});
			component.set('v.tiersLayer', {});
			component.set('v.layerGroup', {});
			component.set('v.hasTractLayer', false);
			component.set('v.hasSubtractLayer', false);
			component.set('v.hasHorizontalUnitLayer', false);
			component.set('v.hasVerticalUnitLayer', false);
			component.set('v.hasHorizontalProducingWellLayer', false);
			component.set('v.hasHorizontalPermitWellLayer', false);
			component.set('v.hasHorizontalDUCWellLayer', false);
			component.set('v.hasVerticalWellLayer', false);
			component.set('v.hasInactiveSubtractLayer', false);
			component.set('v.hasActiveSubtractLayer', false);
			component.set('v.tractLayerLoaded', false);
			component.set('v.subtractLayerLoaded', false);
			component.set('v.horizontalUnitLayerLoaded', false);
			component.set('v.verticalUnitLayerLoaded', false);
			component.set('v.horizontalProducingWellLayerLoaded', false);
			component.set('v.horizontalPermitWellLayerLoaded', false);
			component.set('v.horizontalDUCWellLayerLoaded', false);
			component.set('v.verticalWellLayerLoaded', false);
			component.set('v.inactiveSubtractLayerLoaded', false);
			component.set('v.activeSubtractLayerLoaded', false);
			component.set('v.allLayersLoaded', false);
			component.set('v.bounds', {});
			component.set('v.map', {});
			component.set('v.token', '');
			component.set('v.generalOptions', []);
			component.set('v.scopedOptions', []);
			component.set('v.generalSelectedOptions', []);
			component.set('v.scopedSelectedOptions', []);
			//component.set('v.value', 'option1'/>
			component.set('v.isWaiting', false);
			component.set('v.recordId2', '');
			component.set('v.sObjectName', '');
		},

		loadMap: function (component, helper) {
			component.set('v.isWaiting', true);
			helper.setMapToken(component, helper).then(function(result) {
				//console.log('promise result:'+result);
				component.set("v.token",result);
				// Draw the map ONLY when we have the token
				helper.drawMap(component, helper);
			}).catch(function err(err) {
				console.log(err);
			})
			
				
		},

	
})