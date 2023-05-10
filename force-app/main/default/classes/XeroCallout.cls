//Actual callout method
public with sharing class XeroCallout {
    //Method to send request and return the response to the orchestrator
    public static String getXeroData(HttpRequest request,String resource){

        BlueLogProcessor.IBlueLogger ibl = BlueLogProcessor.getLogger(XeroCallout.class);
		ibl.debug('getXeroData method start', 'getXeroDataRecord');
		RequestResponseProcessor.RequestResponseLogger req = RequestResponseProcessor.getLogger(XeroCallout.class);
        
        try{
            //Send request
            HttpResponse response = new Http().send(request);
            req.debug('Http Request Sent:'+request,'getXeroData');
            
            Map<String,Object> responseMap = new Map<String,Object>();
            
            //Check if response was successful else, throw an error.
            if(response.getStatusCode() != 200){
                ibl.debug('Exception occured while sending the request: Status Code'+response.getStatusCode()+ ' Error Occured! '+response.getBody(),'getXeroData');
                throw new XeroException('Status Code '+ response.getStatusCode() +' Error: '+response.getBody());
    
            }
            else{
                responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                req.debug('Response recieved: '+responseMap,'getXeroData');
                return createResponse(responseMap.get(resource),null,200);
            }
        }
        catch(XeroException ex){
            System.debug('An Error Occurred! '+ex.getMessage());
            ibl.error('Exception occured:'+ex.getMessage(), 'getXeroData');
            ibl.debug('getXeroData method ends', 'getXeroDataRecord');
            BlueLogProcessor.getInstance().forceFlush();
            RequestResponseProcessor.getInstance().forceFlush();
            return createResponse(null,ex.getMessage(),400);
        }
        //Return the response at the end.
    }

    //Method to create a response object and sending it back to orchestrator
    public static String createResponse(Object data,String err,Integer status){

        RequestResponseProcessor.RequestResponseLogger req = RequestResponseProcessor.getLogger(XeroCallout.class);
		req.debug('createResponse method start', 'createResponseRecord');

        Map<String,Object> responseMap = new Map<String,Object>();
        responseMap.put('data', data);
        responseMap.put('err',err);
        responseMap.put('status',status);
        
        req.debug('createResponse method ends', 'createResponseRecord');
        RequestResponseProcessor.getInstance().forceFlush();

        return (String)JSON.serialize(responseMap);
    }

    //Method to get tenant Id - Which accepts scope
    //Tenant Id is dependant of scope, meaning, depending on scope, tenant id will change. 
    //Tenant Id is mandetory for fetching
    //We cannot fetch Invoices with tenant Id which was fetched with the scope as Contacts
    public static String getTenantId(String scope){

        BlueLogProcessor.IBlueLogger ibl = BlueLogProcessor.getLogger(XeroCallout.class);
		ibl.debug('getTenantId method start', 'getTenantId');
		RequestResponseProcessor.RequestResponseLogger req = RequestResponseProcessor.getLogger(XeroCallout.class);
        
        HttpRequest request = new HttpRequest();
        //Construct the request
        request.setMethod('GET');
        request.setEndpoint('callout:XeroCredentials/connections');
		request.setHeader('scope', 'accounting.'+scope);
        request.setTimeout(120000);
        
        //Send the request, store the response
        try{
        	HttpResponse response = new Http().send(request);
            req.debug('Http Request Sent: '+request, 'getTenantId');

            //Check weather the response was successful.
            if(response.getStatusCode() != 200){
                System.debug(response);
                req.debug('Exception Occured','getXeroData');
                ibl.debug('Exception occured while sending the request:'+response.getStatusCode()+ 'Error' +response.getBody(),'getTenantId');
                throw new XeroException('Tenant Id Not returned!'); 
            }
            else{
                //Deserialize the response and return the tenant id value.
                List<Object> result =  (List<Object>) JSON.deserializeUntyped(response.getBody());
                Map<String,Object> tempMap = new Map<String,Object>();

     		    for(Object obj : result) { 
	    		    tempMap = (Map<String,Object>)obj; 
    			    return (String)tempMap.get('tenantId'); 
			    }
                req.debug('Response recieved:'+result,'getXeroData');
            }
            //'0' will be returned if response was returned but tenant id was not found.
            return '0';
        }
        catch(Exception ex){
            //Exception will be thrown and again '0' will be returned if there was any error
         	System.debug('Error ' + ex.getMessage());
            ibl.error('Exception occured:'+ex.getMessage(), 'getXeroData');
            ibl.debug('getTenantId method ends', 'getTenantId');
            BlueLogProcessor.getInstance().forceFlush();
            RequestResponseProcessor.getInstance().forceFlush();
            return '0';
        }
        
    }
    //Custom exception to print custom error messages.
    class XeroException extends Exception{}
}