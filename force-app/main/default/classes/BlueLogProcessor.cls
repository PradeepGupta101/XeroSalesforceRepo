global without sharing class BlueLogProcessor {
	
    private static BlueLogProcessor instance;
    
    private List<Blue_Log_Event__e> logEvents;
    
    private BlueLogProcessor(){
        logEvents = new List<Blue_Log_Event__e>();
    }
   
    global static BlueLogProcessor getInstance(){
        if(instance == null){
            instance = new BlueLogProcessor();
        }  
        return instance;
    }
    
    global static BlueLogProcessor.BlueLogger getLogger(Type cls){
        return new BlueLogProcessor.BlueLogger(cls);
    }
    
    global void saveLogs(List<Blue_Log_Event__e> logEvents){
        List<Blue_Log__c> logs = new List<Blue_Log__c>();
		for (Blue_Log_Event__e le : logEvents) {
            logs.add(new Blue_Log__c(
                	LogLevel__c = le.LogLevel__c,
            		ClassMethod__c = le.ClassMethod__c,
                	Message__c = le.Message__c,
                	User__c = le.UserId__c,
                	ContextId__c = le.ContextId__c,
                	Log_Timestamp__c = le.Log_Timestamp__c
            	));
        }
        if(!logs.isEmpty()) insert logs;
	}
    global void queueEvent(Blue_Log_Event__e logEvent){
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
    
    
    //-----------Interface
    global interface IBlueLogger {
       void debug(String message, String classMethod);
       void debug(String message, String classMethod, String ctxId);
       void error(Exception ex, String classMethod);
       void error(Exception ex, String classMethod, String ctxId);
    }
    
    global class BlueLogger implements IBlueLogger{
    	
        private String loggingClass;
        public BlueLogger(Type cls){
			this.loggingClass = cls.getName();
        } 
	        
        public void debug(String message, String classMethod){
            debug(message, classMethod, null);	
        }
        public void debug(String message, String classMethod, String ctxId){
            asyncLog(message, classMethod, LoggingLevel.DEBUG, ctxId);
        }/*
        public void error(String message, String classMethod){
            error(message, classMethod, null);            
        }
        public void error(String message, String classMethod, String ctxId){
            asyncLog(message, classMethod, LoggingLevel.ERROR, ctxId);            
        }
*/
          
        //All exceptions to be logged as errors 
        public void error(Exception ex, String classMethod){
            error(ex, classMethod, null);
        }
        public void error(Exception ex, String classMethod, String ctxId){
            asyncLog(ex, classMethod, ctxId);            
        }

        private void asyncLog(Exception ex, String classMethod, String ctxId){
            String exText =  'Exception: [' + ex.getTypeName() + ']:'
								+ '[' + ex.getLineNumber() + ']'
                				+ ':' + ex.getMessage()
                				+ '\n'
								+ 'Trace: ' + ex.getStackTraceString();
            
            asyncLog(exText, classMethod, LoggingLevel.error, ctxId, true);
        }
        
        private void asyncLog(String message, String classMethod, System.LoggingLevel logLevel, String ctxId){
            asyncLog(message, classMethod, logLevel, ctxId, false);
        }
	
        private void asyncLog(String message, String classMethod, System.LoggingLevel logLevel, String ctxId, Boolean immediate){
            Blue_Log_Event__e e = new Blue_Log_Event__e(
            	Message__c = message,
                LogLevel__c = logLevel.name(),
                ClassMethod__c = loggingClass + '.' + classMethod,
                ContextId__c = ctxId,
                Log_Timestamp__c = System.now()
            );
            String userId = UserInfo.getUserId();
        	if (userId != null) {
            	e.UserId__c = userId;
        	} 
            
            BlueLogProcessor.getInstance().queueEvent(e);
            if(immediate){
                BlueLogProcessor.getInstance().forceFlush();
            }
        }
    }
}