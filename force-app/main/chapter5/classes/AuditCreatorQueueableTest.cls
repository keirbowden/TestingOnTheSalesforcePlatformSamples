@isTest
private class AuditCreatorQueueableTest {

    static List<AuditCreatorQueueable.AuditRequest> GetAuditRequests(Integer numRequests) {
        List<Account> accs=new List<Account>();
        for (Integer idx=0; idx<numRequests; idx++) {
            accs.add(new Account(Name='Test Account ' + idx));
        }
        insert accs;

        List<AuditCreatorQueueable.AuditRequest> auditRequests=
                        new List<AuditCreatorQueueable.AuditRequest>();

        for (Integer idx=0; idx<numRequests; idx++) {   
            AuditCreatorQueueable.AuditRequest auditRequest=
                                new AuditCreatorQueueable.AuditRequest();

            auditRequest.action='Created';
            auditRequest.sObjectName='Account';
            auditRequest.recordId=accs[idx].Id;
            auditRequest.user=new User(Id=UserInfo.GetUserId(),
                                       Username=UserInfo.getUserName());

            auditRequests.add(auditRequest);
        }

        return auditRequests;
    }

    @isTest
    static void TestCreateOneAuditEntry() {
        List<AuditCreatorQueueable.AuditRequest> auditRequests=
                            GetAuditRequests(1);

        Test.startTest();
        System.enqueueJob(new AuditCreatorQueueable(auditRequests, 2));
        Test.stopTest();

        List<Audit_Entry__c> auditEntries=[select Id, Details__c 
                                           from Audit_Entry__c];

        Assert.areEqual(1, auditEntries.size(),
                        'A single audit entry should be created');
    }

    @isTest
    static void TestCreateMultipleAuditEntries() {
        Integer entryCount=20;
        List<AuditCreatorQueueable.AuditRequest> auditRequests=
                            GetAuditRequests(entryCount);

        AsyncOptions asyncOptions = new AsyncOptions();
        asyncOptions.maximumQueueableStackDepth = 5;
        Test.startTest();
        System.enqueueJob(new AuditCreatorQueueable(auditRequests, 4), asyncOptions);
        Test.stopTest();

        List<Audit_Entry__c> auditEntries=[select Id, Details__c 
                                           from Audit_Entry__c];

        Assert.areEqual(entryCount, auditEntries.size(),
                        entryCount + ' audit entries should be created');

        Set<Id> expectedRecordIds=new Set<Id>();
        for (AuditCreatorQueueable.AuditRequest auditRequest: auditRequests){
            expectedRecordIds.add(auditRequest.recordId);
        }

        Set<Id> matchedRecordIds=new Set<Id>();
        for (Audit_Entry__c auditEntry: auditEntries) { 
            Boolean found=false;
            for (AuditCreatorQueueable.AuditRequest auditRequest: auditRequests) {
                if (auditEntry.Details__c.contains(auditRequest.recordId)) {
                    matchedRecordIds.add(auditRequest.recordId);
                    found=true;
                    break;
                }
            }

            Assert.isTrue(found, 'Each audit entry should contain one of the test record ids');
        }

        Assert.areEqual(expectedRecordIds.size(), matchedRecordIds.size(),
                        'Not all test records were matched against the audit entries');
    }
}