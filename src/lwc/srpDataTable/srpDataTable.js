import LightningDatatable from 'lightning/datatable';
import textExtended from './textExtended.html';
import numberExtended from './numberExtended.html';
import buttonIconExtended from './buttonIconExtended.html';
import checkBoxGroupExtended from './checkBoxGroupExtended.html';
import addressExtended from './addressExtended.html';
import rowCheckBox from './rowCheckBox.html';


export default class srpDataTable extends LightningDatatable {
    static customTypes = {
        textExtended: {
            template: textExtended,
            // Provide template data here if needed
            typeAttributes: ['title', 'value', 'linkify', 'class'],
        },
        numberExtended: {
            template: numberExtended,
            typeAttributes: ['title', 'value', 'className', 'style', 'currencyCode', 'currencyDisplayAs', 'minimumIntegerDigits', 'minimumFractionDigits', 'maximumFractionDigits', 'minimumSignificantDigits', 'maximumSignificantDigits'],
        },
        buttonIconExtended: {
            template: buttonIconExtended,
            typeAttributes: ['name', 'value', 'variant', 'iconName', 'iconClass', 'size', 'type', 'alternativeText', 'tooltip'],
        },
		checkBoxGroupExtended: {
            template: checkBoxGroupExtended,
            typeAttributes: ['label', 'options', 'messageWhenValueMissing', 'name', 'value', 'disabled', 'required', 'variant', 'validity'],
        },
		addressExtended: {
            template: addressExtended,
            typeAttributes: ['street', 'city', 'province', 'country', 'postalCode', 'latitude', 'longitude', 'disabled', 'showStaticMap'],
        },
		checkBoxExtended: {
			template: rowCheckBox,
			typeAttributes: ['checked', 'name', 'label', 'value', 'readOnly', 'disabled', 'fieldLevelHelp', 'onClick'],
		}

        //more custom types here
    };
}