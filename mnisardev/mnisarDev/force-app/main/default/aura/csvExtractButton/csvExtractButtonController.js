({
	exportData: function (component, event, helper) {
		console.log('exportData called.');
		console.log(JSON.stringify(component.get('v.columns')));
		console.log(JSON.stringify(component.get('v.data')));
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
		for(var dataKey in data){
			var exportRow = [];
			for(var labelKey in labels){
				//console.log('Inside inner for');
				//console.log('fieldNames keyValue is: ' + fieldNames[labelKey]);
				console.log('type of field value is' + typeof data[dataKey][fieldNames[labelKey]]);
				if(data[dataKey][fieldNames[labelKey]] && typeof data[dataKey][fieldNames[labelKey]] == 'string' && data[dataKey][fieldNames[labelKey]].indexOf(",")>-1){
					exportRow.push('"'+data[dataKey][fieldNames[labelKey]]+'"');
				}
				else{
					exportRow.push(data[dataKey][fieldNames[labelKey]]);
				}
			}
			finalExport.push(exportRow);
			//console.log(JSON.stringify(data[dataKey]));
		} 
		//console.log(JSON.stringify(exportValues));

		
		
		//finalExport.push(exportValues);

		let csvContent = "data:text/csv;charset=utf-8,";

		finalExport.forEach(function(rowArray) {
			let row = rowArray.join(",");
			csvContent += row + "\r\n";
		});
		console.log(csvContent);
		var encodedUri = encodeURI(csvContent);

		var link = document.createElement("a");
		link.setAttribute("href", encodedUri);
		link.setAttribute("download", component.get('v.fileName') + '.csv');
		document.body.appendChild(link); // Required for FF

		link.click();

		console.log(encodedUri);
		//window.open(encodedUri);

	}
})