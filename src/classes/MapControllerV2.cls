public class MapControllerV2 {
	public static final String tractReturn = 'Tract';
	public static final String verticalUnitReturn = 'VerticalUnit';
	public static final String horizontalUnitReturn = 'HorizontalUnit';
	public static final String subtractReturn = 'Subtract';
	public static final String activeUASubtractReturn = 'activeUASubtract';
	public static final String inactiveUASubtractReturn = 'inactiveUASubtract';
	public static final String horizontalWellReturn = 'HorizontalWell';
	public static final String verticalWellReturn = 'VerticalWell';
	public static final String horizontalProducingWellReturn = 'HorizontalProducingWell';
	public static final String horizontalPermitWellReturn = 'HorizontalPermitWell';
	public static final String horizontalDUCWellReturn = 'HorizontalDUCWell';

	@AuraEnabled
	public static List<MapResponse> getMaps(Id objId,String objTypeName){
		List<MapResponse> response = new List<MapResponse>();
		List<Log__c> errorLogs = new List<Log__c>();
			if(objTypeName == 'Opportunity'){
				MapResponse tractResponse = getMap(objId, objTypeName, tractReturn);
				tractResponse.mapType = tractReturn;
				MapResponse horizontalUnitResponse = getMap(objId, objTypeName, HorizontalUnitReturn);
				horizontalUnitResponse.mapType = horizontalUnitReturn;
				MapResponse verticalUnitResponse = getMap(objId, objTypeName, VerticalUnitReturn);
				verticalUnitResponse.mapType = verticalUnitReturn;
				MapResponse verticalWellResponse = getMap(objId, objTypeName, verticalWellReturn);
				//MapResponse horizontalWellResponse = getMap(objId, objTypeName, horizontalWellReturn);
				
				verticalWellResponse.mapType = verticalWellReturn;
				//horizontalWellResponse.mapType = horizontalWellReturn;
				response.add(tractResponse);
				response.add(horizontalunitResponse);
				response.add(verticalunitResponse);
				response.add(verticalWellResponse);
				//response.add(horizontalWellResponse);
				MapResponse horizontalProducingWellResponse = getMap(objId, objTypeName, horizontalProducingWellReturn);
				MapResponse horizontalPermitWellResponse = getMap(objId, objTypeName, horizontalPermitWellReturn);
				MapResponse horizontalDUCWellResponse = getMap(objId, objTypeName, horizontalDUCWellReturn);
				horizontalProducingWellResponse.mapType = horizontalProducingWellReturn;
				horizontalPermitWellResponse.mapType = horizontalPermitWellReturn;
				horizontalDUCWellResponse.mapType = horizontalDUCWellReturn;
				response.add(horizontalProducingWellResponse);
				response.add(horizontalPermitWellResponse);
				response.add(horizontalDUCWellResponse);

			}

			if(objTypeName == 'Evaluation__c'){
				Evaluation__c currentEval = [SELECT Id, opportunity__c FROM Evaluation__c WHERE Id = :objId LIMIT 1];
				//Returning same result as Opportunity, set variables to related Opp values.
				objTypeName = 'Opportunity';
				objId = currentEval.opportunity__c;

				MapResponse tractResponse = getMap(objId, objTypeName, tractReturn);
				tractResponse.mapType = tractReturn;
				MapResponse horizontalUnitResponse = getMap(objId, objTypeName, HorizontalUnitReturn);
				horizontalUnitResponse.mapType = horizontalUnitReturn;
				MapResponse verticalUnitResponse = getMap(objId, objTypeName, VerticalUnitReturn);
				verticalUnitResponse.mapType = verticalUnitReturn;
				MapResponse verticalWellResponse = getMap(objId, objTypeName, verticalWellReturn);
				//MapResponse horizontalWellResponse = getMap(objId, objTypeName, horizontalWellReturn);
				
				verticalWellResponse.mapType = verticalWellReturn;
				//horizontalWellResponse.mapType = horizontalWellReturn;
				response.add(tractResponse);
				response.add(horizontalunitResponse);
				response.add(verticalunitResponse);
				response.add(verticalWellResponse);
				//response.add(horizontalWellResponse);
				MapResponse horizontalProducingWellResponse = getMap(objId, objTypeName, horizontalProducingWellReturn);
				MapResponse horizontalPermitWellResponse = getMap(objId, objTypeName, horizontalPermitWellReturn);
				MapResponse horizontalDUCWellResponse = getMap(objId, objTypeName, horizontalDUCWellReturn);
				horizontalProducingWellResponse.mapType = horizontalProducingWellReturn;
				horizontalPermitWellResponse.mapType = horizontalPermitWellReturn;
				horizontalDUCWellResponse.mapType = horizontalDUCWellReturn;
				response.add(horizontalProducingWellResponse);
				response.add(horizontalPermitWellResponse);
				response.add(horizontalDUCWellResponse);

			}

			if (objTypeName == 'Tract__c'){
				MapResponse tractResponse = getMap(objId, objTypeName, tractReturn);
				tractResponse.mapType = tractReturn;
				MapResponse horizontalUnitResponse = getMap(objId, objTypeName, HorizontalUnitReturn);
				horizontalUnitResponse.mapType = horizontalUnitReturn;
				MapResponse verticalUnitResponse = getMap(objId, objTypeName, VerticalUnitReturn);
				verticalUnitResponse.mapType = verticalUnitReturn;
				MapResponse subtractResponse = getMap(objId, objTypeName, subtractReturn);
				subtractResponse.mapType = subtractReturn;
				MapResponse verticalWellResponse = getMap(objId, objTypeName, verticalWellReturn);
				//MapResponse horizontalWellResponse = getMap(objId, objTypeName, horizontalWellReturn);
				verticalWellResponse.mapType = verticalWellReturn;
				//horizontalWellResponse.mapType = horizontalWellReturn;
				response.add(tractResponse);
				response.add(subtractResponse);
				response.add(horizontalunitResponse);
				response.add(verticalunitResponse);
				response.add(verticalWellResponse);
				//response.add(horizontalWellResponse);
				MapResponse horizontalProducingWellResponse = getMap(objId, objTypeName, horizontalProducingWellReturn);
				MapResponse horizontalPermitWellResponse = getMap(objId, objTypeName, horizontalPermitWellReturn);
				MapResponse horizontalDUCWellResponse = getMap(objId, objTypeName, horizontalDUCWellReturn);
				horizontalProducingWellResponse.mapType = horizontalProducingWellReturn;
				horizontalPermitWellResponse.mapType = horizontalPermitWellReturn;
				horizontalDUCWellResponse.mapType = horizontalDUCWellReturn;
				response.add(horizontalProducingWellResponse);
				response.add(horizontalPermitWellResponse);
				response.add(horizontalDUCWellResponse);
			}
			if (objTypeName == 'Account'){
				MapResponse tractResponse = getMap(objId, objTypeName, tractReturn);
				MapResponse verticalWellResponse = getMap(objId, objTypeName, verticalWellReturn);
				//MapResponse horizontalWellResponse = getMap(objId, objTypeName, horizontalWellReturn);
				tractResponse.mapType = tractReturn;
				verticalWellResponse.mapType = verticalWellReturn;
				//horizontalWellResponse.mapType = horizontalWellReturn;
				MapResponse horizontalUnitResponse = getMap(objId, objTypeName, HorizontalUnitReturn);
				horizontalUnitResponse.mapType = horizontalUnitReturn;
				MapResponse verticalUnitResponse = getMap(objId, objTypeName, VerticalUnitReturn);
				verticalUnitResponse.mapType = verticalUnitReturn;
				response.add(tractResponse);
				response.add(verticalWellResponse);
				//response.add(horizontalWellResponse);
				response.add(horizontalunitResponse);
				response.add(verticalunitResponse);
				MapResponse horizontalProducingWellResponse = getMap(objId, objTypeName, horizontalProducingWellReturn);
				MapResponse horizontalPermitWellResponse = getMap(objId, objTypeName, horizontalPermitWellReturn);
				MapResponse horizontalDUCWellResponse = getMap(objId, objTypeName, horizontalDUCWellReturn);
				horizontalProducingWellResponse.mapType = horizontalProducingWellReturn;
				horizontalPermitWellResponse.mapType = horizontalPermitWellReturn;
				horizontalDUCWellResponse.mapType = horizontalDUCWellReturn;
				response.add(horizontalProducingWellResponse);
				response.add(horizontalPermitWellResponse);
				response.add(horizontalDUCWellResponse);
			}

			if(objTypeName == 'Unit__c'){
				MapResponse verticalWellResponse = getMap(objId, objTypeName, verticalWellReturn);
				//MapResponse horizontalWellResponse = getMap(objId, objTypeName, horizontalWellReturn);
				verticalWellResponse.mapType = verticalWellReturn;
				//horizontalWellResponse.mapType = horizontalWellReturn;
				MapResponse horizontalUnitResponse = getMap(objId, objTypeName, HorizontalUnitReturn);
				horizontalUnitResponse.mapType = horizontalUnitReturn;
				MapResponse verticalUnitResponse = getMap(objId, objTypeName, VerticalUnitReturn);
				verticalUnitResponse.mapType = verticalUnitReturn;
				MapResponse subtractResponse = getMap(objId, objTypeName, subtractReturn);
				subtractResponse.mapType = subtractReturn;
				response.add(subtractResponse);
				response.add(horizontalunitResponse);
				response.add(verticalunitResponse);
				response.add(verticalWellResponse);
				//response.add(horizontalWellResponse);
				MapResponse horizontalProducingWellResponse = getMap(objId, objTypeName, horizontalProducingWellReturn);
				MapResponse horizontalPermitWellResponse = getMap(objId, objTypeName, horizontalPermitWellReturn);
				MapResponse horizontalDUCWellResponse = getMap(objId, objTypeName, horizontalDUCWellReturn);
				horizontalProducingWellResponse.mapType = horizontalProducingWellReturn;
				horizontalPermitWellResponse.mapType = horizontalPermitWellReturn;
				horizontalDUCWellResponse.mapType = horizontalDUCWellReturn;
				response.add(horizontalProducingWellResponse);
				response.add(horizontalPermitWellResponse);
				response.add(horizontalDUCWellResponse);
			}
			if (objTypeName == 'Case'){
				MapResponse tractResponse = getMap(objId, objTypeName, tractReturn);
				tractResponse.mapType = tractReturn;
				response.add(tractResponse);
			}
			if (objTypeName == 'Subtract__c'){
				MapResponse subtractResponse = getMap(objId, objTypeName, subtractReturn);
				subtractResponse.mapType = subtractReturn;
				MapResponse horizontalUnitResponse = getMap(objId, objTypeName, HorizontalUnitReturn);
				horizontalUnitResponse.mapType = horizontalUnitReturn;
				MapResponse verticalUnitResponse = getMap(objId, objTypeName, VerticalUnitReturn);
				verticalUnitResponse.mapType = verticalUnitReturn;
				MapResponse verticalWellResponse = getMap(objId, objTypeName, verticalWellReturn);
				//MapResponse horizontalWellResponse = getMap(objId, objTypeName, horizontalWellReturn);
				verticalWellResponse.mapType = verticalWellReturn;
				//horizontalWellResponse.mapType = horizontalWellReturn;
				response.add(subtractResponse);
				response.add(horizontalunitResponse);
				response.add(verticalunitResponse);
				response.add(verticalWellResponse);
				//response.add(horizontalWellResponse);
				MapResponse horizontalProducingWellResponse = getMap(objId, objTypeName, horizontalProducingWellReturn);
				MapResponse horizontalPermitWellResponse = getMap(objId, objTypeName, horizontalPermitWellReturn);
				MapResponse horizontalDUCWellResponse = getMap(objId, objTypeName, horizontalDUCWellReturn);
				horizontalProducingWellResponse.mapType = horizontalProducingWellReturn;
				horizontalPermitWellResponse.mapType = horizontalPermitWellReturn;
				horizontalDUCWellResponse.mapType = horizontalDUCWellReturn;
				response.add(horizontalProducingWellResponse);
				response.add(horizontalPermitWellResponse);
				response.add(horizontalDUCWellResponse);
			}
			if(objTypeName == 'GIS_Update_Request__c'){
				MapResponse horizontalUnitResponse = getMap(objId, objTypeName, HorizontalUnitReturn);
				horizontalUnitResponse.mapType = horizontalUnitReturn;
				MapResponse verticalUnitResponse = getMap(objId, objTypeName, VerticalUnitReturn);
				verticalUnitResponse.mapType = verticalUnitReturn;
				MapResponse activeUASubtractResponse = getMap(objId, objTypeName, activeUASubtractReturn);
				activeUASubtractResponse.mapType = activeUASubtractReturn;
				MapResponse inactiveUASubtractResponse = getMap(objId, objTypeName, inactiveUASubtractReturn);
				inactiveUASubtractResponse.mapType = inactiveUASubtractReturn;
				response.add(horizontalUnitResponse);
				response.add(verticalUnitResponse);
				response.add(activeUASubtractResponse);
				response.add(inactiveUASubtractResponse);
				
			}
			else if (objTypeName == 'Well__c'){
				MapResponse tractResponse = getMap(objId, objTypeName, tractReturn);
				MapResponse horizontalUnitResponse = getMap(objId, objTypeName, HorizontalUnitReturn);
				MapResponse verticalUnitResponse = getMap(objId, objTypeName, VerticalUnitReturn);
				MapResponse verticalWellResponse = getMap(objId, objTypeName, verticalWellReturn);
				MapResponse horizontalProducingWellResponse = getMap(objId, objTypeName, horizontalProducingWellReturn);
				MapResponse horizontalPermitWellResponse = getMap(objId, objTypeName, horizontalPermitWellReturn);
				MapResponse horizontalDUCWellResponse = getMap(objId, objTypeName, horizontalDUCWellReturn);
				

				tractResponse.mapType = tractReturn;
				horizontalUnitResponse.mapType = horizontalUnitReturn;
				verticalUnitResponse.mapType = verticalUnitReturn;
				verticalWellResponse.mapType = verticalWellReturn;
				horizontalProducingWellResponse.mapType = horizontalProducingWellReturn;
				horizontalPermitWellResponse.mapType = horizontalPermitWellReturn;
				horizontalDUCWellResponse.mapType = horizontalDUCWellReturn;
				

				response.add(tractResponse);
				response.add(horizontalunitResponse);
				response.add(verticalunitResponse);
				response.add(verticalWellResponse);
				response.add(horizontalProducingWellResponse);
				response.add(horizontalPermitWellResponse);
				response.add(horizontalDUCWellResponse);
			}
		for(MapResponse mr: response){
			if(mr.errorLog != null){
				errorLogs.add(mr.errorLog);
			}
		}
		if(errorLogs.size() >0){
			insert errorLogs;
		}
		//System.debug(response);
		return response;
	}

    @AuraEnabled
    public static MapResponse getMap(Id objId,String objTypeName, String returnType) {
        //System.debug('OBJ TYPE:' + objTypeName);
        //System.debug('OBJ ID:' + objId);

        // Equals clause
        // whereClause = '+%3D+%27' + objId + '%27'; encoded =
        
		string gisUnitName;

        Set<String> ids = new Set<String>();
        //Boolean isTract = false;
        //List<Unit__c> currentUnits = null;
		//List<Well__c> wells = null;
		Map<Id, Tract__c> tractMap = null;
        Map<Id, Subtract__c> subtractMap = null;
		Map<String, Unit__c> unitMap = null;
		Map<String, Well__c> wellMap = null;
		if(objTypeName == 'Account')
		{
			List<Tract__c> accountTracts = [SELECT Id FROM Tract__c WHERE Account__c = :objId];
			for(Tract__c accountTract:accountTracts){
				ids.add(accountTract.Id);
			}
			if(returnType == tractReturn){
				ObjectSet tractSet = getTractsFromTractIdSet(ids);
				ids = tractSet.idSet;
				tractMap = (Map<Id, Tract__c>)tractSet.objectIdMap;
			}
			
			if(returnType == horizontalProducingWellReturn || returnType == horizontalPermitWellReturn || returnType == horizontalDUCWellReturn || returnType == verticalWellReturn){
				ObjectSet subtractSet = getSubtractsFromTractIdSet(ids);
				//System.debug('subtract set of ids: ' + subtractSet.idSet);
				ObjectSet wellSet = getWellsFromUnitIdSet(getUnitSetFromSubtractIdSet(subtractSet.idSet), returnType);
				ids = wellSet.idSet;
				wellSet.idSet = null;
				//wells = (List<Well__c>)wellSet.objectList;
				wellMap = (Map<String, Well__c>)wellSet.objectAltIdMap;
			}
			if(returnType == horizontalUnitReturn || returnType == verticalUnitReturn){
				ObjectSet subtractSet = getSubtractsFromTractIdSet(ids);
				ObjectSet unitSet = getUnitsFromUnitIdSet(getUnitSetFromSubtractIdSet(subtractSet.idSet), returnType);
				ids = unitSet.idSet;
				//System.debug('Ids set: ' + ids);
				//currentUnits = (List<Unit__c>)unitSet.objectList;
				unitMap = (Map<String, Unit__c>)unitSet.objectAltIdMap;
				//System.debug(unitMap);

			}
		}
		
		if (objTypeName == 'Tract__c')
        {
            ids.add(objId);
            //isTract = true;
			if(returnType == tractReturn){
				ObjectSet tractSet = getTractsFromTractIdSet(ids);
				ids = tractSet.idSet;
				tractMap = (Map<Id, Tract__c>)tractSet.objectIdMap;
			}
			if(returnType == subtractReturn){
				ObjectSet subtractSet = getSubtractsFromTractIdSet(ids);
				ids = subtractSet.idSet;
				subtractMap = (Map<Id, Subtract__c>)subtractSet.objectIdMap;
			}
			if(returnType == horizontalUnitReturn || returnType == verticalUnitReturn){
				ObjectSet subtractSet = getSubtractsFromTractIdSet(ids);
				ObjectSet unitSet = getUnitsFromUnitIdSet(getUnitSetFromSubtractIdSet(subtractSet.idSet), returnType);
				ids = unitSet.idSet;
				//System.debug('Ids set: ' + ids);
				//currentUnits = (List<Unit__c>)unitSet.objectList;
				unitMap = (Map<String, Unit__c>)unitSet.objectAltIdMap;
				//System.debug(unitMap);

			}				
			if(returnType == horizontalProducingWellReturn || returnType == horizontalPermitWellReturn || returnType == horizontalDUCWellReturn || returnType == verticalWellReturn){
				ObjectSet subtractSet = getSubtractsFromTractIdSet(ids);
				//System.debug('subtract set of ids: ' + subtractSet.idSet);
				ObjectSet wellSet = getWellsFromUnitIdSet(getUnitSetFromSubtractIdSet(subtractSet.idSet), returnType);
				ids = wellSet.idSet;
				//wells = (List<Well__c>)wellSet.objectList;
				wellMap = (Map<String, Well__c>)wellSet.objectAltIdMap;
			}		
        }
		else if(objTypeName == 'Unit__c'){
			ids.add(objId);
			if(returnType == horizontalUnitReturn || returnType == verticalUnitReturn){
				ObjectSet unitSet = getUnitsFromUnitIdSet(ids, returnType);
				ids = unitSet.idSet;
				//currentUnits = (List<Unit__c>)unitSet.objectList;
				unitMap = (Map<String, Unit__c>)unitSet.objectAltIdMap;
			}
			if(returnType == subtractReturn){
				ObjectSet subtractSet = getSubtractsFromSubtractIdSet(getSubtractSetFromUnitIdSet(ids));
				ids = subtractSet.idSet;
				subtractMap = (Map<Id, Subtract__c>)subtractSet.objectIdMap;
			}
			if(returnType == horizontalProducingWellReturn || returnType == horizontalPermitWellReturn || returnType == horizontalDUCWellReturn || returnType == verticalWellReturn){
				ObjectSet wellSet = getWellsFromUnitIdSet(ids, returnType);
				ids = wellSet.idSet;
				//wells = (List<Well__c>)wellSet.objectList;
				wellMap = (Map<String, Well__c>)wellSet.objectAltIdMap;
			}

		}
        else if (objTypeName == 'Opportunity')
        {
            List<Opportunity_Tract__c> ots = [SELECT Id, Tract__c FROM Opportunity_Tract__c WHERE Opportunity__c =: objId];
            for (Opportunity_Tract__c ot : ots)
            {
                ids.add(ot.Tract__c);
            }
			if(returnType == tractReturn){
				ObjectSet tractSet = getTractsFromTractIdSet(ids);
				ids = tractSet.idSet;
				tractMap = (Map<Id, Tract__c>)tractSet.objectIdMap;
			}
			if(returnType == horizontalUnitReturn || returnType == verticalUnitReturn){
				ObjectSet unitSet = getUnitsFromUnitIdSet(getUnitSetFromSubtractIdSet(getSubtractsFromTractIdSet(ids).idSet), returnType);
				ids = unitSet.idSet;
				//currentUnits = (List<Unit__c>)unitSet.objectList;
				unitMap = (Map<String, Unit__c>)unitSet.objectAltIdMap;
			}
			if(returnType == horizontalProducingWellReturn || returnType == horizontalPermitWellReturn || returnType == horizontalDUCWellReturn || returnType == verticalWellReturn){
				ObjectSet wellSet = getWellsFromUnitIdSet(getUnitSetFromSubtractIdSet(getSubtractsFromTractIdSet(ids).idSet), returnType);
				ids = wellSet.idSet;
				//wells = (List<Well__c>)wellSet.objectList;
				wellMap = (Map<String, Well__c>)wellSet.objectAltIdMap;
			}
        }
       
        else if (objTypeName == 'Subtract__c')
        {
            ids.add(objId);
			if(returnType == subtractReturn){
				ObjectSet subtractSet = getSubtractsFromSubtractIdSet(ids);
				ids = subtractSet.idSet;
				subtractMap = (Map<Id, Subtract__c>)subtractSet.objectIdMap;
			}
			if(returnType == horizontalUnitReturn || returnType == verticalUnitReturn){
				ObjectSet unitSet = getUnitsFromUnitIdSet(getUnitSetFromSubtractIdSet(ids), returnType);
				ids = unitSet.idSet;
				//currentUnits = (List<Unit__c>)unitSet.objectList;
				unitMap = (Map<String, Unit__c>)unitSet.objectAltIdMap;
			}
			if(returnType == horizontalProducingWellReturn || returnType == horizontalPermitWellReturn || returnType == horizontalDUCWellReturn || returnType == verticalWellReturn){
				ObjectSet wellSet = getWellsFromUnitIdSet(getUnitSetFromSubtractIdSet(ids), returnType);
				ids = wellSet.idSet;
				//wells = (List<Well__c>)wellSet.objectList;
				wellMap = (Map<String, Well__c>)wellSet.objectAltIdMap;
			}
        }
        else if (objTypeName == 'Well__c')
        {
            Well__c wellRec = [Select Id,Unit__c from Well__c where Id =: objId Limit 1];
            List<unitAllocation__c> unitAllocationList = [Select Id, subtract__r.Tract__c, Unit__c from unitAllocation__c where unit__c =: wellRec.unit__c  and Inactive__c = false];
            for(unitAllocation__c u : unitAllocationList){
                ids.add(u.Subtract__r.Tract__c);
            }
			if(returnType == tractReturn){
				ObjectSet tractSet = getTractsFromTractIdSet(ids);
				ids = tractSet.idSet;
				tractMap = (Map<Id, Tract__c>)tractSet.objectIdMap;
			}
			if(returnType == horizontalUnitReturn || returnType == verticalUnitReturn){
				ObjectSet subtractSet = getSubtractsFromTractIdSet(ids);
				ObjectSet unitSet = getUnitsFromUnitIdSet(getUnitSetFromSubtractIdSet(subtractSet.idSet), returnType);
				ids = unitSet.idSet;
				//System.debug('Ids set: ' + ids);
				//currentUnits = (List<Unit__c>)unitSet.objectList;
				unitMap = (Map<String, Unit__c>)unitSet.objectAltIdMap;
			}
			if(returnType == horizontalProducingWellReturn || returnType == horizontalPermitWellReturn || returnType == horizontalDUCWellReturn || returnType == verticalWellReturn){
				ids.clear();
				ids.add(wellRec.Id);
				ObjectSet wellSet = getWellsFromWellIdSet(ids, returnType);
				ids = wellSet.idSet;
				//wells = (List<Well__c>)wellSet.objectList;
				wellMap = (Map<String, Well__c>)wellSet.objectAltIdMap;
			}
            
        }

		else if(objTypeName == 'GIS_Update_Request__c'){
			Id unitId = [SELECT Unit__c FROM GIS_Update_Request__c WHERE Id=: objId LIMIT 1].Unit__c;
			//System.debug('unitId value is: ' + unitId);
			if(returnType == activeUASubtractReturn || returnType == inactiveUASubtractReturn){
				List<unitAllocation__c> uas = new List<unitAllocation__c>();
				if(returnType == activeUASubtractReturn){
					uas = [SELECT subtract__c FROM unitAllocation__c WHERE unit__c = :unitId AND Inactive__c = false];
				}
				if(returnType == inactiveUASubtractReturn){
					uas = [SELECT subtract__c FROM unitAllocation__c WHERE unit__c = :unitId AND Inactive__c = true];
				}
				for (unitAllocation__c ua : uas)
				{
					ids.add(ua.subtract__c);
				}
				ObjectSet subtractSet = getSubtractsFromSubtractIdSet(ids);
				ids = subtractSet.idSet;
				subtractMap = (Map<Id, Subtract__c>)subtractSet.objectIdMap;
			}
			if(returnType == horizontalUnitReturn || returnType == verticalUnitReturn){
				ids.add(unitId);
				ObjectSet unitSet = getUnitsFromUnitIdSet(ids, returnType);
				ids = unitSet.idSet;
				//currentUnits = (List<Unit__c>)unitSet.objectList;
				unitMap = (Map<String, Unit__c>)unitSet.objectAltIdMap;
			}
		}

        //HttpResponse response = new HttpResponse();
		MapResponse mr = new MapResponse();
		mr.recordCount = ids.size();
		if(ids.size() > 0){
			List<String> idList = new List<String>();
			idList.addAll(ids);
			String whereClause = ' IN(';
			if(returnType != verticalUnitReturn && returnType != horizontalUnitReturn){
				whereClause +='\'';
				whereClause += String.join(idList,'\',\'');
				whereClause += '\'';
			}
			else{
				whereClause += String.join(idList,',');
			}
			whereClause += ')';

			Http httpProtocol = new Http();
			HttpRequest request = new HttpRequest();
			String token = MapControllerV2.getToken();
			//System.debug('token:'+token);

			String mdLabel = 'Current';
			if (returnType == subtractReturn || returnType == activeUASubtractReturn || returnType == inactiveUASubtractReturn)
			{
				mdLabel = 'Subtract';
			}
			else if(returnType == horizontalUnitReturn  || returnType == verticalUnitReturn){
				mdLabel = 'Units';
			}
			else if(returnType == horizontalProducingWellReturn || returnType == horizontalPermitWellReturn || returnType == horizontalDUCWellReturn){
				mdLabel = 'WellsBorepath';
			}
			else if(returnType == verticalWellReturn){
				mdLabel = 'WellsBHL';
			}
			Map_Setting__mdt metaInfo = [SELECT Id, Web_Service_URL__c FROM Map_Setting__mdt WHERE MasterLabel =: mdLabel];
			mr.requestURL = metaInfo.Web_Service_URL__c;
			System.debug('baseURL: ' + mr.requestURL);

			String url = mr.requestURL + '/query';
			String bodyParam;
			if(returnType == horizontalUnitReturn || returnType == verticalUnitReturn){
				
				mr.whereClause = 'objectId' + whereClause;//  +
						//'&text=&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&relationParam=&outFields=*&returnGeometry=true' +
						//'&returnTrueCurves=false&maxAllowableOffset=&geometryPrecision=&outSR=&having=&returnIdsOnly=false&returnCountOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false' +
						//'&returnM=false&gdbVersion=&historicMoment=&returnDistinctValues=false&resultOffset=&queryByDistance=&returnExtentOnly=false&datumTransformation=' +
						//'&parameterValues=&rangeValues=&quantizationParameters=&f=geojson&token=' + token;
			}
			else if(returnType == verticalWellReturn || returnType == horizontalProducingWellReturn || returnType == horizontalPermitWellReturn || returnType == horizontalDUCWellReturn){
				mr.whereClause = 'UWI' + whereClause;// +
						//'&text=&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&relationParam=&outFields=*&returnGeometry=true' +
						//'&returnTrueCurves=false&maxAllowableOffset=&geometryPrecision=&outSR=&having=&returnIdsOnly=false&returnCountOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false' +
						//'&returnM=false&gdbVersion=&historicMoment=&returnDistinctValues=false&resultOffset=&queryByDistance=&returnExtentOnly=false&datumTransformation=' +
						//'&parameterValues=&rangeValues=&quantizationParameters=&f=geojson&token=' + token;	
			}
			else{
				mr.whereClause = 'Tract_ID' + whereClause;// +
						//'&text=&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&relationParam=&outFields=*&returnGeometry=true' +
						//'&returnTrueCurves=false&maxAllowableOffset=&geometryPrecision=&outSR=&having=&returnIdsOnly=false&returnCountOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false' +
						//'&returnM=false&gdbVersion=&historicMoment=&returnDistinctValues=false&resultOffset=&queryByDistance=&returnExtentOnly=false&datumTransformation=' +
						//'&parameterValues=&rangeValues=&quantizationParameters=&f=geojson&token=' + token;
			}
			bodyParam = 'where=' + mr.whereClause + 
					'&text=&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&relationParam=&outFields=&returnGeometry=true'+
					'&returnTrueCurves=false&maxAllowableOffset=&geometryPrecision=&outSR=&having=&returnIdsOnly=false&returnCountOnly=false&orderByFields='+
					'&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&gdbVersion=&historicMoment=&returnDistinctValues=false&resultOffset='+
					'&resultRecordCount=&queryByDistance=&returnExtentOnly=true&datumTransformation=&parameterValues=&rangeValues=&quantizationParameters='+
					'&featureEncoding=esriDefault&f=json&token=' + token;
			System.debug('endpoint:'+url);
			System.debug('body:'+bodyParam);
			System.debug('fullURL:'+url+bodyParam);
			request.setMethod('POST');

			request.setEndpoint(url);
			request.setBody(bodyParam);
			
			//Use to test timeout error
			//request.setTimeout(1);
			//request.setTimeout(20000);
        

			HttpResponse response;
			response = httpProtocol.send(request);
			System.debug('map resp:'+response);
			System.debug('map resp body: ' + response.getBody());
			mr.bounds = response.getBody();
			//JSONParser parser = JSON.createParser(response.getBody());
			//while (parser.nextToken() != null){
			//	System.debug('token value is: ' + parser.getCurrentToken() + ' text value is: ' + parser.getText());
			//}
        
			/*if(response.getBody().indexOf('"error":{"code"') > 0 ){
				MapResponseError mre = MapResponseError.parse(response.getBody());
				//System.debug(mre);
				mr.geoJSONString = '';
				mr.hasError = true;
				mr.errorCode = mre.error.code;
				mr.errorMessage = mre.error.message;
				Log__c errorLog = new Log__c();
				errorLog.Additional_Details__c = mre.error.message;
				errorLog.Error_Message__c = mre.error.message;
				errorLog.errorCode__c = String.valueOf(mre.error.code);
				errorLog.Additional_Details__c = 'Input variables are - objId: ' + objId + ' objTypeName: ' + objTypeName + ' returnType: ' + returnType + ' response body is: ' + response.getBody();
				errorLog.Process__c = 'MapController.getMap';
				mr.errorLog = errorLog;
				//mre = null;
			}
			else if(response.getBody().contains('<') || response.getBody().contains('>')){
				Log__c errorLog = new Log__c();
				errorLog.Additional_Details__c = 'Input variables are - objId: ' + objId + ' objTypeName: ' + objTypeName + ' returnType: ' + returnType + ' response body is: ' + response.getBody();
				errorLog.Error_Message__c = 'Map Response Error from server with HTML';
				errorLog.Process__c = 'MapController.getMap';
				mr.errorLog = errorLog;
                mr.geoJSONString = '';
				mr.hasError = true;
                mr.errorMessage = 'Response Error';
			}
			else{
				System.debug(response.getBody());
				//Unable to parse the entire JSON file on larger return items.  As such loop through until a feature is found.  As soon as 1 feature is found, incriminate counter
				//and terminate loop. 
				JSONParser parser = JSON.createParser(response.getBody());
				Integer featureCounter = 0;
				while (parser.nextToken() != null){
					if(parser.getCurrentToken() == JSONToken.VALUE_STRING && parser.getText() == 'Feature'){
						featureCounter++;
						break;
						//System.debug('Token is: ' + parser.getCurrentToken());
						//System.debug('Value is: ' + parser.getText());
					}
				}
				parser = null;
				System.debug('featureCounter value is: ' + featureCounter);
				if(featureCounter < 1){
					Log__c errorLog = new Log__c();
					errorLog.Additional_Details__c = 'Input variables are - objId: ' + objId + ' objTypeName: ' + objTypeName + ' returnType: ' + returnType + ' response body is: ' + response.getBody();
					errorLog.Error_Message__c = 'Map Response from server indicated a valid response, but no records were returned';
					errorLog.Process__c = 'MapController.getMap';
					mr.errorLog = errorLog;
					mr.geoJSONString = '';
					mr.hasError = true;
					mr.errorMessage = 'No objects returned';
				}
				else{
					mr.geoJSONString = response.getBody();
				}
			}*/

			if(returnType == tractReturn){
				mr.tractInfo = tractMap;
			}
			if(returnType == subtractReturn){
				System.debug(subtractMap);
				mr.subtractInfo = subtractMap;
				mr.activeSubtractInfo = null;
				mr.inactiveSubtractInfo = null;
			}
			if(returnType == activeUASubtractReturn){
				mr.subtractInfo = null;
				mr.activeSubtractInfo = subtractMap;
				mr.inactiveSubtractInfo = null;
			}
			if(returnType == inactiveUASubtractReturn){
				mr.subtractInfo = null;
				mr.activeSubtractInfo = null;
				mr.inactiveSubtractInfo = subtractMap;
			}
			if(returnType == horizontalUnitReturn){
				mr.horizontalUnitInfo = unitMap;
				mr.verticalUnitInfo = null;
			}
			if(returnType == verticalUnitReturn){
				mr.verticalUnitInfo = unitMap;
				mr.horizontalUnitInfo = null;
			}
			if(returnType == horizontalProducingWellReturn){
				mr.horizontalProducingWellInfo = wellMap;
				mr.horizontalPermitWellInfo = null;
				mr.horizontalDUCWellInfo = null;
				mr.verticalWellInfo = null;
			}
			if(returnType == horizontalPermitWellReturn){
				mr.horizontalProducingWellInfo = null;
				mr.horizontalPermitWellInfo = wellMap;
				mr.horizontalDUCWellInfo = null;
				mr.verticalWellInfo = null;
			}
			if(returnType == horizontalDUCWellReturn){
				mr.horizontalProducingWellInfo = null;
				mr.horizontalPermitWellInfo = null;
				mr.horizontalDUCWellInfo = wellMap;
				mr.verticalWellInfo = null;
			}
			if(returnType == verticalWellReturn){
				mr.verticalWellInfo = wellMap;
				mr.horizontalProducingWellInfo = null;
				mr.horizontalPermitWellInfo = null;
				mr.horizontalDUCWellInfo = null;
			}
			//mr.unitInfo = unitMap;
		}
		else{
			//mr.geoJSONString = '';
			mr.hasError = true;
			mr.errorMessage = 'No Ids to find maps for.';
		}
		//System.debug(mr.geoJSONString);
		//System.debug('Error values are - hasError: ' + mr.hasError + ' errorCode: ' + mr.errorCode + ' errorMessage: ' + mr.errorMessage);

        return mr;
    }

    @AuraEnabled
    public static String getClientToken() {
        // gets a 7 week token for the client, with cache reset in 5 days
        return getToken(true);
    }

	@AuraEnabled
	public static List<LookupSearchResult> searchAccounts(String searchTerm, List<String> selectedIds){
		System.debug('Trying to get search results.');
		return lookupUtility.searchAccounts(searchTerm, selectedIds);
	}

	private static ObjectSet getTractsFromTractIdSet(Set<String> idList){
		ObjectSet returnSet = new ObjectSet();
		Map<Id, Tract__c> m = new Map<Id, Tract__c>();
		m = new Map<Id,Tract__c>([SELECT Id, Full_Legal_Name__c, netAcres__c, Gross_Acres__c, OTG_Cost__c, Name FROM Tract__c WHERE Id IN: idList]);
		for(Id itemId: m.keySet()){
			returnSet.idSet.add(String.valueOf(itemId));
		}
		//returnSet.objectList = m.values();
		returnSet.objectIdMap = m;
		return returnSet;
	}

	private static ObjectSet getWellsFromWellIdSet(Set<String> idList, String returnType){
		ObjectSet returnSet = new ObjectSet();
		Map<Id, Well__c> m = new Map<Id, Well__c>();
		Map<String, Well__c> altMap = new Map<String, Well__c>();

		if(returnType == horizontalWellReturn){
			m = new Map<Id, Well__c>([SELECT API14__c, Id, Name, wellStatus__c, API10__c, Hole_Direction__c FROM Well__c WHERE Id IN : idList]);
		}
		else if(returnType == verticalWellReturn){
			m = new Map<Id, Well__c>([SELECT API14__c, Id, Name, wellStatus__c, API10__c, Hole_Direction__c FROM Well__c WHERE Id IN : idList AND Hole_Direction__c = 'Vertical']);
		}
		else if(returnType == horizontalProducingWellReturn){
			m = new Map<Id, Well__c>([SELECT API14__c, Id, Name, wellStatus__c, API10__c, Hole_Direction__c FROM Well__c WHERE Id IN : idList AND wellStatus__c = 'Producing' AND Hole_Direction__c != 'Vertical']);
		}
		else if(returnType == horizontalDUCWellReturn){
			m = new Map<Id, Well__c>([SELECT API14__c, Id, Name, wellStatus__c, API10__c, Hole_Direction__c FROM Well__c WHERE Id IN : idList AND wellStatus__c = 'DUC' AND Hole_Direction__c != 'Vertical']);
		}

		else if(returnType == horizontalPermitWellReturn){
			m = new Map<Id, Well__c>([SELECT API14__c, Id, Name, wellStatus__c, API10__c, Hole_Direction__c FROM Well__c WHERE Id IN : idList AND wellStatus__c = 'Permit' AND Hole_Direction__c != 'Vertical']);
		}
		for(Id itemId: m.keySet()){
			returnSet.idSet.add(String.valueOf(itemId));
		}
		returnSet.objectList = m.values();
		//returnSet.objectIdMap = m;
		for(Well__c well:(List<Well__c>)returnSet.objectList){
			if(well.API14__c != null){
				returnSet.idSet.add(well.API14__c);
				altMap.put(well.API14__c, well);
			}
		}
		returnSet.objectList = null;
		returnSet.objectAltIdMap = altMap;
		return returnSet;
	}

	private static ObjectSet getWellsFromUnitIdSet(Set<String> idList, String returnType){
		ObjectSet returnSet = new ObjectSet();
		Map<Id, Well__c> m = new Map<Id, Well__c>();
		Map<String, Well__c> altMap = new Map<String, Well__c>();

		if(returnType == horizontalWellReturn){
			m = new Map<Id, Well__c>([SELECT API14__c, Id, Name, wellStatus__c, API10__c, Hole_Direction__c FROM Well__c WHERE Unit__c IN : idList]);
		}
		else if(returnType == verticalWellReturn){
			m = new Map<Id, Well__c>([SELECT API14__c, Id, Name, wellStatus__c, API10__c, Hole_Direction__c FROM Well__c WHERE Unit__c IN : idList AND Hole_Direction__c = 'Vertical']);
		}
		else if(returnType == horizontalProducingWellReturn){
			m = new Map<Id, Well__c>([SELECT API14__c, Id, Name, wellStatus__c, API10__c, Hole_Direction__c FROM Well__c WHERE Unit__c IN : idList AND wellStatus__c = 'Producing' AND Hole_Direction__c != 'Vertical']);
		}
		else if(returnType == horizontalDUCWellReturn){
			m = new Map<Id, Well__c>([SELECT API14__c, Id, Name, wellStatus__c, API10__c, Hole_Direction__c FROM Well__c WHERE Unit__c IN : idList AND wellStatus__c = 'DUC' AND Hole_Direction__c != 'Vertical']);
		}

		else if(returnType == horizontalPermitWellReturn){
			m = new Map<Id, Well__c>([SELECT API14__c, Id, Name, wellStatus__c, API10__c, Hole_Direction__c FROM Well__c WHERE Unit__c IN : idList AND wellStatus__c = 'Permit' AND Hole_Direction__c != 'Vertical']);
		}
		for(Id itemId: m.keySet()){
			returnSet.idSet.add(String.valueOf(itemId));
		}
		returnSet.objectList = m.values();
		//returnSet.objectIdMap = m;
		for(Well__c well:(List<Well__c>)returnSet.objectList){
			if(well.API14__c != null){
				returnSet.idSet.add(well.API14__c);
				altMap.put(well.API14__c, well);
			}
		}
		returnSet.objectList = null;
		returnSet.objectAltIdMap = altMap;
		return returnSet;
	}

	private static ObjectSet getUnitsFromUnitIdSet(Set<String> idList, String returnType){
		ObjectSet returnSet = new ObjectSet();
		Map<Id, Unit__c> m = new Map<Id, Unit__c>();
		Map<String, Unit__c> altMap = new Map<String, Unit__c>();
		
		if(returnType == horizontalUnitReturn){
			m = new Map<Id, Unit__c>([SELECT CreatedById,GIS_Unit_ID__c,GIS_Unit_Name__c,Gross_Acres__c,Id,Name,Operator__c, Operator__r.Name,OwnerId,SRP_Unit_Name__c,Unit_Type__c
							FROM Unit__c WHERE Id IN :idList AND Unit_Type__c = 'Horizontal']);
		}
		if(returnType == verticalUnitReturn){
			m = new Map<Id, Unit__c>([SELECT CreatedById,GIS_Unit_ID__c,GIS_Unit_Name__c,Gross_Acres__c,Id,Name,Operator__c, Operator__r.Name,OwnerId,SRP_Unit_Name__c,Unit_Type__c
							FROM Unit__c WHERE Id IN :idList AND Unit_Type__c = 'Vertical']);
		}
		
		returnSet.objectList = m.values();
		//returnSet.objectIdMap = m;
		for(Unit__c unit:(List<Unit__c>)returnSet.objectList){
			returnSet.idSet.add(unit.GIS_Unit_Name__c);
			altMap.put(unit.GIS_Unit_Name__c, unit);
		}
		returnSet.objectList = null;
		returnSet.objectAltIdMap = altMap;
		return returnSet;
	}

	private static ObjectSet getSubtractsFromTractIdSet(Set<String> idList){
		ObjectSet returnSet = new ObjectSet();
		Map<Id, Subtract__c> m = new Map<Id,Subtract__c>([SELECT Id, Subtract_Full_Legal_Description__c, Subtract_Acres__c, Subtract_Quarter_Call__c, Subtract_Gross_Acres__c FROM Subtract__c WHERE Tract__c IN: idList]);
		for(Id itemId: m.keySet()){
			returnSet.idSet.add(String.valueOf(itemId));
		}
		//returnSet.objectList = m.values();
		returnSet.objectIdMap = m;
		return returnSet;
	}

	private static ObjectSet getSubtractsFromSubtractIdSet(Set<String> idList){
		ObjectSet returnSet = new ObjectSet();
		Map<Id, Subtract__c> m = new Map<Id,Subtract__c>([SELECT Id, Subtract_Full_Legal_Description__c, Subtract_Acres__c, Subtract_Quarter_Call__c, Subtract_Gross_Acres__c FROM Subtract__c WHERE Id IN: idList]);
		for(Id itemId: m.keySet()){
			returnSet.idSet.add(String.valueOf(itemId));
		}
		//returnSet.objectList = m.values();
		returnSet.objectIdMap = m;
		return returnSet;
	}

	private static Set<String> getUnitSetFromSubtractIdSet(Set<String> ids){
		//Records returned through relationship between subtract>unitAllocation>Unit
		Set<String> returnSet = new Set<String>();
		List<unitAllocation__c> uas = [SELECT unit__c FROM unitAllocation__c WHERE subtract__c IN : ids and Inactive__c = false];
		for(unitAllocation__c ua:uas){
			returnSet.add(ua.unit__c);
		}
		return returnSet;
	}

	private static Set<String> getSubtractSetFromUnitIdSet(Set<String> ids){
		//Records returned through relationship between subtract>unitAllocation>Unit
		Set<String> returnSet = new Set<String>();
		List<unitAllocation__c> uas = [SELECT subtract__c FROM unitAllocation__c WHERE unit__c IN : ids and Inactive__c = false];
		for(unitAllocation__c ua:uas){
			returnSet.add(ua.subtract__c);
		}
		return returnSet;
	}

    private static String getToken() {
        // overload for returning short lifespan server side token
        return getToken(false);
    }


    private static String getToken(Boolean isClient) {
        // Gets a token from the ArcGIS web server and caches it across the org
        //System.debug('tokenRequest');

        String cacheKey = isClient ? 'ClientGISToken' : 'GIStoken2';
        // Client cache entry lasts 30 minutes (max allowed), token lasts 60 minutes
        // Server cache lasts 14 minutes, token lasts 15 minutes
        Integer cacheTime = isClient ? 1800 : 840; // in seconds
        Integer tokenTime = isClient ? 3600 : 15; // in minutes

        if (!Cache.Org.contains(cacheKey)) {
            //System.debug('token not cached.');

            // First step: get the portal token
            String userName = 'SalesForce';
            String pw = 'dq8nc6AE16f7';
            String genURL = 'https://maps.strongholdresourcepartners.com/portal/sharing/rest/generateToken';
            String webappURL = 'https%3A%2F%2Fmaps.strongholdresourcepartners.com';

            Http httpProtocol = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(genURL);
            request.setMethod('POST');
            String authParam = '&referer=' + webappURL + '&client=referer';

            String bodyParam = 'f=json&expiration=' + tokenTime + '&username=' + userName + '&password=' + pw + authParam;
            //System.debug('Request Body: ' + bodyParam);

            request.setBody(bodyParam);
            HttpResponse response;

            response = httpProtocol.send(request);
            String res = response.getBody();
            System.debug(res);
            TokenInfo portalTokenInfo = parse(res);
            Datetime exp = Datetime.newInstance(portalTokenInfo.expires);
//            System.debug('Time Now: ' + Datetime.now());
//            System.debug('EXPIRES: ' + exp);
            //System.debug('Portal Token Info: ' + portalTokenInfo);

            Cache.Org.put(cacheKey, portalTokenInfo, cacheTime); // Store in the cache for 14 minutes
            return portalTokenInfo.token;
        } else {
            //System.debug('Token in Cache');
            TokenInfo ti = (TokenInfo) Cache.Org.get(cacheKey);
            return (ti.token);
        }

    }

    

	private class ObjectSet {
		Set<String> idSet {get; set;}
		List<SObject> objectList {get; set;}
		Map<Id, SObject> objectIdMap {get; set;}
		Map<String, SObject> objectAltIdMap {get; set;}

		private ObjectSet(){
			idSet = new Set<String>();
			objectList = new List<SObject>();
			objectIdMap = new Map<Id, SObject>();
			objectAltIdMap = new Map<String, SObject>();
		}
	}

    public class MapResponse {
        @AuraEnabled
        public Map<Id,Tract__c> tractInfo {get; set;}
        @AuraEnabled
        public Map<Id,Subtract__c> subtractInfo {get; set;}
		@AuraEnabled
		public Map<String, Unit__c> verticalUnitInfo {get; set;}
        @AuraEnabled
		public Map<String, Unit__c> horizontalUnitInfo {get; set;}
		@AuraEnabled
		public Map<Id,Subtract__c> activeSubtractInfo {get; set;}
        @AuraEnabled
		public Map<Id,Subtract__c> inactiveSubtractInfo {get; set;}
		@AuraEnabled
		public Map<String,Well__c> horizontalProducingWellInfo {get; set;}
		@AuraEnabled
		public Map<String,Well__c> horizontalPermitWellInfo {get; set;}
		@AuraEnabled
		public Map<String,Well__c> horizontalDUCWellInfo {get; set;}
		@AuraEnabled
		public Map<String,Well__c> verticalWellInfo {get; set;}
        @AuraEnabled
        public String bounds {get;set;}
		@AuraEnabled
		public String whereClause {get; set;}
		@AuraEnabled
		public String requestURL {get; set;}
		@AuraEnabled
		public Integer recordCount {get;set;}
		@AuraEnabled
		public String mapType {get;set;}
		@AuraEnabled
		public Boolean hasError {get;set;}
		@AuraEnabled
		public Integer errorCode {get; set;}
		@AuraEnabled
		public String errorMessage {get;set;}
		@AuraEnabled
		public Log__c errorLog {get; set;}

		public MapResponse(){
			tractInfo = null;
			subtractInfo = null;
			verticalUnitInfo = null;
			horizontalUnitInfo = null;
			activeSubtractInfo = null;
			inactiveSubtractInfo = null;
			horizontalProducingWellInfo = null;
			horizontalPermitWellInfo = null;
			horizontalDUCWellInfo = null;
			verticalWellInfo = null;
			//geoJSONString = null;
			bounds = '';
			mapType = '';
			hasError = false;
			errorCode = 0;
			errorMessage = '';
			errorLog = null;
		}
    }

    public class TokenInfo {
        //
        // Generated by JSON2Apex http://json2apex.herokuapp.com/
        //

        public String token { get; set; }
        public Long expires { get; set; }
        public Boolean ssl { get; set; }

        public TokenInfo(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'token') {
                            token = parser.getText();
                        } else if (text == 'expires') {
                            expires = parser.getLongValue();
                        } else if (text == 'ssl') {
                            ssl = parser.getBooleanValue();
                        } else {
                            System.debug(LoggingLevel.WARN, 'TokenInfo consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public static TokenInfo parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new TokenInfo(parser);
    }

    public static void consumeObject(System.JSONParser parser) {
        Integer depth = 0;
        do {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT ||
                    curr == System.JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == System.JSONToken.END_OBJECT ||
                    curr == System.JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }

	
}