public with sharing class AuditUtils {
    @future
    public static void CreateAuditEntriesFuture(List<Id> recordIds, List<String> objectNames, 
                                          List<String> actions, List<Id> userIds) {

        if ( (null!=userIds.size()) && (!userIds.isEmpty()) ) {
            Map<Id, User> usersById=new Map<Id, User>([select Username 
                                                       from User
                                                       where Id in :userIds]);

            CreateAuditEntries(recordIds, objectNames, actions, userIds, usersById);
        }
    }

    public static void CreateAuditEntries(List<Id> recordIds, List<String> objectNames, 
                                          List<String> actions, List<Id> userIds,
                                          Map<Id, User> usersById) {
        List<Audit_Entry__c> auditEntries=new List<Audit_Entry__c>();

        for (Integer idx=0; idx<recordIds.size(); idx++) {
            String detail=System.now().format('yyyy-MM-dd HH:mm') + ' : User ' + 
                          usersById.get(userIds[idx]).Username + ' with id ' + 
                          userIds[idx] + ' ' + actions[idx] + ' ' + 
                          objectNames[idx] + ' record with id ' + recordIds[idx];

            Audit_Entry__c auditEntry=new Audit_Entry__c(Details__c=detail);
            auditEntries.add(auditEntry);
        }

        insert auditEntries;
    }
}