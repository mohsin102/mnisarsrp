({
    hideCmp: function (component, event, helper) {
        var cmpToHide = component.find('DivOrderRelatedList');
        $A.util.addClass(cmpToHide, 'hideCmp');
        console.log(`classname is-----------------> ${$A.util.hasClass(cmpToHide, 'hideCmp')}`);
    }
});