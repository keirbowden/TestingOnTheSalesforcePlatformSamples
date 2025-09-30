@IsTest
private class AuditUtilsTest {
    @IsTest
    static void TestCreateOneAuditEntryFuture() {
        Account acc=new Account(Name='Test Account 1');
        insert acc;

        List<Id> recordIds=new List<Id>{acc.Id};
        List<String> objectNames=new List<String>{'Account'};
        List<String> actions=new List<String>{'Created'};
        List<Id> userIds=new List<Id>{UserInfo.GetUserId()};

        Test.startTest();
        AuditUtils.CreateAuditEntriesFuture(recordIds, objectNames, actions, userIds);
        Test.stopTest();

        List<Audit_Entry__c> auditEntries=[select Id, Details__c 
                                           from Audit_Entry__c];
        Assert.areEqual(1, auditEntries.size(),
                        'A single audit entry should be created');

        Assert.areNotEqual(-1, auditEntries[0].Details__c.indexOf(UserInfo.getUserName()),
                          'Audit entry detail should contain the current user\'s username');
    }

    @IsTest
    static void TestCreateyAuditEntriesFutureBulk() {
        List<Account> accs=new List<Account>();
        for (Integer idx=0; idx<100; idx++) {
            accs.add(new Account(Name='Test Account ' + idx));
        }
        insert accs;

        List<Contact> conts=new List<Contact>();
        for (Integer idx=0; idx<100; idx++) {
            conts.add(new Contact(FirstName='Unit',
                                  LastName='Test ' + idx));
        }
        insert conts;

        List<Id> recordIds=new List<Id>();
        List<String> objectNames=new List<String>();
        List<String> actions=new List<String>();
        List<Id> userIds=new List<Id>();

        for (Integer idx=0; idx<200; idx++) {
            if (idx<100) {
                recordIds.add(accs[idx].Id);
                objectNames.add('Account');
                actions.add('Created');
            }
            else {
                recordIds.add(conts[idx-100].Id);
                objectNames.add('Contact');
                actions.add('Updated');
            }
            userIds.add(UserInfo.GetUserId());
        }

        Test.startTest();
        AuditUtils.CreateAuditEntriesFuture(recordIds, objectNames, actions, userIds);
        Test.stopTest();

        List<Audit_Entry__c> auditEntries=[select Id, Details__c 
                                           from Audit_Entry__c];
        Assert.areEqual(200, auditEntries.size(),
                        'Should be 200 audit entries created based on the test inputs');
    }

    @IsTest
    static void TestCreateeAuditEntryFutureIsAsync() {
        Account acc=new Account(Name='Test Account 1');
        insert acc;

        List<Id> recordIds=new List<Id>{acc.Id};
        List<String> objectNames=new List<String>{'Account'};
        List<String> actions=new List<String>{'Created'};
        List<Id> userIds=new List<Id>{UserInfo.GetUserId()};

        Test.startTest();
        AuditUtils.CreateAuditEntriesFuture(recordIds, objectNames, actions, userIds);
        List<Audit_Entry__c> auditEntries=[select Id, Details__c 
                                           from Audit_Entry__c];
        Assert.areEqual(0, auditEntries.size(),
                        'No audit entries should be created until Test.stopTest() executes');
        Test.stopTest();

        auditEntries=[select Id, Details__c 
                      from Audit_Entry__c];
        Assert.areEqual(1, auditEntries.size(),
                        'A single audit entry should be created');
    }

    @IsTest
    static void TestCreateOneAuditEntry() {
        List<Account> accs=new List<Account>();
        accs.add(new Account(Name='Test Account 1'));
        insert accs;

        List<Id> recordIds=new List<Id>{accs[0].Id};
        List<String> objectNames=new List<String>{'Account'};
        String action='Created';
        List<String> actions=new List<String>{action};
        List<Id> userIds=new List<Id>{UserInfo.GetUserId()};

        Test.startTest();
        AuditUtils.CreateAuditEntriesFuture(recordIds, objectNames, actions, userIds);
        Test.stopTest();

        List<Audit_Entry__c> auditEntries=[select Id, Details__c 
                                           from Audit_Entry__c];
        Assert.areEqual(1, auditEntries.size(),
                        'A single audit entry should be created');
        Assert.areNotEqual(-1, auditEntries[0].Details__c.indexOf(accs[0].Id),
                      'Audit entry detail should contain the impacted record id');
        Assert.areNotEqual(-1, auditEntries[0].Details__c.indexOf(action),
                      'Audit entry detail should contain the specified action');
    }

    @IsTest
    static void TestCreateManyAuditEntries() {
        List<Account> accs=new List<Account>();
        accs.add(new Account(Name='Test Account 1'));
        accs.add(new Account(Name='Test Account 2'));
        insert accs;

        List<Contact> conts=new List<Contact>();
        conts.add(new Contact(FirstName='Unit',
                              LastName='Test 1'));
        conts.add(new Contact(FirstName='Unit',
                              LastName='Test 2'));
        insert conts;

        List<Id> recordIds=new List<Id>{accs[0].Id, accs[1].Id,
                                        conts[0].Id, conts[1].Id};

        List<String> objectNames=new List<String>{'Account', 'Account', 'Contact', 'Contact'};
        List<String> actions=new List<String>{'Created', 'Updated', 'Inserted', 'Deleted'};
        List<Id> userIds=new List<Id>{UserInfo.GetUserId(), UserInfo.GetUserId(),
                                      UserInfo.GetUserId(), UserInfo.GetUserId()};

        Test.startTest();
        AuditUtils.CreateAuditEntriesFuture(recordIds, objectNames, actions, userIds);
        Test.stopTest();

        List<Audit_Entry__c> auditEntries=[select Id, Details__c 
                                           from Audit_Entry__c];
        Assert.areEqual(4, auditEntries.size(),
                        'Should be 4 audit entries created based on the test inputs');

        Map<Id, String> expectedActionByRecordId = new Map<Id, String>{
            accs[0].Id => actions[0],
            accs[1].Id => actions[1],
            conts[0].Id => actions[2],
            conts[1].Id => actions[3]
        };

        Set<Id> matchedRecordIds = new Set<Id>();

        for (Audit_Entry__c auditEntry : auditEntries) {
            Boolean foundRecordId=false;
            for (Id expectedRecordId : expectedActionByRecordId.keySet()) {
                if (auditEntry.Details__c.contains(expectedRecordId)) {
                    String expectedAction = expectedActionByRecordId.get(expectedRecordId);

                    Assert.areNotEqual(-1, auditEntry.Details__c.indexOf(expectedAction),
                        'Audit entry detail should contain the specified action for record ' + 
                        expectedRecordId);

                    matchedRecordIds.add(expectedRecordId);
                    foundRecordId = true;
                    break;
                }
            }
            if (!foundRecordId) {
                Assert.fail('Audit entry should contain one of the test record ids');
            }
        }

        Assert.areEqual(expectedActionByRecordId.size(), matchedRecordIds.size(),
                'Not all test records were matched against the audit entries');
    }
}