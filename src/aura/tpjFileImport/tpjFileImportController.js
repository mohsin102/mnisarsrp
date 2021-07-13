({
    recordUpdated: function (component, event, helper) {
		var tpjRecord = component.get("v.tpjRecord");
		console.log(JSON.stringify(tpjRecord));
		
		var options = [];
		if(!tpjRecord.flatFileLoaded__c){
			var option = {"label": "Flat File (csv)", "value": "flatFile"};
			options.push(option);
		}
		if(!tpjRecord.runSheetLoaded__c){
			var option = {"label": "Run Sheet (csv)", "value": "runSheet"};
			options.push(option);
		}
		var option = {"label": "JSON", "value": "JSON"};
		options.push(option);
		if (options.length > 0){
			component.set("v.canUpload", true);
		}
		component.set('v.options', options);
		component.set('v.fileType', '');
		component.set('v.uploadDisabled', true);

	},
    handleUploadFinished : function(component, event, helper) {
        var uploadedFiles = event.getParam("files");
		//console.log(JSON.stringify(uploadedFiles));
		//console.log(uploadedFiles);
		var fileTypeStart = uploadedFiles[0].name.lastIndexOf(".")+1;
		var fileTypeLength = uploadedFiles[0].name.length;
		//console.log('start count is ' + fileTypeStart + ' file type length is: ' + fileTypeLength);
		var uploadedFileType = uploadedFiles[0].name.substring(fileTypeStart, fileTypeLength); 
        var spin = component.find("spinner");
		var fileType = component.get('v.fileType');
		var fileFormat = component.get('v.fileFormat');
		console.log ('uploadedFiles length is: ' + uploadedFiles.length + ' uploadedFileType is: ' + uploadedFileType + 'fileFormat is: ' + fileFormat);
		if(uploadedFiles.length > 1 || uploadedFileType.toLowerCase() != fileFormat.toLowerCase()){
			var toastEvent = $A.get("e.force:showToast");
			toastEvent.setParams({
								"title": "Import Failed!",
								"message": 'The file loaded does not match your selection or multiple files were uploaded.\nFiles remain but further processing including loading records has been terminated.',
								"type":"error",
								mode: 'sticky'
							});
			$A.get("e.force:closeQuickAction").fire();
			$A.get('e.force:refreshView').fire();
			toastEvent.fire(); 
		}
		else{
			//console.log('FileType is: ' + fileType);
			//To exclude handling of JSON files for now.  Will probably need to be modified once record processing for uploaded JSON files is defined.
			if(fileType.toLowerCase() != 'json'){
				 $A.util.removeClass(spin,'slds-hide');
				var action = component.get("c.importRecords");
				action.setParams({
					"contentDocId": uploadedFiles[0].documentId,
					"rcId": component.get('v.recordId'),
					"fileType":fileType
				});
				action.setCallback(this, function(response) {
					var state = response.getState();
            
					$A.util.addClass(spin,'slds-hide');
					if (state === "SUCCESS" ) {
						component.set('v.jsonstr',response.getReturnValue());
                
						var toastEvent = $A.get("e.force:showToast");
						if(response.getReturnValue() == 'SUCCESS'){
							toastEvent.setParams({
								"title": "Import Successful!",
								"message": 'File was successfully imported.',
								"type":"success"
							});
						}
						else{
							toastEvent.setParams({
								"title": "Import Failed!",
								"message": response.getReturnValue(),
								"type":"error",
								mode: 'sticky'
							});
						}
                    
                       
                
				
					}else{
						var toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							"title": "Error!",
							"message": "Error during import. Please contact the admin",
							"type":"error",
							mode: 'sticky',
						});
                
					}
					$A.get("e.force:closeQuickAction").fire();
					$A.get('e.force:refreshView').fire();
					toastEvent.fire(); 
			
				});
				$A.enqueueAction(action);
			}
		}
    },
	handleChange : function(component, event, helper){
		var fileType = event.getParam('value');
		component.set('v.fileType', fileType);
		if(fileType == 'flatFile' || fileType == 'runSheet'){
			console.log('Setting fileFormat to: csv');
			component.set('v.fileFormat', 'csv');
		}
		if(fileType == 'JSON'){
			console.log('Setting fileFormat to: json');
			component.set('v.fileFormat', 'json');
		}
		//console.log(fileType);
		if (fileType.length > 0){
			component.set('v.uploadDisabled', false);
		}
		else{
			component.set('v.uploadDisabled', true);
		}
	}
})