//This batch class created to sync salesforce records to Xero

public class XeroObjectBatchSync implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{
	List<Id> recordIds = new List<Id>();
    Schema.SObjectType objectName;
    public XeroObjectBatchSync(List<Id> recordIdList){
        this.recordIds = recordIdList;
        this.objectName = !this.recordIds.isEmpty() ? this.recordIds[0].getSObjectType() : null;
    }
    public Database.QueryLocator start(Database.BatchableContext batchContext){
        List<String> fields = new List<String>(this.objectName.getDescribe().fields.getMap().keySet());
        String query;
        if(this.objectName != null) {
            query = 'select ' + String.join(fields, ',')+ ' from '+this.objectName+ ' where Id in :recordIds AND Is_Sync_with_Xero__c != true';
        }
        return DataBase.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<SObject> sObjectRecords){
        System.debug('Obj: '+String.valueOf(objectName)+ ' sObjectRecords: '+sObjectRecords[0]);
        XeroOrchestrator.sendToXero(String.valueOf(objectName), sObjectRecords[0]);
    }
    public void finish(Database.BatchableContext bc){
        
    }
}