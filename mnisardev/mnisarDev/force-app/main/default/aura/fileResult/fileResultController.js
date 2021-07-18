({
	previewFile :function(component,event,helper){
		//var selectedPillId = e.getSource().get("v.name");
		var selectedRecord = component.get('v.record').cv.ContentDocumentId;
		$A.get('e.lightning:openFiles').fire({
				recordIds: [selectedRecord]
				});
	},
})