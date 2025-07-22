@IsTest
public with sharing class AllContactsDisplayTest {
    @isTest
    static void TestPagination() {
        List<Contact> contacts=new List<Contact>();
        contacts.add(new Contact(FirstName='Unit', 
                            LastName='Test', 
                            Email='unit.test@ut.brightgen.com'));

        contacts.add(new Contact(FirstName='Unit', 
                            LastName='Test2', 
                            Email='unit.test2@ut.brightgen.com'));
        insert contacts;
            
        // inject the test page size
        AllContactsDisplay.PAGE_SIZE=1;
            
        AllContactsDisplay allContactsDisplay=new AllContactsDisplay();
            
        Assert.areEqual(true, allContactsDisplay.showNext(),
                        'Expected showNext() to indicate button is required');
    }
}