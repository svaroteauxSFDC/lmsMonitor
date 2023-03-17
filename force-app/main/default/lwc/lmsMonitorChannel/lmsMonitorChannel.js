import { LightningElement, api } from 'lwc';

export default class LmsMonitorChannel extends LightningElement {
    @api channelRecord;
    @api disableSubscribe;
    disablePublish = true;
    subscribeChannelState = false;
    channelLabel;
    
    connectedCallback() {
        this.channelLabel = this.channelRecord.label;
    }

    handleSubscribeChannel(event) {
        this.subscribeChannelState = !this.subscribeChannelState;
        this.disablePublish = !this.disablePublish;
        this.dispatchEvent(new CustomEvent('debug', {detail: 'lmsMonitorChannel::Send subscribe event'}));
        var eventDetail = {channel:this.channelRecord.developerName, state:this.subscribeChannelState};
        this.dispatchEvent(new CustomEvent('subscription', {detail: eventDetail}));
    }

    handlePublishChannel(event) {
        this.dispatchEvent(new CustomEvent('debug', {detail: 'lmsMonitorChannel::Send publish event to channel ' + this.channelRecord.developerName}));
        let eventDetail = {channel:this.channelRecord.developerName, payload:{}};
        
        this.channelRecord.fields.forEach(field => {
            eventDetail.payload[field.fieldName] = '[Sample]' + field.fieldName + '-' + this.channelLabel;
        });

        this.dispatchEvent(new CustomEvent('publish', {detail: eventDetail}));
    }
}