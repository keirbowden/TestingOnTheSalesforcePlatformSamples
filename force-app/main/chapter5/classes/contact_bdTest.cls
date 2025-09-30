@IsTest
private class contact_bdTest {
    @IsTest
    static void TestDeleteSuccess() {
        Contact cont=new Contact(FirstName='Unit',
                                 LastName='Test');
        insert cont;

        Test.startTest();
        Database.DeleteResult deleteResult=Database.delete(cont, false);
        Test.stopTest();

        Assert.areEqual(true, deleteResult.isSuccess(),
                        'Contact should have been successfully deleted');
    }

    @IsTest
    static void TestDeleteFail() {
        Contact cont=new Contact(FirstName='Unit',
                                    LastName='Test');
        insert cont;

        Task task = new Task(Subject='Test task',
                             Status = 'Not Started',
                             Priority = 'Normal',
                             ActivityDate = System.today().addDays(7),
                             WhoId = cont.Id,
                             OwnerId = UserInfo.getUserId());
        insert task;

        Test.startTest();
        Database.DeleteResult deleteResult=Database.delete(cont.Id, false);
        Test.stopTest();

        Assert.areEqual(false, deleteResult.isSuccess(),
                        'Contact with an open task should error when ' + 
                        'delete is attempted.');
    }

    @IsTest
    static void TestDeleteBulk() {
        List<Contact> contacts=new List<Contact>();
        Contact contactFails=new Contact(FirstName='Unit',
                                         LastName='Test');
        for (Integer idx=0; idx<200; idx++) {
            if (100==idx) {
                contacts.add(contactFails);
            }
            else {
                contacts.add(new Contact(FirstName='Unit',
                                         LastName='Test ' + idx));
            }
        }

        insert contacts;

        Task task = new Task(Subject='Test task',
                             Status = 'Not Started',
                             Priority = 'Normal',
                             ActivityDate = System.today().addDays(7),
                             WhoId = contactFails.Id,
                             OwnerId = UserInfo.getUserId());
        insert task;

        Test.startTest();
        List<Database.DeleteResult> deleteResults=Database.delete(contacts, false);
        Test.stopTest();

        for (Integer idx=0; idx<deleteResults.size(); idx++) {
            Database.DeleteResult deleteResult=deleteResults[idx];
            if (deleteResult.isSuccess()) {
                Assert.areNotEqual(deleteResult.getId(), contactFails.Id,
                        'Contact with open tasks should be successfully deleted');
            }
            else {
                Assert.areEqual(deleteResult.getId(), contactFails.Id,
                        'Contact at ' + idx + ' should be successfully deleted');
            }
        }
    }

    @IsTest
    static void TestDeleteBulk2() {
        List<Contact> contacts=new List<Contact>();
        for (Integer idx=0; idx<200; idx++) {
            if ( (100>=idx) && (110<=idx)) {
                contacts.add(new Contact(FirstName='Unit',
                                         LastName='Test Fail ' + idx));
            }
            else {
                contacts.add(new Contact(FirstName='Unit',
                                         LastName='Test ' + idx));
            }
        }

        insert contacts;

        List<Task> tasks=new List<Task>();
        for (Integer idx=0; idx<=10; idx++) {
            Task task = new Task(Subject='Test task',
                             Status = 'Not Started',
                             Priority = 'Normal',
                             ActivityDate = System.today().addDays(7),
                             WhoId = contacts[idx+100].Id,
                             OwnerId = UserInfo.getUserId());
            tasks.add(task);
        }
        insert tasks;

        Test.startTest();
        List<Database.DeleteResult> deleteResults=Database.delete(contacts, false);
        Test.stopTest();

        Integer deleteErrors=0;
        for (Integer idx=0; idx<deleteResults.size(); idx++) {
            Database.DeleteResult deleteResult=deleteResults[idx];
            if (!deleteResult.isSuccess()) {
                deleteErrors++;
            }
        }

        Assert.areEqual(11, deleteErrors, 'Should be 11 failures');
    }
} 