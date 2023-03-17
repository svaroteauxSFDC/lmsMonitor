import { LightningElement, api } from 'lwc';

export default class lmsMonitorMessage extends LightningElement {
    @api messageKey;        // LMS identifier
    @api messageRecord;     // LMS content
    @api messageChannel;    // LMS object
    messageItems=[];
    isInitialized = false;

    connectedCallback() {
        var counter = 0;
        this.messageItems = this.inspectObjectStructure(this.messageRecord, 0);
        this.isInitialized = true;
    }

    handleDelete() {
        this.dispatchEvent(new CustomEvent('debug', {detail: 'lmsMonitorMessage::Delete: ' + this.messageChannel + '=' + this.messageKey}));
        this.dispatchEvent(new CustomEvent('delete', {detail: this.messageKey}));
    }

    inspectObjectStructure(structure, level) {
        let internalCounter = 0;
        let subCollection = [];

        Object.keys(structure).forEach((currentProperty) => {
            let propertyItem={};
            propertyItem.name = level + '-' + internalCounter;

            if (typeof structure[currentProperty] === 'object') {
                propertyItem.label = currentProperty;
                propertyItem.items = this.inspectObjectStructure(structure[currentProperty], ++level);
                propertyItem.expanded = true;
            } else {
                propertyItem.label = currentProperty + ': ' + structure[currentProperty];
                propertyItem.items = [];
            }

            subCollection.push(propertyItem);
            internalCounter++;
        });

        return subCollection;
    }
}