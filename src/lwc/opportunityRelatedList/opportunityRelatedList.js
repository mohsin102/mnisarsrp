import { LightningElement, wire, track, api } from 'lwc';
import { flattenData, recordUrl } from 'c/lwcutil';
import { NavigationMixin } from 'lightning/navigation';
import { loadScript } from 'lightning/platformResourceLoader';
import jsSRPUtility from '@salesforce/resourceUrl/jsSRPUtility';
import getCaseOpps from '@salesforce/apex/OpportunityRelatedListAura.getCaseOpps';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';


export default class OpportunityRelatedList extends NavigationMixin(LightningElement) {
    @api recordId;
    @track error;
    @track oppData;
    @track columns = [];
    @track title = 'Related Opportunities';
    @track hasOpps = true;
    @track sortCol = 'opportunity__r.CloseDate';
    @track sortDir = 'asc';
    @track caseOppResponse;

    @wire(getCaseOpps, { caseId: '$recordId' })
    wiredFlows(response){
        this.caseOppResponse = response;
        let data = response.data;
        let error = response.error;
    //wiredOpps({ error, data }) {
        if (data) {
            let rows = [];
            data = flattenData(data);
            let iterations = data.length;

            // generate URL
            for (let row of data) {
                const FIELDS_NEEDING_URL = [
                    row['opportunity__r.AccountId'],
                    row['opportunity__r.Acquiring_Entity__c'],
                    row['Id'],
                    row['opportunity__c']
                ];

                const navPromises = FIELDS_NEEDING_URL.map((recordId) =>
                    this[NavigationMixin.GenerateUrl](recordUrl(recordId))
                );

                Promise.all(navPromises)
                    .then(urls => {
                        row.SellerLink = urls[0];
                        row.BuyerLink = urls[1];
                        row.OppCaseLink = urls[2];
                        row.OppLink = urls[3];

                        rows.push(row);
                        if (--iterations <= 0) {
                            _srpUtility.sortArray(
                                rows,
                                this.sortCol,
                                this.sortDir
                            );
                            this.oppData = rows;
                            this.title = 'Related Opportunities (' + rows.length + ')';
                            this.hasOpps = rows.length > 0;
                        }
                    })
                    .catch(error => {
                        console.error(`Error in NavigationMixin: ${error}`);
                    })
            }
        } else if (error) {
            this.error = error;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error on OpportunityRelatedList.js WiredOpps',
                    message: error,
                    variant: 'error'
                })
            );
        }
    }

    constructor() {
        super();
        this.columns = [
            {
                label: 'Opportunity',
                fieldName: 'OppLink',
                sortable: true,
                type: 'url',
                typeAttributes: {
                    value: { fieldName: 'OppLink' },
                    label: { fieldName: 'opportunity__r.Name' },
                    tooltip: 'View Opportunity'
                },
                initialWidth: 300
            },

            {
                label: 'Seller',
                fieldName: 'SellerLink',
                sortable: true,
                type: 'url',
                typeAttributes: {
                    value: { fieldName: 'SellerLink' },
                    label: { fieldName: 'opportunity__r.Account.Name' },
                    tooltip: 'View Seller'
                },
                initialWidth: 280
            },
            {
                label: 'Buyer',
                fieldName: 'BuyerLink',
                sortable: true,
                type: 'url',
                typeAttributes: {
                    value: { fieldName: 'BuyerLink' },
                    label: {
                        fieldName: 'opportunity__r.Acquiring_Entity__r.Name'
                    },
                    tooltip: 'View Buyer'
                },
                initialWidth: 280
            },
            {
                label: 'Stage',
                fieldName: 'opportunity__r.StageName',
                sortable: true,
                initialWidth: 130
            },
            {
                label: 'Type',
                fieldName: 'opportunity__r.Type',
                initialWidth: 120
            },
            {
                label: 'Effective Date',
                fieldName: 'opportunity__r.Effective_Date__c',
                type: 'date-local',
                typeAttributes: {
                    month: '2-digit',
                    day: '2-digit',
                    year: '2-digit'
                },
                sortable: true,
                initialWidth: 120
            },
            {
                label: 'PSA Date',
                fieldName: 'opportunity__r.PSA_Date__c',
                type: 'date-local',
                sortable: true,
                initialWidth: 140
            },
            {
                label: 'Close Date',
                fieldName: 'opportunity__r.CloseDate',
                type: 'date-local',
                typeAttributes: {
                    month: '2-digit',
                    day: '2-digit',
                    year: '2-digit'
                },
                sortable: true,
                initialWidth: 120
            },
            {
                label: 'Owner',
                fieldName: 'opportunity__r.Owner.Name',
                initialWidth: 130
            },
            {
                label: 'Total Price Per Acre',
                fieldName: 'opportunity__r.totalPricePerAcre__c',
                type: 'currency',
                cellAttributes: { alignment: 'left' },
                sortable: true,
                initialWidth: 120
            },
            {
                label: 'Total Price',
                fieldName: 'opportunity__r.totalPrice__c',
                type: 'currency',
                cellAttributes: { alignment: 'left' },
                sortable: true,
                initialWidth: 120,
                editable: false
            },
            {
                label: 'Ask Total Price Per Acre',
                fieldName: 'opportunity__r.askTotalPricePerAcre__c',
                type: 'currency',
                cellAttributes: { alignment: 'left' },
                sortable: true,
                initialWidth: 140
            },
            {
                label: 'Ask Total Price',
                fieldName: 'opportunity__r.askTotalPrice__c',
                type: 'currency',
                cellAttributes: { alignment: 'left' },
                sortable: true,
                initialWidth: 140,
                editable: false
            }
        ];

        loadScript(this, jsSRPUtility)
            .then(result => {
                console.log(`Loaded jsSRPUtility: ${result}`);
            })
            .catch(error => {
                console.error(`Error on loading jsSRPUtility: ${error}`);
            });
    }

    updateColumnSorting(event) {

        let urlLookups = {
            OppLink: 'opportunity__r.Name',
            SellerLink: 'opportunity__r.Account.Name',
            BuyerLink: 'opportunity__r.Acquiring_Entity__r.Name'
        };

        let fieldName = event.detail.fieldName;

        if (typeof urlLookups[fieldName] != 'undefined') {
            fieldName = urlLookups[fieldName];
        }
        let sortDirection = event.detail.sortDirection;

        if (this.sortCol === fieldName) {
            if (this.sortDir === 'asc') {
                sortDirection = 'desc';
            } else if (this.sortDir === 'desc') {
                sortDirection = 'asc';
            }
        }

        this.sortCol = fieldName;
        this.sortDir = sortDirection;

        _srpUtility.sortArray(this.oppData, fieldName, sortDirection);

        this.oppData = JSON.parse(JSON.stringify(this.oppData));
    }

    @api handleApplicationEvent() {
                                                            console.log(`in the oppRelLst handleApplicationEvent`);
        //refreshApex(this.caseOppResponse);
        //eval("$A.get('e.force:refreshView').fire();");
    }
}