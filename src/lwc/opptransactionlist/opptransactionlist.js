import { LightningElement, wire, track, api } from 'lwc';
import { getFieldValue } from 'lightning/uiRecordApi';
import { flattenData, sortArray, recordUrl } from 'c/lwcutil';
import { NavigationMixin } from 'lightning/navigation';
import {refreshApex} from '@salesforce/apex';
import getTracts from '@salesforce/apex/OppExtension.getTracts';
import getOppType from '@salesforce/apex/OppExtension.getOppType';
import updatePricing from '@salesforce/apex/OppExtension.updatePricing';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class OppTransactionList extends NavigationMixin(LightningElement) {
    @api recordId;
	@api sObjectName;
    @track error;
    @track tractData;
    @track columns = [];
    @track title = 'Related Tracts';
    @track hasTracts = false;
    @track sortCol = 'TractLink';
    @track sortDir = 'asc';
    @track largeTractList = false;
    @track tableClass = '';
	@track tableStyle = '';
    wiredDate;
	draftValues = [];

    @api
    forceRefreshInitiated() {
        return refreshApex(this.wiredDate);
    }

    // Build columns based on opportunity type
    @wire(getOppType, {'oppId':'$recordId'})
    wiredOppType({error,data}) {
        // we know the type (Acquisition or Divestiture) now, so set the columns accordingly

        let columns = [
            { label: 'Tract', fieldName: 'TractLink', sortable: true, type:'url', typeAttributes:
                    {value: {fieldName: 'TractLink'}, label: {fieldName: 'Tract__r.Name'}, tooltip: 'View tract'},
                initialWidth: 100},
			{ label: 'Opp Tract', fieldName: 'otLink', sortable: true, type:'url', typeAttributes:
                    {value: {fieldName: 'otLink'}, label: {fieldName: 'Name'}, tooltip: 'View Opportunity Tract'},
                initialWidth: 125},
            { label: 'Full Legal Name', fieldName: 'Tract__r.Full_Legal_Name__c', sortable: true, initialWidth: 200},
            { label: 'Depth', fieldName: 'Tract__r.depth__c', initialWidth: 100},
			{ label: 'Title Source', fieldName: 'Tract__r.titleSourceType__c', initialWidth: 150},
			{ label: 'Notes', fieldName: 'Tract__r.Notes__c', initialWidth: 200},
            { label: 'Instrument', fieldName: 'Instrument_Type__c', initialWidth: 100},
            { label: 'Acres', fieldName: 'Acres', type: 'textExtended', typeAttributes:{title:{ fieldName: 'Acres' }, value:{ fieldName: 'Acres' }}, sortable: true, initialWidth: 90},
        ];

        /*if (data === 'Acquisition') {
            columns.push({ label: 'OTG Cost Per Acre', fieldName: 'OTG_Cost_Per_Acre__c', type: 'currency', sortable: true, initialWidth: 170, }),
                columns.push({ label: 'OTG Cost', fieldName: 'OTG_Cost__c', type: 'currency', sortable: true, initialWidth: 140 });
        }*/

        // Always add total cost columns
        columns.push(...[
			{ label: 'Unit Price', fieldName: 'unitPrice__c', type: 'currency', cellAttributes: { alignment: 'left' }, sortable: true ,initialWidth: 120, editable: true},
            { label: 'Total Price', fieldName: 'totalPrice__c', type: 'currency', cellAttributes: { alignment: 'left' }, sortable: true, initialWidth: 120 },
			{ label: 'Ask Unit Price', fieldName: 'askUnitPrice__c', type: 'currency', cellAttributes: { alignment: 'left' }, sortable: true ,initialWidth: 140, editable: true},
			{ label: 'Ask Total Price', fieldName: 'askTotalPrice__c', type: 'currency', cellAttributes: { alignment: 'left' }, sortable: true, initialWidth: 140 },
			//{ label: 'Total Cost Per Acre', fieldName: 'Total_Cost_Per_Acre__c', type: 'currency', sortable: true, initialWidth: 190, },
            //{ label: 'Total Cost', fieldName: 'Total_Cost__c', type: 'currency', sortable: true, initialWidth: 120, },
			{ label: '% Covered by AOI Pricing', fieldName: 'Tract__r.percentCovered__c', type: 'percent', sortable: true, initialWidth: 190,},
			//{ label: 'Suggested OTG Cost Per Acre', fieldName: 'suggOTGCostPerAcre', type: 'currency', sortable: true, initialWidth: 150,},
			//{ label: 'Suggested OTG Total Cost', fieldName: 'suggTotalOTGCost', type: 'currency', sortable: true, initialWidth: 150,},
			{ label: 'Target OTG Cost Per Acre', fieldName: 'Tract__r.targetPPA__c', type: 'currency', sortable: true, initialWidth: 190,},
			{ label: 'Total Target OTG Cost', fieldName: 'Tract__r.targetPrice__c', type: 'currency', sortable: true, initialWidth: 190,},
			{ label: 'Max OTG Price Per Acre', fieldName: 'Tract__r.maxPPA__c', type: 'currency', sortable: true, initialWidth: 190,},
			{ label: 'Max OTG Total Cost', fieldName: 'Tract__r.maxPrice__c', type: 'currency', sortable: true, initialWidth: 190,}
        ]);

        /*if (data === 'Divestiture') {
            columns.push(...[
                { label: 'FMV Per Acre', fieldName: 'FMV_Per_Acre__c', type: 'currency', sortable: true, initialWidth: 150, },
                { label: 'FMV', fieldName: 'Fair_Market_Value__c', type: 'currency', sortable: true, initialWidth: 150,},
                { label: 'Gain on Asset', fieldName: 'Gain_on_Asset__c', type: 'currency', sortable: true, initialWidth: 150,},
            ]);
        }*/
        // Add a blank column for correct dynamic sizing
        columns.push({label:'',fieldName:'',type:''});
        // All done, update the tracked columns.
        this.columns = columns;
        //console.log('all cols'+JSON.stringify(this.columns));
    }

    @wire(getTracts, {'recordId':'$recordId', 'sObjectName':'$sObjectName'})
    tracts;

    @wire(getTracts, {'recordId':'$recordId', 'sObjectName':'$sObjectName'})
    wiredTracts(result) {
        this.wiredDate = result;
        const sfUrl = async (recordId) => {
            return await this[NavigationMixin.GenerateUrl](recordUrl(recordId));
        }

        if (result.data) {

            var rows = [];
            this.tracts.data = flattenData(result.data);
            
            // Track number of iterations
            let iterations = this.tracts.data.length;

            //this.tableClass = (iterations > 10) ? 'slds-scrollable srp-scroll' : '';
			this.tableStyle = (iterations > 10) ? 'height: 300px;' : '';

            // generate UR
            var count = 0;
            var total = result.data.length;
            for (let row of this.tracts.data) {
                if(row['Tract__r.Account__c'] === row['Opportunity__r.AccountId']){
                    count++;
                }

                sfUrl(row['Tract__r.Id']).then( url => {
                    //console.log('newURL' + url);
                    row.TractLink = url;
                    //rows.push(row);
                    if (--iterations <= 0) {
                        //console.log('ROWS---->'+JSON.stringify(rows));
                        sortArray(rows,this.sortCol,this.sortDir);
                        this.tracts.data = rows;
                        this.tractData = rows;

                        
                        this.hasTracts = (rows.length > 0);
						//console.log(JSON.stringify(this.tractData));
						const passEvent = new CustomEvent('datainformation', {
							detail:{data:this.tractData, columns:this.columns} 
						});
						this.dispatchEvent(passEvent);
                    }
                });
				sfUrl(row['Id']).then( url => {
                    //console.log('newOTURL' + url);
                    row.otLink = url;
                    //rows.push(row);
                });
				rows.push(row);
				//console.log('Tract Acres type is: ' + typeof(row['Tract_Acres__c']));
				//console.log('Tract Acres value is: ' + row['Tract_Acres__c']);
				if(typeof(row['Tract_Acres__c']) == 'string'){
					row['Tract_Acres__c'] = parseFloat(row['Tract_Acres__c']);
				}
				if(row['Tract__r.Id'] && typeof(row['Tract_Acres__c'])!='undefined'){
					if(row['Tract__r.netAcreageUnits__c']){
						row.Acres = row['Tract_Acres__c'].toFixed(1) + ' ' + row['Tract__r.netAcreageUnits__c'];
					}
					else{
						row.Acres = row['Tract_Acres__c'].toFixed(1) + ' ?';
					}
				}
				//console.log(row.Acres);
            }
            this.title = 'Related Tracts ('+count+' out of ' + total + ')';
            
            if(this.tracts.data.length <=0){
                this.tractData =[];
                this.title = 'Related Tracts (0)';
            }


            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.tracts = undefined;
        }
		
    }

    constructor() {
        super();
        //console.log('COLUMNS');
    }

    connectedCallback() {

    }

    updateColumnSorting(event) {
        //console.log('sort requested');

        var urlLookups = {'TractLink':'Tract__r.Name', 'otLink':'Name'};

        var fieldName = event.detail.fieldName;
        if(typeof urlLookups[fieldName] != 'undefined'){
            fieldName = urlLookups[fieldName];
        }
        var sortDirection = event.detail.sortDirection;

        if (this.sortCol === fieldName) {
            if (this.sortDir === 'asc') {
                sortDirection = 'desc';
            } else if (this.sortDir === 'desc') {
                sortDirection = 'asc';
            }
        }

        //console.log('Field: ' + fieldName + ' Dir: ' + sortDirection);
        //console.log('sortby'+sortDirection);

        this.sortCol = fieldName;
        this.sortDir = sortDirection;
        let sortme = this.tractData;
        //console.log('unsortified'+JSON.stringify(sortme));
        sortArray(sortme,fieldName,sortDirection);

        //console.log('SORtified'+JSON.stringify(sortme));
        this.tractData = JSON.parse(JSON.stringify(sortme));
    }

	async handleSave(event) {

        const updatedFields = event.detail.draftValues;
		//console.log(`The updated fields are---------> ${JSON.stringify(updatedFields)}`);
		const notifyChangeIds = updatedFields.map(row => { return { "recordId": row.Id } });

		try {
			// Pass edited fields to the Apex controller
			const result = await updatePricing({data: updatedFields});
			//console.log(JSON.stringify("Apex update result: "+ result));
			this.dispatchEvent(
				new ShowToastEvent({
					title: 'Success',
					message: 'Pricing updated',
					variant: 'success'
				})
			);

			// Refresh LDS cache and wires
			getRecordNotifyChange(notifyChangeIds);
			//console.log('record notify change passed.');
			// Display fresh data in the datatable
			refreshApex(this.tracts).then(() => {
				// Clear all draft values in the datatable
				//console.log('inside refreshApex');
				this.draftValues = [];
			});
		} catch(error) {
			//console.log(JSON.stringify(error));
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