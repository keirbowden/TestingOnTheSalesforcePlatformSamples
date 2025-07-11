@IsTest
private class AuthorServiceTest {

    //
    // publishBooks test case
    // 
    @IsTest
    static void TestPublishBooksZeroRecordBookList() {
        Author__c author=BookStoreTestDataFactory.BuildAuthor('Keir Bowden', null);

        Test.startTest();
        new AuthorService().publishBooks(author, new List<Book__c>());
        Integer dmlStatements = Limits.getDmlStatements(); 
        Test.stopTest();

        Assert.areEqual(0, dmlStatements, 
                'Publishing an empty list of books should not change any records');
    }

    @IsTest 
    static void TestPublishBook() {
        Publisher__c publisher=BookStoreTestDataFactory.CreatePublisher('Leanpub');
        Author__c author=BookStoreTestDataFactory.CreateAuthor('Keir Bowden', publisher.Id);
        Book__c book=BookStoreTestDataFactory.CreateBook('Testing on the Salesforce Platform',
                                        author.Id, 'Technology', 190);

        Test.startTest();
        new AuthorService().publishBooks(author, new List<Book__c> {book});
        Test.stopTest();

        List<Book__c> booksFromDB=[select id, Published_Date__c 
                                   from Book__c];

        Assert.areEqual(1, booksFromDB.size(), 'Expected to find one book record');
        Book__c bookFromDB=booksFromDB[0];

        Assert.isNotNull(bookFromDB.Published_Date__c, 'Published date should be populated');

        Assert.areEqual(System.today(), bookFromDB.Published_Date__c, 'Published date should be today');
    }

    @IsTest 
    static void TestPublishBooksNullBook() {
        Publisher__c publisher=BookStoreTestDataFactory.CreatePublisher('Leanpub');
        Author__c author=BookStoreTestDataFactory.CreateAuthor('Keir Bowden', publisher.Id);

        List<Book__c> books=new List<Book__c>();

        books.add(BookStoreTestDataFactory.BuildBook('Testing on the Salesforce Platform',
                                        author.Id, 'Technology', 190));

        books.add(BookStoreTestDataFactory.BuildBook('The Wizard and the Admin',
                                        author.Id, 'Fantasy', 75));

        insert books;

        books.add(1, null);

        Test.startTest();
        new AuthorService().publishBooks(author, books);
        Test.stopTest();

        List<Book__c> booksFromDB=[select id, Published_Date__c 
                                   from Book__c
                                   where Published_Date__c=:System.today()];

        Assert.areEqual(2, booksFromDB.size(), 'Null book record should be ignored resulting in 2 records');
    }

    @IsTest 
    static void TestPublishBooks200Records() {
        Publisher__c publisher=BookStoreTestDataFactory.CreatePublisher('Leanpub');
        Author__c author=BookStoreTestDataFactory.CreateAuthor('Keir Bowden', publisher.Id);

        List<Book__c> books=new List<Book__c>();

        Integer bookCount=200;
        for (Integer idx=0; idx<bookCount; idx++) {
            books.add(BookStoreTestDataFactory.BuildBook('Test Book ' + idx,
                                        author.Id, 'Technology', 190+idx));
        }

        insert books;

        Test.startTest();
        new AuthorService().publishBooks(author, books);
        Test.stopTest();

        List<Book__c> booksFromDB=[select id, Published_Date__c 
                                   from Book__c
                                   where Published_Date__c=:System.today()];

        Assert.areEqual(bookCount, booksFromDB.size(), 'Expected to find ' + bookCount + ' books published today');
    }


    @IsTest
    static void TestPublishBooksNullAuthorException() {
        Book__c book=BookStoreTestDataFactory.BuildBook('Testing on the Salesforce Platform',
                                        null, 'Technology', 190);

        Test.startTest();
        try {
            new AuthorService().publishBooks(null, new List<Book__c>{book});
            Assert.fail('Null author should cause publish books to throw an exception');
        }
        catch (BookStoreException bse) {
            // expected result
        }
        Test.stopTest();
    }

    @IsTest
    static void TestPublishBooksNullBooksException() {
        Author__c author=BookStoreTestDataFactory.BuildAuthor('Keir Bowden', null);
        Test.startTest();
        try {
            new AuthorService().publishBooks(author, null);
            Assert.fail('Null book list should cause publish books to throw an exception');
        }
        catch (BookStoreException bse) {
            // expected result
        }
        Test.stopTest();
    }

    @IsTest 
    static void TestPublishBooksScope() {
        Publisher__c publisher=BookStoreTestDataFactory.CreatePublisher('Leanpub');
        Author__c author=BookStoreTestDataFactory.CreateAuthor('Keir Bowden', publisher.Id);

        List<Book__c> books=new List<Book__c>();

        books.add(BookStoreTestDataFactory.BuildBook('Testing on the Salesforce Platform',
                                        author.Id, 'Technology', 190));

        books.add(BookStoreTestDataFactory.BuildBook('The Wizard and the Admin',
                                        author.Id, 'Fantasy', 75));

        insert books;

        Test.startTest();
        new AuthorService().publishBooks(author, new List<Book__c> {books[0]});
        Test.stopTest();

        List<Book__c> booksFromDB=[select id, Published_Date__c 
                                   from Book__c
                                   where Published_Date__c=null];

        Assert.areEqual(1, booksFromDB.size(), 'Expected to find one umpublished book records');
    }

    //
    // scheduleReading test cases
    //
    @IsTest
    static void TestScheduleReadingDefaultVirtualReading() {
        Author__c author=BookStoreTestDataFactory.CreateAuthor('Keir Bowden', null);
        Book__c book=BookStoreTestDataFactory.CreateBook('Testing on the Salesforce Platform',
                                        author.Id, 'Technology', 190);

        DateTime startDT=System.now().addHours(72);
        DateTime endDT=System.now().addHours(73);

        Test.startTest();
        new AuthorService().scheduleReading(book, startDT, endDT, null);
        Test.stopTest();

        List<Author_Reading__c> readingsFromDB=[select Id, Book__c, Starts__c,
                                                       Ends__c, Virtual__c
                                                from Author_Reading__c];

        Assert.areEqual(1, readingsFromDB.size(), 
                        'Reading should be succesfully scheduled');

        Assert.areEqual(startDT, readingsFromDB[0].Starts__c, 
                        'Expected reading to start at ' + startDT + 
                        ' but was actually ' + readingsFromDB[0].Starts__c);

        Assert.areEqual(endDT, readingsFromDB[0].Ends__c, 
                        'Expected reading to end at ' + startDT + 
                        ' but was actually ' + readingsFromDB[0].Ends__c);

        Assert.areEqual(false, readingsFromDB[0].Virtual__c, 
                        'Expected null virtual reading parameter to default to false');

        List<Task> tasksFromDB=[select Status, Priority, ActivityDate, WhatId
                                from Task];
        
        Assert.areEqual(1, tasksFromDB.size(), 
                        'Expected to find a single task to send invites, but found ' + 
                        tasksFromDB.size());

        Assert.areEqual(readingsFromDB[0].Id, tasksFromDB[0].WhatId,
                        'Expected send invites task whatId to be reading ' + 
                        readingsFromDB[0].Id +
                        ' but was actually ' + tasksFromDB[0].WhatId);

        Date dueDate=endDT.date().addDays(-1);
        Assert.areEqual(dueDate, tasksFromDB[0].ActivityDate,
                        'Expected send invites task due date of ' + dueDate + 
                        ' but was actually ' + tasksFromDB[0].ActivityDate);
    }

    @IsTest
    static void TestScheduleReadingVirtual() {
        Author__c author=BookStoreTestDataFactory.CreateAuthor('Keir Bowden', null);
        Book__c book=BookStoreTestDataFactory.CreateBook('Testing on the Salesforce Platform',
                                        author.Id, 'Technology', 190);

        DateTime startDT=System.now().addHours(24);
        DateTime endDT=System.now().addHours(25);

        Test.startTest();
        new AuthorService().scheduleReading(book, startDT, endDT, true);
        Test.stopTest();

        List<Author_Reading__c> readingsFromDB=[select Id, Book__c, Starts__c,
                                                       Ends__c, Virtual__c
                                                from Author_Reading__c];

        Assert.areEqual(1, readingsFromDB.size(), 
                        'Reading should be succesfully scheduled');

        Assert.areEqual(true, readingsFromDB[0].Virtual__c, 
                        'Expected virtual reading to be true');

        List<Event> eventsFromDB=[select StartDateTime, endDateTime, location, 
                                        WhatId
                                  from Event];

        Assert.areEqual(1, eventsFromDB.size(), 
                        'Expected to find a single virtual event but found ' + 
                        eventsFromDB.size());

        Assert.areEqual(startDT, eventsFromDB[0].StartDateTime,
                        'Expected virtual reading to start at ' + startDT +
                        ' but is actuall scheduled for ' +
                        eventsFromDB[0].StartDateTime);

        Assert.areEqual(endDT, eventsFromDB[0].EndDateTime,
                        'Expected virtual reading to end at ' + endDT +
                        ' but is actually scheduled for ' +
                        eventsFromDB[0].EndDateTime);

        Assert.areEqual('Online', eventsFromDB[0].Location,
                        'Expected virtual reading location to be online, but was ' +
                        eventsFromDB[0].Location);

        Assert.areEqual(readingsFromDB[0].Id, eventsFromDB[0].WhatId,
                        'Expected virtual reading whatId to be ' + 
                        readingsFromDB[0].Id + 
                        ', but was ' +
                        eventsFromDB[0].WhatId);

    }

    @IsTest
    static void TestScheduleReadingNotVirtual() {
        Author__c author=BookStoreTestDataFactory.CreateAuthor('Keir Bowden', null);
        Book__c book=BookStoreTestDataFactory.CreateBook('Testing on the Salesforce Platform',
                                        author.Id, 'Technology', 190);

        DateTime startDT=System.now().addHours(24);
        DateTime endDT=System.now().addHours(25);

        Test.startTest();
        new AuthorService().scheduleReading(book, startDT, endDT, false);
        Test.stopTest();

        List<Author_Reading__c> readingsFromDB=[select Id, Book__c, Starts__c,
                                                       Ends__c, Virtual__c
                                                from Author_Reading__c];

        Assert.areEqual(1, readingsFromDB.size(), 
                        'Reading should be succesfully scheduled');

        Assert.areEqual(false, readingsFromDB[0].Virtual__c, 
                        'Expected virtual reading to be false');

        List<Event> eventsFromDB=[select StartDateTime, endDateTime, location, 
                                        WhatId
                                  from Event];

        Assert.areEqual(0, eventsFromDB.size(), 
                        'Expected to find a no virtual events but found ' + 
                        eventsFromDB.size());
    }

    @IsTest
    static void TestScheduleReadingNullBook() {
        DateTime startDT=System.now().addHours(24);
        DateTime endDT=System.now().addHours(25);

        Test.startTest();
        try {
            new AuthorService().scheduleReading(null, startDT, endDT, true);
            Assert.fail('Scheduling reading with null book should throw exception');
        }
        catch (BookStoreException bse) {
            // expected
        }
        Test.stopTest();
    }

    @IsTest
    static void TestScheduleReadingNullStart() {
        Book__c book=BookStoreTestDataFactory.BuildBook('Testing on the Salesforce Platform',
                                        null, 'Technology', 190);
        DateTime endDT=System.now().addHours(25);

        Test.startTest();
        try {
            new AuthorService().scheduleReading(book, null, endDT, true);
            Assert.fail('Scheduling reading with null start should throw exception');
        }
        catch (BookStoreException bse) {
            // expected
        }
        Test.stopTest();
    }

    @IsTest
    static void TestScheduleReadingNullEnd() {
        Book__c book=BookStoreTestDataFactory.BuildBook('Testing on the Salesforce Platform',
                                        null, 'Technology', 190);
        DateTime startDT=System.now().addHours(24);

        Test.startTest();
        try {
            new AuthorService().scheduleReading(book, startDT, null, true);
            Assert.fail('Scheduling reading with null end should throw exception');
        }
        catch (BookStoreException bse) {
            // expected
        }
        Test.stopTest();
    }
}