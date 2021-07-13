({
    openCreatedRecord: function (component, event, helper) {
        var record = event.getParam("response");
        var recordId = record.id;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId,
            "slideDevName": "detail"
        });
        navEvt.fire();
        component.find("overlayLib").notifyClose();
    }
})