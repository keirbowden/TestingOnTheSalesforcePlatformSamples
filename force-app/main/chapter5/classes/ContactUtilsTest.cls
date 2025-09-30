@isTest
private class ContactUtilsTest {    
    @isTest
    static void TestValidateDeleteOneSuccess() {
        Contact cont=new Contact(Id='003JW00000wjd3rYAA',
                                 FirstName='Unit',
                                 LastName='Test');

        Map<Id, Contact> contactsById=new Map<Id, Contact>{cont.Id=>cont};

        ContactDAOStub cDAOstub=new ContactDAOStub();
        cDAOstub.openTaskCountForContacts=new Map<Id, Integer> {cont.Id=>0};

        ContactUtils cUtil=new ContactUtils();
        cUtil.contactDAO=cDAOStub;

        Test.startTest();
        List<Id> errorIds=cUtil.ValidateDelete(contactsById);
        Test.stopTest();

        Assert.areEqual(0, errorIds.size(),
                        'No error should have been returned for a single contact with no open tasks.');
    }   

    @isTest
    static void TestValidateDeleteFail() {
        Contact cont=new Contact(Id='003JW00000wjd3rYAA',
                                 FirstName='Unit',
                                 LastName='Test');

        Map<Id, Contact> contactsById=new Map<Id, Contact>{cont.Id=>cont};

        ContactDAOStub cDAOstub=new ContactDAOStub();
        cDAOstub.openTaskCountForContacts=new Map<Id, Integer> {cont.Id=>4};

        ContactUtils cUtil=new ContactUtils();
        cUtil.contactDAO=cDAOStub;

        Test.startTest();
        List<Id> errorIds=cUtil.ValidateDelete(contactsById);
        Test.stopTest();

        Assert.areEqual(1, errorIds.size(),
                        'A single contact with open tasks should return an error.');
    }   

    @isTest
    static void TestValidateDeleteBulk() {
        Map<Id, Contact> contactsById=new Map<Id, Contact>();
        Map<Id, Integer> openTaskCountForContacts=new Map<Id, Integer>();

        Integer errorCount=0;

        for (Integer idx=0; idx<200; idx++) {
            String counter=String.valueOf(idx).leftPad(3, '0');
            Id contactId='003JW00' + counter + 'wjd3rYAA';

            Contact cont=new Contact(Id=contactId,
                                     FirstName='Unit',
                                     LastName='Test' + idx);

            contactsById.put(cont.Id, cont);

            Integer taskCount=0;
            if (0==Math.mod(idx, 40)) {
                taskCount=1+idx;
                errorCount++;
            }
            openTaskCountForContacts.put(cont.Id, taskCount);
        }

        ContactDAOStub cDAOstub=new ContactDAOStub();
        cDAOstub.openTaskCountForContacts=openTaskCountForContacts;

        ContactUtils cUtil=new ContactUtils();
        cUtil.contactDAO=cDAOStub;

        Test.startTest();
        List<Id> errorIds=cUtil.ValidateDelete(contactsById);
        Test.stopTest();

        Assert.areEqual(5, errorIds.size(),
                        'Five contacts have open tasks and should return errors.');
    }   

    @isTest
    static void TestValidateDeleteNullContact() {
        Contact cont=new Contact(Id='003JW00000wjd3rYAA',
                                 FirstName='Unit',
                                 LastName='Test');

        Map<Id, Contact> contactsById=new Map<Id, Contact>{cont.Id=>cont, null=>null};

        ContactDAOStub cDAOstub=new ContactDAOStub();
        cDAOstub.openTaskCountForContacts=new Map<Id, Integer> {cont.Id=>1, null=>1};

        ContactUtils cUtil=new ContactUtils();
        cUtil.contactDAO=cDAOStub;

        Test.startTest();
        List<Id> errorIds=cUtil.ValidateDelete(contactsById);
        Test.stopTest();

        Assert.areEqual(2, errorIds.size(),
                        'Null in contactsById should be processed as an Id');
    }   

    @isTest
    static void TestValidateDeleteNullContactMap() {
        Map<Id, Contact> contactsById=null;

        ContactDAOStub cDAOstub=new ContactDAOStub();
        cDAOstub.openTaskCountForContacts=new Map<Id, Integer> {null=>1};

        ContactUtils cUtil=new ContactUtils();
        cUtil.contactDAO=cDAOStub;

        Test.startTest();
        try {
            List<Id> errorIds=cUtil.ValidateDelete(contactsById);
            Assert.fail('Accessing keySet of null map should throw exception');
        }
        catch (Exception exc) {
            // expected - accessing keySet of null map throws exception
        }
        Test.stopTest();
    }   
}