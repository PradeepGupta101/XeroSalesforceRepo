public with sharing class XeroCallout {
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
            
        	List<Object> result =  (List<Object>) JSON.deserializeUntyped(response.getBody());
            Map<String,Object> tempMap = new Map<String,Object>();

     		for(Object obj : result) { 
	    		tempMap = (Map<String,Object>)obj; 
    			return (String)tempMap.get('tenantId'); 
			} 
            return '0';
        }
        catch(Exception ex){
         	System.debug('Error ' + ex.getMessage());
            return '0';
        }
    }
    
    public static String getXeroData(HttpRequest request,String resource){
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