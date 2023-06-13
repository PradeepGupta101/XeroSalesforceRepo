//Actual callout method
public with sharing class XeroCallout {
    //Method to send request and return the response to the orchestrator
    public static String getXeroData(HttpRequest request,String resource){
        try{
            //Send request
            HttpResponse response = new Http().send(request);
            
            Map<String,Object> responseMap = new Map<String,Object>();
            
            //Check if response was successful else, throw an error.
            if(response.getStatusCode() != 200){
                throw new XeroException('Status Code '+response.getStatusCode()+' Error Occured! '+response.getBody());
            }
            else{
                responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                return createResponse(responseMap.get(resource),null,200);
            }
        }
        catch(XeroException ex){
            System.debug('An Error Occurred! '+ex.getMessage() + 'Stack Trace: ' + ex.getStackTraceString());
            return createResponse(null,ex.getMessage(),400);
        }
        //Return the response at the end.
    }

    //Method to create a response object and sending it back to orchestrator
    public static String createResponse(Object data,String err,Integer status){
        Map<String,Object> responseMap = new Map<String,Object>();
        responseMap.put('data', data);
        responseMap.put('err',err);
        responseMap.put('status',status);

        return (String)JSON.serialize(responseMap);
    }

    //Method to get tenant Id - Which accepts scope
    //Tenant Id is dependant of scope, meaning, depending on scope, tenant id will change. 
    //Tenant Id is mandetory for fetching
    //We cannot fetch Invoices with tenant Id which was fetched with the scope as Contacts
    public static String getTenantId(String scope){
        HttpRequest request = new HttpRequest();
        //Construct the request
        request.setMethod('GET');
        request.setEndpoint('callout:XeroCredentials/connections');
		request.setHeader('scope', 'accounting.'+scope);
        request.setTimeout(120000);
        
        //Send the request, store the response
        try{
        	HttpResponse response = new Http().send(request);
            //Check weather the response was successful.
            if(response.getStatusCode() != 200){
                System.debug(response);
                throw new XeroException('Tenant Id Not returned!' + response.getBody());
            }
            else{
                //Deserialize the response and return the tenant id value.
                List<Object> tokenObject =  (List<Object>) JSON.deserializeUntyped(response.getBody());
                Map<String,Object> tokenMap = (Map<String,Object>) tokenObject[0];
                return (String)tokenMap.get('tenantId');
            }
        }
        catch(Exception ex){
            //Exception will be thrown and again '0' will be returned if there was any error
         	System.debug('Error ' + ex.getMessage());
            return '0';
        }
    }
    //Custom exception to print custom error messages.
    class XeroException extends Exception{}
}