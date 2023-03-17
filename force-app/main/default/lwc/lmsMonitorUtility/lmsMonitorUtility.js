import { LightningElement, api, wire } from 'lwc';

import queryChannels from '@salesforce/apex/MessageChannelInfo.getLightningMessageChannels';
import { getChannel, hasChannel } from 'c/lmsMonitorHelpers';

import {
    subscribe,
    unsubscribe,
    publish,
    APPLICATION_SCOPE,
    MessageContext
} from 'lightning/messageService';

export default class lmsMonitorUtility extends LightningElement {
    @api lmsMonitorsettingName;     // DeveloperName of the LMS_Monitor_Setting__mdt record to be used
    @api lmsMonitorDebugMode;       // Make available the debug tab

    @wire(MessageContext)
    messageContext;

    isInitialized = false;
    showDebugTab = false;
    showSpinner = true;

    channelList;
    MessageList = [];
    MessageCounter = 0;
    initializationError = '';
    debugTrace = 'Not initialized';
    
    connectedCallback() {
        this.isInitialized = false;
        this.showSpinner = true;
        this.writeToDebug('lmsMonitorUtility::Init:', true);

        if ((!this.lmsMonitorsettingName) || (this.lmsMonitorsettingName === 'N/A')){
            this.writeToDebug(' - Missing configuration!', false, true);
            this.initializationError = 'Impossible to retrieve channels: missing configuration';
            this.errorMsg = 'Missing configuration!';
            this.isReady = true;
            return;
        } else {
            this.writeToDebug(' - Settings: ' + this.lmsMonitorsettingName, false, true);
        }

        this.writeToDebug('lmsMonitorUtility::Init:Fetching Message Channel list');
        queryChannels({lmsMonitorSettings: this.lmsMonitorsettingName})
            .then(result => {
                let jsonResults = JSON.parse(result);
                if (jsonResults.totalSize) {
                    this.channelList = jsonResults;
                    this.fetchMessageChannelList();
                    this.isInitialized = true;
                } else if (jsonResults.errorCode) {
                    this.writeToDebug('Error in the query: ' + jsonResults.message, false, true);
                    this.initializationError = 'Error in the query: ' + jsonResults.message;
                } else {
                    this.writeToDebug('Unknown error, initialization aborded: ' + JSON.stringify(jsonResults), false, true);
                    this.initializationError = 'Unknown error, initialization aborded';
                }
            })
            .catch(error => {
                this.writeToDebug(' - Ko: ' + JSON.stringify(error), false, true);
                this.initializationError = 'Impossible to retrieve channels: ' + JSON.stringify(error);
                this.isInitialized = false;
            });

        this.showSpinner = false;
    }

/*
    async loadCtor(channel) {
        this.writeToDebug('MonitorUtility::Init:loadCtor ' + channel + '__c');
        this.writeToDebug('   - aborted, not supported for the moment');
    }
*/

    fetchMessageChannelList() {
        this.writeToDebug(' - ' + this.channelList.totalSize + ' record(s) found in LightningMessageChannel', false, true);
        this.channelList.channels.forEach(element => {
            element.disableSubscribable = !hasChannel(element.developerName);

            if (element.disableSubscribable) {
                this.writeToDebug(' - ' + element.label + ' is disabled, update the "lmsMonitorHelper.js" with "' + element.developerName + '" to manage it', false, true);
            } else {
                this.writeToDebug(' - ' + element.label + ' is managed', false, true);
            }
        });
    }

    getUTCTimeStamp() {
        return new Date().toUTCString();
    }
    
    handleDebug(event) {
        this.writeToDebug(event.detail);
    }

    writeToDebug(content, flush=false, hideTimeStamp=false) {
        if (this.lmsMonitorDebugMode){
            if (flush) {
                this.debugTrace = '';
            }

            let newLine = (this.debugTrace == '')?'':'\n';
            let timeStamp = '';

            if (!hideTimeStamp) {
                timeStamp = '[' + this.getUTCTimeStamp() + '] ';
            }

            this.debugTrace += newLine + timeStamp + content;
        }
    }

    handleSubscription(event) {
        this.manageSubscription(event.detail.channel, event.detail.state);
    }

    manageSubscription(channel, state) {
        if (state) {
            this.subscribeToMessageChannel(channel);
        } else {
            this.unsubscribeToMessageChannel(channel);
        }
    }

    subscribeToMessageChannel(channel) {
        this.writeToDebug('lmsMonitorUtility::Subscription to: ' + channel);

        subscribe(
            this.messageContext,
            getChannel(channel),
            (message) => this.handleMessage(channel, message),
            { scope: APPLICATION_SCOPE }
        );
    }

    unsubscribeToMessageChannel(channel) {
        this.writeToDebug('lmsMonitorUtility::Unsubscription to: ' + channel);
        unsubscribe(getChannel(channel));
    }

    handlePublish(event) {
        publish(this.messageContext, getChannel(event.detail.channel), event.detail.payload);
    }

    handleMessage(channel, message) {
        this.writeToDebug('lmsMonitorUtility::handleMessage on ' + channel);

        let newMessage = {};
        newMessage.key = 'LMS' + (this.MessageCounter++);
        newMessage.channel = channel;
        newMessage.message = message;
        
        let cloneList = [... this.MessageList];
        cloneList.unshift(newMessage);
        this.MessageList = cloneList;
    }

    handleFlushLog() {
        this.debugTrace = '';
    }

    handleDeleteMessage(event) {
        let cloneList = [... this.MessageList];
        for (var i = 0; i < cloneList.length; i++) {
            if (cloneList[i].key === event.detail) {
                cloneList.splice(i, 1);
            }
        }
        this.MessageList = cloneList;
    }
}