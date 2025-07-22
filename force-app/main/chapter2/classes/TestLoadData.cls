@isTest
private class TestLoadData {
    
 @isTest
    static void TestLoadAccounts()
    {
        Test.loadData(Account.sobjectType, 'testaccounts');
		
        List<Account> accs=[select id, Name, Industry, Website from Account];
        for (Account acc : accs)
        {
            System.debug('TestLoadAccounts: Account = ' + acc);
        }
    }

    @isTest
    static void TestLoadExported()
    {
        Test.loadData(Account.sobjectType, 'exportedaccounts');
        Test.loadData(Contact.sobjectType, 'exportedcontacts');
		
        List<Account> accs=[select id, Name, 
                    (select id, Account.Name, FirstName, LastName from Contacts) 
                                          from Account];
        for (Account acc : accs)
        {
            System.debug('Exported: Account = ' + acc);
            for (Contact cont : acc.Contacts)
            {
                System.debug('Exported: Contact = ' + cont);
            }
        }
    }

    @isTest
    static void TestLoadStringIds()
    {
        Test.loadData(Account.sobjectType, 'stringidaccounts');
        Test.loadData(Contact.sobjectType, 'stringidcontacts');
		
        List<Account> accs=[select id, Name, 
                    (select id, Account.Name, FirstName, LastName from Contacts) 
                                          from Account];
        for (Account acc : accs)
        {
            System.debug('StringIds: Account = ' + acc);
            for (Contact cont : acc.Contacts)
            {
                System.debug('StringIds: Contact = ' + cont);
            }
        }
    }    
}