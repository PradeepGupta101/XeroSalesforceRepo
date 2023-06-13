//Orchestrator class.
//This class construct the request and handle response coming from XeroCallout class. 
public with sharing class XeroOrchestrator {
    //Declaring tenantId as global variable so that it will be accessible throughout the class.
    public static String tenantId = '';

    //Method to construct the request. Setting the request parameters and return it for further processing.
    public static HttpRequest constructRequest(String method, String resource,String tenantId){
      HttpRequest request = new HttpRequest();
      request.setMethod(method);
      request.setEndpoint('callout:XeroCredentials/api.xro/2.0/'+resource);
      request.setTimeout(120000);
      request.setHeader('Accept', 'application/json');
      request.setHeader('xero-tenant-id', tenantId);
      return request;
    }
    
    //Method to check if user has required permisions to perform the action
    public static Boolean checkForPermission(String requiredPermission){  
      //Getting logged in user details 
      User userRecord = [SELECT Id, username,Name 
                     	 FROM User 
                		 WHERE Id = :UserInfo.getUserId()];

      //Variable assignment - Permission Set Names
      	String permission = requiredPermission == 'Read' ? 'Xero_Integration_Read' : 'Xero_Integration_Edit';
        
      	List<PermissionSet> permissionSets = [SELECT Id FROM PermissionSet WHERE Name = :permission];
      
		try{
        	//If query returns something, which means user has permission set assigned. Return true in that case.
			List<PermissionSetAssignment> permissionSetIds = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId =: userRecord.Id AND PermissionSetId = :permissionSets[0].Id];
        	return permissionSetIds.size() != 0 ? true : false;
		}
		catch(QueryException ex){
        	//else the flow moves into the exception and returns false.
    	  	return false;
		}    
    }
    
    
    
    //Method to retrieve the records from xero platform.
    public static String connectToXero(String resource,String filter){
      //Check if user has permission
      if(checkForPermission('Read')){
        //Fetch Tenant Id
        String tenantId = XeroCallout.getTenantId(resource);
          //Check if tenant id is returned, return and print an error instead.
          if(tenantId != '0'){
              String resourceTobeSent = filter.length() > 0 ? resource+'/'+filter : resource;
              //Construct the request with parameters.
              HttpRequest request = constructRequest('GET', resourceTobeSent, tenantId);
              //Send request to callout method, deserialize the response and assign it to a variable called data.
              Map<String,Object> data = (Map<String,Object>)JSON.deserializeUntyped(XeroCallout.getXeroData(request,resource)); 
              //Check weather the response is successful or not, print and return either details.
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