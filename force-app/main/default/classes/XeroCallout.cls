public with sharing class XeroCallout {
    public static String getXeroData(HttpRequest request,String resource){
        try{
            HttpResponse response = new Http().send(request);
            
            Map<String,Object> responseMap = new Map<String,Object>();
            
            if(response.getStatusCode() != 200){
                throw new XeroException('Status Code '+response.getStatusCode()+' Error Occured! '+response.getBody());
            }
            else{
                responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                return createResponse(responseMap.get(resource),null,200);
            }
        }
        catch(XeroException ex){
            System.debug('An Error Occurred! '+ex.getMessage());
            return createResponse(null,ex.getMessage(),400);
        }
    }

    public static String createResponse(Object data,String err,Integer status){
        Map<String,Object> responseMap = new Map<String,Object>();
        responseMap.put('data', data);
        responseMap.put('err',err);
        responseMap.put('status',status);

        return (String)JSON.serialize(responseMap);
    }

    public static String getTenantId(String scope){
        HttpRequest request = new HttpRequest();
        
        request.setMethod('GET');
        request.setEndpoint('callout:XeroCredentials/connections');
		request.setHeader('scope', 'accounting.'+scope);
        request.setTimeout(120000);
        
        try{
        	HttpResponse response = new Http().send(request);
            
            if(response.getStatusCode() != 200){
                System.debug(response);
                throw new XeroException('Tenant Id Not returned!');
            }
            else{
                List<Object> result =  (List<Object>) JSON.deserializeUntyped(response.getBody());
                Map<String,Object> tempMap = new Map<String,Object>();

     		    for(Object obj : result) { 
	    		    tempMap = (Map<String,Object>)obj; 
    			    return (String)tempMap.get('tenantId'); 
			    }
            } 
            return '0';
        }
        catch(Exception ex){
         	System.debug('Error ' + ex.getMessage());
            return '0';
        }
    }

    class XeroException extends Exception{}
}