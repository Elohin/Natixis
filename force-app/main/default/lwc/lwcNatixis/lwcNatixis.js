import { LightningElement, wire } from 'lwc';
import makeCallout from '@salesforce/apex/DummyJsonController.makeCallout';

const columns = [
    { label: 'Title',               fieldName: 'Name'        },
    { label: 'Description',         fieldName: 'Description' },
    { label: 'Price',               fieldName: 'Price__c',      type: 'currency' },
    { label: 'Discount Percentage', fieldName: 'Discount__c',   type: 'number' },
    { label: 'Rating',              fieldName: 'Rating__c',     type: 'number' },
    { label: 'Stock',               fieldName: 'Stock__c',      type: 'number' },
    { label: 'Brand',               fieldName: 'Brand__c'    },
    { label: 'Category',            fieldName: 'Category__c' },
    { label: 'Thumbnail',           fieldName: 'DisplayUrl',    type:'customImage' },
];

export default class LwcNatixis extends LightningElement {

    data = [];
    columns = columns;
    value = 'Title';
    container = {};
    total = 0.0;

    get options() {
        return [
            { label: 'Title',               value: 'Name'        },
            { label: 'Description',         value: 'Description' },
            { label: 'Brand',               value: 'Brand__c'    },
            { label: 'Category',            value: 'Category__c' },
        ];
    }

    handleChange(event) {
        this.container[event.target.name] = event.detail.value;
    }

    refreshList(event){
        makeCallout({filter:this.container})
		.then(result => {
            this.total = 0.0;
            result.forEach(element => {
                this.total += element['Price__c'] * element['Stock__c'];
            });
			this.data = result;
			this.error = undefined;
		})
		.catch(error => {
            this.total = 0.0;
			this.error = error;
			this.data = undefined;
		})
    }

}