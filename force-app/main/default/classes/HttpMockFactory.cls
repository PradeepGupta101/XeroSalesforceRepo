@isTest
public class HttpMockFactory implements HttpCalloutMock{

    public HttpResponse respond(HttpRequest request){
        HttpResponse response = new HttpResponse();

        response.setBody(request.getEndpoint().endsWith('connections') ? '[{"id":"1e95b4b8-8215-44c5-8243-028cb7b37ce3","authEventId":"7afbbfcc-bd43-4ef0-bea7-9a4a5f746832","tenantId":"012f16a4-dbd7-41e6-925d-e459b23c1804","tenantType":"ORGANISATION","tenantName":"Demo Company (Global)","createdDateUtc":"2023-04-27T04:59:47.0195430","updatedDateUtc":"2023-04-27T04:59:47.0206660"}]' : '{"Id":"14554145ddvsvsdvsdv","Status":"OK","ProviderName":"SF Connect","Contacts":[{"ContactID": "1e564b0e-5537-4b74-81de-057057687b70","ContactStatus": "ACTIVE","Name": "Anish Marathe","FirstName":"Anish","LastName":"Marathe","EmailAddress":"anish.marathe@bluepineapple.io"}]}');
        response.setStatus('OK');
        response.setStatusCode(200);
        
        return response;
    }
}