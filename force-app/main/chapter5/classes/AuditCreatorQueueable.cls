public with sharing class AuditCreatorQueueable implements Queueable {
    private List<AuditRequest> auditRequests;
    private Integer batchSize=10;
    
    public AuditCreatorQueueable(List<AuditRequest> auditRequests) {
        this.auditRequests=auditRequests;
    }

    public AuditCreatorQueueable(List<AuditRequest> auditRequests, Integer batchSize) {
        this.auditRequests=auditRequests;
        this.batchSize=batchSize;
    }

    public void execute(QueueableContext context) {
        Integer recordCount=(batchSize<=auditRequests.size() ? batchSize : auditRequests.size());
        
        List<Id> recordIds=new List<Id>();
        List<String> objectNames=new List<String>();
        List<String> actions=new List<String>();
        List<Id> userIds=new List<Id>();

        Map<Id, User> usersById=new Map<Id, User>();        
        for (Integer idx=0; idx<recordCount; idx++) {
            User us=auditRequests[idx].user;
            userIds.add(us.Id); 
            usersById.put(us.Id, us);
            recordIds.add(auditRequests[idx].recordId);
            actions.add(auditRequests[idx].action); 
            objectNames.add(auditRequests[idx].sObjectName);
        }

        AuditUtils.CreateAuditEntries(recordIds, objectNames, actions, userIds, usersById);

        for (Integer idx=0; idx<recordCount; idx++) {
            auditRequests.remove(0);
        }

        if (auditRequests.size()>0) {
            System.enqueueJob(new AuditCreatorQueueable(auditRequests, batchSize));
        }
    }

    public class AuditRequest {
        public User user;
        public Id recordId;
        public String action;
        public String sObjectName;

        public AuditRequest(){
        }
    }
}