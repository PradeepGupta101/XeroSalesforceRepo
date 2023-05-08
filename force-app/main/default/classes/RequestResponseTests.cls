@isTest
private class RequestResponseTests {
    @testSetup static void setup() {
        List<RequestResponse_Log__c> testRecords = new List<RequestResponse_Log__c>();
        for(Integer i=0;i<2;i++) {
            testRecords.add(new RequestResponse_Log__c(RequestBody__c = 'http REQ-00000'+i));
        }
        insert testRecords;
    	}
    
	@isTest
    static void testEventTrigger(){        
        Test.startTest();
		RequestResponseLogEvent__e e = new RequestResponseLogEvent__e(
            	RequestBody__c = 'request',
                ResponseBody__c = 'response',
                ContextId__c = '1234567890',
            	Log_Timestamp__c = System.Now()
            );     
        system.debug(e);
        EventBus.publish(e);
        RequestResponseProcessor.getInstance().forceFlush();
        Test.stopTest();
        
        RequestResponse_Log__c bl = [SELECT Name, RequestBody__c, ResponseBody__c,ContextId__c, Log_Timestamp__c
                                     FROM RequestResponse_Log__c 
                                     WHERE ContextId__c = '1234567890' LIMIT 1];
        System.debug(bl);
        System.assert(bl.Name != null, 'Name should not be null');
        System.assertEquals(bl.RequestBody__c, 'request');
        System.assertEquals(bl.ResponseBody__c, 'response');
        System.assertEquals(bl.ContextId__c, '1234567890');
        System.assert(bl.Log_Timestamp__c != null, 'Log Timestamp should not be null');
    }
    
    
    @isTest
    static void testupdateResponseLog(){   
        Test.startTest();
        List<RequestResponse_Log__c> reqList = [SELECT Name, RequestBody__c, ResponseBody__c, Log_Timestamp__c 
                                                FROM RequestResponse_Log__c WHERE Name = 'REQ-100008'];
        system.debug(reqList);
        if(reqList.size()>0){
        	reqList[0].ResponseBody__c = 'updating the response body';
            RequestResponseProcessor.updateResponseLog(reqList);
        }
        Test.stopTest();
        
        RequestResponse_Log__c rl = [SELECT Name, ResponseBody__c, RequestBody__c, Log_Timestamp__c
                                     FROM RequestResponse_Log__c 
                                     WHERE Name = 'REQ-100008'];
        
        System.assertEquals(rl.Name, 'REQ-100008');
        System.assertEquals(rl.ResponseBody__c, 'updating the response body');
        System.assert(rl.Log_Timestamp__c != null, 'Log Timestamp should not be null');             
        
    }

		@isTest
    	static void testAsyncLog(){      
        Test.startTest();
            RequestResponseProcessor req = RequestResponseProcessor.getinstance();
            req.asyncLog('MockRequest', 'MockResponse','MockCtxId');
        	RequestResponseProcessor.getInstance().forceFlush();
        Test.stopTest();
        
        RequestResponse_Log__c rl = [SELECT Name, ResponseBody__c, RequestBody__c, ContextId__c,Log_Timestamp__c
                                     FROM RequestResponse_Log__c
                                     WHERE ContextId__c = 'MockCtxId'];
            
        System.assertEquals(rl.RequestBody__c, 'MockRequest');
        System.assertEquals(rl.ResponseBody__c, 'MockResponse');
        System.assertEquals(rl.ContextId__c, 'MockCtxId');
		System.assert(rl.Log_Timestamp__c != null, 'Log Timestamp should not be null');
    }    
}