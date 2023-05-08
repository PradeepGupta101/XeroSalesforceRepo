global with sharing class RequestResponseProcessor {

    private static RequestResponseProcessor instance;
    private List<RequestResponseLogEvent__e> logEvents;

    private RequestResponseProcessor(){
       logEvents = new List<RequestResponseLogEvent__e>();
    }
   
    global static RequestResponseProcessor getInstance(){
        if(instance == null){
            instance = new RequestResponseProcessor();
        }  
        return instance;
    }

   //-------------Creation of log records----------
    global void createRequestLog(List<RequestResponseLogEvent__e> logEvents){
        List<RequestResponse_Log__c> logs = new List<RequestResponse_Log__c>();
		for (RequestResponseLogEvent__e le : logEvents) {
            logs.add(new RequestResponse_Log__c(
                    RequestBody__c = le.RequestBody__c,
                	ResponseBody__c = le.ResponseBody__c,
                	UserId__c = le.UserId__c,
                	ContextId__c = le.ContextId__c,
                    Log_Timestamp__c = System.now()
                
            	));
        }
        if(!logs.isEmpty()) insert logs;
	}

    
    //-------------Updating the records-------
   global static void updateResponseLog(List<RequestResponse_Log__c> responseRecord ){
       
       List<RequestResponse_Log__c> updateResponse = new List<RequestResponse_Log__c>(); 
       
       if(responseRecord.size()>0){
           for(RequestResponse_Log__c record : responseRecord){
       				List<RequestResponse_Log__c> lstResponse = [SELECT Name, ResponseBody__c 
                                                   				FROM RequestResponse_Log__c
                                                   				WHERE Name = : record.Name];
       				System.debug(record.Name); 

       				for(RequestResponse_Log__c req : responseRecord){
           				for(RequestResponse_Log__c res : lstResponse){
            					if(res.Name == req.Name){
                					res.ResponseBody__c = req.ResponseBody__c;
                					res.RequestBody__c = req.RequestBody__c;
                					res.Log_Timestamp__c = System.now();
                					updateResponse.add(res);    
            					}
        				} 
        			update updateResponse;   
       				}
    		}
       }
   }
    global void queueEvent(RequestResponseLogEvent__e logEvent){
        this.logEvents.add(logEvent);
    }
    global void forceFlush(){
        if(this.logEvents.size() > 0){
            try{
                Database.SaveResult[] results = EventBus.publish(logEvents);
            }finally{
                this.logEvents.clear();
            }
        }
    }
    
    global void asyncLog(String request, String response, String ctxId){
            RequestResponseLogEvent__e e = new RequestResponseLogEvent__e(RequestBody__c = request,
                														  ResponseBody__c = response,
                														  ContextId__c = ctxId,
                														  Log_Timestamp__c = System.now());
            RequestResponseProcessor.getinstance().queueEvent(e);
            
        } 
}