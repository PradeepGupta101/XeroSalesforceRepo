public with sharing class XeroOrchestrator {
    
    public static String tenantId = '';
    
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
        
    public static void getContacts(){
        if(checkForPermission()){
          String tenantId = XeroCallout.getTenantId('Contacts');
            if(tenantId != '0'){
                Map<String,Object> data = (Map<String,Object>)JSON.deserializeUntyped(XeroCallout.getXeroData('GET','Contacts',tenantId)); 
                if(data.get('status')!= 200){
                  System.debug(data.get('err'));
                }
                else{
                  System.debug(data.get('data'));
                }            
            }
            else{
                System.debug('There was some problem in retriving the Tenant Id');
            }
        }
        else{
          System.debug('User does not have sufficiant access!');
        }
    }
    
    
    public static void getInvoices(){
        if(checkForPermission()){
          String tenantId = XeroCallout.getTenantId('Invoices');
            if(tenantId != '1'){
              Map<String,Object> data = (Map<String,Object>)JSON.deserializeUntyped(XeroCallout.getXeroData('GET','Invoices',tenantId)); 
              if(data.get('status')!= 200){
                System.debug(data.get('err'));
              }
              else{
                System.debug(data.get('data'));
              }    
            }
            else{
                System.debug('There was some problem in retriving the Tenant Id');
            }
        }
        else{
          System.debug('User does not have sufficiant access!');
        }
    }
}


//Once response is recieved: Perform the following actions
//List<Object> listOfContacts = (List<Object>) data;
//for(Object contact: listOfContacts){
//	Map<String,Object> contacts = (Map<String,Object>) contact;
//	System.debug(contacts.get('Name'));
//}