# Using the LmsMonitor component
1. [Pre requisite](https://github.com/svaroteauxSFDC/lmsMonitor/edit/main/README.md#pre-requisite)
    - [Connected App](https://github.com/svaroteauxSFDC/lmsMonitor/edit/main/README.md#connected-app)
    - [Auth. Provider](https://github.com/svaroteauxSFDC/lmsMonitor/edit/main/README.md#auth-provider)
    - [Named Credential](https://github.com/svaroteauxSFDC/lmsMonitor/edit/main/README.md#named-credential)
    - [Remote Site Setting](https://github.com/svaroteauxSFDC/lmsMonitor/edit/main/README.md#remote-site-setting)
2. [Set user permissions](https://github.com/svaroteauxSFDC/lmsMonitor/edit/main/README.md#set-user-permissions)
3. [Update LMS Custom Setting](https://github.com/svaroteauxSFDC/lmsMonitor/edit/main/README.md#update-lms-custom-setting)
4. [Update with the message channels available in your org](https://github.com/svaroteauxSFDC/lmsMonitor/edit/main/README.md#update-with-the-message-channels-available-in-your-org)
    
---

## Pre requisite
To use to component, you need a way to connect to the org to make a loopback call from the LWC to the ToolingApi
- NamedCredential connection type:    you will use a OAuth 2.0 named credential with a pre-authenticated user
- JWT connection type:                you will use a JWT named credential and the component will provide a JWT token according to your configuration

### Connected App
- `Enable OAuth settings`: true
- `Callback URL`: auth providers' callback URL
 > ie. https://[...].my.salesforce.com/services/authcallback/[Auth provider's URL Suffix]
- `OAuth Scopes`: api, refresh_token
- `Use digital signature`: Provide a certificate
- `Manage`
    - `Permitted users`: Admin approved user are pre-authorized
    - `Profile` / `Pset`: Choose how to authorize access, by profile or by using the MessageChannel_PSet permission set provided in this package or else
    - Click on `Manage Consumer Details`
        - Copy to configure the Auth Provider
            - Consumer Key
            - Consumer Secret

### Auth. Provider
Ex:
- `Provider type`: Salesforce
- `Name`: LMS Loopback AuthProvider
- `URL Suffix`: LMS_Loopback_AuthProvider
- `Consumer Key`: paste the Connected App's Consumer key
- `Consumer secret`: paste the Connected App's Consumer secret

### Named Credential
Ex:
- `Name`: LMS_Loopback_NamedCredential
- `URL`: https://xxxx.my.salesforce.com/services/data/v57.0/tooling/query
- `Identity`: Named Principal

If you want to use the NamedCredential connection type, you have to check the "Start Authentication Flow on Save" checkbox
- `Authentication Protole`: OAuth 2.0
- `Authentication Provider`: the one proviously created
- `Start Authentication Flow on Save` checked

or, choose a JWT authentication protocole and fill 
- `Issuer`: the consumer key
- `Subject Claim`: the username you want to give access to
- `Audience`: https://test.salesforce.com
- `Certificate`: the certificate you want to use

### Remote Site Setting
ex:
- `Remote Site Name`: Loopback
- `Remote Site URL`: https://test.salesforce.com

## Set user permissions
- Assign the *MessageChannel Permissions* Permission Set

## Update LMS Custom Setting
- if you want a namedCredential connection type, update the "Default Named Credential"
    - `Named credential`: write down the named credential you want to use

- if you want to use a JWT connection type
    - Update "Default JWT" settings, ie:
        - `Type`: Legacy
        - `Issuer`: Consumer Key
        - `Subject Claim`: username	 	 
        - `Audience`: https://test.salesforce.com	 	 
        - `Certificate`: the certificate name to use (it MUST be in Key & Certificate) 	 

## Update with the message channels available in your org
For the moment, import injection is impossible in LWC. So, you have to provide your list of MessageChannel in the file
> force-app/main/default/lwc/lmsMonitorHelpers/lmsMonitorHelpers.js

To do make it more simply, I provide a shell script which use Salesforce CLI (SFDX) commands
> deployer/deployMessageChannelMonitor.sh

So, before executing it, please register your orgs a command such as:
> sfdx auth web login 

When executed, the `deployMessageChannelMonitor.sh` will ask you to provide the sfdx alias of the targeted org.
It will execute a query against the tooling API to retrieve all existing MessageChannels and will update the `force-app/main/default/lwc/lmsMonitorHelpers/lmsMonitorHelpers.js` file
Then, if you agree, it will execute a deploy against the specified org
