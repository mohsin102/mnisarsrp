({
    recordUpdated: function (component, event, helper) {
		
		var aijRecord = component.get("v.aijRecord");
		console.log(JSON.stringify(aijRecord));
		console.log(event.getParam('changeType'));
		var options = [];
		if(!aijRecord.transactionFileLoaded__c){
			var option = {'label': 'Acct TXN File', 'value': 'accountTransactionFile'};
			options.push(option);
		}
		if (options.length > 0){
			component.set("v.canUpload", true);
		}
		component.set('v.options', options);
		component.set('v.fileType', 'accountTransactionFile');
        component.set('v.fileFormat', 'csv');
        component.set('v.uploadDisabled', false);

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
						console.log(response.getReturnValue());
						if(response.getReturnValue() == 'SUCCESS'){
							toastEvent.setParams({
								"title": "Import Successful!",
								"message": 'File was successfully imported.',
								"type":"success"
							});
						}
						
						else if(response.getReturnValue().startsWith("Partial Success")){
							toastEvent.setParams({
								"title": "Partial Import Success!",
								"message": response.getReturnValue(),
								"type":"warning",
								mode: 'sticky'
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
		if(fileType == 'accountTransactionFile'){
			console.log('Setting fileFormat to: csv');
			component.set('v.fileFormat', 'csv');
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