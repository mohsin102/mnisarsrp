import { LightningElement, wire, track, api } from 'lwc';
import { flattenData, sortArray, recordUrl } from 'c/lwcutil';
import { NavigationMixin } from 'lightning/navigation';
import {refreshApex} from '@salesforce/apex';
import getOpps from '@salesforce/apex/TractExtension.getOpps';
import updatePricing from '@salesforce/apex/TractExtension.updatePricing';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// This is the one that goes on TRACTS and lists Opportunities
export default class TractOpportunityList extends NavigationMixin(LightningElement) {
    @api recordId;
    @track error;
    @track oppData;
    @track columns = [];
    @track title = 'Related Opportunities';
    @track hasOpps = false;
    @track sortCol = 'Opportunity__r.CloseDate';
    @track sortDir = 'asc';
    wiredDate;
	draftValues = [];

    @api
    forceRefreshInitiated() {
        return refreshApex(this.wiredDate);
    }

    @wire(getOpps, {'tractId':'$recordId'})
    opps;

    @wire(getOpps, {'tractId':'$recordId'})
    wiredOpps({error,data}) {

        const sfUrl = async (recordId) => {
            return await this[NavigationMixin.GenerateUrl](recordUrl(recordId));
        }


        if (data) {

            var rows = [];
            this.opps.data = flattenData(data);

            // Track number of iterations
            let iterations = this.opps.data.length;
            console.log(JSON.stringify(this.opps.data));

            // generate URL
            for (let row of this.opps.data) {
                // need to use Promise.all for 3 url's
                sfUrl(row['Opportunity__r.AccountId']).then( url => {
                    row.SellerLink = url;
                });
                sfUrl(row['Opportunity__r.Acquiring_Entity__c']).then( url => {
                    row.BuyerLink = url;
                });
				sfUrl(row['Id']).then( url => {
                    row.OppTractLink = url;
                });
                sfUrl(row['Opportunity__c']).then( url => {
                    console.log('newURL' + url);
                    row.OppLink = url;
                    rows.push(row);
                    if (--iterations <= 0) {
                        //console.log('ROWS---->'+JSON.stringify(rows));
                        sortArray(rows,this.sortCol,this.sortDir);
                        this.opps.data = rows;
                        this.oppData = rows;
                        this.title = 'Related Opportunities (' + rows.length + ')';
                        this.hasOpps = (rows.length > 0);
                    }
                });
            }
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.opps = undefined;
        }
    }

    constructor() {
        super();
        this.columns = [
            { label: 'Opp Tract', fieldName: 'OppTractLink', sortable: true, type:'url', typeAttributes:
                    {value: {fieldName: 'OppLink'}, label: {fieldName: 'Name'}, tooltip: 'View Opportunity Tract'},
                initialWidth: 150},
			{ label: 'Opportunity', fieldName: 'OppLink', sortable: true, type:'url', typeAttributes:
                    {value: {fieldName: 'OppLink'}, label: {fieldName: 'Opportunity__r.Name'}, tooltip: 'View Opportunity'},
                initialWidth: 300},
			
            { label: 'Seller', fieldName: 'SellerLink', sortable: true, type:'url', typeAttributes:
                    {value: {fieldName: 'SellerLink'}, label: {fieldName: 'Opportunity__r.Account.Name'}, tooltip: 'View Seller'},
                initialWidth: 280},
            { label: 'Buyer', fieldName: 'BuyerLink', sortable: true, type:'url', typeAttributes:
                    {value: {fieldName: 'BuyerLink'}, label: {fieldName: 'Opportunity__r.Acquiring_Entity__r.Name'}, tooltip: 'View Buyer'},
                initialWidth: 280},
            { label: 'Stage', fieldName: 'Opportunity__r.StageName', sortable: true, initialWidth: 130},
            { label: 'Type', fieldName: 'Opportunity__r.Type', initialWidth: 120},
            { label: 'Effective Date', fieldName: 'Opportunity__r.Effective_Date__c', type: 'date-local', typeAttributes:{
                month:"2-digit", day:"2-digit", year:"2-digit"}, sortable: true, initialWidth: 120},
            { label: 'PSA Date', fieldName: 'Opportunity__r.PSA_Date__c', type: 'date-local', sortable: true, initialWidth: 140},
            { label: 'Close Date', fieldName: 'Opportunity__r.CloseDate', type: 'date-local', typeAttributes:{
                month:"2-digit", day:"2-digit", year:"2-digit"}, sortable: true, initialWidth: 120},
            { label: 'Owner', fieldName: 'Opportunity__r.Owner.Name', initialWidth: 130},
            { label: 'Unit Price', fieldName: 'unitPrice__c', type: 'currency', cellAttributes: { alignment: 'left' }, sortable: true ,initialWidth: 120,  editable: true},
			{ label: 'Total Price', fieldName: 'totalPrice__c', type: 'currency', cellAttributes: { alignment: 'left' }, sortable: true, initialWidth: 120 },
            { label: 'Ask Unit Price', fieldName: 'askUnitPrice__c', type: 'currency', cellAttributes: { alignment: 'left' }, sortable: true ,initialWidth: 140, editable: true},
			{ label: 'Ask Total Price', fieldName: 'askTotalPrice__c', type: 'currency', cellAttributes: { alignment: 'left' }, sortable: true, initialWidth: 140 }
        ];

    }

    connectedCallback() {

    }

    updateColumnSorting(event) {
		var urlLookups = {'OppTractLink':'Name', 'OppLink':'Opportunity__r.Name', 'SellerLink':'Opportunity__r.Account.Name', 'BuyerLink':'Opportunity__r.Acquiring_Entity__r.Name'};

        //console.log('sort requested');
		//console.log(JSON.stringify(event.detail));
        var fieldName = event.detail.fieldName;
		//console.log('typeof value is: ' + typeof urlLookups[fieldName]);
		if(typeof urlLookups[fieldName] != 'undefined'){
			fieldName = urlLookups[fieldName];
			console.log ('Sort field should be updated to: ' + urlLookups[fieldName]);
		}
        var sortDirection = event.detail.sortDirection;

        if (this.sortCol === fieldName) {
            if (this.sortDir === 'asc') {
                sortDirection = 'desc';
            } else if (this.sortDir === 'desc') {
                sortDirection = 'asc';
            }
        }

        console.log('Field: ' + fieldName + ' Dir: ' + sortDirection);
        console.log('sortby'+sortDirection);

        this.sortCol = fieldName;
        this.sortDir = sortDirection;
        let sortme = this.oppData;
        //console.log('unsortified'+JSON.stringify(sortme));
        //TODO: make sortArray return a COPY of the object.  new syntax: this.oppData = sortArray(etc...)
        sortArray(sortme,fieldName,sortDirection);

        //console.log('SORtified'+JSON.stringify(sortme));
        this.oppData = JSON.parse(JSON.stringify(sortme));
    }

    async handleSave(event) {

        const updatedFields = event.detail.draftValues;
		console.log(JSON.stringify(updatedFields));
		// Prepare the record IDs for getRecordNotifyChange()
		const notifyChangeIds = updatedFields.map(row => { return { "recordId": row.Id } });

		try {
			// Pass edited fields to the updateContacts Apex controller
			const result = await updatePricing({data: updatedFields});
			console.log(JSON.stringify("Apex update result: "+ result));
			this.dispatchEvent(
				new ShowToastEvent({
					title: 'Success',
					message: 'Pricing updated',
					variant: 'success'
				})
			);

			// Refresh LDS cache and wires
			getRecordNotifyChange(notifyChangeIds);
			console.log('record notify change passed.');
			// Display fresh data in the datatable
			refreshApex(this.opps).then(() => {
				// Clear all draft values in the datatable
				console.log('inside refreshApex');
				this.draftValues = [];
			});
		} catch(error) {
			console.log(JSON.stringify(error));
			this.dispatchEvent(
				new ShowToastEvent({
					title: 'Error updating or refreshing records',
					//message: error.body.message,
					variant: 'error'
				})
			);
		};
    }
}