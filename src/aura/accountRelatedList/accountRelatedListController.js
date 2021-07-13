({
	doInit : function(component, event, helper) {
		helper.getTotalNumberOfRecords(component);
        helper.getColumns(component);
        helper.getData(component, helper);
    },
     
    handleLoadMore: function (component, event, helper) {
        event.getSource().set("v.isLoading", true);
        component.set('v.loadMoreStatus', 'Loading....');
		helper.getData(component, helper);
    },
    handleColumnSorting: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        var data = component.get('v.data');
		console.log('fieldName value is: ' + fieldName);
		console.log('sortDirection value is: ' + sortDirection);
		component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
		data = _srpUtility.sortArray(data, fieldName, sortDirection);
		component.set('v.data', data);
        //helper.sortData(component, fieldName, sortDirection);
    },
	jsLoaded: function(component, event, helper){
		//Placeholder if need to perform action after scripts are loaded.
		//console.log('javascript library has been loaded.');
	}
})