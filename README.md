#After installation
Pre requisite: a way to connect to the org to make a loopback call from the LWC to the ToolingApi
    NamedCredential connection type:    you will use a OAuth 2.0 named credential with a pre-authenticated user
    JWT connection type:                you will use a JWT named credential and the component will provide a JWT token according to your configuration

    Connected App
        Enable OAuth settings:  true
        Callback URL:           auth providers' callback URL
                                --> ie. https://[...].my.salesforce.com/services/authcallback/[Auth provider's URL Suffix]
        OAuth Scopes:           api, refresh_token
        Use digital signature:  Provide a certificate
        Manage
            Permitted users:    Admin approved user are pre-authorized
            Profile / Pset:     Choose hox to authorize access, by profile or by using the MessageChannel_PSet permission set provided in this package or else
        Click on "Manage Consumer Details"
            Copy to configure the Auth Provider
                Consumer Key
                Consumer Secret

    Auth. Provider
        Ex:
            Provider type: Salesforce
            Name: LMS Loopback AuthProvider
            URL Suffix: LMS_Loopback_AuthProvider
            Consumer Key: paste the Connected App's Consumer key
            Consumer secret: paste the Connected App's Consumer secret

    Named Credential
        Ex:
            Name: LMS_Loopback_NamedCredential
            URL: https://xxxx.my.salesforce.com/services/data/v57.0/tooling/query
            Identity: Named Principal

            If you want to use the NamedCredential connection type, you have to check the "Start Authentication Flow on Save" checkbox
                Authentication Protole: OAuth 2.0
                Authentication Provider : the one proviously created
               Start Authentication Flow on Save checked

            or, choose a JWT authentication protocole and fill 
                Issuer (Consumer Key)
                Subject Claim (username): the username you want to give access to
                Audience: https://test.salesforce.com
                Certificate: the certificate you want to use

    Remote Site Setting
        Remote Site Name: Loopback
            Remote Site URL: https://test.salesforce.com

    User
        Assign Permission Set

    LMS Setting
        if you want a namedCredential connection type
            Update "Default Named Credential"
                Named credential: write down the named credential you xant to use

        if you want to use a JWT connection type
            Update "Default JWT" settings
                Ex:
                    Type: Legacy
                    Issuer: Consumer Key
                    Subject Claim: username	 	 
                    Audience: https://test.salesforce.com	 	 
                    Certificate: the certificate name to use (it MUST be in Key & Certificate) 	 


