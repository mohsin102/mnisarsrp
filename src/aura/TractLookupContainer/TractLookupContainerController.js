({
    lookupSearch : function(component, event, helper) {
              // Get the SampleLookupController.search server side action
              const serverSearchAction = component.get('c.search');
              // Passes the action to the Lookup component by calling the search method
              component.find('lookup').search(serverSearchAction);
          },

               linkGridToTract : function(component, event, helper) {
                   // Prevent action if selection is not allowed
                    var sel = component.get("v.selection");
                    console.log(JSON.stringify(sel));
                    console.log(sel[0].id);
                    console.log(component.get("v.parentId"));

                   var action = component.get('c.linkTract');
                   action.setParams({selectedId:sel[0].id, parentId:component.get("v.parentId")});
                   console.log('Sending parameter');
                   action.setCallback(this, function(response) {
                       var state = response.getState();
                       if (state === "SUCCESS") {
                           window.parent.location = '/' + component.get("v.parentId");
                       }
                       else if (state === "ERROR") {
                                      var errors = response.getError();
                                      if (errors) {
                                          if (errors[0] && errors[0].message) {
                                              console.log("Error message: " +
                                                       errors[0].message);
                                          }
                                      } else {
                                          console.log("Unknown error");
                                      }
                                  }
                   });
                   $A.enqueueAction(action);

               }
})