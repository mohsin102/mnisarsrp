import { LightningElement, track, wire, api } from 'lwc';
import { flattenData, sortArray, recordUrl, pageData } from 'c/lwcutil';
import { NavigationMixin } from 'lightning/navigation';
import getWellInfo from '@salesforce/apex/WellUnitUtil.getWellInfo';

//TODO: this needs to use a control to display the tables with pagers, rather than have all the logic
// for all three types of lists
export default class LightningExampleAccordionMultiple extends NavigationMixin(LightningElement) {

    @api recordId;

    // columns for the well object, WellColumns apply to both Hz/Vt Well InterestAllocation objects
    @track columns = {well:[],permit:[],duc:[]};
    @track accordionLabel = {permit:'Hz Permits',duc:'Hz DUC',hz:'Horizontal Wells',vert:'Vertical Wells'};
    @track value = ['option1'];
    @track isSelected = false;
    @track table = { permits:[],DUC:[],hzWells:[],vertWells:[]};
    // This could be restructured like paging.hz paging.vt, paging.permits with same object structure underneath
    @track paging = { permitsPage:1,DUCPage:1,hzWellsPage:1,vertWellsPage:1,size:10,
                        permitsPages:1,DUCPages:1,hzPages:1,vertPages:1,
                        showPermitLeft:true,showPermitRight:true,showPermitPager:false,
                        showDUCLeft:true,showDUCRight:true,showDUCPager:false,
                        showHzLeft:true,showHzRight:true,showHzPager:false,
                        showVtLeft:true,showVtRight:true,showVtPager:false
                    };
    @track loaded = false;
    @track sortDir = 'asc';

    @wire(getWellInfo, {'objId': '$recordId'})
    wiredWellInfo({error, data}) {
        //console.log(JSON.stringify(data));
        if (data) {
            this.accordionLabel.permit = 'Hz Permits (' + data.permits.length + ')';
            this.accordionLabel.duc = 'Hz DUC (' + data.ducWells.length + ')';
            this.accordionLabel.hz  = 'Horizontal Wells (' + data.hzPaying + '/' + data.hzWells.length + ' with Production Data)';
            this.accordionLabel.vert  = 'Vertical Wells (' + data.vertPaying + '/' + data.vertWells.length + ' with Production Data)';
        }

        //TODO: Move to util
        var formatter = new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD',
        });

        // Generate a URL from a recordId
        // Needs to move to LWCUtil.js but utils can't access NavigationMixin
        const sfUrl = async (recordId) => {
            return await this[NavigationMixin.GenerateUrl](recordUrl(recordId));
        }

        if (data) {
            this.vertPaying = data.vertWells;

            // Need to flatten each of the tables to use dot notation
            this.table.vertWells = flattenData(data.vertWells);
            this.table.permits = flattenData(data.permits);
            this.table.hzWells = flattenData(data.hzWells);
            this.table.duc = flattenData(data.ducWells);
            if(data.objName === 'Unit__c'){
                this.columns.well = [
                    //{label: 'Interest', fieldName: 'WILink', sortable: true, type:'url', cellAttributes: { alignment: 'left' }, typeAttributes: {value: {fieldName: 'WILink'},label: {fieldName: 'suaName'}, tooltip: 'View Interest'}, initialWidth: 120},
                    {label: 'Well', fieldName: 'WellLink', sortable: true, type:'url', cellAttributes: { alignment: 'left' }, typeAttributes: {value: {fieldName: 'WellLink'},label: {fieldName: 'well.Name'}, tooltip: 'View Well'}, initialWidth: 200},
                    {label: 'API', fieldName: 'well.API10__c', sortable: true, cellAttributes: { alignment: 'left' }, initialWidth: 200},
                    //{label: 'API', fieldName: 'WellLink', sortable: true, type:'url', cellAttributes: { alignment: 'left' }, typeAttributes: {value: {fieldName: 'WellLink'},label: {fieldName: 'well.API10__c'}, tooltip: 'View Well'}, initialWidth: 100},
                    {label: 'Unit', fieldName: 'unitLink', sortable: true, type:'url', cellAttributes: { alignment: 'left' }, typeAttributes: {value: {fieldName: 'unitLink'},label: {fieldName: 'well.Unit__r.Name'}, tooltip: 'View Unit'}, initialWidth: 100},
                    //{label: 'Name', fieldName: 'well.Name', sortable: true, cellAttributes: { alignment: 'left' }, initialWidth: 200},
                   // {label: 'Subtract', fieldName: 'well.Name', sortable: true, cellAttributes: { alignment: 'left' }, initialWidth: 200},
                    {label: 'Operator', fieldName: 'well.Current_Operator_Name__c', sortable: true, cellAttributes: { alignment: 'left' }, initialWidth: 150},
                    {label: 'Direction', fieldName: 'well.Hole_Direction__c', sortable: true, cellAttributes: { alignment: 'left' }},
                    {label: 'Last Activity', fieldName: 'well.LastActivityDate__c', type: 'date-local', sortable: true, cellAttributes: { alignment: 'left' }},
                    {label: 'Producing', fieldName: 'well.Is_Paying_calc__c', type: 'boolean', sortable: true, cellAttributes: { alignment: 'left' }},
                    //{label: 'NRI', fieldName: 'suaDecimal', type: 'number', typeAttributes: {minimumFractionDigits:9}, sortable: true, cellAttributes: { alignment: 'left' }},
                    {label: 'Last Production Month', fieldName: 'well.Last_Production_Month__c', type: 'date-local', sortable: true, cellAttributes: { alignment: 'left' }},
                ];        
            }
            // Update loaded to turn off the spinner
            this.loaded=true;

            // Track number of iterations so we can process at the end
            // Promise would be better than running logic on the last iteration
            // start fresh and build rows table with link.
            // Add link column to permits.  Need to do this for Hz and Vt as well.
            let iterations = this.table.permits.length;
            let rows = [];
            for (let row of this.table.permits) {
                sfUrl(row['Unit__c']).then(url =>
                    row.unitLink = url
                );
				sfUrl(row['suaId']).then(url =>
                    row.WILink = url
                );
                sfUrl(row['Id']).then(url => {
                        row.WellLink = url;
                        rows.push(row);
                        iterations--;
                        if (iterations === 0) {
                            this.table.permits = [...rows];
                            this.renderPermits();
                        }
                    });
            }

            let ducRows = [];
            let ducIterations = this.table.duc.length;
            for(let row of this.table.duc){
				sfUrl(row['Unit__c']).then(url =>
                    row.unitLink = url
                );
                sfUrl(row['Id']).then(url => {
                    row.WellLink = url;
                    ducRows.push(row);
                    ducIterations--;
                    if (ducIterations === 0) {
                        this.table.duc = [...ducRows];
                        this.renderDUCs();
                    }
                });
            }


            // TODO: Combine hz/vt into a helper function or move all this to a control... they're pretty much the same code
            let hzRows = [];
            let hzRev = 0;
            let hzIterations = this.table.hzWells.length;
            // Make links for Wells, calculate revenue, start with Hz

            for (let row of this.table.hzWells) {
                // Generate URL
                sfUrl(row['suaRec.Id']).then(url =>
                    row.WILink = url
                );
                sfUrl(row['well.Unit__c']).then(url =>
                    row.unitLink = url
                );
                sfUrl(row['well.Id']).then(url => {
                        row.WellLink = url;
                        hzRows.push(row);
                        hzIterations--;
                        if (hzIterations === 0) {
                            //console.log('lasthz'+hzIterations);
                            this.table.hzWells = [...hzRows];
                            this.renderHzWells();
                        }
                    });

                // Calc revenue
                let rev = row['wia.Last_Month_Actual_Revenue__c'];
                if (Number(parseFloat(rev)) === rev) {
                    hzRev += rev;
                }
            }

            if (hzRev > 0) {
                this.accordionLabel.hz += ' - Total Revenue Last Mo: ' + formatter.format(hzRev);
            }

            let vertIterations = this.table.vertWells.length;
            let vertRows = [];
            let vertRev = 0;
            // Make links for Wells, calculate revenue, start with Hz
            for (let row of this.table.vertWells) {
                // Generate URL
                sfUrl(row['suaRec.Id']).then(url =>
                    row.WILink = url
                );
                sfUrl(row['well.Unit__c']).then(url =>
                    row.unitLink = url
                );
                sfUrl(row['well.Id']).then(url => {
                        row.WellLink = url;
                        vertRows.push(row);
                        vertIterations--;
                        if (vertIterations === 0) {
                            // on the last one, copy to update rendering
                            // then render the data
                            this.table.vertWells = [...vertRows];
                            this.renderVtWells();
                        }
                    }
                );
                // Calc revenue
                let rev = row['wia.Last_Month_Actual_Revenue__c'];
                //console.log('rev:'+rev);
                if (Number(parseFloat(rev)) === rev) {
                    vertRev += rev;
                } 
            }

            if (vertRev > 0) {
                this.accordionLabel.vert += ' - Total Revenue Last Mo: ' + formatter.format(vertRev);
            }
        }
    }

    constructor() {
        super();
        // Keep in mind, these column structures reference two separate SOQL queries, hence the different structure
        this.columns.well = [
            //{label: 'Interest', fieldName: 'WILink', sortable: true, type:'url', cellAttributes: { alignment: 'left' }, typeAttributes: {value: {fieldName: 'WILink'},label: {fieldName: 'suaName'}, tooltip: 'View Interest'}, initialWidth: 120},
            {label: 'Well', fieldName: 'WellLink', sortable: true, type:'url', cellAttributes: { alignment: 'left' }, typeAttributes: {value: {fieldName: 'WellLink'},label: {fieldName: 'well.Name'}, tooltip: 'View Well'}, initialWidth: 200},
            {label: 'API', fieldName: 'well.API10__c', sortable: true, cellAttributes: { alignment: 'left' }, initialWidth: 200},
            //{label: 'API', fieldName: 'WellLink', sortable: true, type:'url', cellAttributes: { alignment: 'left' }, typeAttributes: {value: {fieldName: 'WellLink'},label: {fieldName: 'well.API10__c'}, tooltip: 'View Well'}, initialWidth: 100},
            {label: 'Unit', fieldName: 'unitLink', sortable: true, type:'url', cellAttributes: { alignment: 'left' }, typeAttributes: {value: {fieldName: 'unitLink'},label: {fieldName: 'well.Unit__r.Name'}, tooltip: 'View Unit'}, initialWidth: 100},
            //{label: 'Name', fieldName: 'well.Name', sortable: true, cellAttributes: { alignment: 'left' }, initialWidth: 200},
           // {label: 'Subtract', fieldName: 'well.Name', sortable: true, cellAttributes: { alignment: 'left' }, initialWidth: 200},
            {label: 'Operator', fieldName: 'well.Current_Operator_Name__c', sortable: true, cellAttributes: { alignment: 'left' }, initialWidth: 150},
            {label: 'Direction', fieldName: 'well.Hole_Direction__c', sortable: true, cellAttributes: { alignment: 'left' }},
            {label: 'Last Activity', fieldName: 'well.LastActivityDate__c', type: 'date-local', sortable: true, cellAttributes: { alignment: 'left' }},
            {label: 'Producing', fieldName: 'well.Is_Paying_calc__c', type: 'boolean', sortable: true, cellAttributes: { alignment: 'left' }},
            //{label: 'NRI', fieldName: 'suaDecimal', type: 'number', typeAttributes: {minimumFractionDigits:9}, sortable: true, cellAttributes: { alignment: 'left' }},
            {label: 'Last Production Month', fieldName: 'well.Last_Production_Month__c', type: 'date-local', sortable: true, cellAttributes: { alignment: 'left' }},
            {label: 'Oil', fieldName: 'sumOil', type: 'currency', sortable: true, cellAttributes: { alignment: 'left' }},
            {label: 'Gas', fieldName: 'sumGas', type: 'currency', sortable: true, cellAttributes: { alignment: 'left' }},
           // {label: 'Last Mo Est', fieldName: 'suaRec.lastMonthOwnerNetRevenueValue__c', type: 'currency', sortable: true, cellAttributes: { alignment: 'left' }},
           // {label: 'Last Mo', fieldName: 'suaRec.actualTotalRevenueLastMonth__c', type: 'currency', sortable: true, cellAttributes: { alignment: 'left' }}
        ];
 
        this.columns.permit = [
            {label: 'Name', fieldName: 'WellLink', sortable: true, type:'url', typeAttributes: {value: {fieldName: 'WellLink'},label: {fieldName: 'Name'}, tooltip: 'View Well'}},
            {label: 'API', fieldName: 'API10__c', sortable: true},
			{label: 'Unit', fieldName: 'unitLink', sortable: true, type:'url', cellAttributes: { alignment: 'left' }, typeAttributes: {value: {fieldName: 'unitLink'},label: {fieldName: 'Unit__r.Name'}, tooltip: 'View Unit'}},
            {label: 'Operator', fieldName: 'Current_Operator_Name__c', sortable: true},
            {label: 'Direction', fieldName: 'Hole_Direction__c', sortable: true},
            {label: 'Permit Date', fieldName: 'Last_Activity_Date__c', sortable: true},
        ];

        this.columns.duc = [
            {label: 'Name', fieldName: 'WellLink', sortable: true, type:'url', typeAttributes: {value: {fieldName: 'WellLink'},label: {fieldName: 'Name'}, tooltip: 'View Well'}},
            {label: 'API', fieldName: 'API10__c', sortable: true},
			{label: 'Unit', fieldName: 'unitLink', sortable: true, type:'url', cellAttributes: { alignment: 'left' }, typeAttributes: {value: {fieldName: 'unitLink'},label: {fieldName: 'Unit__r.Name'}, tooltip: 'View Unit'}},
            {label: 'Operator', fieldName: 'Current_Operator_Name__c', sortable: true},
            {label: 'Direction', fieldName: 'Hole_Direction__c', sortable: true},
            {label: 'Spud Date', fieldName: 'Spud_Date__c', sortable: true},
        ];
    }

    updateColumnSortingPermits(event) {
        this.table.permits = this.updateColumnSorting(event,this.table.permits);
        //this.paging.permitsPage = 1;
        this.renderPermits();
    }

    updateColumnSortingDUCs(event) {
        this.table.duc = this.updateColumnSorting(event,this.table.duc);
        this.renderDUCs();
    }

    updateColumnSortingHz(event) {
        this.table.hzWells = this.updateColumnSorting(event,this.table.hzWells);
        this.renderHzWells();
    }

    updateColumnSortingVt(event) {
        this.table.vertWells = this.updateColumnSorting(event,this.table.vertWells);
        this.renderVtWells();
    }

    pageUpVt(event) {
        // probably should be target info in the button, and one event handler
        this.paging.vertWellsPage++;
        this.renderVtWells();
    }

    pageDownVt(event) {
        this.paging.vertWellsPage--;
        this.renderVtWells();
    }

    pageUpPermit(event) {
        // probably should be target info in the button, and one event handler
        this.paging.permitsPage++;
        this.renderPermits();
    }

    pageDownPermit(event) {
        this.paging.permitsPage--;
        this.renderPermits();
    }

    pageUpDUC(event) {
        // probably should be target info in the button, and one event handler
        this.paging.DUCPage++;
        this.renderDUCs();
    }

    pageDownDUC(event) {
        this.paging.DUCPage--;
        this.renderDUCs();
    }

    pageUpHz(event) {
        // probably should be target info in the button, and one event handler
        this.paging.hzWellsPage++;
        this.renderHzWells();
    }

    pageDownHz(event) {
        this.paging.hzWellsPage--;
        this.renderHzWells();
    }

    renderVtWells() {
        this.table.vertWellsPaged = pageData(this.table.vertWells,this.paging.vertWellsPage,this.paging.size,this.paging);
        this.paging.vertWellsPage = this.table.vertWellsPaged.currentPage;
        this.paging.vertPages = this.table.vertWellsPaged.totalPages;
        this.paging.showVtPager = this.table.vertWellsPaged.totalPages > 1;
        let firstPage = (this.paging.vertWellsPage == 1);
        let lastPage = (this.paging.vertWellsPage == this.paging.vertPages);
        // console.log('fp:'+this.paging.vertWellsPage+ ' -> '+firstPage);
        // console.log('lp:' + lastPage);
        this.paging.disableVtLeft = firstPage;
        this.paging.disableVtRight = lastPage;
    }

    renderHzWells() {
        this.table.hzWellsPaged = pageData(this.table.hzWells,this.paging.hzWellsPage,this.paging.size,this.paging);
        this.paging.hzWellsPage = this.table.hzWellsPaged.currentPage;
        this.paging.hzPages = this.table.hzWellsPaged.totalPages;
        this.paging.showHzPager = this.table.hzWellsPaged.totalPages > 1;
        let firstPage = (this.paging.hzWellsPage == 1);
        let lastPage = (this.paging.hzWellsPage == this.paging.hzPages);
        // console.log('fp:'+this.paging.vertWellsPage+ ' -> '+firstPage);
        // console.log('lp:' + lastPage);
        this.paging.disableHzLeft = firstPage;
        this.paging.disableHzRight = lastPage;
    }

    renderPermits() {
        this.table.permitsPaged = pageData(this.table.permits,this.paging.permitsPage,this.paging.size,this.paging);
        this.paging.permitsPage = this.table.permitsPaged.currentPage;
        this.paging.permitsPages = this.table.permitsPaged.totalPages;
        this.paging.showPermitPager = this.table.permitsPaged.totalPages > 1;
        let firstPage = (this.paging.permitsPage == 1);
        let lastPage = (this.paging.permitsPage == this.paging.permitsPages);
        // console.log('fp:'+this.paging.vertWellsPage+ ' -> '+firstPage);
        // console.log('lp:' + lastPage);
        this.paging.disablePermitsLeft = firstPage;
        this.paging.disablePermitsRight = lastPage;
    }

    renderDUCs() {
        console.log('DUC----'+JSON.stringify(this.table.duc));
        this.table.DUCPaged = pageData(this.table.duc,this.paging.DUCPage,this.paging.size,this.paging);
        this.paging.DUCPage = this.table.DUCPaged.currentPage;
        this.paging.DUCPages = this.table.DUCPaged.totalPages;
        this.paging.showDUCPager = this.table.DUCPaged.totalPages > 1;
        let firstPage = (this.paging.DUCPage == 1);
        let lastPage = (this.paging.DUCPage == this.paging.DUCPages);

        console.log('fp:::::::::'+this.paging.DUCPage+ ' -> '+firstPage);
        console.log('lp:::::::::' + lastPage);

        this.paging.disableDUCLeft = firstPage;
        this.paging.disableDUCRight = lastPage;
    }

    updateColumnSorting(event,sortData) {
        //console.log('Well List sort requested' + JSON.stringify(event));
        var fieldName = event.detail.fieldName;
        var sortDirection = event.detail.sortDirection;
        //console.log('Sorting ' + fieldName + ' by ' + sortDirection);

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

        let sortMe = [...sortData];
        //console.log('unsortified'+JSON.stringify(sortMe));
        sortArray(sortMe,fieldName,sortDirection);
        //console.log('SORtified'+JSON.stringify(sortMe));
        // Return sorted results
        return sortMe;
    }

    //The following functions were added to solve for an error thrown when accessing this cmp from Firefox browser
    handleSectionToggle(event){

    }
    activeSections(event){
        
    }
}