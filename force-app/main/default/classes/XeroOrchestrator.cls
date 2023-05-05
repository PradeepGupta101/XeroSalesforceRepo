public with sharing class XeroOrchestrator {
    
    public static String tenantId = '';

    public static HttpRequest constructRequest(String method, String resource,String tenantId){
      HttpRequest request = new HttpRequest();
      
      request.setMethod(method);
      request.setEndpoint('callout:XeroCredentials/api.xro/2.0/'+resource);
      request.setTimeout(120000);
      request.setHeader('Accept', 'application/json');
      request.setHeader('xero-tenant-id', tenantId);
      
      return request;
    }
    
    public static Boolean checkForPermission(){    
      User u = [select Id, username,Name from User where Id = :UserInfo.getUserId()];
      Set<String> permissions = new Set<String>{'Xero_Integration_Read','Xero_Integration_Write'};
		  PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE Name IN :permissions];

		  try{
			  PermissionSetAssignment pId = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId =: u.Id AND PermissionSetId =: ps.Id];
			  return true;
		  }
		  catch(QueryException ex){
    	  return false;
		  }    
    }
    
    public static String connectToXero(String resource){
      if(checkForPermission()){
        String tenantId = XeroCallout.getTenantId(resource);
          if(tenantId != '0'){
              HttpRequest request = constructRequest('GET', resource, tenantId);
              Map<String,Object> data = (Map<String,Object>)JSON.deserializeUntyped(XeroCallout.getXeroData(request,resource)); 
              if(data.get('status')!= 200){
                System.debug(data.get('err'));
                return (String)data.get('err');
              }
              else{
                System.debug(data.get('data'));
                return 'Data Present';
              }
          }
          else{
              System.debug('There was some problem in retriving the Tenant Id');
              return 'There was some problem in retriving the Tenant Id';
          }
      }
      else{
        System.debug('User does not have sufficiant access!');
        return 'User does not have sufficiant access!';
      }
    }
}


//Once response is recieved: Perform the following actions
//List<Object> listOfContacts = (List<Object>) data;
//for(Object contact: listOfContacts){
//	Map<String,Object> contacts = (Map<String,Object>) contact;
//	System.debug(contacts.get('Name'));
//}