({
	exportData: function (component, helper) {
		var data = component.get('v.data');
		var columns = component.get('v.columns');
		var labels=[];
		var fieldNames=[];
		//var exportValues = [];
		var finalExport = [];
		for(var columnKey in columns){
			if(columns[columnKey].label != undefined && columns[columnKey].label != ''){ 
				labels.push(columns[columnKey].label);
				if(columns[columnKey].type && columns[columnKey].type.toLowerCase() == 'url'){
					fieldNames.push(columns[columnKey].typeAttributes.label.fieldName);
				}
				else{
					fieldNames.push(columns[columnKey].fieldName);
				}
			}
		}
		finalExport.push(labels);
		//var equalLengths = fieldNames.length == labels.length;
		//console.log('equalLengths variable is: ' + equalLengths);
		//console.log(JSON.stringify(labels));
		//console.log(JSON.stringify(fieldNames));
		console.log('Entering second for loop at: ' + new Date());
		var columnCounter = 0;
		var rowStart = 0;
		var totalRows = data.length;
		var columnCount = labels.length;
		window.setTimeout(
			 $A.getCallback(function() {
				 helper.exportBlockOfRows(component, helper, labels, data, fieldNames, rowStart,finalExport, 100, totalRows)
			 }), 
			 4
		 );
		 //setTimeout(helper.exportBlockOfRows(labels, data, fieldNames, rowStart,finalExport, 100), 4);

		 
		/*for(var i = rowCounter; i < rowCounter + 100 ; i++){
			var exportRow = [];
			for(var labelKey in labels){
				//console.log('Inside inner for');
				//console.log('fieldNames keyValue is: ' + fieldNames[labelKey]);
				//console.log('type of field value is' + typeof data[dataKey][fieldNames[labelKey]]);
				if(data[i][fieldNames[labelKey]] && typeof data[i][fieldNames[labelKey]] == 'string' && data[i][fieldNames[labelKey]].indexOf(",")>-1){
					exportRow.push('"'+data[i][fieldNames[labelKey]]+'"');
				}
				else{
					exportRow.push(data[i][fieldNames[labelKey]]);
				}
			}
			finalExport.push(exportRow);
			//console.log(JSON.stringify(data[dataKey]));
		} */
		/*for(var dataKey in data){
			var exportRow = [];
			for(var labelKey in labels){
				//console.log('Inside inner for');
				//console.log('fieldNames keyValue is: ' + fieldNames[labelKey]);
				//console.log('type of field value is' + typeof data[dataKey][fieldNames[labelKey]]);
				if(data[dataKey][fieldNames[labelKey]] && typeof data[dataKey][fieldNames[labelKey]] == 'string' && data[dataKey][fieldNames[labelKey]].indexOf(",")>-1){
					exportRow.push('"'+data[dataKey][fieldNames[labelKey]]+'"');
				}
				else{
					exportRow.push(data[dataKey][fieldNames[labelKey]]);
				}
			}
			finalExport.push(exportRow);
			//console.log(JSON.stringify(data[dataKey]));
		} */
		/*console.log('Finished second for loop at: ' + new Date());
		//console.log(JSON.stringify(exportValues));

		
		
		//finalExport.push(exportValues);

		let csvContent = "data:text/csv;charset=utf-8,";

		finalExport.forEach(function(rowArray) {
			let row = rowArray.join(",");
			csvContent += row + "\r\n";
		});
		//console.log(csvContent);
		var encodedUri = encodeURI(csvContent);

		var link = document.createElement("a");
		link.setAttribute("href", encodedUri);
		link.setAttribute("download", component.get('v.fileName') + '.csv');
		document.body.appendChild(link); // Required for FF

		link.click();

		//console.log(encodedUri);
		console.log('Finishing at: '+ new Date());
		//var returnValue = true;
		//return returnValue;
		component.set('v.isExporting', false);
		*/
	},

	exportBlockOfRows: function(component, helper, labels, data, fieldNames, rowStart, finalExport, numberOfRows, totalRows){
		console.log('Entering export with startRow: ' + rowStart + ' and totalRows: ' + totalRows);
		var exportCount = rowStart;
		var totalCount = ((rowStart + numberOfRows) > totalRows?totalRows:rowStart+ numberOfRows);
		for(exportCount; exportCount < totalCount ; exportCount++){
			var exportRow = [];
			for(var labelKey in labels){
				//console.log('Inside inner for');
				//console.log('label keyValue is: ' + fieldNames[labelKey]);
				//console.log('type of field value is' + typeof data[dataKey][fieldNames[labelKey]]);
				//console.log(JSON.stringify(data[i]));
				if(data[exportCount][fieldNames[labelKey]] && typeof data[exportCount][fieldNames[labelKey]] == 'string' && data[exportCount][fieldNames[labelKey]].indexOf(",")>-1){
					exportRow.push('"'+data[exportCount][fieldNames[labelKey]]+'"');
				}
				else{
					
					exportRow.push(data[exportCount][fieldNames[labelKey]]);
				}
			}
			finalExport.push(exportRow);
			//console.log(JSON.stringify(data[dataKey]));
		} 
		rowStart = exportCount;
		console.log('Checking result with startRow: ' + rowStart + ' and totalRows: ' + totalRows);
		if(totalRows > rowStart){
			window.setTimeout(
				$A.getCallback(function() {
					helper.exportBlockOfRows(component, helper, labels, data, fieldNames, rowStart,finalExport, 100, totalRows)
				}), 
				4
			);
		}
		else{
			console.log('Finished adding rows');
			console.log(finalExport);
			let csvContent = "data:text/csv;charset=utf-8,";

			finalExport.forEach(function(rowArray) {
				let row = rowArray.join(",");
				csvContent += row + "\r\n";
			});
			//console.log(csvContent);
			var encodedUri = encodeURI(csvContent);

			var link = document.createElement("a");
			link.setAttribute("href", encodedUri);
			link.setAttribute("download", component.get('v.fileName') + '.csv');
			document.body.appendChild(link); // Required for FF

			link.click();

			//console.log(encodedUri);
			//console.log('Finishing at: '+ new Date());
			//var returnValue = true;
			//return returnValue;
			//component.set('v.isExporting', false);
			
			component.set('v.isExporting', false);
		}
	}
})