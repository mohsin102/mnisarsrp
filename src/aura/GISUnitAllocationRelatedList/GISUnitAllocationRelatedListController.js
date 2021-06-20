({
	handleKeyUp: function (component, event, helper) {
       var activeChildComp = component.find('ActiveChildComponent');
       activeChildComp.callChild();

       var inactiveChildComp = component.find('InactiveChildComponent');
       inactiveChildComp.callChild();
	}
    
})