public class MarkNeglectedLeadsBatch implements Database.Batchable<sObject>, Database.Stateful {
    public static String NEW_STATUS='New';

    public Integer totalProcessed=0;    
   
    public Database.QueryLocator start(Database.BatchableContext context){
        DateTime fiveDaysAgo=System.now().addDays(-5);
        
        Map<String, Object> queryBinds = 
              new Map<String, Object>{'fiveDaysAgo' => fiveDaysAgo,
                                      'newStatus' => NEW_STATUS};

        String query='select Id, Email from Lead ' + 
                     'where CreatedDate<:fiveDaysAgo ' + 
                       'and Status=:newStatus';

        return Database.getQueryLocatorWithBinds(query, queryBinds, AccessLevel.USER_MODE);
    }

    public void execute(Database.BatchableContext context, List<sObject> records) {
        LeadUtils.MarkLeadsAsNeglectedAndUpdate(records);
    
        totalProcessed+=records.size();
    }

    public void finish(Database.BatchableContext context) { 
        System.debug('Total processed = ' + totalProcessed);
    }
}