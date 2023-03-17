public with sharing class LoopbackManager {
    private static string getJwtToken(string issuer, string subjectClaim, string audience, string certificate) {
        system.debug('getJwtToken::Init');
        String tokenEndpoint = audience + '/services/oauth2/token';

        //Set JWT token
        Auth.JWT jwt = new Auth.JWT();
        jwt.setIss(issuer);
        jwt.setSub(subjectClaim);
        jwt.setAud(audience);
        
        system.debug('getJwtToken::Sign the Token');
        //Sign the Token
        Auth.JWS jws = new Auth.JWS(jwt, certificate);
        string token = jws.getCompactSerialization();
        
        system.debug('getJwtToken::Get the access token');
        //Get the access token
        Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange(tokenEndpoint, jws);
        return bearer.getAccessToken();
    }

    public static string loopbackJwtCall(string endPoint, string method, string issuer, string subjectClaim, string audience, string certificate) {
        system.debug('loopbackJwtCall::Init from ' + endPoint);
        return loopbackCall(endPoint, method, getJwtToken(issuer, subjectClaim, audience, certificate));
	}

    public static string loopbackNamedCredentialCall(string endPoint, string method) {
        system.debug('loopbackNamedCredentialCall::Init from ' + endPoint);
        return loopbackCall(endPoint, method, null);
    }

    private static string loopbackCall(string endPoint, string method, string jwtBearer) {
        string result='';

        try {
            HttpRequest httpRequest = new HttpRequest();
            if (jwtBearer != null) {
                system.debug('loopbackCall::With JWT Bearer token');
                httpRequest.setHeader('Authorization', 'Bearer ' + jwtBearer);
            }
            httpRequest.setTimeout(60000);
            httpRequest.setEndpoint(endPoint);
            httpRequest.setMethod(method);

            Http http = new Http();
            HttpResponse httpResponse = http.send(httpRequest);
            result = httpResponse.getBody();
        } catch(Exception ex) {
            system.debug('loopbackCall::Exception: '+ ex.getMessage());
            result = ex.getMessage();
        }

        return result;
    }
}