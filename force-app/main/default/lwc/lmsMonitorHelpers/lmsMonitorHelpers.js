import sfpegAction from '@salesforce/messageChannel/sfpegAction__c';
import sfpegCustomAction from '@salesforce/messageChannel/sfpegCustomAction__c';
import sfpegCustomNotification from '@salesforce/messageChannel/sfpegCustomNotification__c';
import KiamoSoftphone__KiamoMessageChannel from '@salesforce/messageChannel/KiamoSoftphone__KiamoMessageChannel__c';
import MonitorMessageChannel from '@salesforce/messageChannel/MonitorMessageChannel__c';
import SampleMessageChannel from '@salesforce/messageChannel/SampleMessageChannel__c';

let channels = new Map();
channels.set('sfpegAction', sfpegAction);
channels.set('sfpegCustomAction', sfpegCustomAction);
channels.set('sfpegCustomNotification', sfpegCustomNotification);
channels.set('KiamoSoftphone__KiamoMessageChannel', KiamoSoftphone__KiamoMessageChannel);
channels.set('MonitorMessageChannel', MonitorMessageChannel);
channels.set('SampleMessageChannel', SampleMessageChannel);

const getChannel = (channelName) => {
    return channels.get(channelName);
};

const hasChannel = (channelName) => {
    return channels.has(channelName);
};

export {getChannel, hasChannel};