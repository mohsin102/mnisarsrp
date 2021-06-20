/* datatableDeleteRowBtn.js */
import { LightningElement, api, track } from 'lwc';
// Accessibility module
//import { baseNavigation } from 'lightning/datatableKeyboardMixins';
// For the render() method
import template from './checkBoxExtended.html';

export default class CheckBoxExtended extends LightningElement {
    @api rowId;
    @api checked;
    @api name;
    @api label;
    @api value;
    @api readOnly;
    @api disabled;
	@api fieldLevelHelp;


    fireRowCheck(event) {
		console.log('Click count value is: ' + this.clickCount + ' checked value is: ' + event.target.checked);
		const checkEvent = CustomEvent('rowcheckaction', {
				composed: true,
				bubbles: true,
				cancelable: true,
				detail: {
					rowId: this.rowId,
					checked: event.target.checked
				},
		});
		//console.log('Event fired ' + this.rowId + ' is checked' + this.checked);
		this.dispatchEvent(checkEvent);		
    }
}