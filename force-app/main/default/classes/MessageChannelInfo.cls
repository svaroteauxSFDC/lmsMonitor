public class MessageChannelInfo {
	private static final string TOOLING_QUERY_CHANNELS = 'select LightningMessageChannel.DeveloperName, LightningMessageChannel.NamespacePrefix, LightningMessageChannel.MasterLabel, LightningMessageChannel.Description, FieldName, Description from LightningMessageField order by LightningMessageChannel.MasterLabel, FieldName';

	private static string toolingAPIRequest(string query, string lmsSettingRecordName) {
        system.debug('toolingAPIRequest::INIT');
        LMS_Monitor_Setting__mdt lmsSettings = LMS_Monitor_Setting__mdt.getInstance(lmsSettingRecordName);

        string serviceResult = '';

        switch on lmsSettings.ConnectionType__c {
            when 'NamedCredential' {
                system.debug('toolingAPIRequest::Named Credential connection');
                serviceResult = LoopbackManager.loopbackNamedCredentialCall(
                    'callout:' + lmsSettings.NamedCredential__c + '?q='+ (query.replace(' ', '+')), 
                    'GET');
            }
            when 'DirectAccessJWT' {
                system.debug('toolingAPIRequest::Direct JWT connection');
                serviceResult = LoopbackManager.loopbackJwtCall(
                    lmsSettings.EndPointUrl__c + '?q='+ (query.replace(' ', '+')), 
                    'GET', 
                    lmsSettings.Issuer__c, 
                    lmsSettings.Subject_Claim__c, 
                    lmsSettings.Audience__c, 
                    lmsSettings.Certificate__c);
            }
            when else {
                system.debug('toolingAPIRequest::Unsupported connection type: ' + lmsSettings.ConnectionType__c);
                serviceResult = 'Unsupported connection type: ' + lmsSettings.ConnectionType__c;
            }
        } 

        return serviceResult;
	} 
    
	private static string soqlRequest(string query, string lmsSettingRecordName) {
        system.debug('soqlRequest::INIT');
        return 'Not supported yet';
        //return restGet(TOOLING_BASE_URL +'q='+ (query.replace(' ', '+')), 'GET');
	} 

	@AuraEnabled(cacheable=true)
    public static string getLightningMessageChannels(string lmsMonitorSettings) {
        system.debug('getLightningMessageChannelOLD');
        string results = '';
        string queryResult = executeQuery(TOOLING_QUERY_CHANNELS, 'ToolingApi', lmsMonitorSettings);
        
        if(string.isNotBlank(queryResult) && queryResult.contains('errorCode')) {
            system.debug('getLightningMessageChannel::Query error:: ' + queryResult);
            try {
                List<Query_Error> errors = (List<Query_Error>) JSON.deserialize(queryResult, List<Query_Error>.class);
                system.debug(' - ' + errors.size() + ' error(s). Only the first is sent as result');
                results = json.serialize(errors[0]);
            } catch (exception e) {
                system.debug('getLightningMessageChannel::Query error::Exception:: ' + e.getMessage());
            }
        } else if (string.isNotBlank(queryResult)) {
            system.debug('getLightningMessageChannel::Query result:: ' + queryResult);
            string lastChannel = '';
            List<ChannelRecord> channels = new List<ChannelRecord>();
            ChannelRecord currentChannel;

            Query_LightningMessageField_Result lmsQueryResults = (Query_LightningMessageField_Result) JSON.deserialize(queryResult, Query_LightningMessageField_Result.class);

            for (Query_LightningMessageField lmsField : lmsQueryResults.records) {
                system.debug('getLightningMessageChannel::Processing ' + lmsField.LightningMessageChannel.MasterLabel + '.' + lmsField.FieldName);
                
                string fullName = lmsField.LightningMessageChannel.DeveloperName;
                if (string.isNotEmpty(lmsField.LightningMessageChannel.NamespacePrefix)) {
                    fullName = lmsField.LightningMessageChannel.NamespacePrefix + '__' + fullName;
                } 

                if (lastChannel != fullName) {
                    if (lastChannel != '') {
                        // It's not the first iteration, so a channel has already been processed
                        channels.add(currentChannel);
                    }
                    
                    // Initialization of a new channel
                    currentChannel = new ChannelRecord();
                    currentChannel.label = lmsField.LightningMessageChannel.MasterLabel;
                    currentChannel.developerName = fullName;
                    currentChannel.fields = new List<ChannelField>();
                    lastChannel = fullName;
                }
                
                // Add field to the current channel
                ChannelField currentField = new ChannelField();
                currentField.fieldName = lmsField.FieldName;
                currentField.description = lmsField.Description;
                currentChannel.fields.add(currentField);
            }
            
            // add the last processed channel
            channels.add(currentChannel); 

            ChannelSet channelSet = new ChannelSet();
            channelSet.channels = channels;
            channelSet.totalSize = channels.size();

            results = json.serialize(channelSet);
        } else {
            system.debug('getLightningMessageChannel::No result');
            results = 'No results';
        }
        return results;
    }

    private static string executeQuery(string query, string queryType, string lmsSettingRecordName) {
        system.debug('MessageChannelInfo::executeQuery:: ' + query);
        string queryResult;

        if (queryType == 'ToolingApi') {
            queryResult = toolingAPIRequest(query, lmsSettingRecordName);
        } else {
            queryResult = soqlRequest(query, lmsSettingRecordName);
        }

        return queryResult;
	} 


    /**********************************************
     *** Structures returned by the Tooling API ***
    ***********************************************/
    /* Error classes */
    public class Query_Error {
        public string message;
        public string errorCode;
    }

    /* Main query result structure on LightningMessageField */
    public class Query_LightningMessageField_Result {
        public Integer size;
        public Integer totalSize;
        public List<Query_LightningMessageField> records;
    }

    /* LightningMessageField, data contained into the main data which represent the LightningMessageFields */
    public class Query_LightningMessageField {
        public Query_MetadataAttribute attributes;
        public Query_LightningMessageChannel LightningMessageChannel;
        public string FieldName;
        public string Description;
    }

    /* LightningMessageChannel, data contained into the main data which represent the LightningMessageChannel information */
    public class Query_LightningMessageChannel {
        public Query_MetadataAttribute attributes;
        public string DeveloperName;
        public string NamespacePrefix;
        public string MasterLabel;
        public string Description;
    }

    /* Attribute common structure of the Tooling API */
    public class Query_MetadataAttribute {
        public string type;
        public string url;
    }


    /**************************************************
     *** LMS Monitor classes to be fetch by the LWC ***
    ***************************************************/
    /* Main wrapper */
    public class ChannelSet {
        public Integer totalSize;
        public List<ChannelRecord> channels;
    }

    /* LightningMessageChannel information */
    public class ChannelRecord {
        public string label;
        public string developerName;
        public string description;
                
        public List<ChannelField> fields;
    }

    /* LightningMessageField information */
    public class ChannelField {
        public string description;
        public string fieldName;
    }
}