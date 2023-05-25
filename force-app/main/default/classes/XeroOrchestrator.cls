//Orchestrator class 
public with sharing class XeroOrchestrator {
    //Declaring tenantId as global class variable so that it will be accessible within any block.
    public static String tenantId = '';

    //Method to construct 
    public static HttpRequest constructRequest(String method, String resource,String tenantId, String requestBody){
        
      BlueLogProcessor.IBlueLogger ibl = BlueLogProcessor.getLogger(XeroOrchestrator.class);
        ibl.debug('constructRequest method starts','constructRequest');
        
      HttpRequest request = new HttpRequest();
      //Construct the request - setting the parameters.
      if(requestBody != null)
      {         
          request.setbody(requestBody);
      }
      request.setMethod(method);
      request.setEndpoint('callout:XeroCredentials/api.xro/2.0/'+resource);
      request.setTimeout(120000);
      request.setHeader('Accept', 'application/json');
      request.setHeader('xero-tenant-id', tenantId);
      //return the request for further processing.
      
      ibl.debug('constructRequest method ends','constructRequest');
      BlueLogProcessor.getInstance().forceFlush();
      return request;
    }
    
    public static Boolean checkForPermission(){  
      //Getting logged in user details 
      User u = [SELECT Id, username,Name 
                FROM User 
                WHERE Id = :UserInfo.getUserId()];

      //Variable assignment - Permission Set Names
      String readPermission = 'Xero_Integration_Read';
      String editPermission = 'Xero_Integration_Edit';

      //Getting permission set Ids. 
      //Getting permission set details in a set.
      Set<String> permissions = new Set<String>{[SELECT Id FROM PermissionSet WHERE Name =:readPermission].Id,[SELECT Id FROM PermissionSet WHERE Name =:editPermission].Id};
      
		  try{
        //If query returns something, which means user has permission set assigned. Return true in that case.
			  PermissionSetAssignment pId = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId =: u.Id AND PermissionSetId IN :permissions];
			  return true;
		  }
		  catch(QueryException ex){
        //else the flow moves into the exception and returns false.
    	  return false;
		  }    
    }
    
    //Method of orchestration.
    public static String retrieveFromXero(String resource){
        
      BlueLogProcessor.IBlueLogger ibl = BlueLogProcessor.getLogger(XeroOrchestrator.class);
	    ibl.debug('connectToXero method starts', 'retrieveFromXero');
        
      //Check if user has permission
      if(checkForPermission()){
        //Fetch Tenant Id
        String tenantId = XeroCallout.getTenantId(resource);
          //Check if tenant id is returned, return and print an error instead.
          if(tenantId != '0'){
              //Construct the request with parameters.
              HttpRequest request = constructRequest('GET', resource, tenantId, null);
              ibl.debug('Request sent to fetch data: '+resource, 'retrieveFromXero');
              
              //Send request to callout method, deserialize the response and assign it to a variable called data.
              Map<String,Object> data = (Map<String,Object>)JSON.deserializeUntyped(XeroCallout.getXeroData(request,resource)); 
                            
              
              //Check weather the response is successful or not, print and return either details.
              if(data.get('status')!= 200){
                System.debug(data.get('err'));
                ibl.error('Error Occured:'+data.get('status'), 'retrieveFromXero');
                BlueLogProcessor.getInstance().forceFlush();
                return (String)data.get('err');
              }
              else{
                System.debug(data.get('data'));
                ibl.debug('Received Data Successfully:'+data.get('status'), 'retrieveFromXero');
                BlueLogProcessor.getInstance().forceFlush();
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
        ibl.debug('User does not have sufficiant access!', 'retrieveFromXero');
        BlueLogProcessor.getInstance().forceFlush();
        return 'User does not have sufficiant access!';
      }
    }
   
    // Method to Send Data from Salesforce to Xero
    public static String sendToXero(ContactWrapper contct){
      String resource = 'Contact';
      String tenantId = XeroCallout.getTenantId(resource);
      if(tenantId != '0'){
           String serializedData = JSON.serialize(contct);
          //Construct the request with parameters.
          HttpRequest request = constructRequest('POST', resource, tenantId, serializedData);
 
          //Send request to callout method, deserialize the response and assign it to a variable called data.
          Map<String,Object> data = (Map<String,Object>)JSON.deserializeUntyped(XeroCallout.getXeroData(request,resource)); 
 
          //Check weather the response is successful or not, print and return either details.
          if(data.get('status')!= 200){
            System.debug(data.get('err'));
            return (String)data.get('err');
          }
          else{
            System.debug(data.get('data')); 
            return 'Contact created in Xero';
          } 
      	}
      	else{
              System.debug('There was some problem in retriving the Tenant Id');
              return 'There was some problem in retriving the Tenant Id';
        }
    } 
}


//Once response is recieved: Perform the following actions
//List<Object> listOfContacts = (List<Object>) data;
//for(Object contact: listOfContacts){
//	Map<String,Object> contacts = (Map<String,Object>) contact;
//	System.debug(contacts.get('Name'));
//}