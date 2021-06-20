public with sharing class NewTractWizardExtension {

    public LandGridTract__c selLandGridTract {get; set;}
    public String selLandGridTractId {get; set;}
    public Tract__c newTract {get; set;}
    public Boolean showNext {get; set;}

    public Boolean showInstrument {get; set;}
    public Boolean showExisting {get; set;}
    public Boolean showNewInstrument {get; set;}

    public Instrument__c newInstrument {get; set;}
    public Subtract__c newSubtract {get; set;}

    public NewTractWizardExtension(ApexPages.StandardController tractController)
    {
        newSubtract = new Subtract__c();
        showNext = false;
        newTract = new Tract__c(Ford_Tract_Status__c = '107 - Pending Investigation');
        newInstrument = new Instrument__c();
        selLandGridTract = new LandGridTract__c();
        showInstrument = false;
        showExisting = false;
        showNewInstrument = false;
    }

    public PageReference saveNew() {
        return saveTract(Page.NewTractWizard);
    }

    public PageReference save() {
        return saveTract(null);
    }

	//Instrument functionality removed per Quin Cogdell (jdg 02-13-2020)
/*    public PageReference useExisting() {
        showExisting = true;
        showNewInstrument = false;
        return null;
    }

    public PageReference useNewInstrument() {
        showExisting = false;
        showNewInstrument = true;
        return null;
    }
*/

    private PageReference saveTract(PageReference nextPage) {

        Boolean isValid = true;

        if (newTract.LandGridTract__c == null)
        {
            ApexPages.Message newMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'LandGridTract is required.');
            ApexPages.addMessage(newMsg);
            isValid = false;
        }
        if (newTract.Instrument_Type__c == null)
        {
            newTract.Instrument_Type__c.addError('Instrument Type is Required.');
            isValid = false;
        }
        /*if (showInstrument && showNewInstrument) {
            // if the user is creating a new instrument Lessor and Lessee must be filled in at a minimum
            if (newInstrument.Lessee__c == null) {
                newInstrument.Lessee__c.addError('Lessee is required for a new instrument.');
                isValid = false;
            }
            if (newInstrument.Lessor__c == null) {
                newInstrument.Lessor__c.addError('Lessor is required for a new instrument.');
                isValid = false;
            }
        }*/
		System.debug(newTract.Ford_Tract_Status__c);
        if (newTract.Ford_Tract_Status__c == null) {
            newTract.Ford_Tract_Status__c.addError('Ford Tract Status is required.');
            isValid = false;
        }

        if (isValid) {
			try{
				insert newTract;
			}
			catch(DmlException ex){
				System.debug('ex value is: ' + ex.getCause());
				//System.debug(ex.
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage().replace('&quot;', '"')));
				return null;
			}
            

            /*newSubtract.Subtract_Quarter_Call__c = newTract.Quarter_Call__c;
            newSubtract.Subtract_Gross_Acres__c = newTract.Gross_Acres__c;
            newSubtract.Subtract_Acres__c = newTract.netAcres__c;
            newSubtract.Subtract_Full_Legal_Description__c = newTract.Full_Legal_Name__c;
            newSubtract.Lot__c = newTract.Lots__c;
            newSubtract.Grid_Exception__c = newTract.Grid_Exception__c;
            newSubtract.Tract__c = newTract.Id;

            // If a new instrument is created, insert it and link it to the subtract
            if (showInstrument && showNewInstrument) {
                insert newInstrument;
                newSubtract.Instrument__c = newInstrument.Id;
            }
			List<Subtract__c> subTracts = [SELECT Id FROM Subtract__c WHERE Tract__c =:newTract.Id];
            if(subTracts.size()<1){
            	insert newSubtract;
            }*/

            PageReference tractPage = nextPage;
            if (tractPage == null) {
                tractPage = new PageReference('/'+newTract.Id);
            }

            tractPage.setRedirect(true);
            return tractPage;
            //return null;
        }
        else {
            return null;
        }
    }

    public void setId() {
		
        selLandGridTractId = ApexPages.currentPage().getParameters().get('selectedValue');
		if(String.isNotEmpty(selLandGridTractId)){
			newTract.LandGridTract__c = selLandGridTractId;
			selLandGridTract = [SELECT Id,Name,State__c,County__c,
					Abstract__c,Block__c,Section__c,Title_Notes__c,
					Township__c,Title_Status__c,RecordType.Name
				FROM LandGridTract__c WHERE Id =: selLandGridTractId];
			showNext=true;
		}
		else{
			newTract.LandGridTract__c = null;
			showNext=true;
		}
		
    }
    public void setOppId() {
        newTract.Link_to_Opportunity__c= ApexPages.currentPage().getParameters().get('selectedOppValue');
    }

/*    public void updateInstrument() {
        showInstrument = (newTract.Instrument_Type__c != 'Surface');
        System.debug('Instrument Type: ' + newTract.Instrument_Type__c);
        if (showInstrument) {
            showExisting = true;
            showNewInstrument = false;
        } else {
            showExisting = false;
            showNewInstrument = false;
        }

    }
*/
}