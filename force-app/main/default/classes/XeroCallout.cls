//Xero callout class
public with sharing class XeroCallout {
    //Method to send request and return the response to the orchestrator
    public static String getXeroData(HttpRequest request,String resource){
        BlueLogProcessor.IBlueLogger ibl = BlueLogProcessor.getLogger(XeroCallout.class); 
        try{
            //Send request
            HttpResponse response = new Http().send(request);
            ibl.debug('Http Request Sent to Xero:'+request.getEndpoint()+ ' Method :' +request.getMethod(),'getXeroData');
                      
            
            Map<String,Object> responseMap = new Map<String,Object>();
            
            //Check if response was successful else, throw an error.
            if(response.getStatusCode() != 200){
                ibl.debug('Status Code '+ response.getStatusCode() +' Error: '+response.getBody(),'getXeroData');
            }
            else{
                System.debug(response.getBody());
                responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                ibl.debug('Http Request Sent to Xero: '+request.getEndpoint()+ ' Method :' +request.getMethod(), 'Response Recieved: '+response);
                return createResponse(responseMap.get(resource),null,200);
            }
        }
        catch(XeroException ex){
            ibl.error(ex, 'getXeroData');
            BlueLogProcessor.getInstance().forceFlush();
            return createResponse(null,ex.getMessage(),400);
        }
        BlueLogProcessor.getInstance().forceFlush();
        //Return the response at the end.
        return null;
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
        BlueLogProcessor.IBlueLogger ibl = BlueLogProcessor.getLogger(XeroCallout.class);    
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
                ibl.debug(response.getBody(),'Tenant Id Not returned!'); 
            }
            else{
                //Deserialize the response and return the tenant id value.
                List<Object> result =  (List<Object>) JSON.deserializeUntyped(response.getBody());
                Map<String,Object> tempMap = new Map<String,Object>();
     		    for(Object obj : result) { 
	    		    tempMap = (Map<String,Object>)obj; 
                    ibl.debug('Request Sent to fetch Tenant ID: '+request.getEndpoint(),'Tenant ID Received :'+tempMap.get('tenantId'),'');
    			    return (String)tempMap.get('tenantId'); 
			    }                
            }
            //'0' will be returned if response was returned but tenant id was not found.
            return '0';
        }
        catch(Exception ex){
            //Exception will be thrown and again '0' will be returned if there was any error
            ibl.error(ex, 'getTenantId');
            BlueLogProcessor.getInstance().forceFlush();
            return '0';
        }
        
    }
    //Custom exception to print custom error messages.
    class XeroException extends Exception{}
}