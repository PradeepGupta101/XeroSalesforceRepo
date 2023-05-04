public with sharing class XeroCallout {
    public static HttpRequest constructRequest(String method, String resource,String scope){
        HttpRequest request = new HttpRequest();
        
        request.setMethod(method);
        request.setEndpoint('callout:XeroCredentials/'+resource);
		request.setTimeout(120000);
        
        if(scope != null) request.setHeader('scope', 'accounting.'+scope);
        
        return request;
    }
    
    public static String createResponse(Object data,String err,Integer status){
        Map<String,Object> responseMap = new Map<String,Object>();
        responseMap.put('data', data);
        responseMap.put('err',err);
        responseMap.put('status',status);

        return (String)JSON.serialize(responseMap);
    }

    public static String getTenantId(String scope){
        HttpRequest request = constructRequest('GET','connections',scope);
        
        try{
        	HttpResponse response = new Http().send(request);
        
        	List<Object> result =  (List<Object>) JSON.deserializeUntyped(response.getBody());
        
     		for(Object obj : result) { 
	    		Map<String,Object> tempMap = (Map<String,Object>)obj; 
    			for(String key : tempMap.keyset()) { 
        			if(key == 'tenantId')
        				return (String)tempMap.get(key); 
    			} 
			} 
            return '0';
        }
        catch(Exception ex){
         	System.debug('Error ' + ex.getMessage());
            return '0';
        }
    }
    
    public static String getXeroData(String method,String resource,String tenantId){
        
        String resourceToBeSent = 'api.xro/2.0/'+resource;
        
        HttpRequest request = constructRequest(method,resourceToBeSent,null);
        request.setHeader('Accept', 'application/json');
        request.setHeader('xero-tenant-id', tenantId);

        
        try{
            HttpResponse response = new Http().send(request);
            
            Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
            
            if(response.getStatusCode() != 200){
                throw new XeroException();
            }
            else{
                return createResponse(responseMap.get(resource),null,200);
            }
        }
        catch(XeroException ex){
            System.debug('An Error Occurred! '+ex.getMessage());
            return createResponse(null,ex.getMessage(),400);
        }
    }

    class XeroException extends Exception{}
}




/*
Map<String,Object> response = new Map<String,Object>();
response.put('Data','Data');
response.put('ErrorMessage',null);
response.put('Status',400);

System.debug(response);

Object responseObj = JSON.serialize(response);

System.debug(responseObj);

*/