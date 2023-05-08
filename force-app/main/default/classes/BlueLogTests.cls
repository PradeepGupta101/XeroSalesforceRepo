@isTest
private class BlueLogTests {
    @isTest
    static void testEventTrigger(){        
        Test.startTest();
		Blue_Log_Event__e e = new Blue_Log_Event__e(
            	Message__c = 'Test Message',
                LogLevel__c = LoggingLevel.DEBUG.name(),
                ClassMethod__c = 'BlueLogTests' + '.' + 'testEventTrigger',
                ContextId__c = '1234567890',
            	Log_Timestamp__c = System.Now()
            );       
          
        EventBus.publish(e);
        Test.stopTest();
        
        Blue_Log__c bl = [SELECT Id, Name, Message__c, LogLevel__c, ClassMethod__c, ContextId__c, Log_Timestamp__c
                         FROM Blue_Log__c WHERE ContextId__c = '1234567890'];
        
        System.assertEquals(bl.Message__c, 'Test Message');
        System.assertEquals(bl.LogLevel__c, 'DEBUG');
        System.assertEquals(bl.ClassMethod__c, 'BlueLogTests.testEventTrigger');
        System.assertEquals(bl.ContextId__c, '1234567890');
        System.assert(bl.Log_Timestamp__c != null, 'Log Timestamp should not be null');
    }

	@isTest
    static void testLoggingDebug(){
        
        Test.startTest();
            BlueLogProcessor.IBlueLogger ibl = BlueLogProcessor.getLogger(BlueLogTests.class);
            ibl.debug('MockLogMessage', 'testLoggingDebug');
        	BlueLogProcessor.getInstance().forceFlush();
        Test.stopTest();
        
        Blue_Log__c bl = [SELECT Id, Name, Message__c, LogLevel__c, ClassMethod__c, ContextId__c
                          FROM Blue_Log__c LIMIT 1];

        System.assertEquals(bl.Message__c, 'MockLogMessage');
        System.assertEquals(bl.LogLevel__c, 'DEBUG');
        System.assertEquals(bl.ClassMethod__c, 'BlueLogTests.testLoggingDebug');        
    }

    @isTest
    static void testLoggingError(){
        
        Test.startTest();
            BlueLogProcessor.IBlueLogger ibl = BlueLogProcessor.getLogger(BlueLogTests.class);
            ibl.error('MockLogMessage', 'testLoggingError');
        	BlueLogProcessor.getInstance().forceFlush();
        Test.stopTest();
        
        Blue_Log__c bl = [SELECT Id, Name, Message__c, LogLevel__c, ClassMethod__c, ContextId__c
                          FROM Blue_Log__c LIMIT 1];
        System.assertEquals(bl.Message__c, 'MockLogMessage');
        System.assertEquals(bl.LogLevel__c, 'ERROR');
        System.assertEquals(bl.ClassMethod__c, 'BlueLogTests.testLoggingError');        
    }
    
    @isTest
    static void testLotsOfLogs(){
        Test.startTest();
            BlueLogProcessor.IBlueLogger ibl = BlueLogProcessor.getLogger(BlueLogTests.class);
      
            for(integer i=0;i<400;i++){
                ibl.debug('LogMessage ' + i, 'testLotsOfLog');   
            }
            BlueLogProcessor.getInstance().forceFlush();
        Test.stopTest();
        List<Blue_Log__c> bls = [SELECT Id, Name, Message__c, LogLevel__c, ClassMethod__c, ContextId__c
                                 FROM Blue_Log__c];  
        System.assertEquals(bls.size(), 400);                
        
    }
}
