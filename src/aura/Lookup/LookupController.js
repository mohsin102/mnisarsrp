({
    search : function(component, event, helper) {
        const action = event.getParam('arguments').serverAction;
        helper.toggleSearchSpinner(component);

        action.setParams({
            searchTerm : component.get('v.searchTerm'),
            selectedIds : helper.getSelectedIds(component)
        });

        action.setCallback(this, (response) => {
            const state = response.getState();
            if (state === 'SUCCESS') {
                helper.toggleSearchSpinner(component);
                // Process server success response
                const returnValue = response.getReturnValue();
                component.set('v.searchResults', returnValue);
            }
            else if (state === 'ERROR') {
                helper.toggleSearchSpinner(component);
                // Retrieve the error message sent by the server
                const errors = response.getError();
                let message = 'Unknown error'; // Default error message
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    const error = errors[0];
                    if (typeof error.message != 'undefined') {
                        message = error.message;
                    } else if (typeof error.pageErrors != 'undefined' && Array.isArray(error.pageErrors) && error.pageErrors.length > 0) {
                        const pageError = error.pageErrors[0];
                        if (typeof pageError.message != 'undefined') {
                            message = pageError.message;
                        }
                    }
                }
                // Display error in console
                console.error('Error: '+ message);
                console.error(JSON.stringify(errors));
                // Fire error toast if available (LEX only)
                const toastEvent = $A.get('e.force:showToast');
                if (typeof toastEvent !== 'undefined') {
                    toastEvent.setParams({
                        title : 'Server Error',
                        message : message,
                        type : 'error',
                        mode: 'sticky'
                    });
                    toastEvent.fire();
                }
            }
        });

        //action.setStorable(); // Enables client-side cache & makes action abortable
        $A.enqueueAction(action);
    },

    onInput : function(component, event, helper) {
        // Prevent action if selection is not allowed
        console.log('onInput method called.');

		if (!helper.isSelectionAllowed(component)) {
            return;
        }
		console.log('Selection allowed.');
        const newSearchTerm = event.target.value;
        helper.updateSearchTerm(component, newSearchTerm);
    },

    onResultClick : function(component, event, helper) {
        const recordId = event.currentTarget.id;
        helper.selectResult(component, recordId);
        console.log(recordId);

        // additional user defined event on result click
        // for optional error handling / clearing in consumer
        var event = component.getEvent('onSelection');
        if (event) {

            setTimeout($A.getCallback(function() {

                var selEvent = $A.get('e.c:LandGridTractSelected');
                console.log('event:'+selEvent);
                selEvent.setParam('selId',recordId);
				selEvent.setParam('parentId', component.get('v.parentId'));
                selEvent.fire();
            }));

//                    myEvent.setParam('selId',recordId);
//                    myEvent.fire();
            console.log('fired event');
        }
    },

    onComboboxClick : function(component, event, helper) {
        // Hide combobox immediately
        const blurTimeout = component.get('v.blurTimeout');
        if (blurTimeout) {
            clearTimeout(blurTimeout);
        }
        component.set('v.hasFocus', false);
    },

    onFocus : function(component, event, helper) {
        // Prevent action if selection is not allowed
        console.log('focus');
		console.log(event.currentTarget.id);
        if (!helper.isSelectionAllowed(component)) {
            return;
        }
        component.set('v.hasFocus', true);
        var cbox = component.find('searchInput');

        console.log(cbox);
        console.log(cbox.getGlobalId()+'_'+cbox.getLocalId());
        //cbox.setAttribute('Autocomplete','off');
        var inputBox = document.getElementById(event.currentTarget.id);
        console.log('got inputbox');
            console.log(inputBox);
			if(inputBox){
				if(inputBox.getAttribute("autocomplete") !== "off"){
					inputBox.setAttribute("autocomplete","off");
				}
			}

    },

    onBlur : function(component, event, helper) {
        // Prevent action if selection is not allowed
        console.log('blur');
        if (!helper.isSelectionAllowed(component)) {
            return;
        }
        // Delay hiding combobox so that we can capture selected result
        const blurTimeout = window.setTimeout(
            $A.getCallback(function() {
                component.set('v.hasFocus', false);
                component.set('v.blurTimeout', null);
            }),
            300
        );
        component.set('v.blurTimeout', blurTimeout);
    },

    onRemoveSelectedItem : function(component, event, helper) {
        const itemId = event.getSource().get('v.name');
        helper.removeSelectedItem(component, itemId);
    },

    onClearSelection : function(component, event, helper) {
        helper.clearSelection(component);
    },

     onKeyDown : function(component, event, helper) {

         console.log('Key Code: ' + event.keyCode);
         var searchBox = component.find('searchInput');
         var arrowPos = component.get('v.arrowPos');
         var e = event;
         const searchResults = component.get('v.searchResults');
         console.log(searchBox);

        // Handle down arrow and Tab
        // Tab will select the first item ONLY if no item is selected.  If you click tab again, you will select the first item.
         if (e.keyCode === 40 || (e.keyCode === 9 && searchResults.length > 0 && arrowPos != 0)) {

            if (searchResults.length > 0) {
                 var results = component.find('sResult');
                 if (!Number.isInteger(arrowPos)) {
                     arrowPos = 0;
                     $A.util.addClass(results[arrowPos],'selResultClass');
                     component.set('v.arrowPos',0);
                     e.preventDefault();
                 } else if (arrowPos < searchResults.length -1) {
                     // do this only if we're not at the last position
                     $A.util.removeClass(results[arrowPos],'selResultClass');
                     arrowPos++;
                     $A.util.addClass(results[arrowPos],'selResultClass');
                     component.set('v.arrowPos',arrowPos);
                     results[arrowPos].getElement().scrollIntoView();
                     e.preventDefault();
                 }
             }
         } else if (e.keyCode === 38) {
             // Handle up arrow
             if (searchResults.length > 0) {
                 var results = component.find('sResult');
                 if (!Number.isInteger(arrowPos)) {
                     arrowPos = searchResults.length - 1;
                     $A.util.addClass(results[arrowPos],'selResultClass');
                     component.set('v.arrowPos',0);
                 } else if (arrowPos > 0) {
                     // do this only if we're not on the last position
                     $A.util.removeClass(results[arrowPos],'selResultClass');
                     arrowPos--;
                     $A.util.addClass(results[arrowPos],'selResultClass');
                     component.set('v.arrowPos',arrowPos);
                     results[arrowPos].getElement().scrollIntoView();
                 }
             }
         } else if (e.keyCode === 13 || e.keyCode === 9) {
            // Enter or Tab was selected - select the item

            if (Number.isInteger(arrowPos) && arrowPos >= 0) {
                var recordId = searchResults[arrowPos].id;
                helper.selectResult(component, recordId);
                setTimeout($A.getCallback(function() {
                    var selEvent = $A.get('e.c:LandGridTractSelected');
                    selEvent.setParam('selId',recordId);
                    selEvent.fire();
                }));
                component.set('v.arrowPos',undefined);
                e.preventDefault();
                e.stopPropagation();
            }

            return false;
         }
         else if (event.which == 46 || event.which == 8)
         {
             // delete / backspace clicked, remove the selected item.

         }
     }
})