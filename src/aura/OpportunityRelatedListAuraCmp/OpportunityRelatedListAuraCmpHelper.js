({
    getData: function (component){
		var action = component.get('c.getCaseOpps');

        action.setParams({
            recordId: component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var result = response.getReturnValue();
                                                                                        console.log('state-------------------->' + component.get('v.recordId'));
                                                                                        console.log('state-------------------->' + state);
                                                                                        console.log('result-------------------->' + JSON.stringify(result));
            if (state === 'SUCCESS') {
                var oppCaseList = result;

				if(oppCaseList.length>10){
                    var scrollerDiv = component.find("scrollerDiv");
                    $A.util.addClass(scrollerDiv, 'maxHeight');
                }

                oppCaseList.forEach(function (record) {
                                                                                            console.log('oppCaseList record-------------------->' + record);
                    record.linkName = '/' + record.Id;
                    record.ownerLink = '/' + record.opportunity__r.Owner.Id;
					record.sellerLink = '/' + record.opportunity__r.Account.Id;
					record.buyerLink = '/' + record.opportunity__r.Acquiring_Entity__r.Id;
					record.oppLink = '/' + record.opportunity__c;
					
					record.oppName = record.opportunity__r.Name;
                    record.sellerName = record.opportunity__r.Account.Name;
                    record.buyerName = record.opportunity__r.Acquiring_Entity__r.Name;
                    record.oppStageName = record.opportunity__r.StageName;
                    record.oppType = record.opportunity__r.Type;
                    record.oppEffectiveDate = record.opportunity__r.Effective_Date__c;
                    record.oppPSADate = record.opportunity__r.PSA_Date__c;
                    record.oppCloseDate = record.opportunity__r.CloseDate;
                    record.oppOwnerName = record.opportunity__r.Owner.Name;
                    record.oppTotalPricePerAcre = record.opportunity__r.totalPricePerAcre__c;
                    record.oppTotalPrice = record.opportunity__r.totalPrice__c;
                    record.oppAskTotalPricePerAcre = record.opportunity__r.askTotalPricePerAcre__;
                    record.oppAskTotalPrice = record.opportunity__r.askTotalPrice__c;
                });
                component.set('v.data', oppCaseList);
                component.set('v.listlength', oppCaseList.length);
            }
        });
        $A.enqueueAction(action);
    },
})