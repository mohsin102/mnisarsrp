({
    doInit: function (component, event, helper) {},

    showManageCases: function (component, event, helper) {
        $A.createComponent(
            'c:ManageCases',
            { recordId: component.get('v.recordId') },
            function (modalComponent, status, errorMessage) {
                if (status === 'SUCCESS') {
                    console.log('SUCCESS');
                    var body = component.get('v.body');
                    body.push(modalComponent);
                    component.set('v.body', body);
                } else if (status === 'INCOMPLETE') {
                    console.error('No response from modal');
                } else if (status === 'ERROR') {
                    console.error(`Error: ${errorMessage}`);
                }
            }
        );
    },
    handleCloseModal: function (component, event, helper) {
        component.find('relatedList').refreshCmp();
    }
});