//Orchestrator class 
public with sharing class XeroOrchestrator {
    //Declaring tenantId as global class variable so that it will be accessible within any block.
    public static String tenantId;
    public List<Id> recIds = new List<Id>();
    //This constructor called from visualforce page button
    public XeroOrchestrator(ApexPages.StandardSetController controller){
        for(sObject obj: controller.getSelected()){
            recIds.add(obj.Id);
        }
    }
    //This method called from visualforce page to execute batch class.
    public void executeBatch(){
        Id jobId = Database.executeBatch(new XeroObjectBatchSync(recIds),1);
    }

    //Method to construct request and return the request for further processing.
    public static HttpRequest constructRequest(String method, String resource,String tenantId, String requestBody){
        
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
      BlueLogProcessor.getInstance().forceFlush();
      return request;
    }
    
    //Check wheteher login user has permission to send request to xero
    public static Boolean checkForPermission(String requiredPermission){  
      //Getting logged in user details 
      User userRecord = [SELECT Id, username,Name FROM User 
                		    WHERE Id = :UserInfo.getUserId() with security_enforced];

      //Variable assignment - Permission Set Names
      String permission = requiredPermission == 'Read' ? 'Xero_Integration_Read' : 'Xero_Integration_Edit';

      //Getting permission set details in a set.
      List<PermissionSet> permissionSets = [SELECT Id FROM PermissionSet WHERE Name = :permission with security_enforced];

      Set<String> permissions = new Set<String>{};
      permissions.add(permissionSets[0].Id);
      
		  try{
        //If query returns something, which means user has permission set assigned. Return true in that case.
			  List<PermissionSetAssignment> permissionSetIds = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId =: userRecord.Id AND PermissionSetId IN :permissions with security_enforced];
        return permissionSetIds.size() != 0 ? true : false;
		  }
		  catch(QueryException ex){
        //else the flow moves into the exception and returns false.
    	  return false;
		  }    
    }
    public static String retrieveFromXero(String resource){
        return retrieveFromXero(resource,'');
    }
    
    //Method to retrieve records from Xero app
    public static String retrieveFromXero(String resource,String filter){
        
      BlueLogProcessor.IBlueLogger ibl = BlueLogProcessor.getLogger(XeroOrchestrator.class);
        
      //Check if user has permission
      if(checkForPermission('Read')){
        //Fetch Tenant Id
          if(tenantId == null){
              tenantId = XeroCallout.getTenantId(resource);
          }
          //Check if tenant id is returned, return and print an error instead.
          if(tenantId != '0'){
              String resourceTobeSent = filter.length() > 0 ? resource+'/'+filter : resource;
              //Construct the request with parameters.
              HttpRequest request = constructRequest('GET', resourceTobeSent, tenantId, null);
              ibl.debug('Request sent to fetch data for: '+resource+ 'retrieveFromXero Request: ',String.valueOf(request));
              
              //Send request to callout method, deserialize the response and assign it to a variable called data.
              Map<String,Object> data = (Map<String,Object>)JSON.deserializeUntyped(XeroCallout.getXeroData(request,resource)); 
              
              //Check weather the response is successful or not, print and return either details.
              if(data.get('status')!= 200){
                ibl.debug('Error Occured:'+data.get('err'), 'retrieveFromXero');
                BlueLogProcessor.getInstance().forceFlush();
                return (String)data.get('err');
              }
              else{
                ibl.debug('Received Data Successfully:'+data.get('status'), 'retrieveFromXero');
                BlueLogProcessor.getInstance().forceFlush();
                return 'Data Present';
              }
          }
          else{
            ibl.debug('There was some problem in retriving the Tenant Id', 'retrieveFromXero');
            BlueLogProcessor.getInstance().forceFlush();
            return 'There was some problem in retriving the Tenant Id';
          }
      }
      else{
        ibl.debug('User does not have sufficiant access!', 'connectToXero');
        BlueLogProcessor.getInstance().forceFlush();
        return 'User does not have sufficiant access!';
      }
    }
    
    // Method to Send Data from Salesforce to Xero
    public static String sendToXero(String resource, sObject recordToSend){
        Object wrapperData;
        BlueLogProcessor.IBlueLogger ibl = BlueLogProcessor.getLogger(XeroOrchestrator.class);
        
        //Check if user has permission
        if(checkForPermission('Edit')){
      		//Fetch Tenant Id
      		if(tenantId == null){
              tenantId = XeroCallout.getTenantId(resource);
          }
        	if(resource == 'Contact'){
        			ContactWrapper createContact = new ContactWrapper((Contact)recordToSend);
              String contactToJson = JSON.serialize(createContact);
              wrapperData = JSON.deserialize(contactToJson, ContactWrapper.class);
        	}
        	else if(resource == 'Invoice'){
            	InvoiceWrapper createInvoice = new InvoiceWrapper((Invoice)recordToSend);
              String invoiceToJson = JSON.serialize(createInvoice);
              wrapperData = JSON.deserialize(invoiceToJson, InvoiceWrapper.class);
        	}

      		if(tenantId != '0'){
          		//Construct the request with parameters.
          		System.debug('Res: '+resource+' tenantId: '+tenantId+' data: '+JSON.serialize(wrapperData));
          		HttpRequest request = constructRequest('POST', resource, tenantId, JSON.serialize(wrapperData));
          		//Send request to callout method, deserialize the response and assign it to a variable called data.
          		Map<String,Object> data = (Map<String,Object>)JSON.deserializeUntyped(XeroCallout.getXeroData(request,resource)); 
 
          		//Check weather the response is successful or not, print and return either details.
          		if(data.get('status')!= 200){
                ibl.debug('Error Occured:'+data.get('err'), 'retrieveFromXero');
                BlueLogProcessor.getInstance().forceFlush();
                return (String)data.get('err');
              }
          		else{
                ibl.debug('Record Synced Successfully:'+data.get('status'), 'retrieveFromXero');
                BlueLogProcessor.getInstance().forceFlush();
                updateRecord(recordToSend.Id);  	
            		return 'Contact created in Xero';
          		} 
      		}
      		else{
            ibl.debug('There was some problem in retriving the Tenant Id', 'retrieveFromXero');
            BlueLogProcessor.getInstance().forceFlush();
            return 'There was some problem in retriving the Tenant Id';
          }
        }
        else{
          ibl.debug('User does not have sufficiant access!', 'connectToXero');
          BlueLogProcessor.getInstance().forceFlush();
          return 'User does not have sufficiant access!';
        }
    }

    //This method update Is_Sync_with_Xero__c field when record successfully sync with Xero
    public static void updateRecord(Id recId){
      if(String.valueOf(recId.getSObjectType()) == 'Contact'){
        Contact contactToUpdate = new Contact();
        contactToUpdate.Id = recId;
        contactToUpdate.Is_Sync_with_Xero__c = true;
        update contactToUpdate;
      }
      else if(String.valueOf(recId.getSObjectType()) == 'Invoice'){
        Invoice invoiceToUpdate = new Invoice();
        invoiceToUpdate.id = recId;
        invoiceToUpdate.Is_Sync_with_Xero__c = true;
        update invoiceToUpdate;
      }
    } 
}